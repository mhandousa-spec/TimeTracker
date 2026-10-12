/// Module: services_management_module
/// Description: Dialog helpers (validation-error / confirm-activate /
///              success) for the bulk-upload request-preview screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: AppColors, StyleText, lottie
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from upload_details.dart
///     (fix item 5 — page LOC reduction).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class UploadDetailsDialogs {
  const UploadDetailsDialogs._();

  static void showMustCorrectErrors(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.all(20.sp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                width: 90.sp, height: 90.sp, fit: BoxFit.contain),
            SizedBox(height: 20.sp),
            Text(
              S.of(context).mustCorrectErrors,
              style: StyleText.fontSize18Weight500
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showConfirmActivate(
    BuildContext context, {
    required bool lightMode,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (confirmCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.all(20.sp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
                width: 90.sp, height: 90.sp, fit: BoxFit.contain),
            SizedBox(height: 15.sp),
            Text(
              S.of(context).activatingRequests,
              style: StyleText.fontSize20Weight500
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.sp),
            Text(
              S.of(context).areYouSureActivateRequests,
              style: StyleText.fontSize18Weight500
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customButton(
                  title: S.of(confirmCtx).no,
                  function: () => Navigator.pop(confirmCtx),
                  textStyle: StyleText.fontSize18Weight500
                      .copyWith(color: AppColors.onSecondaryAction),
                  width: 135.sp,
                  height: 38.sp,
                  radius: 4.r,
                  color: AppColors.secondaryAction,
                ),
                SizedBox(width: 28.sp),
                customButton(
                  title: S.of(confirmCtx).yes,
                  function: () {
                    Navigator.pop(confirmCtx);
                    onConfirm();
                  },
                  textStyle: StyleText.fontSize18Weight500
                      .copyWith(color: AppColors.textButton),
                  width: 135.sp,
                  height: 38.sp,
                  radius: 4.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showActivatedSuccess(
    BuildContext context, {
    required VoidCallback onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (successCtx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(successCtx)) {
            Navigator.pop(successCtx);
          }
          onDismiss();
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(20.sp),
          content: SizedBox(
            width: 400.sp,
            height: 180.sp,
            child: Column(
              children: [
                Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                    width: 90.sp, height: 90.sp, fit: BoxFit.contain),
                SizedBox(height: 15.sp),
                Text(S.of(context).activated,
                    style: StyleText.fontSize20Weight500
                        .copyWith(color: AppColors.secondaryText),
                    textAlign: TextAlign.center),
                SizedBox(height: 18.sp),
                Text(S.of(context).servicesRequestsActivatedSuccessfully,
                    style: StyleText.fontSize18Weight500
                        .copyWith(color: AppColors.secondaryText),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}
