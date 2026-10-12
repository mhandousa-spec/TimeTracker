/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: messaging_custom_button.dart
/// Purpose: Declares `CustomButton`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/helper/main_helper/haptic_feedback_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  CustomButton(
      {required this.buttonText,
      required this.onTap,
      this.buttonColor,
      this.width,
      this.textStyle,
      this.horizontalPadding,
      this.height,
      this.verticalPadding,
      this.borderRadius});
  double? verticalPadding;

  /// Corner radius (already scaled). Null keeps the original 2.r.
  double? borderRadius;
  double? horizontalPadding;
  String buttonText;
  var onTap;
  Color? buttonColor;
  TextStyle? textStyle;
  double? width;
  double? height;
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedbackHelper.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );
        widget.onTap();
      },
      splashColor: Colors.transparent,
      child: Container(
        height: widget.height?.sp,
        alignment: Alignment.center,
        width: widget.width?.w,
        padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPadding ?? 24.sp,
            vertical: widget.verticalPadding ?? 8.sp),
        decoration: BoxDecoration(
          color: widget.buttonColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 2.r),
        ),
        child: FittedBox(
          child: Text(
            widget.buttonText,
            style: widget.textStyle ??
                StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.textButton,
                ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
