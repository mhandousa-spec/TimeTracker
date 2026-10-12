/// Module: roles / r1_role_management / domain / enums / grc
///
///*************************** FILE INFO ****************************///
/// File Name: grc_dashboards_permissions_enum.dart
/// Purpose: Declares `GrcDashboardsPermissions` — the "Dashboards" section of the GRC
///          permission tree.
/// Author: Knowticed Plus team
/// Created: 13/9/2026
///
/// [getDataBaseName] IS THE CONTRACT WITH THE ADMIN DASHBOARD — see
/// grc_module_permissions_enum.dart for the full note. Every string below has
/// a twin key in `_getDefaultPermissionsForModule('grc')` over in
/// knowticed_admin_dashboard.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

enum GrcDashboardsPermissions implements ModulePermissionsSectionsPermission {
  mainModuleDashboard,
  cancelService;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case mainModuleDashboard:
        return 'Main_Module_Dashboard';
      case cancelService:
        return 'Cancel_Service';
    }
  }

  @override
  String get getUiName {
    // English labels off the design; no ARB keys exist for these yet. See the
    // note in grc_module_permissions_enum.dart.
    switch (this) {
      case mainModuleDashboard:
        return 'Main Module Dashboard';
      case cancelService:
        return 'Cancel Service';
    }
  }
}
