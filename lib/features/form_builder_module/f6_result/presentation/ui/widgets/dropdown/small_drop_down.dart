// Last update: 2/10/2024

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';

class SmallDropdown extends StatelessWidget {
  SmallDropdown(
      {super.key,
      required this.onChanged,
      required this.items,
      required this.textButton,
      this.end,
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
      this.svgIconPath,
      this.textStyle,
      this.menuItemHeight,
      this.showErrorBorder = false});

  double? menuItemHeight;
  final Function(dynamic) onChanged;
  final List<DropdownMenuItem> items;
  final String? textButton;
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: AppColors.transparent,
        highlightColor: splashColorOn ? AppColors.primary : AppColors.transparent,
        hoverColor: AppColors.transparent,
      ),
      child: DropdownButtonFormField2(
        decoration: InputDecoration(
          focusColor: AppColors.transparent,
          hoverColor: AppColors.transparent,
          filled: true,
          fillColor: fillColor ?? AppColors.card,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          errorStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          focusedBorder: showErrorBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(color: AppColors.red),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide.none,
                ),
          disabledBorder: showErrorBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide:
                  BorderSide(
                    color: AppColors.red,
                  ),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide.none,
                ),
          enabledBorder: showErrorBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide:  BorderSide(
                    color: AppColors.red,
                  ),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide.none,
                ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide:
            BorderSide(
              color: AppColors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide:  BorderSide(
              color: AppColors.red,
            ),
          ),
        ),
        validator: validator,
        customButton: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              shape: BoxShape.rectangle),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                AppAssets.filter,
                colorFilter:
                    ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
              ),
            ),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: menuItemHeight ?? 25.h,
          overlayColor: WidgetStateProperty.all(AppColors.transparent),
        ),
        value: value,
        dropdownStyleData: DropdownStyleData(
          offset: Offset((context.isArabic) ? 290.sp : -265.sp, 0.sp),
          width: menuWidth,
          maxHeight: 300,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: fillColor ?? AppColors.card,
          ),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
