/// Module: roles / r1_role_management / domain / enums / knowledge
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_permissions_enum.dart
/// Purpose: Declares `SubmissionsPermissions`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum SubmissionsPermissions implements ModulePermissionsSectionsPermission {
  /// ADDED 22/9/2026 — CREATING is not EDITING.
  ///
  /// There was no permission for "may publish a NEW document without a
  /// supervisor", so `_getKnowledgeStatus` in creating_knowledge_hub.actions
  /// read [editDocumentWithoutApproval] for both cases. A role given the right
  /// to re-publish its own edits therefore also had every new document it
  /// created go straight to `approved` — the supervisor's queue showed it
  /// already approved and was never notified.
  ///
  /// This switch governs CREATION only. [editDocumentWithoutApproval] keeps
  /// governing edits, exactly as its name says.
  createWithoutNeedApproval,
  editDocumentWithApproval,
  editDocumentWithoutApproval,
  removeDocuments,
  exportStatisticsTable;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case createWithoutNeedApproval:
        return 'Create_Without_Need_Approval';
      case editDocumentWithApproval:
        return 'Edit_Document_With_Approval';
      case editDocumentWithoutApproval:
        return 'Edit_Document_Without_Approval';
      case removeDocuments:
        return 'Remove_Documents';
      case exportStatisticsTable:
        return 'Export_Statistics_Table';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createWithoutNeedApproval:
        return S.current.createWithoutNeedApproval;
      case editDocumentWithApproval:
        return S.current.editDocumentWithApproval;
      case editDocumentWithoutApproval:
        return S.current.editDocumentWithoutApproval;
      case removeDocuments:
        return S.current.removeDocuments;
      case exportStatisticsTable:
        return S.current.exportStatisticsTable;
    }
  }
}