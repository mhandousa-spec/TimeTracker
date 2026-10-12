/// Module: roles / r1_role_management / domain / enums / services
///
///*************************** FILE INFO ****************************///
/// File Name: employee_services.dart
/// Purpose: Declares `RequestServicesModule`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum RequestServicesModule implements ModulePermissionsSectionsPermission {
  statusRequested;

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
      case statusRequested:
        return 'Status_Requested';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case statusRequested:
        return 'Status Requested';
    }
  }
}