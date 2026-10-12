/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/knowledge_hub_dialog_helper.dart
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_dialog_helper.dart
/// Purpose: Reusable dialog helpers for the create-knowledge flow.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';


import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/helper/responsive_helper.dart';

class KnowledgeHubDialogHelper {
  static void showMessageDialog(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    String? title,
    String? lottiePath = 'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    BuildContext? dialogCtx;

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx;
        return _buildMessageDialog(
          ctx,
          message,
          backgroundColor,
          title,
          lottiePath,
        );
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    _scheduleDialogClose(dialogCtx, autoCloseDuration);
  }

  static Widget _buildMessageDialog(
    BuildContext ctx,
    String message,
    Color? backgroundColor,
    String? title,
    String? lottiePath,
  ) {
    final isDarkMode = Theme.of(ctx).brightness == Brightness.dark;

    return Dialog(
      backgroundColor:
          backgroundColor ??
          (isDarkMode ? AppColors.chatBackground : AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lottiePath != null) ...[
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: false,
                ),
                SizedBox(height: 15.sp),
              ],
              if (title != null) ...[
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: isDarkMode
                        ? AppColors.grey
                        : AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 15.sp),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: isDarkMode
                      ? AppColors.grey
                      : AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showSuccessDialog(
    BuildContext context, {
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    BuildContext? dialogCtx;

    showDialog(
      context: context,
      builder: (ctx) {
        dialogCtx = ctx;
        return Center(child: _buildSuccessDialog(ctx));
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    _scheduleDialogClose(dialogCtx, autoCloseDuration);
  }

  static Widget _buildSuccessDialog(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 411.w,
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
              style: StyleText.fontSize14Weight500.copyWith(
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

  static void _scheduleDialogClose(BuildContext? dialogCtx, Duration duration) {
    Future.delayed(duration).then((_) {
      if (dialogCtx != null) {
        final nav = Navigator.of(dialogCtx, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
        }
      }
    });
  }
}
