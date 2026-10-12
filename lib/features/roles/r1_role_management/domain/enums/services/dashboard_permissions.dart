/// Module: roles / r1_role_management / domain / enums / services
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_permissions.dart
/// Purpose: Declares `DashboardPermissions`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum DashboardPermissions implements ModulePermissionsSectionsPermission {
  adminDashboard,
  departmentDashboard;

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
      case adminDashboard:
        return 'Admin_Dashboard';
      case departmentDashboard:
        return 'Department_Dashboard';
      default:
        return '';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case adminDashboard:
        return 'Admin Dashboard';
      case departmentDashboard:
        return 'Department Dashboard';
      default:
        return '';
    }
  }
}