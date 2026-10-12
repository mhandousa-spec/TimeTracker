/// Module: core / custom
///
///*************************** FILE INFO ****************************///
/// File Name: 100-custom_add_row_button.dart
/// Purpose: Declares `CustomAddRowButton` — the small dark "+ Label" button
///          that appends a row to a repeating list ("+ Reminder", "+ Item").
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Created for the To-Do module, where two hand-made copies drifted: one used
/// `AppColors.blackButton`, which turns WHITE in dark mode while the label
/// stayed white — an unreadable button. Colours come from the theme only:
/// `AppColors.header` (#2D2D2D light / #171717 dark) with white content, so it
/// reads on both the light and the dark page background.
///
/// Fires the MEDIUM haptic (Add = medium, owner standard) and shrinks on tap
/// (`ShrinkOnTap`). Pass `onTap: null` to hide nothing but disable it; callers
/// that reach a maximum (e.g. 3 reminders) should simply not build it.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CustomAddRowButton extends StatelessWidget {
  const CustomAddRowButton({
    super.key,
    required this.label,
    required this.onTap,
    this.minWidth = 100,
    this.height = 28,
  });

  /// Text after the "+" — already localised by the caller.
  final String label;

  /// Called after the medium haptic.
  final VoidCallback onTap;

  /// Unscaled; `.sp` is applied here.
  final double minWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ShrinkOnTap(
        child: GestureDetector(
          onTap: () {
            HapticController.medium();
            onTap();
          },
          child: Container(
            constraints: BoxConstraints(minWidth: minWidth.sp),
            height: height.sp,
            padding: EdgeInsetsDirectional.symmetric(horizontal: 10.sp),
            decoration: BoxDecoration(
              color: AppColors.header,
              borderRadius: BorderRadiusDirectional.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomSvgImage(
                  assetPath: AppAssets.add,
                  width: 12.sp,
                  height: 12.sp,
                  color: AppColors.colorWhite,
                ),
                SizedBox(width: 8.sp),
                Text(
                  label,
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.colorWhite),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
