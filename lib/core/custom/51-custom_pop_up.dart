/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_popup_menu_button.dart
/// Purpose: Declares `CustomPopupMenuButton`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ******************* FILE INFO *******************
/// File Name: custom_pop_up.dart
/// Description: this is custom calender dropdown can reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';




class CustomPopupMenuButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final List<PopupOption> options;
  final Function(String) onSelected;
  final Color backgroundColor;
  final Color iconColor;
  final double width;
  final double height;

  const CustomPopupMenuButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.options,
    required this.onSelected,
    required this.backgroundColor,
    required this.iconColor,
    this.width = 155,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return PopupMenuButton<String>(
      tooltip: "",
      onSelected: onSelected,
      offset: Offset(0, height + 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : AppColors.chatBackground,
      itemBuilder: (context) => options.map((option) {
        return HoverablePopupMenuItem(
          value: option.value,
          label: option.label,
          labelColor: option.labelColor,
        );
      }).toList(),
      child: Container(
        width: title.isEmpty ? 38.sp : width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.transparent),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.5.sp),
        child: title.isEmpty
            ? Center(
          child: SvgPicture.asset(
            iconPath,
            width: 16.sp,
            height: 16.sp,
            color: iconColor,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 16.sp,
              height: 16.sp,
              color: iconColor,
            ),
            SizedBox(width: 8.sp),
            FittedBox(
              child: Text(
                title,
                style: StyleText.fontSize16Weight500.copyWith(
                    color: iconColor
                ),
              ),
            ),
            SizedBox(width: 4.sp),
          ],
        ),
      ),

    );
  }
}

class PopupOption {
  final String value;
  final String label;

  /// Optional resting colour for this one row's label.
  ///
  /// ADDED 15/8/2026: destructive rows ("Delete") are red in the Figma while
  /// every other row keeps the theme's text colour. Without this the caller
  /// had to rebuild the whole menu locally to recolour a single item, which
  /// is how a second, drifting copy of this widget gets born. Null keeps the
  /// previous behaviour exactly — white on dark, black on light.
  final Color? labelColor;

  PopupOption({required this.value, required this.label, this.labelColor});
}

// ✅ Custom hoverable item
class HoverablePopupMenuItem extends StatefulWidget implements PopupMenuEntry<String> {
  final String value;
  final String label;

  /// Resting label colour. Null falls back to the theme default.
  final Color? labelColor;

  /// Row fill while the pointer is over it. Null keeps the historical
  /// [AppColors.primary].
  final Color? hoverColor;

  /// Label colour while hovered. Null keeps the historical
  /// [AppColors.textButton], which is what reads on top of the primary fill.
  ///
  /// Both are additive: the existing [CustomPopupMenuButton] passes neither
  /// and is unchanged.
  final Color? hoverLabelColor;

  /// Where the label sits in the row. Defaults to [Alignment.center], which
  /// is what [CustomPopupMenuButton] has always drawn; a menu hung off a card
  /// with a mix of short and long labels ("Edit" / "Previous Module Owners")
  /// wants [Alignment.centerLeft] instead.
  final AlignmentGeometry alignment;

  final double _height;

  const HoverablePopupMenuItem({
    super.key,
    required this.value,
    required this.label,
    this.labelColor,
    this.hoverColor,
    this.hoverLabelColor,
    this.alignment = Alignment.center,
    double height = kMinInteractiveDimension,
  }) : _height = height;

  @override
  _HoverablePopupMenuItemState createState() => _HoverablePopupMenuItemState();

  @override
  double get height => _height;

  @override
  bool represents(String? value) => value == this.value;
}

class _HoverablePopupMenuItemState extends State<HoverablePopupMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => Navigator.pop(context, widget.value),
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 12.sp),
        decoration: BoxDecoration(
          color: isHovered
              ? (widget.hoverColor ?? AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Align(
          alignment: widget.alignment,
          // The row is as wide as the menu, so it must not also stretch to the
          // widest label's height.
          heightFactor: 1,
          child: Text(
            widget.label,
            style: StyleText.fontSize14Weight500.copyWith(
              // Hover wins over labelColor: the row is repainted underneath,
              // so a red "Delete" left red on the default primary fill would
              // be red-on-yellow the moment the pointer touched it.
              // labelColor only paints the resting state.
              color: isHovered
                  ? (widget.hoverLabelColor ?? AppColors.textButton)
                  : (widget.labelColor ??
                      (isDark ? AppColors.white : AppColors.blackButton)),
            ),
          ),
        ),
      ),
    );
  }
}