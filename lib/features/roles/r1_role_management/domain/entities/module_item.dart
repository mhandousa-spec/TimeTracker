/// Module: roles / r1_role_management / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: module_item.dart
/// Purpose: Declares `ModuleItem`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

class ModuleItem {
  final String imageUrl;
  final String text;
  bool isSelected;

  ModuleItem(
      {required this.imageUrl, required this.text, required this.isSelected});
}
