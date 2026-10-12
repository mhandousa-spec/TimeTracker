// ****************** FILE INFO ******************
// File Name: crm_compare_limit_dialog.dart
// Purpose: Custom warning dialog shown when quote compare selection reaches 3 quotes limit matching Figma screenshot
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Future<bool?> showCrmCompareLimitDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) => const CrmCompareLimitDialog(),
  );
}

class CrmCompareLimitDialog extends StatelessWidget {
  const CrmCompareLimitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 28.sp),
        child: SizedBox(
          width: 380.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Warning Icon + Title in single row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xFFFF7A00),
                    size: 26.sp,
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    'Limited Reach',
                    style: StyleText.fontSize18Weight600.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.sp),

              // Description
              Text(
                'The maximum quotes for comparing is 3 quotes',
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: 24.sp),

              // Action Buttons Row (Cancel / Ok)
              Row(
                children: <Widget>[
                  Expanded(
                    child: customButton(
                      title: 'Cancel',
                      function: () => Navigator.of(context).pop(false),
                      color: AppColors.white,
                      textColor: AppColors.black,
                      borderColor: AppColors.border,
                      textStyle: StyleText.fontSize16Weight600,
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: customButton(
                      title: 'Ok',
                      function: () => Navigator.of(context).pop(true),
                      color: AppColors.primary,
                      textColor: AppColors.black,
                      textStyle: StyleText.fontSize16Weight600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
