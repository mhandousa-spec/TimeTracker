/// Module: todo / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: todo_access.dart
/// Purpose: Declares `TodoAccess` — the single place the To-Do module asks
///          "who is signed in" and "may they do X".
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Three layers must all say yes (see "To-Do Admin Control Plan.md"):
///   1. the company is licensed for To-Do (drawer/nav bar already enforce it),
///   2. Knowticed Admin's ceiling in `Demo_Permissions/{cid}.todo`,
///   3. the role's grant in `todo_module_permissions/{roleId}`.
/// Layers 2+3 are merged by `MainCoreEmployeeController`'s permission cache;
/// this class only asks it. Fail-closed: anything missing reads as "no".
///
/// A permission is granted only when BOTH the section master toggle
/// (`To_Do_Permissions`) AND the specific switch are on.

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/todo/todo_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/todo/todo_sections_enum.dart';

class TodoAccess {
  const TodoAccess();

  /// Lower-cased email of the signed-in employee, or '' before login.
  String get currentUserEmail =>
      (AppControllers.employee.employeeEntity?.email ?? '').toLowerCase();

  bool get canView => _allowed(TodoPermissions.viewToDo);
  bool get canCreate => _allowed(TodoPermissions.createToDo);
  bool get canEdit => _allowed(TodoPermissions.editToDo);
  bool get canDelete => _allowed(TodoPermissions.deleteToDo);
  bool get canRestore => _allowed(TodoPermissions.restoreToDo);

  bool _allowed(TodoPermissions permission) {
    final bool sectionOn = AppControllers.employee.isHasPermission(
      module: Modules.todo,
      section: TodoPermissionsSections.toDoPermissions,
      permission: null,
    );
    if (!sectionOn) return false;
    return AppControllers.employee.isHasPermission(
      module: Modules.todo,
      section: TodoPermissionsSections.toDoPermissions,
      permission: permission,
    );
  }
}
