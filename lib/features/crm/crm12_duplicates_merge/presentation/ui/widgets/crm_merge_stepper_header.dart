// ****************** FILE INFO ******************
// File Name: crm_merge_stepper_header.dart
// Purpose: 4-Step wizard stepper header widget matching Figma design
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/enums/crm_duplicates_enums.dart';

class CrmMergeStepperHeader extends StatelessWidget {
  final CrmMergeStep currentStep;

  const CrmMergeStepperHeader({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildStepItem(
            stepNumber: 1,
            title: FormatHelper.localizedString(
              englishName: 'Select Duplicates',
              arabicName: 'اختيار المكررات',
            ),
            subtitle: FormatHelper.localizedString(
              englishName: 'Review potential duplicates',
              arabicName: 'مراجعة المكررات المحتملة',
            ),
            stepEnum: CrmMergeStep.selectDuplicates,
          ),
          SizedBox(width: 28.sp),
          _buildStepItem(
            stepNumber: 2,
            title: FormatHelper.localizedString(
              englishName: 'Compare & Merge',
              arabicName: 'المقارنة والدمج',
            ),
            subtitle: FormatHelper.localizedString(
              englishName: 'Select Master and merge fields',
              arabicName: 'تحديد السجل الرئيسي ودمج الحقول',
            ),
            stepEnum: CrmMergeStep.compareAndMerge,
          ),
          SizedBox(width: 28.sp),
          _buildStepItem(
            stepNumber: 3,
            title: FormatHelper.localizedString(
              englishName: 'Review & Confirm',
              arabicName: 'المراجعة والتأكيد',
            ),
            subtitle: FormatHelper.localizedString(
              englishName: 'Preview Changes',
              arabicName: 'معاينة التغييرات',
            ),
            stepEnum: CrmMergeStep.reviewAndConfirm,
          ),
          SizedBox(width: 28.sp),
          _buildStepItem(
            stepNumber: 4,
            title: FormatHelper.localizedString(
              englishName: 'Completed',
              arabicName: 'مكتمل',
            ),
            subtitle: FormatHelper.localizedString(
              englishName: 'Merge Completed',
              arabicName: 'تم الدمج بنجاح',
            ),
            stepEnum: CrmMergeStep.completed,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String subtitle,
    required CrmMergeStep stepEnum,
  }) {
    final bool isCompleted = stepEnum.index < currentStep.index;
    final bool isCurrent = stepEnum == currentStep;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Step Circle
        Container(
          width: 36.sp,
          height: 36.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.green
                : (isCurrent ? AppColors.primary : AppColors.card),
            border: isCompleted || isCurrent
                ? null
                : Border.all(color: AppColors.darkGrey, width: 1.sp),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check, color: AppColors.white, size: 20.sp)
              : Text(
                  stepNumber.toString(),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: isCurrent ? AppColors.text : AppColors.darkGrey,
                    fontWeight: FontWeight.bold,
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
                fontWeight: isCurrent || isCompleted
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: isCurrent || isCompleted
                    ? AppColors.text
                    : AppColors.darkGrey,
              ),
            ),
            Text(
              subtitle,
              style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
