/// Module: roles / r1_role_management / domain / enums / knowledge
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hubssections_enum.dart
/// Purpose: Declares `KnowledgeHubPermissionsSections`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/submissions_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'approval_permissions.dart';
import 'knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum KnowledgeHubPermissionsSections implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  knowledgeHubPermissions,
  submissions,
  approval,
  dashboard,
  allowsRemovingDocumentsOwnedByAnyone;

  @override
  String get getName {
    switch (this) {
      case KnowledgeHubPermissionsSections.knowledgeHubPermissions:
        return S.current.knowledgeHubPermissions;
      case KnowledgeHubPermissionsSections.submissions:
        return S.current.submissions;
      case KnowledgeHubPermissionsSections.approval:
        return S.current.approval;
      case KnowledgeHubPermissionsSections.dashboard:
        return S.current.dashboard;
      case KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone:
        return S.current.allowsRemovingDocumentsOwnedByAnyone;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case KnowledgeHubPermissionsSections.knowledgeHubPermissions:
        return 'Knowledge_Hub_Permissions';
      case KnowledgeHubPermissionsSections.submissions:
        return 'Submissions';
      case KnowledgeHubPermissionsSections.approval:
        return 'Approval';
      case KnowledgeHubPermissionsSections.dashboard:
        return 'Dashboard';
      case KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone:
        return 'Allows_Removing_Documents_Owned_By_Anyone';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case KnowledgeHubPermissionsSections.knowledgeHubPermissions:
        return S.current.knowledgeHubPermissions;
      case KnowledgeHubPermissionsSections.submissions:
        return S.current.submissions;
      case KnowledgeHubPermissionsSections.approval:
        return S.current.approval;
      case KnowledgeHubPermissionsSections.dashboard:
        return S.current.dashboard;
      case KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone:
        return S.current.allowsRemovingDocumentsOwnedByAnyone;
    }
  }

  @override
  bool get isChild {
    return false;
  }

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case KnowledgeHubPermissionsSections.knowledgeHubPermissions:
        return KnowledgeHubPermissions.values;
      case KnowledgeHubPermissionsSections.submissions:
        return SubmissionsPermissions.values;
      case KnowledgeHubPermissionsSections.approval:
        return ApprovalPermissions.values;
      default:
        return [];
    }
  }

  static List<Enum> get firstColumnValues {
    return [
      KnowledgeHubPermissionsSections.knowledgeHubPermissions,
      KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone,
    ];
  }

  static List<Enum> get lastColumnValues {
    return [
      KnowledgeHubPermissionsSections.submissions,
      KnowledgeHubPermissionsSections.approval,
      KnowledgeHubPermissionsSections.dashboard,
    ];
  }
}