/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: role_approver_directory.dart
/// Purpose: Declares `RoleApproverDirectory` — the HR approvers of the
///          company, from the roles' Time Tracker switches and the employee
///          directory.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// A role grants the HR step when it carries the Time Tracker module
/// (`time_tracker` or a legacy spelling, `ModuleNameAliases`) and its
/// `time_tracker_module_permissions/{roleId}` has `Approval_Permissions` +
/// `Approve_And_Reject` on; `Approvals_All_Departments` widens the scope to
/// every department (FINAL SPEC §1). An employee holds the role when their
/// `Role` equals the role's NAME or id (both spellings exist in tenant
/// data — same matching as `UserRequestsApproversRepository`). A switch is a
/// bool or a history list whose last entry is current. The answer is cached
/// for five minutes (each lookup is one read per role). Unlike the Settings
/// fan-out there is NO Master-Admin fallback: telling someone who cannot act
/// is noise; the request still waits in the Approvals tab.
/// [waitingApprovers] adds the "{count}" of the Pending Approvals
/// notification (`ApprovalInbox.waitingCount` over the company's requests)
/// and never throws.
/// Updated: 9/10/2026 - code review: HR approvers = "All Departments"
/// holders ONLY (FINAL SPEC; never the person who decided the manager step
/// of the same round); [fetchApprovers] / [knownApproverEmails] (finding
/// 7); a user who may not read the company's requests (finding 9) counts
/// only the request at hand.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_sections_enum.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

class RoleApproverDirectory implements ApproverDirectory {
  RoleApproverDirectory({
    required TimeTrackerRoleRemoteDataSource roles,
    required EmployeeDirectoryBaseRepository directory,
    required RequestBaseRepository requests,
    DateTime Function() clock = DateTime.now,
    bool Function()? readsCompanyRequests,
  })  : _roles = roles,
        _directory = directory,
        _requests = requests,
        _clock = clock,
        _readsCompany = readsCompanyRequests ?? _always;

  final TimeTrackerRoleRemoteDataSource _roles;
  final EmployeeDirectoryBaseRepository _directory;
  final RequestBaseRepository _requests;
  final DateTime Function() _clock;
  final bool Function() _readsCompany;

  static bool _always() => true;

  static const Duration cacheFor = Duration(minutes: 5);
  List<TimeTrackerApprover>? _cache;
  DateTime? _cachedAt;

  @override
  Set<String>? get knownApproverEmails {
    final List<TimeTrackerApprover>? cached = _cache;
    return cached == null ? null : <String>{for (final TimeTrackerApprover a in cached) a.email};
  }

  @override
  Future<List<TimeTrackerApprover>> fetchHrApprovers() async => List<TimeTrackerApprover>.unmodifiable(
        (await fetchApprovers()).where((TimeTrackerApprover a) => a.allDepartments),
      );

  @override
  Future<List<TimeTrackerApprover>> fetchApprovers() async {
    final DateTime now = _clock();
    final List<TimeTrackerApprover>? cached = _cache;
    final DateTime? at = _cachedAt;
    if (cached != null && at != null && now.difference(at) < cacheFor) return cached;
    try {
      // Role key (lower-cased name AND id) → "All Departments".
      final Map<String, bool> granting = <String, bool>{};
      for (final TimeTrackerRoleRecord role in await _roles.fetchRoles()) {
        final bool licensed = role.modules.any(
          (String m) => ModuleNameAliases.canonical(m) == TimeTrackerFirestorePaths.moduleKey,
        );
        if (!licensed) continue;
        final Map<String, dynamic> switches = await _roles.fetchTimeTrackerSwitches(role.id);
        if (!isOn(switches[TimeTrackerPermissionsSections.approvals.storageKey]) ||
            !isOn(switches[TimeTrackerPermissions.approveAndReject.storageKey])) {
          continue;
        }
        final bool all = isOn(switches[TimeTrackerPermissions.approvalsAllDepartments.storageKey]);
        for (final String key in <String>[role.id, role.name]) {
          final String k = key.trim().toLowerCase();
          if (k.isNotEmpty) granting[k] = (granting[k] ?? false) || all;
        }
      }
      final List<TimeTrackerApprover> approvers = <TimeTrackerApprover>[
        if (granting.isNotEmpty)
          for (final TimeTrackerEmployee e in await _directory.fetchEmployees(isArabic: false))
            if (granting.containsKey(e.role.trim().toLowerCase()))
              TimeTrackerApprover(
                email: e.email.trim().toLowerCase(),
                departmentId: e.departmentId,
                allDepartments: granting[e.role.trim().toLowerCase()]!,
              ),
      ];
      _cache = List<TimeTrackerApprover>.unmodifiable(approvers);
      _cachedAt = now;
      return _cache!;
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('Could not load the approvers: $error');
    }
  }

  @override
  Future<bool> mayApprove(String email) async {
    final String who = email.trim().toLowerCase();
    if (who.isEmpty) return false;
    try {
      return (await fetchApprovers()).any((TimeTrackerApprover a) => a.email == who);
    } catch (_) {
      // Unknown → keep the manager (an HR approver can act on a blocked step).
      return true;
    }
  }

  @override
  Future<bool> isSoleOtherHrApprover({required String email, required String requesterEmail}) async {
    final String who = email.trim().toLowerCase();
    final String requester = requesterEmail.trim().toLowerCase();
    try {
      final List<TimeTrackerApprover> hr = await fetchHrApprovers();
      if (!hr.any((TimeTrackerApprover a) => a.email == who)) return false;
      return !hr.any((TimeTrackerApprover a) => a.email != who && a.email != requester);
    } catch (_) {
      // Unknown → keep the HR step (never auto-final on a failed read).
      return false;
    }
  }

  @override
  Future<Map<String, int>> waitingApprovers(TimeTrackerRequest request) async {
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(request);
    if (step == null) return const <String, int>{};
    try {
      // Finding 9 (9/10/2026): an employee's device does not read the
      // company's requests — it counts the request at hand only.
      final List<TimeTrackerRequest> stored =
          _readsCompany() ? await _requests.watchRequests().first : const <TimeTrackerRequest>[];
      // The request as just saved replaces its stored copy.
      final List<TimeTrackerRequest> all = <TimeTrackerRequest>[
        for (final TimeTrackerRequest r in stored)
          if (r.id != request.id) r,
        request,
      ];
      if (step.step == ApprovalStepKind.manager) {
        final String manager = step.approverEmail.trim().toLowerCase();
        if (manager.isEmpty || RequestCycleRules.isRequester(request, manager)) {
          return const <String, int>{};
        }
        return <String, int>{manager: ApprovalInbox.waitingCount(all, email: manager)};
      }
      return <String, int>{
        for (final TimeTrackerApprover a in await fetchHrApprovers())
          if (ApprovalInbox.waitsFor(request, email: a.email, isHrApprover: true, hrAllDepartments: true))
            a.email: ApprovalInbox.waitingCount(
              all,
              email: a.email,
              isHrApprover: true,
              hrAllDepartments: true,
            ),
      };
    } catch (_) {
      // A missing notification must never fail the decision that caused it.
      return const <String, int>{};
    }
  }

  /// Function Name: [isOn]
  ///
  /// Purpose: A stored switch value read as on / off (bool, 'true', or a
  /// history list whose last entry is current).
  ///
  /// Return type: [bool]
  static bool isOn(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is List && value.isNotEmpty) return isOn(value.last);
    return false;
  }
}
