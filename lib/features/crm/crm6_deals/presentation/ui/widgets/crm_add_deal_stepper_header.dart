// ****************** FILE INFO ******************
// File Name: crm_add_deal_stepper_header.dart
// Purpose: 4-step wizard navigation header for Add Deal matching exact Figma design
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmAddDealStepperHeader extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const CrmAddDealStepperHeader({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  static const List<Map<String, String>> _steps = <Map<String, String>>[
    <String, String>{
      'number': '1',
      'titleEn': 'Deal Details',
      'titleAr': 'تفاصيل الصفقة',
      'subtitleEn': 'Details',
      'subtitleAr': 'التفاصيل',
    },
    <String, String>{
      'number': '2',
      'titleEn': 'Add Products & Services',
      'titleAr': 'إضافة منتجات وخدمات',
      'subtitleEn': 'Add Product & Service',
      'subtitleAr': 'إضافة منتج وخدمة',
    },
    <String, String>{
      'number': '3',
      'titleEn': 'Progress Per Stage',
      'titleAr': 'التقدم حسب المرحلة',
      'subtitleEn': 'Add Progress Setting',
      'subtitleAr': 'إضافة إعداد التقدم',
    },
    <String, String>{
      'number': '4',
      'titleEn': 'Review & Confirm',
      'titleAr': 'مراجعة وتأكيد',
      'subtitleEn': 'Confirm',
      'subtitleAr': 'تأكيد',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = constraints.maxWidth < 750;

        if (isCompact) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < _steps.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(width: 20.sp),
                  _buildStepItem(context, i + 1, _steps[i]),
                ],
              ],
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (int i = 0; i < _steps.length; i++)
              _buildStepItem(context, i + 1, _steps[i]),
          ],
        );
      },
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    int stepNumber,
    Map<String, String> stepInfo,
  ) {
    final bool isActive = currentStep == stepNumber;

    final String title = FormatHelper.localizedString(
      englishName: stepInfo['titleEn'] ?? '',
      arabicName: stepInfo['titleAr'] ?? '',
    );
    final String subtitle = FormatHelper.localizedString(
      englishName: stepInfo['subtitleEn'] ?? '',
      arabicName: stepInfo['subtitleAr'] ?? '',
    );

    return InkWell(
      onTap: onStepTapped != null ? () => onStepTapped!(stepNumber) : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.sp, horizontal: 4.sp),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // ── Circle Badge ──────────────────────────────────────────────────
            Container(
              width: 38.sp,
              height: 38.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                      isActive ? Colors.transparent : const Color(0xFFC4C4C4),
                  width: 1.5.sp,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$stepNumber',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: isActive
                      ? const Color(0xFF222222)
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),

            SizedBox(width: 12.sp),

            // ── Text Column ───────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.sp),
                Text(
                  subtitle,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
