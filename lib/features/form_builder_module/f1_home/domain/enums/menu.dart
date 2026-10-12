
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/ui/widgets/hover_item.dart';
import 'package:knowticed_plus/generated/l10n.dart';
enum MenuEnum {
  duplicate,
  edit,
  convertToPDF,
  delete,

  /// ADDED 19/8/2026 for the Deleted tab's card menu.
  ///
  /// NOT part of any "every action" list: it is the only entry the Deleted tab
  /// offers, and it is meaningless on every other tab. `home_grid_item_view`
  /// therefore passes an EXPLICIT list per tab rather than `MenuEnum.values` —
  /// which is what it used to pass, and what would have put "Restore" in the
  /// Publish card's menu the moment this value was added. Any new call site
  /// should name the entries it wants for the same reason.
  restore;
}

extension MenuEnumExtension on MenuEnum {
  /// STABLE identifier. NOT translated; see [label].
  String get name {
    switch (this) {
      case MenuEnum.duplicate:
        return 'Duplicate';
      case MenuEnum.edit:
        return 'Edit';
      case MenuEnum.convertToPDF:
        return 'Convert to PDF';
      case MenuEnum.delete:
        return 'Delete';
      case MenuEnum.restore:
        return 'Restore';

      default:
        return '';
    }
  }

  /// Translated label — what the user actually reads in the card menu.
  String get label {
    final s = S.current;
    switch (this) {
      case MenuEnum.duplicate:
        return s.menuDuplicate;
      case MenuEnum.edit:
        return s.edit;
      case MenuEnum.convertToPDF:
        return s.convertToPdf;
      case MenuEnum.delete:
        return s.delete;
      case MenuEnum.restore:
        return s.restore;

      default:
        return '';
    }
  }

  static List<PopupMenuEntry<MenuEnum>> menuList() {
    return MenuEnum.values.map((menuEnum) {
      return PopupMenuItem<MenuEnum>(
        value: menuEnum,
        padding: EdgeInsets.zero, // <-- Remove default padding
        height: 45,
        // Use a full-width Container to cover the entire menu item
        child: HoverableMenuItem(menuEnum: menuEnum),
      );
    }).toList();
  }
}
