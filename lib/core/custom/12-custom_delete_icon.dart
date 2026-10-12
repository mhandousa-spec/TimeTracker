/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_delete_icon.dart
/// Purpose: Declares `CustomDeleteIcon`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Delete action button.
///
/// Fixed (static) values:
/// - Mobile: 38.sp x 38.sp, icon only (no text)
/// - Non-mobile: 135.sp x 38.sp, svg + text with 8.sp space;
///   if the content doesn't fit, wraps with 12.sp horizontal padding
/// - Border radius: 8.r
/// - Svg: assets/icons_assets/form_builder_assets/delete_trash_red.svg, 20.sp x 20.sp
class CustomDeleteIcon extends StatelessWidget {
  static const String _svgPath = 'assets/icons_assets/form_builder_assets/delete_trash_red.svg';

  final String? title;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Color? svgColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const CustomDeleteIcon({
    super.key,
    this.title,
    this.onTap,
    this.color,
    this.borderColor,
    this.svgColor,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final String text = title ?? (isArabic ? 'حذف' : 'Delete');
    final Color iconColor = svgColor ?? AppColors.white;

    final Widget svg = CustomSvgImage(
      assetPath: _svgPath,
      width: 20.sp,
      height: 20.sp,
      color: iconColor,
      fit: BoxFit.scaleDown,
    );

    final TextStyle effectiveStyle =
        textStyle ?? StyleText.fontSize14Weight400.copyWith(color: iconColor);

    // Enforced sizing: 38.sp icon-only on mobile; 135.sp on tablet, or
    // content width + 12.sp horizontal padding when the text doesn't fit.
    final double? buttonWidth = isMobile
        ? ButtonSizing.iconButtonSize
        : ButtonSizing.width(
            context,
            title: text,
            textStyle: effectiveStyle,
            extraContentWidth: 20.sp + 8.sp,
          );

    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticController.high(); // destructive: delete
              onTap!();
            },
      child: Container(
        width: buttonWidth,
        height: ButtonSizing.height,
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          border: Border.all(color: borderColor ?? AppColors.transparent),
          borderRadius: BorderRadius.circular(ButtonSizing.radius),
        ),
        child: isMobile
            ? Center(child: svg)
            : Padding(
                padding: buttonWidth == null
                    ? EdgeInsets.symmetric(
                        horizontal: ButtonSizing.horizontalPadding,
                      )
                    : (padding ?? EdgeInsets.zero),
                child: buttonWidth == null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          svg,
                          SizedBox(width: 8.sp),
                          Text(text, style: effectiveStyle, maxLines: 1),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          svg,
                          SizedBox(width: 8.sp),
                          Flexible(
                            child: Text(
                              text,
                              style: effectiveStyle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}
