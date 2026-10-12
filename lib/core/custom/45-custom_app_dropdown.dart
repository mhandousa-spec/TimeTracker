/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_dropdown.dart
/// Purpose: Declares `AppDropdown`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Last update: 2/10/2024
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class AppDropdown extends StatelessWidget {
  AppDropdown(
      {super.key,
        this.customButton,
        required this.onChanged,
        required this.items,
        required this.textButton,
        this.end,
        this.hintText,
        this.value,
        this.customSpacing,
        this.menuWidth,
        this.width,
        this.height,
        this.textColor,
        this.splashColorOn = true,
        this.showDropdownIcon = true,
        this.validator,
        this.fillColor,
        this.menuColor,
        this.svgIconPath,
        this.textStyle,
        this.menuItemHeight,
        this.showErrorBorder = false,
        this.isSelectedItemHasBackGround = false,
        this.borderRadius,
        this.isAllCornersRounded = false,
        this.leadingLabel,
        this.yOffset = 0,
        this.xOffset = 0});

  /// Optional label drawn BEFORE the selected value inside the trigger.
  ///
  /// Null by default, and it must stay null for an ordinary form dropdown.
  /// FIXED 17/8/2026: this used to be a hardcoded `S.current.sort`, printed
  /// unconditionally, so every dropdown in the app rendered the word
  /// "Sort" / "ترتيب" in front of its own value — Access Management,
  /// Orientation, field type, alignment, Department, the preview fields, the
  /// Summary dialog. With no value selected the trigger showed *only*
  /// "ترتيب", which is why the Department dropdown looked empty-but-labelled.
  ///
  /// Pass a label only for a trigger that names an action instead of showing
  /// a selection. The toolbar Sort button is NOT such a case — it is
  /// [CustomSortButton] on top of [CustomDropdown] and carries its own title.
  final String? leadingLabel;
  bool isAllCornersRounded;
  double xOffset;
  double? borderRadius;
  Widget? customButton;
  final bool isSelectedItemHasBackGround;
  double? menuItemHeight;
  final Function(dynamic) onChanged;
  final List<DropdownMenuItem> items;
  final String? textButton;
  final String? hintText;
  final dynamic value;
  final Widget? customSpacing;
  final bool splashColorOn, showErrorBorder;
  final bool showDropdownIcon;
  final Color? textColor;
  final String? svgIconPath;
  final TextStyle? textStyle;
  final String? Function(dynamic)? validator;
  final double? height, width, menuWidth;
  final double? end;
  final Color? fillColor;

  /// Menu (dropdown list) background. Falls back to [fillColor] so all
  /// existing usages keep their current behavior.
  final Color? menuColor;
  double yOffset;

  @override
  Widget build(BuildContext context) {
    yOffset = yOffset.abs();
    // print("//////// init state called${yOffset}");
    if (!context.isArabic) {
      yOffset = -1 * yOffset;
    }
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: splashColorOn ? AppColors.primary : Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: DropdownButtonFormField2(
        decoration: InputDecoration(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          filled: true,
          fillColor: fillColor ?? AppColors.field,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          errorStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          focusedBorder: showErrorBorder
              ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: const BorderSide(color: Colors.red),
          )
              : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: BorderSide.none,
          ),
          disabledBorder: showErrorBorder
              ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: const BorderSide(color: Colors.red),
          )
              : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: showErrorBorder
              ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: const BorderSide(color: Colors.red),
          )
              : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
        ),
        validator: validator,
        customButton: customButton ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  svgIconPath != null
                      ? _buildIconSection()
                      : const SizedBox.shrink(),
                  //    horizontalSpace(10),
                  Expanded(
                      child: Padding(
                          padding: EdgeInsetsDirectional.only(start: 10.sp),
                          child: _buildDropdownText())),
                  customSpacing ?? const SizedBox(),
                  showDropdownIcon
                      ? Padding(
                    padding: EdgeInsetsDirectional.only(end: end ?? 8.w),
                    child: SizedBox(
                      child: SvgPicture.asset(
                        AppAssets.arrowDown,
                        height: 22.sp,
                        width: 22.sp,
                        colorFilter: ColorFilter.mode(
                            AppColors.secondaryBlack, BlendMode.srcIn),
                      ),
                    ),
                  )
                      : const SizedBox(),
                ],
              ),
            ),
        menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsets.symmetric(
              horizontal: isSelectedItemHasBackGround ? 0 : 8.sp),
          height: menuItemHeight ?? 25.h,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        value: value,
        dropdownStyleData: DropdownStyleData(
          elevation: 10,
          offset: Offset(yOffset, xOffset),

          padding: EdgeInsets.zero,
          width: menuWidth,
          maxHeight: 150.sp,
          // Form-builder bug report #9/#30/#37: no visible scrollbar inside
          // the menu — it still scrolls with the wheel / drag.
          scrollbarTheme: ScrollbarThemeData(
            thickness: WidgetStateProperty.all(0),
            thumbVisibility: WidgetStateProperty.all(false),
            trackVisibility: WidgetStateProperty.all(false),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.r),

            color: menuColor ?? fillColor ?? AppColors.field,
          ),
        ),
        hint: Text(
          (hintText ?? 'Choose Here'),
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
          overflow: TextOverflow.ellipsis,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownText() {
    // The trigger has to render its own placeholder. `customButton` replaces
    // the whole button, so `DropdownButtonFormField2`'s `hint` is never drawn —
    // if this returns nothing the box looks blank rather than unselected.
    final String shownText = textButton ?? hintText ?? 'Choose Here';
    final TextStyle shownStyle = value != null
        ? textStyle ?? StyleText.fontSize12Weight400
        : StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack);

    final String? label = leadingLabel;
    if (label == null || label.isEmpty) {
      return Text(
        shownText,
        style: shownStyle,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            shownText,
            style: shownStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  SvgPicture _buildIconDropdown() {
    return SvgPicture.asset(
      svgIconPath!,
      width: 14.w,
      height: 6.h,
      fit: BoxFit.fill,
      colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
    );
  }

  _buildIconSection() {
    return Row(
      children: [
        horizontalSpace(11),
        _buildIconDropdown(),
      ],
    );
  }
}
