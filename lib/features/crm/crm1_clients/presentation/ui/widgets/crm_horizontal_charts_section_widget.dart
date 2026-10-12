// ****************** FILE INFO ******************
// File Name: crm_horizontal_charts_section_widget.dart
// Purpose: Horizontal distribution chart section for the CRM clients dashboard
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_chart_card.dart';
import 'package:knowticed_plus/core/custom/28-custom_horizontal_bar_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_dashboard_view_data.dart';

class CrmHorizontalChartsSectionWidget extends StatelessWidget {
  final List<CrmDashboardHorizontalChartData> charts;

  const CrmHorizontalChartsSectionWidget({
    super.key,
    required this.charts,
  });

  @override
  Widget build(BuildContext context) {
    final List<CrmDashboardHorizontalChartData> visibleCharts = charts
        .where(
          (CrmDashboardHorizontalChartData chart) => chart.bars.any(
            (CrmDashboardSlice bar) => bar.value > 0,
          ),
        )
        .toList();

    if (visibleCharts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: visibleCharts.map((CrmDashboardHorizontalChartData chart) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.sp),
          child: HorizontalBarChartCard(
            title: chart.title,
            dotColor: AppColors.primary,
            dotIcon: _iconForTitle(chart.title),
            barColor: AppColors.primary,
            bars: chart.bars
                .map(
                  (CrmDashboardSlice bar) => ChartData(
                    label: bar.label,
                    value: bar.value,
                    color: AppColors.primary,
                  ),
                )
                .toList(),
          ),
        );
      }).toList(),
    );
  }

  String _iconForTitle(String title) {
    switch (title) {
      case 'Industry Distribution':
        return AppAssets.crmIndustryField;
      case 'Government Sector':
        return AppAssets.crmGovernment;
      case 'Company Size':
        return AppAssets.crmCompanySizeField;
      default:
        return AppAssets.crmClients;
    }
  }
}
