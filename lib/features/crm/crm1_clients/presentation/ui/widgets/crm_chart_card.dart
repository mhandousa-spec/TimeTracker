// ****************** FILE INFO ******************
// File Name: crm_chart_card.dart
// Purpose: Feature-specific chart card shell and header badge components for CRM dashboard.
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

/// Re-export shared chart data structures for convenience in CRM.
export 'package:knowticed_plus/core/custom/24-custom_chart_card.dart'
    show
        ChartData,
        ChartOrientation,
        ChartLegendRow,
        ChartLegendInline,
        ChartTabPill;

/// White rounded container with the CRM custom chart header:
/// [padded icon badge / dot] Title ........................ [trailing controls]
class CrmChartCard extends StatelessWidget {
  final String title;
  final Color? dotColor;
  final Widget? trailing;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final String? dotIcon;

  const CrmChartCard({
    super.key,
    required this.title,
    required this.child,
    this.dotColor,
    this.trailing,
    this.width,
    this.height,
    this.padding,
    this.dotIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Header marker: a padded icon badge when [dotIcon] is given,
              // otherwise the standard small colored dot.
              if (dotIcon != null)
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  padding: EdgeInsets.all(5.sp),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomSvgImage(
                    assetPath: dotIcon!,
                    width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                )
              else
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: dotColor ?? AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: CardStyles.title(14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}
