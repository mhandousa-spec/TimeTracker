/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: check_row.dart
/// Purpose: A labelled checkbox row used by the demo signup form.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// Objectives: single "requirement met / not met" row used by the reset
/// password checklist.
///
/// The shared [CustomCheckBox] followed by the requirement text, 0.01.h of top
/// padding per row.
///
/// CHANGED 26/8/2026: the box was a pair of hand-picked SVGs —
/// `checkbox_checked_yellow.svg` / `checkbox_empty_outline.svg`, tinted with
/// AppColors.lightPrimary — which is a second checkbox look living outside the
/// app's own component. It now uses core/custom/23-custom_check_box.dart, so
/// this checklist follows the same fill, border and radius as every other
/// checkbox in the app and picks up any change made there.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CheckRow extends StatelessWidget {
  const CheckRow({super.key, required this.isChecked, required this.text});

  final bool isChecked;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // `size` left at the widget's own default (22.sp) rather than the
          // 0.025.h the SVG used: that was a fraction of SCREEN HEIGHT, so the
          // box shrank on a short window and grew on a tall one while the
          // 12pt label beside it stayed put. The component's default is the
          // size every other checkbox in the app draws at.
          CustomCheckBox(isSelected: isChecked),
          SizedBox(width: 0.01.w),
          Expanded(
            child: Text(
              text,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
