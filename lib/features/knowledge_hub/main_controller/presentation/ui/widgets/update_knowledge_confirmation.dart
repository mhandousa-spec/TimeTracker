/// ************************* FILE INFO *************************** ///
/// File Name: update_knowledge_confirmation.dart
/// Purpose: The old yes/no resubmit dialog.
///
/// SUPERSEDED 22/9/2026 and no longer called. The resubmit flow moved to
/// `CustomDialogManager.showDialogFlow` (see `_handleResubmitWithReason` in
/// creating_knowledge_hub.actions.dart) so that it can ask for a reason
/// between the confirmation and the success message, which this widget has no
/// step for. Kept rather than deleted only so nothing in flight breaks on it;
/// delete it once that is confirmed.

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget updateKnowledgeConfirmation(
  BuildContext context, {
  required bool isUploading,
  required Future<void> Function() submitForApproval,
}) {
  var lightMode = Theme.of(context).brightness == Brightness.light;
  final isMobile = ContextExtension(context).isPhone;
  return Material(
    color: Colors.transparent,
    child: Container(
      width: isMobile ? double.infinity : 411.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      padding: EdgeInsets.all(20.r),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json',
            height: 70.h,
            width: 70.w,
          ),
          SizedBox(height: 20.h),
          Text(
            S.of(context)!.requestingResubmit,
            style: StyleText.fontSize20Weight500,
          ),
          SizedBox(height: 18.h),
          Text(
            S.of(context)!.areYouSureYouWantToResubmit,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 15.h),

          // Show loading indicator when uploading
          if (isUploading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  // CHANGED 22/9/2026 — the app-wide spinner; see the note in
                  // creating_knowledge_confirmation_dialog.dart.
                  CircleProgressMaster(),
                  SizedBox(height: 10.h),
                  Text(
                    S.of(context)!.uploading,
                    style: StyleText.fontSize14Weight500.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: customButton(
                    title: S.of(context).no,
                    height: 38.h,
                    width: 135.w,
                    textStyle: StyleText.fontSize16Weight400.copyWith(
                     color:  lightMode ? Colors.black : Colors.white,
                    ),
                    color: lightMode ? Colors.grey[400] : Colors.grey[700],
                    function: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(width: 45.w),
                Expanded(
                  child: customButton(
                    height: 38.h,
                    width: 135.w,
                    title: S.of(context).yes,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight400.copyWith(
                      color: AppColors.textButton
  ),
                    function: () async {
                      await submitForApproval();
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
