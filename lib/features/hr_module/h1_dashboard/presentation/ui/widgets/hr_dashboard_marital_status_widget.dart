// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_marital_status_widget.dart
// Purpose: Displays the employee marital-status distribution chart.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/24-custom_chart_card.dart';
import '../../../../../../core/custom/27-custom_donut_chart_card.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_distribution_item.dart';
import '../../../../h3_add_employee/utils/add_employee_marital_status_option.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';

class HRDashboardMaritalStatusWidget extends StatelessWidget {
  const HRDashboardMaritalStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();
    final data = state.demographicsData;
    final localization = S.of(context);
    return DonutChartCard(
      title: FormatHelper.capitalize(localization.maritalStatus),
      dotIcon: HRAssets.dashboardMaritalStatus,
      centerValue: data.filteredEmployeeTotal.toString(),
      centerLabel: FormatHelper.capitalize(localization.total),
      sections: [
        for (final item in data.maritalStatusDistribution)
          _chartData(item, localization),
      ],
    );
  }

  /// Method Name: [_chartData]
  ///
  /// Purpose: Converts an enum-backed marital-status item into chart data.
  ///
  /// Parameters:
  /// - [item]: Marital-status distribution item from the calculator.
  /// - [localization]: Current application localization.
  ///
  /// Returns: A localized and color-configured chart data item.
  ChartData _chartData(
    HrDashboardDistributionItem item,
    S localization,
  ) {
    final status = _statusFromCategory(item.category);
    final label = switch (status) {
      MaritalStatusOption.single => localization.single,
      MaritalStatusOption.married => localization.married,
      MaritalStatusOption.divorced => localization.divorced,
      MaritalStatusOption.widowed => localization.widowed,
      null => item.category,
    };
    final color = switch (status) {
      MaritalStatusOption.single => AppColors.primary,
      MaritalStatusOption.married => AppColors.greyDark,
      MaritalStatusOption.divorced => AppColors.disabledGrey,
      MaritalStatusOption.widowed => AppColors.grey,
      null => AppColors.grey,
    };

    return ChartData(
      label: FormatHelper.capitalize(label),
      value: item.count.toDouble(),
      color: color,
    );
  }

  /// Method Name: [_statusFromCategory]
  ///
  /// Purpose: Resolves a dashboard category to its marital-status enum.
  ///
  /// Parameters:
  /// - [category]: Stored enum category name.
  ///
  /// Returns: The matching marital-status option, or null for an unexpected category.
  MaritalStatusOption? _statusFromCategory(String category) {
    for (final option in MaritalStatusOption.values) {
      if (option.name == category) return option;
    }
    return null;
  }
}
