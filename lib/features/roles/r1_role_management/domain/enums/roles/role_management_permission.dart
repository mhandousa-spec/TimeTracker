/// Module: roles / r1_role_management / domain / enums / roles
///
///*************************** FILE INFO ****************************///
/// File Name: role_management_permission.dart
/// Purpose: Declares `RoleManagement`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum RoleManagement implements ModulePermissionsSectionsPermission {
  createRoleManagement,
  editRole,
  deleteRole,
  changeRoleStatus,
  exportRoleData;

  @override
  bool get isChild {
    switch (this) {
      default:
        return false;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case createRoleManagement:
        return 'Create_Role_Management';
      case editRole:
        return 'Edit_Role';
      case deleteRole:
        return 'Delete_Role';
      case changeRoleStatus:
        return 'Change_Role_Status';
      case exportRoleData:
        return 'Export_Role_Data';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createRoleManagement:
        return 'Create Role Management';
      case editRole:
        return 'Edit Role';
      case deleteRole:
        return 'Delete Role';
      case changeRoleStatus:
        return 'Change Role Status';
      case exportRoleData:
        return 'Export Role Data';
    }
  }
}