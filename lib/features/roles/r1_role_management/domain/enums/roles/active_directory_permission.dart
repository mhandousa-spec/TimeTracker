/// Module: roles / r1_role_management / domain / enums / roles
///
///*************************** FILE INFO ****************************///
/// File Name: active_directory_permission.dart
/// Purpose: Declares `ActiveDirectory`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum ActiveDirectory implements ModulePermissionsSectionsPermission {
  uploadDocument,
  restoreData,
  exportData,
  editUploadedDocument,
  removeEmployee;

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
      case uploadDocument:
        return 'Upload_Document';
      case restoreData:
        return 'Restore_Data';
      case exportData:
        return 'Export_Data';
      case editUploadedDocument:
        return 'Edit_Uploaded_Document';
      case removeEmployee:
        return 'Remove_Employee';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case uploadDocument:
        return 'Upload Document';  // ✅ With translation
      case restoreData:
        return 'Restore Data';  // ✅ With translation
      case exportData:
        return 'Export Data';  // ✅ With translation
      case editUploadedDocument:
        return 'Edit Uploaded Document';  // ✅ With translation
      case removeEmployee:
        return 'Remove Employee';  // ✅ With translation
    }
  }

}