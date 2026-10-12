/// Module: roles / r1_role_management / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: module_permissions_sections.dart
/// Purpose: Declares `ModulePermissionsSections`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

abstract class ModulePermissionsSections {
  List<Enum> get sectionPermissions;
  static List<Enum> get lastColumnValues => [];
  static List<Enum> get firstColumnValues => [];
  String get getName;
}
