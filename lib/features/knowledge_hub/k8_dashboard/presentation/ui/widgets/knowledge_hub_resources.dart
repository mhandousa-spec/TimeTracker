/// Module: knowledge_hub / presentation / s8_dashboard / widgets/knowledge_hub_resources.dart
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_resources.dart
/// Purpose: Knowledge hub resources — Dashboard (S8) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

Widget knowledgeHubResources(
    BuildContext context, {
      required bool lightMode,
      required Map<String, int> extensionData,
    }) {
  // Check if we have data
  if (extensionData.isEmpty) {
    return _buildEmptyState(context, lightMode);
  }

  // Convert extension data for BarChartCard
  final List<String> extensions = extensionData.keys.toList();
  final List<double> counts = extensionData.values.map((e) => e.toDouble()).toList();

  // Calculate max value with padding
  final maxValue = counts.isNotEmpty
      ? counts.reduce((a, b) => a > b ? a : b) + 2
      : 10.0;

  // Format extension names for display (uppercase)
  final List<String> displayNames = extensions.map((ext) {
    return ext.toUpperCase();
  }).toList();

  return BarChartCard(
           title: S.of(context)!.knowledgeHubResources,
           dotIcon: 'assets/icons_assets/knowledge_hub_assets/Knowledge Hub Resources.svg',
           dotColor: AppColors.primary,
           bars: List.generate(
             displayNames.length,
             (i) => ChartData(
               label: displayNames[i],
               value: counts[i],
             ),
           ),
           maxY: maxValue,
           chartHeight: 300,
           barWidth: 20.sp,
           barColor: AppColors.primary,
         );
}

/// Build empty state when no data available
Widget _buildEmptyState(BuildContext context, bool lightMode) {
  return Container(
    padding: EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      color: lightMode ? AppColors.white : AppColors.chatBackground,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 26.sp,
              height: 26.sp,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomSvgImage(
                  assetPath: 'assets/icons_assets/knowledge_hub_assets/Knowledge Hub Resources.svg',
                  height: 16.sp,
                  width: 16.sp,
                  color: AppColors.textButton,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                S.of(context)!.knowledgeHubResources,
                style: StyleText.fontSize14Weight600.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        // Empty message
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text(
              S.of(context)!.noResourcesDataAvailable,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.colorGrey,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
