/// Module: roles / r1_role_management / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: module_permissions_sections_permissions.dart
/// Purpose: Declares `ModulePermissionsSectionsPermission`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

abstract class ModulePermissionsSectionsPermission {
  /// Whether the permission is a child permission or not
  bool get isChild;

  /// The name of the permission to be used in ui
  String get getDataBaseName;

  String get getUiName;
}
