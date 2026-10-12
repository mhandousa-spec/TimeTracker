/// Module: roles / r1_role_management / domain / enums / grc
///
///*************************** FILE INFO ****************************///
/// File Name: grc_policy_permissions_enum.dart
/// Purpose: Declares `GrcPolicyPermissions` — the "Policy Permissions" section of the GRC
///          permission tree.
/// Author: Knowticed Plus team
/// Created: 13/9/2026
///
/// [getDataBaseName] IS THE CONTRACT WITH THE ADMIN DASHBOARD — see
/// grc_module_permissions_enum.dart for the full note. Every string below has
/// a twin key in `_getDefaultPermissionsForModule('grc')` over in
/// knowticed_admin_dashboard.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

enum GrcPolicyPermissions implements ModulePermissionsSectionsPermission {
  createSinglePolicy,
  createBulkUploadPolicy,
  draftPolicy,
  editPolicy,
  changeStatusOfPolicy,
  deletePolicy,
  policyWeightIssue,
  editPolicyWeightIssue,
  policyWeightHistory,
  policyScore;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case createSinglePolicy:
        return 'Create_Single_Policy';
      case createBulkUploadPolicy:
        return 'Create_Bulk_Upload_Policy';
      case draftPolicy:
        return 'Draft_Policy';
      case editPolicy:
        return 'Edit_Policy';
      case changeStatusOfPolicy:
        return 'Change_Status_Of_Policy';
      case deletePolicy:
        return 'Delete_Policy';
      case policyWeightIssue:
        return 'Policy_Weight_Issue';
      case editPolicyWeightIssue:
        return 'Edit_Policy_Weight_Issue';
      case policyWeightHistory:
        return 'Policy_Weight_History';
      case policyScore:
        return 'Policy_Score';
    }
  }

  @override
  String get getUiName {
    // English labels off the design; no ARB keys exist for these yet. See the
    // note in grc_module_permissions_enum.dart.
    switch (this) {
      case createSinglePolicy:
        return 'Create Single Policy';
      case createBulkUploadPolicy:
        return 'Create Bulk Upload Policy';
      case draftPolicy:
        return 'Draft Policy';
      case editPolicy:
        return 'Edit Policy';
      case changeStatusOfPolicy:
        return 'Change Status Of Policy';
      case deletePolicy:
        return 'Delete Policy';
      case policyWeightIssue:
        return 'Policy Weight Issue';
      case editPolicyWeightIssue:
        return 'Edit Policy Weight Issue';
      case policyWeightHistory:
        return 'Policy Weight History';
      case policyScore:
        return 'Policy Score';
    }
  }
}
