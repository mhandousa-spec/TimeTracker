// ****************** FILE INFO ******************
// File Name: crm_deal_cancel_activity_dialog.dart
// Purpose: Confirmation dialog when Cancel is selected from Activity status dropdown matching Image 1
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmDealCancelActivityDialog extends StatelessWidget {
  final VoidCallback? onReschedule;
  final VoidCallback? onConfirmCancel;

  const CrmDealCancelActivityDialog({
    super.key,
    this.onReschedule,
    this.onConfirmCancel,
  });

  static Future<void> show({
    required BuildContext context,
    VoidCallback? onReschedule,
    VoidCallback? onConfirmCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => CrmDealCancelActivityDialog(
        onReschedule: onReschedule,
        onConfirmCancel: onConfirmCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: AppColors.white,
      child: Container(
        width: 400.sp,
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Yellow circle icon
            Container(
              width: 52.sp,
              height: 52.sp,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFD97706),
                size: 30.sp,
              ),
            ),
            SizedBox(height: 14.sp),

            // Title: Cancel Activity
            Text(
              FormatHelper.localizedString(
                englishName: 'Cancel Activity',
                arabicName: 'إلغاء النشاط',
              ),
              style: StyleText.fontSize18Weight600.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.sp),

            // Subtitle: Are you sure you want to cancel this activity?
            Text(
              FormatHelper.localizedString(
                englishName: 'Are you sure you want to cancel this activity?',
                arabicName: 'هل أنت متأكد من رغبتك في إلغاء هذا النشاط؟',
              ),
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 24.sp),

            // Action Buttons: Reschedule (Grey) & Cancel (Yellow)
            Row(
              children: <Widget>[
                // Reschedule Button
                Expanded(
                  child: customButton(
                    title: FormatHelper.localizedString(
                      englishName: 'Reschedule',
                      arabicName: 'إعادة جدولة',
                    ),
                    color: const Color(0xFFF1F5F9),
                    textColor: AppColors.black,
                    function: () {
                      Navigator.pop(context);
                      onReschedule?.call();
                    },
                  ),
                ),
                SizedBox(width: 12.sp),

                // Cancel Button
                Expanded(
                  child: customButton(
                    title: FormatHelper.localizedString(
                      englishName: 'Cancel',
                      arabicName: 'إلغاء النشاط',
                    ),
                    color: AppColors.primary,
                    textColor: AppColors.black,
                    function: () {
                      Navigator.pop(context);
                      onConfirmCancel?.call();
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
}
