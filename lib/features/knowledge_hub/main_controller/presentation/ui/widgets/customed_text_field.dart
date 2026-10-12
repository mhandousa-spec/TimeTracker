import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CustomValidatedTextField extends StatelessWidget {
  final String label;
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
  final Color? fillColor;

// Error text parameter
  final String? errorText;

// Keyboard type parameter
  final TextInputType? keyboardType;

// ✅ NEW: Optional validator function
  final String? Function(String?)? validator;

// SVG prefix icon parameters
  final String? prefixSvgAsset;
  final double? prefixIconWidth;
  final double? prefixIconHeight;
  final EdgeInsetsGeometry? prefixPadding;
  final VoidCallback? onPrefixTap;
  final BoxConstraints? prefixConstraints;

  const CustomValidatedTextField({
    super.key,
    required this.label,
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
    this.fillColor,
    this.errorText,
    this.keyboardType,

// ✅ NEW: Validator parameter
    this.validator,

// SVG prefix icon params
    this.prefixSvgAsset,
    this.prefixIconWidth,
    this.prefixIconHeight,
    this.prefixPadding,
    this.onPrefixTap,
    this.prefixConstraints,
  });

  String _toArabicNum(int number) {
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((e) => arabicNums[int.parse(e)])
        .join();
  }

  TextInputType _getKeyboardType() {
    if (keyboardType != null) {
      return keyboardType!;
    }
    return onlyDigits ? TextInputType.number : TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabicField = textDirection == TextDirection.rtl;
    final bool isEnglishField = textDirection == TextDirection.ltr;

    final String text = controller.text;

    final bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
    final bool isNotDigits =
        onlyDigits && text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text);

    final bool isEmpty = text.trim().isEmpty;

// ✅ Updated error logic with validator priority
    String? displayErrorText;
    bool showError = false;

// Priority 1: Custom validator function (if provided)
    if (validator != null) {
      displayErrorText = validator!(text.isEmpty ? null : text);
      showError = displayErrorText != null;
    }
// Priority 2: errorText parameter (from external validation)
    else if (errorText != null && errorText!.isNotEmpty) {
      displayErrorText = errorText;
      showError = true;
    }
// Priority 3: Built-in validation logic
    else {
      showError = (submitted && isEmpty) ||
          (!isEmpty &&
              ((isEnglishField && hasArabic) ||
                  (isArabicField && hasEnglish) ||
                  isNotDigits));

      if (showError) {
        if (isEmpty) {
          displayErrorText = textDirection == TextDirection.rtl
              ? "هذا الحقل مطلوب"
              : "This field is required.";
        } else if (isEnglishField && hasArabic) {
          displayErrorText = "Please use English characters only.";
        } else if (isArabicField && hasEnglish) {
          displayErrorText = "الرجاء استخدام الأحرف العربية فقط.";
        } else if (isNotDigits) {
          displayErrorText = "Only numbers are allowed.";
        }
      }
    }

    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    Widget? buildPrefixIcon() {
      if (prefixSvgAsset == null || prefixSvgAsset!.isEmpty) return null;

      final svg = SvgPicture.asset(
        prefixSvgAsset!,
        width: (prefixIconWidth ?? 16).w,
        height: (prefixIconHeight ?? 16).h,
      );

      final padded = Padding(
        padding: prefixPadding ?? EdgeInsets.symmetric(horizontal: 8.w),
        child: svg,
      );

      if (onPrefixTap != null) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPrefixTap,
          child: padded,
        );
      }
      return padded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textDirection: textDirection,
          style: StyleText.fontSize14Weight400.copyWith(
            color:
                lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: width?.w,
          height: height.h,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            textDirection: textDirection,
            textAlign: textAlign,
            keyboardType: _getKeyboardType(),
            style: textStyle ??
                StyleText.fontSize12Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
            onChanged: (val) {
              if (onChanged != null) onChanged!(val);
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 8.w,
              ),
              hoverColor: Colors.transparent,
              hintText: hint,
              hintStyle: StyleText.fontSize10Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
              filled: true,
              fillColor: fillColor ??
                  (lightMode ? AppColors.background : AppColors.background),
              isDense: true,
              counterText: '',
              prefixIcon: buildPrefixIcon(),
              prefixIconConstraints: prefixConstraints ??
                  BoxConstraints(
                    minWidth: (prefixIconWidth ?? 16).w + 16.w,
                    minHeight: (prefixIconHeight ?? 16).h,
                  ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: showError ? Colors.red : Colors.transparent,
                  width: 1,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: showError ? Colors.red : AppColors.primary,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        if (showError && displayErrorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              displayErrorText,
              textDirection: textDirection,
              style: TextStyle(fontSize: 10.sp, color: Colors.red),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (showCharCount)
          Align(
            alignment: textDirection == TextDirection.rtl
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                textDirection == TextDirection.rtl
                    ? "٥٠٠/${_toArabicNum(controller.text.length)}"
                    : "${controller.text.length}/500",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}
