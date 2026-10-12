/// Module: roles / r1_role_management / domain / enums / grc
///
///*************************** FILE INFO ****************************///
/// File Name: grc_control_permissions_enum.dart
/// Purpose: Declares `GrcControlPermissions` — the "Control Permissions" section of the GRC
///          permission tree.
/// Author: Knowticed Plus team
/// Created: 13/9/2026
///
/// [getDataBaseName] IS THE CONTRACT WITH THE ADMIN DASHBOARD — see
/// grc_module_permissions_enum.dart for the full note. Every string below has
/// a twin key in `_getDefaultPermissionsForModule('grc')` over in
/// knowticed_admin_dashboard.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

enum GrcControlPermissions implements ModulePermissionsSectionsPermission {
  createSingleControl,
  createBulkUploadControl,
  draftControl,
  editControl,
  changeStatusOfControl,
  deleteControl,
  controlWeightIssue,
  editControlWeightIssue,
  previousControlOwners;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case createSingleControl:
        return 'Create_Single_Control';
      case createBulkUploadControl:
        return 'Create_Bulk_Upload_Control';
      case draftControl:
        return 'Draft_Control';
      case editControl:
        return 'Edit_Control';
      case changeStatusOfControl:
        return 'Change_Status_Of_Control';
      case deleteControl:
        return 'Delete_Control';
      case controlWeightIssue:
        return 'Control_Weight_Issue';
      case editControlWeightIssue:
        return 'Edit_Control_Weight_Issue';
      case previousControlOwners:
        return 'Previous_Control_Owners';
    }
  }

  @override
  String get getUiName {
    // English labels off the design; no ARB keys exist for these yet. See the
    // note in grc_module_permissions_enum.dart.
    switch (this) {
      case createSingleControl:
        return 'Create Single Control';
      case createBulkUploadControl:
        return 'Create Bulk Upload Control';
      case draftControl:
        return 'Draft Control';
      case editControl:
        return 'Edit Control';
      case changeStatusOfControl:
        return 'Change Status Of Control';
      case deleteControl:
        return 'Delete Control';
      case controlWeightIssue:
        return 'Control Weight Issue';
      case editControlWeightIssue:
        return 'Edit Control Weight Issue';
      case previousControlOwners:
        return 'Previous Control Owners';
    }
  }
}
