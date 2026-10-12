// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_range_summary_widget.dart
// Purpose: Renders the shared Age and Experience range-summary card.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_range_summary.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Renders a prepared HR dashboard range summary.
class HRDashboardRangeSummaryWidget extends StatelessWidget {
  const HRDashboardRangeSummaryWidget({
    super.key,
    required this.title,
    required this.svgImage,
    required this.summary,
    required this.emptyMessage,
  });

  final String title;
  final String svgImage;
  final HrDashboardRangeSummary summary;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final items = summary.hasData
        ? [
            _item(localization.minimum, summary.minimum!),
            _item(localization.average, summary.average!),
            _item(localization.maximum, summary.maximum!),
          ]
        : [_item(emptyMessage, null)];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.sp),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: CustomSvgImage(
                  assetPath: svgImage,
                  width: 10.sp,
                  height: 10.sp,
                  color: AppColors.textButton,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: StyleText.fontSize20Weight500,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final item in items) _RangeSummaryItem(item: item),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Method Name: [_item]
  ///
  /// Purpose: Creates one localized year-valued statistics tile.
  ///
  /// Parameters:
  /// - [label]: Localized range label.
  /// - [value]: Completed whole-year value, or null for an empty tile.
  ///
  /// Returns: A configured range-summary item.
  _RangeItem _item(String label, int? value) => _RangeItem(
        label: label,
        value: value == null ? '-' : '$value',
      );
}

class _RangeItem {
  const _RangeItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _RangeSummaryItem extends StatelessWidget {
  const _RangeSummaryItem({required this.item});

  final _RangeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(item.label, style: StyleText.fontSize23Weight500.copyWith(color: AppColors.darkGrey)),
          SizedBox(height: 12.h),
          Text(item.value, style: StyleText.fontSize20Weight500),
        ],
      ),
    );
  }
}
