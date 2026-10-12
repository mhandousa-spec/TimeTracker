/// Module: roles / r1_role_management / domain / enums / todo
///
///*************************** FILE INFO ****************************///
/// File Name: todo_permissions_enum.dart
/// Purpose: Declares `TodoPermissions` — the five switches under the To Do
///          Permissions block on the "Adding New Role" screen.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Agreed with the owner 7/10/2026: View · Create · Edit · Delete · Restore.
/// To-dos are personal, so there is no "assign" switch.
///
/// ⚠️ [getDataBaseName] is the exact key stored in `Demo_Permissions/{cid}.todo`
/// (written by Knowticed Admin) and in `todo_module_permissions/{roleId}`.
/// The SAME strings are hard-coded in the admin app
/// (`clients_repository.dart` + `dashboard_clients_controller.dart`
/// `_getDefaultPermissionsForModule`). Change one, change all three — the
/// client compares keys with an exact `containsKey`.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum TodoPermissions implements ModulePermissionsSectionsPermission {
  viewToDo,
  createToDo,
  editToDo,
  deleteToDo,
  restoreToDo;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case viewToDo:
        return 'View_To_Do';
      case createToDo:
        return 'Create_To_Do';
      case editToDo:
        return 'Edit_To_Do';
      case deleteToDo:
        return 'Delete_To_Do';
      case restoreToDo:
        return 'Restore_To_Do';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case viewToDo:
        return S.current.viewToDo;
      case createToDo:
        return S.current.createToDo;
      case editToDo:
        return S.current.editToDo;
      case deleteToDo:
        return S.current.deleteToDo;
      case restoreToDo:
        return S.current.restoreToDo;
    }
  }
}
