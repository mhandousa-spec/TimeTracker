// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_gender_widget.dart
// Purpose: Displays the employee gender distribution chart.
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
import '../../../../h3_add_employee/utils/add_employee_gender_option.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';

class HRDashboardGenderWidget extends StatelessWidget {
  const HRDashboardGenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();
    final data = state.demographicsData;
    final localization = S.of(context);
    return DonutChartCard(
      title: FormatHelper.capitalize(localization.gender),
      dotIcon: HRAssets.dashboardGender,
      centerValue: data.filteredEmployeeTotal.toString(),
      centerLabel: FormatHelper.capitalize(localization.total),
      sections: [
        for (final item in data.genderDistribution)
          _chartData(item, localization),
      ],
    );
  }

  /// Method Name: [_chartData]
  ///
  /// Purpose: Converts an enum-backed gender item into chart data.
  ///
  /// Parameters:
  /// - [item]: Gender distribution item from the dashboard calculator.
  /// - [localization]: Current application localization.
  ///
  /// Returns: A localized and color-configured chart data item.
  ChartData _chartData(HrDashboardDistributionItem item, S localization) {
    final gender = _genderFromCategory(item.category);
    final label = switch (gender) {
      GenderOption.male => localization.male,
      GenderOption.female => localization.female,
      null => item.category,
    };
    final color = switch (gender) {
      GenderOption.male => AppColors.primary,
      GenderOption.female => AppColors.greyDark,
      null => AppColors.grey,
    };

    return ChartData(
      label: FormatHelper.capitalize(label),
      value: item.count.toDouble(),
      color: color,
    );
  }

  /// Method Name: [_genderFromCategory]
  ///
  /// Purpose: Resolves a dashboard category to its gender enum.
  ///
  /// Parameters:
  /// - [category]: Stored enum category name.
  ///
  /// Returns: The matching gender option, or null for an unexpected category.
  GenderOption? _genderFromCategory(String category) {
    for (final option in GenderOption.values) {
      if (option.name == category) return option;
    }
    return null;
  }
}
