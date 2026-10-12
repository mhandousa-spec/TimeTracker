/// Module: roles / r1_role_management / domain / enums / knowledge
///
///*************************** FILE INFO ****************************///
/// File Name: approval_permissions.dart
/// Purpose: Declares `ApprovalPermissions`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

enum ApprovalPermissions implements ModulePermissionsSectionsPermission {
  approvedAndRejected,
  approvedOnly;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case approvedAndRejected:
        return 'Approved And Rejected';
      case approvedOnly:
        return 'Approved Only';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case approvedAndRejected:
        return 'Approved And Rejected';
      case approvedOnly:
        return 'Approved Only';
    }
  }
}
