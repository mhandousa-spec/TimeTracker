/// Module: knowledge_hub_module / core/success_dialog.dart
/// ************************* FILE INFO *************************** ///
/// File Name: success_dialog.dart
/// Purpose: Success dialog — knowledge_hub_module core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


Widget successDialog(BuildContext context, bool lightMode) {
  return Material(
    color: AppColors.transparent,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: lightMode ? AppColors.white : AppColors.background,
      ),
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
            height: 60.h,
            width: 60.w,
          ),
          SizedBox(height: 33.h),
          Text(
            S.of(context).successful,
            style: StyleText.fontSize20Weight500.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            S.of(context).submit_success_message,
            style: StyleText.fontSize10Weight400.copyWith(
              color: lightMode
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
