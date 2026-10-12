/// Module: roles / r4_active_directory / presentation / ui / widgets / fields
///
///*************************** FILE INFO ****************************///
/// File Name: default_csv_field.dart
/// Purpose: Declares `DefaultCsvField`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 25/5/2026
// Objectives: This file is responsible for providing default text form field widget that is used in active_directory module.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

class DefaultCsvField extends StatelessWidget {
  const DefaultCsvField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.showBorder,
    this.enabledBorder,
    this.textAlign,
    this.width,
    this.inputTextStyle,
    this.hintStyle,
    this.style,
    this.hintText,
    this.isObscureText,
    this.suffixIcon,
    this.backGroundColor,
    this.onChanged,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.prefixIcon2,
    this.label,
    this.readOnly,
    this.enabled,
    this.onTap,
    this.top,
    this.bottom,
    this.maxLength,
    this.expands,
    this.keyboardType,
    this.autovalidateMode,
    this.height,
    this.labelText,
    this.minLines,
    this.maxLines,
    this.collapsed,
    this.defaultHeight,
    this.textDirection,
    this.alignCounterTextLeft = false,
    this.showCounter = false,
    this.helperText,
    this.hasError,
    this.titleValidator,
    this.removeBorder = false,
    this.fillColor,
    this.filled = false,
    this.borderRadius,
  });

  final TextAlign? textAlign;
  final int? maxLength;
  final bool? defaultHeight;
  final bool? collapsed;
  final bool? hasError;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle, style;
  final String? hintText;
  final bool? isObscureText, readOnly, enabled, showBorder;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefixIcon2;
  final Widget? label;
  final Color? backGroundColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? Function(String?)? titleValidator;
  final double? top, bottom;
  final double? height;
  final double? width;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onTap;
  final bool? expands;
  final TextInputType? keyboardType;
  final String? labelText;
  final int? minLines;
  final int? maxLines;
  final TextDirection? textDirection;
  final bool alignCounterTextLeft;
  final bool showCounter;
  final String? helperText;

  // NEW PARAMETERS
  final bool removeBorder;
  final Color? fillColor;
  final bool filled;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = AppControllers.theme;
    final isLightTheme = themeController.currentTheme.value == AppColors.lightTheme;

    // Default border radius
    final radius = borderRadius ?? 8.0;

    return SizedBox(
      height: height ?? 30.h,
      child: TextFormField(
        textDirection: textDirection,
        textInputAction: TextInputAction.done,
        keyboardType: keyboardType,
        expands: expands ?? false,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
        onTap: onTap,
        controller: controller,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        readOnly: readOnly ?? false,
        enabled: enabled,
        maxLength: showCounter ? maxLength : null,
        textAlignVertical: TextAlignVertical.center,
        textAlign: textAlign ?? TextAlign.start,
        cursorColor: AppColors.lightPrimary,

        decoration: InputDecoration(
          // Counter settings
          counterText: showCounter ? null : '',
          counterStyle: showCounter ? null : const TextStyle(fontSize: 0),

          // Helper text
          helperText: helperText,

          // Hint text and style
          hintText: hintText,
          hintStyle: hintStyle ?? AppFontStyle.cairoRegularStyle.copyWith(
            color: isLightTheme ? AppColors.colorBlack : AppColors.colorWhite,
            fontSize: 12.sp,
          ),

          // Label
          label: label,
          labelText: labelText,
          labelStyle: AppFontStyle.cairoRegularStyle.copyWith(
            color: isLightTheme ? AppColors.colorBlack : AppColors.colorWhite,
          ),

          // Content padding
          contentPadding: contentPadding ?? EdgeInsetsDirectional.symmetric(
            horizontal: 12.w,
            vertical: 8.h,
          ),

          // Border configurations - CONDITIONAL based on removeBorder
          border: removeBorder
              ? InputBorder.none
              : OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError ?? false
                  ? AppColors.delete
                  : (isLightTheme ? AppColors.colorBlack : AppColors.colorWhite),
            ),
            borderRadius: BorderRadius.circular(radius),
          ),

          enabledBorder: removeBorder
              ? InputBorder.none
              : enabledBorder ?? OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError ?? false
                  ? AppColors.delete
                  : (isLightTheme ? AppColors.colorBlack : AppColors.colorWhite),
            ),
            borderRadius: BorderRadius.circular(radius),
          ),

          focusedBorder: removeBorder
              ? InputBorder.none
              : focusedBorder ?? OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError ?? false
                  ? AppColors.delete
                  : AppColors.lightPrimary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(radius),
          ),

          errorBorder: removeBorder
              ? InputBorder.none
              : OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.delete, width: 1),
            borderRadius: BorderRadius.circular(radius),
          ),

          focusedErrorBorder: removeBorder
              ? InputBorder.none
              : OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.delete, width: 2),
            borderRadius: BorderRadius.circular(radius),
          ),

          // Fill color and background
          fillColor: fillColor ?? backGroundColor ?? AppColors.transparent,
          filled: filled || (fillColor != null) || removeBorder,

          // Icons
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          prefixIconConstraints: prefixIcon2 != null
              ? const BoxConstraints(minWidth: 40, maxHeight: 40)
              : null,

          // Error style
          errorStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: hasError == true ? 10.sp : 0,
            color: AppColors.delete,
          ),

          // Additional styling
          isDense: true,
        ),

        style: style ?? AppFontStyle.cairoRegularStyle.copyWith(
          color: isLightTheme ? AppColors.colorBlack : AppColors.colorWhite,
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),

        validator: validator,
        obscureText: isObscureText ?? false,
      ),
    );
  }
}