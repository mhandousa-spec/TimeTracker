/// Module: roles / r5_system_logs / data
///
/// ************************* FILE INFO ************************* ///
/// File Name: role_log_service.dart
/// Purpose: Centralized system log helper for the Role Management module.
///          Call RoleLogService.log('action') from any page or button
///          in the Roles module to record an activity in system logs.
/// Pattern: Matches QiyasLogService in qiyas_log_service.dart

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

class RoleLogService {
  // ─── Page views ────────────────────────────────────────────
  static const String pageRoleManagementHome   = 'view role management home';
  static const String pageRoleDetails          = 'view role details';
  static const String pageAddNewRole           = 'view add new role';
  static const String pageEditRole             = 'view edit role';
  static const String pageUserManagementHome   = 'view user management home';
  static const String pageEmployeeDetails      = 'view employee details';
  static const String pageRoleUserDetails      = 'view role user details';
  static const String pageRequestApproval      = 'view request approval';
  static const String pageEditUserRoles        = 'view edit user roles dialog';

  // ─── Role Management actions ────────────────────────────────
  static const String actionCreateRole         = 'create role';
  static const String actionUpdateRole         = 'update role';
  static const String actionDeleteRole         = 'delete role';
  static const String actionExportRole         = 'export role';

  // ─── User Management actions ────────────────────────────────
  static const String actionGrantAccess        = 'grant user access';
  static const String actionUpdateAccess       = 'update user access';
  static const String actionRevokeAccess       = 'revoke user access';
  static const String actionActivateAccount    = 'activate account';
  static const String actionDeactivateAccount  = 'deactivate account';
  static const String actionScheduleActivation = 'schedule account activation';
  static const String actionScheduleDeactivation = 'schedule account deactivation';
  static const String actionCancelSchedule     = 'cancel scheduled access change';
  static const String actionUnlockAccount      = 'unlock account';
  static const String actionApproveRequest     = 'approve user access request';
  static const String actionRejectRequest      = 'reject user access request';
  static const String actionAddUserAccess      = 'add new user access';
  static const String actionEditUserAccess     = 'edit user access';
  static const String actionImportUsers        = 'import users';
  static const String actionExportUsers        = 'export users';

  /// Log an action for the Roles module.
  ///
  /// The failure is swallowed on purpose — logging must never break a UI flow —
  /// but it is recorded rather than vanishing into an empty `catch (_) {}`
  /// (§19 anti-pattern: empty catch).
  static void log(String action) {
    try {
      AppControllers.systemLogs
          .systemLogsAction(action, module: Modules.roles);
    } catch (e, stackTrace) {
      debugPrint('RoleLogService.log("$action") failed: $e\n$stackTrace');
    }
  }
}
