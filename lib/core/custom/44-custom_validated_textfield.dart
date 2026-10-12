/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_validated_textfield.dart
/// Purpose: Declares `CustomValidatedTextFieldMaster`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ******************* FILE INFO *******************
/// File Name: custom_textformfield.dart
/// Description: this is custom Text field can reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/services.dart';

class CustomValidatedTextFieldMaster extends StatelessWidget {
  final String? label; // optional
  final String hint;
  final TextEditingController controller;
  final double height;
  final double? width;
  final int maxLines;
  final bool enabled;
  final bool showCharCount;
  final ValueChanged<String>? onChanged;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final bool onlyDigits;
  final bool submitted;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;

  /// NEW: hard character cap (default 500)
  final int maxLength;

  const CustomValidatedTextFieldMaster({
    super.key,
    this.label,
    required this.hint,
    required this.controller,
    this.height = 36,
    this.width,
    this.maxLines = 1,
    this.enabled = true,
    this.showCharCount = false,
    this.onChanged,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.onlyDigits = false,
    this.submitted = false,
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.maxLength = 500, // <-- default cap
  });

  String _toArabicNum(int number) {
    const arabicNums = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    return number
        .toString()
        .split('')
        .map((e) => arabicNums[int.parse(e)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabicField = textDirection == TextDirection.rtl;
    final bool isEnglishField = textDirection == TextDirection.ltr;
    final String text = controller.text;

    final bool hasArabic  = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
    final bool isNotDigits =
        onlyDigits && text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text);
    final bool isEmpty = text.trim().isEmpty;

    final bool showError = (submitted && isEmpty) ||
        (!isEmpty &&
            ((isEnglishField && hasArabic) ||
                (isArabicField && hasEnglish) ||
                isNotDigits));

    String errorText = '';
    if (isEmpty) {
      errorText = textDirection == TextDirection.rtl
          ? "هذا الحقل مطلوب"
          : "This field is required.";
    } else if (isEnglishField && hasArabic) {
      errorText = "Please use English characters only.";
    } else if (isArabicField && hasEnglish) {
      errorText = "الرجاء استخدام الأحرف العربية فقط.";
    } else if (isNotDigits) {
      errorText = "Only numbers are allowed.";
    }

    final bool lightMode   = Theme.of(context).brightness == Brightness.light;
    final bool showCounter = showCharCount && !showError;

    // Input formatters: enforce digits (optional) + length cap (hard)
    final List<TextInputFormatter> formatters = [
      if (onlyDigits) FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(maxLength),
    ];

    // Helper for current length (already limited by formatter)
    int currentLen = controller.text.characters.length; // safer for graphemes

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            textDirection: textDirection,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text
            ),
          ),
        if (label != null) SizedBox(height: 6.h),

        // Text field
        SizedBox(
          width: width,
          height: height.h,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            textDirection: textDirection,
            textAlign: textAlign,
            keyboardType: onlyDigits ? TextInputType.number : TextInputType.text,
            style: textStyle ??
                StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text
                ),
            onChanged: onChanged,
            inputFormatters: formatters, // <-- enforce limits
            maxLength: maxLength,        // <-- show native limit (hidden via buildCounter)
            maxLengthEnforcement: MaxLengthEnforcement.enforced, // <-- hard cap
            decoration: InputDecoration(
              hoverColor: Colors.transparent,
              hintText: hint,
              hintStyle: hintStyle ??
                  StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText
                  ),
              filled: true,
              fillColor: fillColor ?? AppColors.background,
              isDense: true,
              // Hide Flutter's default counter (we render our own below)
              counterText: '',
              // Or more robustly:
              // buildCounter: (_, {int? currentLength, bool? isFocused, int? maxLength}) => const SizedBox.shrink(),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(color: Colors.transparent, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(color: Colors.transparent, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
            ),
          ),
        ),

        // Fixed-height lane: error OR counter OR nothing
        SizedBox(
          height: 18.h, // keeps rows aligned
          child: showError
              ? Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: AppColors.red,
              ),
            ),
          )
              : (showCounter
              ? Align(
            alignment: textDirection == TextDirection.rtl
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              // Show current / max in the correct numeral system
              textDirection == TextDirection.rtl
                  ? "${_toArabicNum(currentLen)}/${_toArabicNum(maxLength)}"
                  : "$currentLen/$maxLength",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          )
              : const SizedBox.shrink()),
        ),
      ],
    );
  }
}
