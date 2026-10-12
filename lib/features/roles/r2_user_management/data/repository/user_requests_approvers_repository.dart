/// Module: roles / r2_user_management / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: user_requests_approvers_repository.dart
/// Purpose: Resolve WHO is allowed to review employee change requests, so a
///          submitted request can notify all of them.
/// Author: Knowticed Plus team
/// Created at: 24/8/2026
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// `MainCoreEmployeeController.isHasPermission` answers only for the employee
/// who is signed in — it reads `currentEmployeeRole` and the private
/// `_modulePermissionsCache`. Nothing in the app could answer the opposite
/// question: *which* employees hold a permission. So a settings change request
/// had no audience to notify, and `SettingsNotificationService
/// .changeRequestSubmitted` sat with zero call sites.
///
/// The only fan-out that existed —
/// `UserManagementNotificationService._masterAdminEmails` — matches on the role
/// NAME `master admin`, which is not the same question and misses every custom
/// role that was granted request review.
///
/// ─── HOW THE ANSWER IS BUILT ─────────────────────────────────────────
/// Same three facts the Requests button in `user_management_home.dart` checks,
/// asked of every role instead of one:
///
///   1. the role's `Selected_Modules` contains the Roles module;
///   2. its document in `roles_module_permissions` (was `roles_permissions`
///      until 9/10/2026) has `Users_Requests` enabled;
///   3. the employee's current `Role` is one of those roles.
///
/// A permission value may be stored as a bare bool or as a history list whose
/// last entry is the current value — [_isGranted] reads both, exactly as
/// `MainCoreEmployeeController._loadModulePermissions` does when it fills its
/// cache.
///
/// ─── FALLBACK ────────────────────────────────────────────────────────
/// An empty answer means nobody would be told a request is waiting, which is
/// worse than telling the wrong person. When no role grants the permission, or
/// no employee holds such a role, this falls back to the Master Admins.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/user_management_permission.dart';
// ADDED 9/10/2026 — the requester is left off the reviewer list.
import 'package:knowticed_plus/features/settings/se6_requests/domain/rules/self_approval_rule.dart';

