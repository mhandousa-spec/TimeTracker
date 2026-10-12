/// Module: roles / r1_role_management / domain / enums / roles
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_permission.dart
/// Purpose: Declares `UserManagement`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum UserManagement implements ModulePermissionsSectionsPermission {
  giveAccess,
  editAccess,
  removeAccess,
  importUsersData,
  exportUsersData,
  usersRequests,
  approvedAndRejectedRequest,
  approvedOnly;

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
      case giveAccess:
        return 'Give_Access';
      case editAccess:
        return 'Edit_Access';
      case removeAccess:
        return 'Remove_Access';
      case importUsersData:
        return 'Import_Users_Data';
      case exportUsersData:
        return 'Export_Users_Data';
      case usersRequests:
        return 'Users_Requests';
      case approvedAndRejectedRequest:
        return 'Approved_And_Rejected_Request';
      case approvedOnly:
        return 'Approved_Only';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case giveAccess:
        return 'Give Access';
      case editAccess:
        return 'Edit Access';
      case removeAccess:
        return 'Remove Access';
      case importUsersData:
        return 'Import Users Data';
      case exportUsersData:
        return 'Export Users Data';
      case usersRequests:
        return 'Users Requests';
      case approvedAndRejectedRequest:
        return 'Approved And Rejected Request';
      case approvedOnly:
        return 'Approved Only';
    }
  }
}