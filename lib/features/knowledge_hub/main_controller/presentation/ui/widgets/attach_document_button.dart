import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget attachDocumentButton(
  BuildContext context, {
  required String text,
  required VoidCallback onPressed,
  Color? textColor,
  Color? backgroundColor,
  double? horizontalPadding,
  double? verticalPadding,
  double? borderRadius,
  double? buttonWidth,
  double? buttonHeight,
  TextStyle? textStyle,
  Widget? icon,
  double? spacingBetweenIconAndText,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: buttonWidth ?? ScreenUtil().screenWidth,
      height: buttonHeight ?? 36,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon,
          spacingBetweenIconAndText != null
              ? SizedBox(width: spacingBetweenIconAndText.w,)
              : SizedBox(width: 16.w,),
          Text(
            text,
            style:
                textStyle ??
                StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.textButton,
                ),
          ),
        ],
      ),
    ),
  );
}