class UserRequestsApproversRepository {
  UserRequestsApproversRepository({
    RoleRepository? roleRepository,
    FirebaseFirestore? firestore,
  })  : _roleRepository = roleRepository ?? RoleRepository(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final RoleRepository _roleRepository;
  final FirebaseFirestore _firestore;

  /// The module the User Management section lives under. Matches
  /// `RoleCubit.moduleEnumToString(Modules.roles)` and the `case 'roles'` in
  /// `RoleRepository._getPermissionCollectionName`.
  static const String rolesModule = 'roles';

  static const String _employeesInfo = 'Employees_Info';
  static const String _employeeRoleKey = 'Role';
  static const String _employeeEmailKey = 'Email';
  static const String _masterAdminRoleName = 'master admin';

  /// Function Name: [approverEmails]
  ///
  /// Purpose: Every employee who may review change requests.
  ///
  /// [requesterEmail] (ADDED 9/10/2026, owner decision): who raised the
  /// request. They are LEFT OUT — a requester can no longer approve their own
  /// request (`SelfApprovalRule`), so "a request is waiting for you" would be
  /// a notification they cannot act on. Compared trimmed + lower-cased. When
  /// the requester was the only reviewer, the Master Admin fallback is used
  /// (minus the requester too); empty means nobody else can decide it.
  ///
  /// Returns: [Future<List<String>>] de-duplicated emails. Never throws — a
  ///          failed read yields the Master Admin fallback, and a failed
  ///          fallback yields an empty list, because a missing notification
  ///          must not fail the submission that triggered it.
  Future<List<String>> approverEmails({String requesterEmail = ''}) async {
    // 9/10/2026 — every return path drops the requester.
    Future<List<String>> fallback() async => SelfApprovalRule.withoutRequester(
        await masterAdminEmails(), requesterEmail);

    try {
      final Set<String> roleKeys = await _rolesGrantingUsersRequests();
      if (roleKeys.isEmpty) {
        // Worth saying out loud: this is the difference between "nobody has
        // the permission" and "the permission lookup failed", and from the UI
        // the two look identical — no notification either way.
        if (kDebugMode) {
          debugPrint(
            '[approvers] no role grants Users_Requests on the "$rolesModule" '
            'module — falling back to Master Admins.',
          );
        }
        return fallback();
      }

      final List<String> emails = SelfApprovalRule.withoutRequester(
          await _emailsForRoles(roleKeys), requesterEmail);
      if (emails.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[approvers] roles granting Users_Requests: ${roleKeys.join(', ')} '
            '— but no employee other than the requester currently holds one. '
            'Falling back to Master Admins.',
          );
        }
        return fallback();
      }

      if (kDebugMode) {
        debugPrint('[approvers] resolved ${emails.length}: ${emails.join(', ')}');
      }
      return emails;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[approvers] lookup failed: $e\n$stackTrace');
      }
      return fallback();
    }
  }

  /// Function Name: [_rolesGrantingUsersRequests]
  ///
  /// Purpose: The lower-cased names and ids of every non-deleted role that
  ///          carries the Roles module AND `Users_Requests`.
  ///
  /// Both the name and the id go into the set: an employee document stores its
  /// role as a NAME (`Role` history list, which is what
  /// `MainCoreEmployeeController` matches against `currentRoleName`), while a
  /// user-access document stores a role ID. Holding both spellings means the
  /// match below works whichever one a tenant's data uses.
  Future<Set<String>> _rolesGrantingUsersRequests() async {
    final dynamic rolesResult = await _roleRepository.getUnDeletedRoles();

    final List<RoleHistoryModel> roles = rolesResult.fold(
      (_) => <RoleHistoryModel>[],
      (dynamic value) =>
          value is List ? value.whereType<RoleHistoryModel>().toList() : <RoleHistoryModel>[],
    );

    final Set<String> granted = <String>{};

    for (final RoleHistoryModel role in roles) {
      final bool hasRolesModule = role.currentSelectedModules.any(
        (String m) => ModuleNameAliases.canonical(m) == rolesModule,
      );
      if (!hasRolesModule) continue;

      final dynamic permissionsResult = await _roleRepository.getRolePermissions(
        roleId: role.roleId,
        module: rolesModule,
      );

      final Map<String, dynamic>? permissions = permissionsResult.fold(
        (_) => null,
        (dynamic value) => value is Map<String, dynamic> ? value : null,
      );
      if (permissions == null) continue;

      if (!_isGranted(permissions[UserManagement.usersRequests.getDataBaseName])) {
        continue;
      }

      granted.add(role.roleId.toLowerCase().trim());
      final String name = role.currentRoleName.toLowerCase().trim();
      if (name.isNotEmpty) granted.add(name);
    }

    return granted;
  }

  /// Function Name: [_emailsForRoles]
  ///
  /// Purpose: The current email of every employee whose current role is in
  ///          [roleKeys].
  ///
  /// `Role` and `Email` are history lists in `Employees_Info`; the current
  /// value of each is the last entry, the same reading
  /// `UserManagementNotificationService._masterAdminEmails` performs.
  Future<List<String>> _emailsForRoles(Set<String> roleKeys) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(getBaseUrl(_employeesInfo)).get();

    final Set<String> emails = <String>{};

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();

      final String? role = _currentOf(data[_employeeRoleKey]);
      if (role == null) continue;
      if (!roleKeys.contains(role.toLowerCase().trim())) continue;

      final String? email = _currentOf(data[_employeeEmailKey]);
      if (email == null || email.isEmpty) continue;

      emails.add(email);
    }

    return emails.toList();
  }

  /// Function Name: [masterAdminEmails]
  ///
  /// Purpose: The fallback audience — every Master Admin.
  ///
  /// Deliberately public: it is the documented behaviour when no role grants
  /// the permission, and a caller may want it directly.
  Future<List<String>> masterAdminEmails() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(getBaseUrl(_employeesInfo)).get();

      final Set<String> emails = <String>{};

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();

        final String? role = _currentOf(data[_employeeRoleKey]);
        if (role == null) continue;
        if (role.toLowerCase().trim() != _masterAdminRoleName) continue;

        final String? email = _currentOf(data[_employeeEmailKey]);
        if (email == null || email.isEmpty) continue;

        emails.add(email);
      }

      return emails.toList();
    } catch (_) {
      return <String>[];
    }
  }

  /// The current value of a history list, or the value itself when the field
  /// was written as a plain string.
  static String? _currentOf(dynamic value) {
    if (value is List) {
      if (value.isEmpty) return null;
      return value.last?.toString();
    }
    if (value is String) return value;
    return null;
  }

  /// Whether a stored permission value reads as enabled.
  ///
  /// Mirrors `MainCoreEmployeeController._loadModulePermissions`: a permission
  /// is written as a history list whose last entry is current, but older
  /// documents hold a bare bool.
  static bool _isGranted(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is List && value.isNotEmpty) {
      final dynamic last = value.last;
      return last == true || last.toString().toLowerCase() == 'true';
    }
    return false;
  }
}
