// ****************** FILE INFO ******************
// File Name: crm_client_overview_bar_charts.dart
// Purpose: Bar charts & progress metrics for the CRM Client Profile Overview tab
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/28-custom_horizontal_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmClientOverviewBarCharts extends StatelessWidget {
  const CrmClientOverviewBarCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Relationship Monthly Bar Chart
        _buildRelationshipBarChart(context),
        SizedBox(height: 16.sp),

        // 2. Deals Monthly Bar Chart
        _buildDealsBarChart(context),
        SizedBox(height: 16.sp),

        // 3. Deals Progress Horizontal Bar Chart
        _buildDealsProgressHorizontalChart(context),
        SizedBox(height: 16.sp),

        // 4. Activities Monthly Bar Chart
        _buildActivitiesBarChart(context),
        SizedBox(height: 16.sp),

        // 5. Revenue Monthly Bar Chart
        _buildRevenueBarChart(context),
      ],
    );
  }

  Widget _buildRelationshipBarChart(BuildContext context) {
    return BarChartCard(
      title: FormatHelper.localizedString(
        englishName: 'Relationship',
        arabicName: 'العلاقات',
      ),
      dotColor: AppColors.primary,
      dotIcon: AppAssets.crmRelationship,
      trailing: _buildChartTrailingControls(['Baseline', 'Sort']),
      chartHeight: 180,
      barWidth: 20,
      barColor: AppColors.primary,
      bars: const [
        ChartData(label: 'Jan', value: 250),
        ChartData(label: 'Feb', value: 430),
        ChartData(label: 'Mar', value: 380),
        ChartData(label: 'Apr', value: 180),
        ChartData(label: 'May', value: 35),
        ChartData(label: 'Jun', value: 80),
      ],
    );
  }

  Widget _buildDealsBarChart(BuildContext context) {
    return BarChartCard(
      title: FormatHelper.localizedString(
        englishName: 'Deals',
        arabicName: 'الصفقات',
      ),
      dotColor: AppColors.primary,
      dotIcon: AppAssets.crmDeal,
      trailing: _buildChartTrailingControls(['Baseline', 'Sort']),
      chartHeight: 180,
      barWidth: 20,
      barColor: AppColors.primary,
      bars: const [
        ChartData(label: 'Jan', value: 250),
        ChartData(label: 'Feb', value: 430),
        ChartData(label: 'Mar', value: 380),
        ChartData(label: 'Apr', value: 180),
        ChartData(label: 'May', value: 35),
        ChartData(label: 'Jun', value: 80),
      ],
    );
  }

  Widget _buildDealsProgressHorizontalChart(BuildContext context) {
    return HorizontalBarChartCard(
      title: FormatHelper.localizedString(
        englishName: 'Deals Progress',
        arabicName: 'تقدم الصفقات',
      ),
      dotColor: AppColors.primary,
      dotIcon: AppAssets.crmDeal,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvgImage(
            assetPath: AppAssets.sort,
            width: 14.sp,
            height: 14.sp,
            color: AppColors.primary,
          ),
        ],
      ),
      maxX: 100,
      barHeight: 12,
      barColor: AppColors.primary,
      showValues: true,
      divisions: 4,
      bars: const [
        ChartData(label: 'Healthcare', value: 76),
        ChartData(label: 'Education', value: 45),
        ChartData(label: 'Finance', value: 25),
        ChartData(label: 'Energy', value: 5),
      ],
    );
  }

  Widget _buildActivitiesBarChart(BuildContext context) {
    return BarChartCard(
      title: FormatHelper.localizedString(
        englishName: 'Activities',
        arabicName: 'الأنشطة',
      ),
      dotColor: AppColors.primary,
      dotIcon: AppAssets.calendar,
      trailing: _buildChartTrailingControls(['Baseline', 'Sort', 'Category']),
      chartHeight: 180,
      barWidth: 20,
      barColor: AppColors.primary,
      bars: const [
        ChartData(label: 'Jan', value: 250),
        ChartData(label: 'Feb', value: 430),
        ChartData(label: 'Mar', value: 380),
        ChartData(label: 'Apr', value: 180),
        ChartData(label: 'May', value: 35),
        ChartData(label: 'Jun', value: 80),
      ],
    );
  }

  Widget _buildRevenueBarChart(BuildContext context) {
    return BarChartCard(
      title: FormatHelper.localizedString(
        englishName: 'Revenue',
        arabicName: 'الإيرادات',
      ),
      dotColor: AppColors.primary,
      dotIcon: AppAssets.crmPrice,
      trailing: _buildChartTrailingControls(['Baseline', 'Sort']),
      chartHeight: 180,
      barWidth: 20,
      barColor: AppColors.primary,
      bars: const [
        ChartData(label: 'Jan', value: 250),
        ChartData(label: 'Feb', value: 430),
        ChartData(label: 'Mar', value: 380),
        ChartData(label: 'Apr', value: 180),
        ChartData(label: 'May', value: 35),
        ChartData(label: 'Jun', value: 80),
      ],
    );
  }

  Widget _buildChartTrailingControls(List<String> controls) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < controls.length; i++) ...[
          if (i > 0) SizedBox(width: 8.sp),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4.sp),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controls[i],
                  style: StyleText.fontSize12Weight400.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
                if (controls[i] == 'Category') ...[
                  SizedBox(width: 4.sp),
                  CustomSvgImage(
                    assetPath: AppAssets.arrowDown,
                    width: 10.sp,
                    height: 10.sp,
                    color: AppColors.darkGrey,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
