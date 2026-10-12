// ****************** FILE INFO ******************
// File Name: crm_merge_success_view.dart
// Purpose: Step 4 Success view with audit details, success confirmation, and Undo card matching Figma screenshot 5
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmMergeSuccessView extends StatelessWidget {
  final VoidCallback onBackToDuplicates;
  final VoidCallback onViewClient;
  final VoidCallback? onUndo;

  const CrmMergeSuccessView({
    super.key,
    required this.onBackToDuplicates,
    required this.onViewClient,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 1. Top Audit Card (By, Date, Time)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Row 1: Merged By + Avatar + Name
              Row(
                children: <Widget>[
                  Text(
                    FormatHelper.localizedString(
                      englishName: 'By',
                      arabicName: 'بواسطة',
                    ),
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Container(
                    width: 24.sp,
                    height: 24.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: CustomSvgImage(
                      assetPath: AppAssets.crmPerson,
                      width: 14.sp,
                      height: 14.sp,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    'Aya Ahmed',
                    style: StyleText.fontSize12Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.sp),

              // Row 2: Date & Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        FormatHelper.localizedString(
                          englishName: 'Date: ',
                          arabicName: 'التاريخ: ',
                        ),
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      Text(
                        '7 Jun 2026',
                        style: StyleText.fontSize12Weight500.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        FormatHelper.localizedString(
                          englishName: 'Time: ',
                          arabicName: 'الوقت: ',
                        ),
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      Text(
                        '11/11/2026',
                        style: StyleText.fontSize12Weight500.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 120.sp),

        // 2. Center Success Confirmation Message
        Center(
          child: Text(
            FormatHelper.localizedString(
              englishName: 'Merge Completed Successfully!',
              arabicName: 'تمت عملية الدمج بنجاح!',
            ),
            style: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 60.sp),

        // 3. Bottom Undo Available Banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left: Curved Yellow Undo Icon + Details
              Row(
                children: <Widget>[
                  CustomSvgImage(
                    assetPath: AppAssets.crmUndo,
                    width: 22.sp,
                    height: 22.sp,
                  ),
                  SizedBox(width: 10.sp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        FormatHelper.localizedString(
                          englishName: 'Undo Available',
                          arabicName: 'التراجع متاح',
                        ),
                        style: StyleText.fontSize12Weight400.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.sp),
                      Text(
                        FormatHelper.localizedString(
                          englishName: 'You can undo this merge within 30 days',
                          arabicName:
                              'يمكنك التراجع عن هذا الدمج خلال 30 يوماً',
                        ),
                        style:
                            StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                          color: AppColors.darkGrey,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right: Undo Action Button
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Undo',
                  arabicName: 'تراجع',
                ),
                color: AppColors.primary,
                textColor: AppColors.text,
                function: onUndo ?? onBackToDuplicates,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
