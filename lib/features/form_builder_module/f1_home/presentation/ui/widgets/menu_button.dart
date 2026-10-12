// created by Mohamed Elrashidy
// created at 29-1-2024
// last edit at 31-1-2024

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/menu.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';

class MenuDropdown extends StatefulWidget {
  MenuDropdown(
      {required this.items,
        required this.currentEnumValue,
        required this.onChanged,
        this.customIcon,
        this.iconWidth = 35,
        this.yOffset = -110,
        this.xOffset = 0,
        this.alignment = AlignmentDirectional.centerStart});
  List<MenuEnum> items;
  var currentEnumValue;
  var onChanged;
  double iconWidth;
  double yOffset;
  double xOffset;
  Widget? customIcon;
  AlignmentDirectional alignment;
  @override
  State<MenuDropdown> createState() => _AppDropDownButtonState();
}

class _AppDropDownButtonState extends State<MenuDropdown> {
  @override
  void initState() {
    super.initState();
  }

  List<MenuEnum> _getFilteredItems() {
    return widget.items.where((item) {
      // Check if item is duplicate and filter based on permission
      if (item == MenuEnum.duplicate) {
        return Get.find<MainCoreEmployeeController>().isHasPermission(
          module: Modules.formBuilder,
          section: FormPermissionsSections.formPermissions,
          permission: FormPermissions.duplicateForm,
        );
      }
      // Check if item is convert to PDF and filter based on permission
      if (item == MenuEnum.convertToPDF) {
        return Get.find<MainCoreEmployeeController>().isHasPermission(
          module: Modules.formBuilder,
          section: FormPermissionsSections.formPermissions,
          permission: FormPermissions.convertToPdf,
        );
      }
      // Form bug report #27: every switch in the Form Permissions section
      // is respected, not just Duplicate / Convert to PDF.
      final FormPermissions? gate = switch (item) {
        MenuEnum.edit => FormPermissions.editForm,
        MenuEnum.delete => FormPermissions.deleteForm,
        MenuEnum.restore => FormPermissions.restoreForm,
        _ => null,
      };
      if (gate != null) {
        return Get.find<MainCoreEmployeeController>().isHasPermission(
          module: Modules.formBuilder,
          section: FormPermissionsSections.formPermissions,
          permission: gate,
        );
      }
      // Include all other items
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    widget.yOffset = widget.yOffset.abs();
    
    if (Get.locale?.languageCode == "en") {
      widget.yOffset = -1 * widget.yOffset;
    }

    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButton2(
      menuItemStyleData: MenuItemStyleData(
        height: (filteredItems.length == 1) ? 24.h : 32.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
        overlayColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary;
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.transparent;
            }
            return AppColors.transparent;
          },
        ),
      ),
      // button decoration
      customButton: widget.customIcon ??
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.menu,
                width: 20.sp,
                colorFilter:
                ColorFilter.mode(AppColors.fullBlack, BlendMode.srcIn),
              ),
            ],
          ),

      // dropdown menu decoration
      dropdownStyleData: DropdownStyleData(
        maxHeight: 190.h,
        offset: Offset(widget.yOffset.sp, widget.xOffset),
        width: 130.sp,
        elevation: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.background,
        ),
      ),
      value: _getSelectedValue(),
      style: StyleText.fontSize14Weight500,
      underline: Container(color: AppColors.transparent),
      items: filteredItems.map<DropdownMenuItem<dynamic>>((dynamic value) {
        return DropdownMenuItem<dynamic>(
          alignment: widget.alignment,
          value: value,
          // CHANGED: was a bare `Text` with a fixed colour. `menuItemStyleData`
          // paints AppColors.primary behind the row under the pointer, but the
          // label knew nothing about that, so the highlighted row kept its
          // resting dark/red text on the yellow. See [_MenuItemLabel].
          child: _MenuItemLabel(
            text: getItemListText(value),
            restingColor: (value == MenuEnum.delete)
                ? AppColors.red
                : AppColors.secondaryBlack,
          ),
        );
      }).toList(),

      onChanged: (value) {
        
        widget.onChanged(value);
        setState(() {});
      },
    );
  }

  String getSelectedText() {
    final MenuEnum? current = widget.currentEnumValue as MenuEnum?;
    return current?.label ?? "";
  }

  /// FIXED 19/8/2026 — this used to be `item as Enum; return item.name;`.
  /// Casting to `Enum` first made `.name` resolve to `dart:core`'s `Enum.name`
  /// rather than the extension, so the menu rendered raw identifiers
  /// ("convertToPDF") instead of a label — and never translated either.
  /// [MenuEnumExtension.label] is the localized text.
  String getItemListText<T>(MenuEnum item) {
    return item.label;
  }

  _getSelectedValue() {
    return widget.currentEnumValue;
  }
}

/// One row's label, repainted when the pointer is over that row.
///
/// ADDED: `DropdownMenuItem` builds its child once and hands it no pointer
/// state, so a `Text` inside it cannot react to the highlight that
/// `MenuItemStyleData.overlayColor` paints on hover. The row went yellow
/// (AppColors.primary) while its label stayed `secondaryBlack` — or red, for
/// Delete — which is the mismatch in the screenshot.
///
/// Hovered, the label is [AppColors.textButton]: the colour the app already
/// pairs with a primary-coloured surface everywhere else (see `customButton` /
/// `customButtonWithSvg`), so a highlighted menu row now reads like every other
/// primary-filled control.
class _MenuItemLabel extends StatefulWidget {
  const _MenuItemLabel({required this.text, required this.restingColor});

  final String text;

  /// Colour when the pointer is elsewhere — red for Delete, secondaryBlack for
  /// everything else, exactly as before.
  final Color restingColor;

  @override
  State<_MenuItemLabel> createState() => _MenuItemLabelState();
}

class _MenuItemLabelState extends State<_MenuItemLabel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        // Full row width on purpose. `DropdownMenuItem` sizes its child to the
        // text, so without this the pointer would only count as "on this row"
        // while it was literally over the glyphs — the label would flick back
        // to its resting colour in the empty space the highlight still covers.
        width: double.infinity,
        child: Text(
          widget.text,
          style: StyleText.fontSize14Weight500.copyWith(
            color: _hovered ? AppColors.textButton : widget.restingColor,
          ),
        ),
      ),
    );
  }
}