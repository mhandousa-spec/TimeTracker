/// Module: services_management_module
///
///*************************** FILE INFO ****************************///
/// File Name: employee_services_permissions.dart
/// Purpose: Answers "may THIS employee (not the logged-in user) act as a
///          service provider / approver?" from the Services switches on the
///          employee's ROLE.
/// Author: Knowticed Plus team
/// Created at: 25/9/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Services bug report p1–p2: the Service Provider picker and the Add
/// Approvals picker listed every employee, even those whose role has the
/// "Requested Services" / "Approval Permissions" switches OFF. Those people
/// can never open the screen that lets them act on the request, so choosing
/// them silently dead-ends the service.
///
/// [ServicesModuleAccess] only answers for the logged-in user (it reads the
/// controller's cached role). Here we load the `services` permission document
/// of every role the listed employees hold, once per picker load, and apply
/// the same rule [ServicesModuleAccess.can] does: the section master switch
/// AND the leaf switch must both be on.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/approval_permission_work.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/employee_services.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

abstract class EmployeeServicesPermissions {
  static const String _servicesModule = 'services';
  static const String _superAdmin = 'super admin';

  /// normalised role name -> (permission database name -> value).
  /// A role that exists but has no Services module maps to an empty map.
  static final Map<String, Map<String, bool>> _byRole = {};

  /// False until at least one role could be resolved. While false every
  /// check answers `true`, so a roles list that has not loaded yet never
  /// empties the pickers.
  static bool _ready = false;

  static String _norm(String? s) => (s ?? '').toLowerCase().trim();

  /// Loads the Services permissions for every role held by [employees].
  /// Always re-reads, so switches changed in the role editor apply the next
  /// time a picker opens.
  static Future<void> preload(Iterable<EmployeeEntityPro> employees) async {
    final List<RoleHistoryModel> roles = roleCubit.roles;
    if (roles.isEmpty) {
      _ready = false;
      return;
    }

    final roleNames = employees
        .map((e) => _norm(e.role))
        .where((r) => r.isNotEmpty && r != _superAdmin)
        .toSet();

    final repo = RoleRepository();
    final fresh = <String, Map<String, bool>>{};

    await Future.wait(roleNames.map((roleName) async {
      final RoleHistoryModel? role = roles
          .where((r) => _norm(r.currentRoleName) == roleName)
          .firstOrNull;
      if (role == null) {
        fresh[roleName] = const {};
        return;
      }
      final String? moduleKey = role.currentSelectedModules
          .where((m) => _norm(m) == _servicesModule)
          .firstOrNull;
      if (moduleKey == null) {
        fresh[roleName] = const {};
        return;
      }
      final Either<FirebaseFailure, Map<String, dynamic>?> result =
          await repo.getRolePermissions(roleId: role.roleId, module: moduleKey);
      result.fold(
        (l) => debugPrint(
            'EmployeeServicesPermissions: load failed for $roleName: ${l.errMessage}'),
        (data) {
          final map = <String, bool>{};
          data?.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              map[key] = value.last == true;
            } else if (value is bool) {
              map[key] = value;
            }
          });
          fresh[roleName] = map;
        },
      );
    }));

    _byRole
      ..clear()
      ..addAll(fresh);
    _ready = true;
  }

  static bool _has(EmployeeEntityPro e, String section, String leaf) {
    if (!_ready) return true;
    final role = _norm(e.role);
    if (role == _superAdmin) return true;
    final perms = _byRole[role];
    // Role never loaded (e.g. its permission read failed) -> don't hide.
    if (perms == null) return true;
    return (perms[section] ?? false) && (perms[leaf] ?? false);
  }

  /// Role has "Requested Services" section + "Status Requested" on — the
  /// switches that let an employee work the requests sent to them.
  static bool canBeProvider(EmployeeEntityPro e) => _has(
        e,
        ServicePermissionsSections.requestedServices.getDataBaseName,
        RequestServicesModule.statusRequested.getDataBaseName,
      );

  /// Role has "Approval Permissions" section + "Approve And Reject" on.
  static bool canApprove(EmployeeEntityPro e) => _has(
        e,
        ServicePermissionsSections.approvalPermissions.getDataBaseName,
        ApprovalPermissionsServices.approveAndReject.getDataBaseName,
      );

  /// Whether [preload] resolved real role data (so the checks are meaningful).
  static bool get isReady => _ready;
}
