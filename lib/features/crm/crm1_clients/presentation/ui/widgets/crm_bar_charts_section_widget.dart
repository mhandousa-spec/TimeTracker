// ****************** FILE INFO ******************
// File Name: crm_bar_charts_section_widget.dart
// Purpose: Status grouped chart section for the CRM clients dashboard
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_chart_card.dart';
import 'package:knowticed_plus/core/custom/29-custom_grouped_bar_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_dashboard_view_data.dart';

class CrmBarChartsSectionWidget extends StatelessWidget {
  final CrmDashboardGroupedChartData clientStatusChart;

  const CrmBarChartsSectionWidget({
    super.key,
    required this.clientStatusChart,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasData = clientStatusChart.groupValues.any(
      (List<double> values) => values.any((double value) => value > 0),
    );
    if (!hasData || clientStatusChart.groupLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    return GroupedBarChartCard(
      title: clientStatusChart.title,
      dotColor: AppColors.primary,
      dotIcon: AppAssets.crmStatus,
      series: <ChartData>[
        ChartData(
          label: clientStatusChart.seriesLabels[0],
          value: 0,
          color: AppColors.green,
        ),
        ChartData(
          label: clientStatusChart.seriesLabels[1],
          value: 0,
          color: AppColors.orange,
        ),
        ChartData(
          label: clientStatusChart.seriesLabels[2],
          value: 0,
          color: AppColors.blue,
        ),
        ChartData(
          label: clientStatusChart.seriesLabels[3],
          value: 0,
          color: AppColors.grey,
        ),
      ],
      groups: List<GroupedBarData>.generate(
        clientStatusChart.groupLabels.length,
        (int index) => GroupedBarData(
          label: clientStatusChart.groupLabels[index],
          values: clientStatusChart.groupValues[index],
        ),
      ),
    );
  }
}
