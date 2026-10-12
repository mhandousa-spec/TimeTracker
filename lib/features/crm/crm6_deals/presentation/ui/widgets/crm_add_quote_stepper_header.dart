// ****************** FILE INFO ******************
// File Name: crm_add_quote_stepper_header.dart
// Purpose: 4-step wizard navigation header for Add Quote matching exact Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmAddQuoteStepperHeader extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const CrmAddQuoteStepperHeader({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  static const List<Map<String, String>> _steps = <Map<String, String>>[
    <String, String>{
      'number': '1',
      'titleEn': 'Quote Details',
      'titleAr': 'تفاصيل عرض الأسعار',
      'subtitleEn': 'Choose Details',
      'subtitleAr': 'اختر التفاصيل',
    },
    <String, String>{
      'number': '2',
      'titleEn': 'Preview Products',
      'titleAr': 'معاينة المنتجات',
      'subtitleEn': 'View products',
      'subtitleAr': 'عرض المنتجات',
    },
    <String, String>{
      'number': '3',
      'titleEn': 'Commercial Terms',
      'titleAr': 'الشروط التجارية',
      'subtitleEn': 'View Commercial Terms',
      'subtitleAr': 'عرض الشروط التجارية',
    },
    <String, String>{
      'number': '4',
      'titleEn': 'Review & PDF',
      'titleAr': 'المراجعة وملف PDF',
      'subtitleEn': 'PDF View',
      'subtitleAr': 'معاينة PDF',
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
      borderRadius: BorderRadius.circular(8.sp),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.sp, horizontal: 6.sp),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Step Number Circle
            Container(
              width: 36.sp,
              height: 36.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : AppColors.white,
                border: Border.all(
                  color: isActive ? AppColors.primary : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                stepInfo['number'] ?? '$stepNumber',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.black : const Color(0xFF6B7280),
                ),
              ),
            ),

            SizedBox(width: 10.sp),

            // Step Titles
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? AppColors.black : const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 2.sp),
                Text(
                  subtitle,
                  style: StyleText.fontSize12Weight400.copyWith(
                    fontSize: 11.sp,
                    color: const Color(0xFF9CA3AF),
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
