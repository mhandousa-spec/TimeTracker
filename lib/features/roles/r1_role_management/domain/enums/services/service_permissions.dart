/// Module: roles / r1_role_management / domain / enums / services
///
///*************************** FILE INFO ****************************///
/// File Name: service_permissions.dart
/// Purpose: Declares `ServicePermissions`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum ServicePermissions implements ModulePermissionsSectionsPermission {
  createService,
  bulkUpload,
  masterBulkUpload,
  exportService,
  editService,
  deleteService,
  changeServiceStatus,
  viewRequesters,
  exportRequestedServices;

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
      case createService:
        return 'Create_Service';
      case bulkUpload:
        return 'Bulk_Upload';
      case masterBulkUpload:
        return 'Master_Bulk_Upload';
      case exportService:
        return 'Export_Service';
      case editService:
        return 'Edit_Service';
      case deleteService:
        return 'Delete_Service';
      case changeServiceStatus:
        return 'Change_Service_Status';
      case viewRequesters:
        return 'View_Requesters';
      case exportRequestedServices:
        return 'Export_Requested_Services';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createService:
        return 'Create Service';
      case bulkUpload:
        return 'Bulk Upload';
      case masterBulkUpload:
        return 'Master Bulk Upload';
      case exportService:
        return 'Export Service';
      case editService:
        return 'Edit Service';
      case deleteService:
        return 'Delete Service';
      case changeServiceStatus:
        return 'Change Service Status';
      case viewRequesters:
        return 'View Requesters';
      case exportRequestedServices:
        return 'Export Requested Services';
    }
  }
}