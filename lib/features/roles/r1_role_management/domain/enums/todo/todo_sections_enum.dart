/// Module: roles / r1_role_management / domain / enums / todo
///
///*************************** FILE INFO ****************************///
/// File Name: todo_sections_enum.dart
/// Purpose: Declares `TodoPermissionsSections` — the single switch group
///          (with its master toggle) the To Do Permissions block is built from.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Same double-implement as `NotificationPermissionsSections`: the section is
/// both a container of permissions AND a permission itself, so the master
/// toggle can be queried with `permission: null`.
///
/// One column — [lastColumnValues] is deliberately empty.
///
/// ⚠️ [getDataBaseName] (`To_Do_Permissions`) is stored in Firestore and
/// mirrored in the admin app. Never rename it.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'todo_permissions_enum.dart';

enum TodoPermissionsSections
    implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  toDoPermissions;

  @override
  String get getName {
    switch (this) {
      case TodoPermissionsSections.toDoPermissions:
        return S.current.toDoPermissions;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case TodoPermissionsSections.toDoPermissions:
        return 'To_Do_Permissions';
    }
  }

  @override
  String get getUiName => getName;

  @override
  bool get isChild {
    return false;
  }

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case TodoPermissionsSections.toDoPermissions:
        return TodoPermissions.values;
    }
  }

  /// Left column — the only column this block has.
  static List<Enum> get firstColumnValues {
    return <Enum>[TodoPermissionsSections.toDoPermissions];
  }

  /// Right column. Empty on purpose.
  static List<Enum> get lastColumnValues {
    return <Enum>[];
  }
}
