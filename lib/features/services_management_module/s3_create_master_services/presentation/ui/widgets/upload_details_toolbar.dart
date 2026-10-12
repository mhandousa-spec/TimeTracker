/// Module: services_management_module
/// Description: Toolbar row (error navigation + "remove selection"/"add
///              row" actions) for the bulk-upload request-preview screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: AppColors, StyleText, customButtonWithSvg
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from upload_details.dart
///     (fix item 5 — page LOC reduction).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class UploadDetailsToolbar extends StatelessWidget {
  final bool isArabic;
  final bool lightMode;
  final int totalErrorCount;
  final int currentErrorIndex;
  final VoidCallback onPrevError;
  final VoidCallback onNextError;
  final VoidCallback onRemoveSelection;
  final VoidCallback onAddRow;

  const UploadDetailsToolbar({
    super.key,
    required this.isArabic,
    required this.lightMode,
    required this.totalErrorCount,
    required this.currentErrorIndex,
    required this.onPrevError,
    required this.onNextError,
    required this.onRemoveSelection,
    required this.onAddRow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 30.sp,
          width: 138.sp,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onPrevError,
                child: Container(
                  padding: EdgeInsets.all(4.sp),
                  child: SvgPicture.asset(
                    isArabic
                        ? 'assets/icons_assets/main_icons_assets/chevron_right.svg'
                        : 'assets/icons_assets/main_icons_assets/chevron_left.svg',
                    width: 15.sp,
                    height: 15.sp,
                    color: totalErrorCount == 0
                        ? AppColors.grey
                        : (lightMode ? AppColors.blackButton : AppColors.whiteShadow),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 9.sp),
              Text(
                '${S.of(context).error}: ',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
              ),
              Text(
                totalErrorCount > 0
                    ? '${currentErrorIndex + 1}/$totalErrorCount'
                    : '$totalErrorCount',
                style: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.red),
              ),
              SizedBox(width: 9.sp),
              GestureDetector(
                onTap: onNextError,
                child: Container(
                  padding: EdgeInsets.all(4.sp),
                  child: SvgPicture.asset(
                    isArabic
                        ? 'assets/icons_assets/main_icons_assets/chevron_left.svg'
                        : 'assets/icons_assets/main_icons_assets/chevron_right.svg',
                    width: 15.sp,
                    height: 15.sp,
                    color: totalErrorCount == 0
                        ? AppColors.grey
                        : (lightMode ? AppColors.blackButton : AppColors.whiteShadow),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        customButtonWithSvg(
          title: S.of(context).removeSelection,
          function: onRemoveSelection,
          textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.white),
          width: 166.sp,
          height: 30.sp,
          space: 8.sp,
          radius: 4.r,
          color: AppColors.black,
          image: 'assets/icons_assets/main_icons_assets/minus_circle_red.svg',
          svgColor: AppColors.white,
          widthImage: 12.sp,
          heightImage: 1.5.sp,
          colorBorder: Colors.transparent,
        ),
        SizedBox(width: 10.sp),
        customButtonWithSvg(
          title: S.of(context).row,
          function: onAddRow,
          textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.white),
          width: 82.sp,
          height: 30.sp,
          space: 8.sp,
          radius: 4.r,
          color: AppColors.black,
          image: 'assets/icons_assets/main_icons_assets/plus.svg',
          svgColor: AppColors.white,
          widthImage: 12.sp,
          heightImage: 12.sp,
          colorBorder: Colors.transparent,
        ),
      ],
    );
  }
}
