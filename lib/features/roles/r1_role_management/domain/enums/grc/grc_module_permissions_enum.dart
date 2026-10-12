/// Module: roles / r1_role_management / domain / enums / grc
///
///*************************** FILE INFO ****************************///
/// File Name: grc_module_permissions_enum.dart
/// Purpose: Declares `GrcModulePermissions` — the "Module Permissions"
///          section of the GRC permission tree.
/// Author: Knowticed Plus team
/// Created: 13/9/2026
///
/// [getDataBaseName] IS THE CONTRACT WITH THE ADMIN DASHBOARD. Each string
/// here must match a key in `_getDefaultPermissionsForModule('grc')` in
/// knowticed_admin_dashboard (clients/presentation/controller/
/// dashboard_clients_controller.dart) character for character — that map is
/// what writes Demo_Permissions, and this enum is what reads it back. A
/// mismatch does not throw; the permission just reads as absent and the
/// feature silently disappears.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

enum GrcModulePermissions implements ModulePermissionsSectionsPermission {
  createModule,
  editModule,
  changeStatusOfModule,
  deleteModule,
  restoreModule,
  previousModuleOwnerHistory,
  showComplianceScore;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case createModule:
        return 'Create_Module';
      case editModule:
        return 'Edit_Module';
      case changeStatusOfModule:
        return 'Change_Status_Of_Module';
      case deleteModule:
        return 'Delete_Module';
      case restoreModule:
        return 'Restore_Module';
      case previousModuleOwnerHistory:
        return 'Previous_Module_Owner_History';
      case showComplianceScore:
        return 'Show_Compliance_Score';
    }
  }

  @override
  String get getUiName {
    // English labels straight off the design. They are NOT routed through
    // S.current yet: the ARB has no key for any of these, and inventing
    // getters here would not compile. Add the ARB entries, then swap this
    // switch to S.current.* exactly like KnowledgeHubPermissions does.
    switch (this) {
      case createModule:
        return 'Create Module';
      case editModule:
        return 'Edit Module';
      case changeStatusOfModule:
        return 'Change Status Of Module';
      case deleteModule:
        return 'Delete Module';
      case restoreModule:
        return 'Restore Module';
      case previousModuleOwnerHistory:
        return 'Previous Module Owner History';
      case showComplianceScore:
        return 'Show Compliance Score';
    }
  }
}
