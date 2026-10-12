// ****************** FILE INFO ******************
// File Name: crm_duplicates_kpi_bar.dart
// Purpose: Metric count bar displaying total, pending, and merged counts matching Figma
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmDuplicatesKpiBar extends StatelessWidget {
  final int totalCount;
  final int activePendingCount;
  final int mergedCount;

  const CrmDuplicatesKpiBar({
    super.key,
    required this.totalCount,
    required this.activePendingCount,
    required this.mergedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildKpiItem(
          count: totalCount,
          label: FormatHelper.localizedString(
            englishName: 'All',
            arabicName: 'الكل',
          ),
          color: AppColors.primary,
          textColor: AppColors.text,
          labelColor: AppColors.text,
        ),
        SizedBox(width: 16.sp),
        _buildKpiItem(
          count: activePendingCount,
          label: FormatHelper.localizedString(
            englishName: 'Pending',
            arabicName: 'معلق',
          ),
          color: AppColors.card,
          textColor: AppColors.darkGrey,
          labelColor: AppColors.green,
        ),
        SizedBox(width: 16.sp),
        _buildKpiItem(
          count: mergedCount,
          label: FormatHelper.localizedString(
            englishName: 'Merged',
            arabicName: 'مدمج',
          ),
          color: AppColors.card,
          textColor: AppColors.darkGrey,
          labelColor: AppColors.orange,
        ),
      ],
    );
  }

  Widget _buildKpiItem({
    required int count,
    required String label,
    required Color color,
    required Color textColor,
    required Color labelColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 45.sp,
          height: 45.sp,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.center,
          child: Text(
            count.toString(),
            style: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: textColor,
            ),
          ),
        ),
        SizedBox(width: 8.sp),
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            color: labelColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
