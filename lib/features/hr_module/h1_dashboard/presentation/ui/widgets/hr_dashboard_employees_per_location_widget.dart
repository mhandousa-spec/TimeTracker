// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_employees_per_location_widget.dart
// Purpose: Displays employee counts grouped by work location.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/24-custom_chart_card.dart';
import '../../../../../../core/custom/26-custom_bar_chart_card.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';

class HRDashboardEmployeesPerLocationWidget extends StatelessWidget {
  const HRDashboardEmployeesPerLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();

    return BarChartCard(
      title: FormatHelper.capitalize(S.of(context).employeesPerLocation),
      dotIcon: HRAssets.dashboardEmployeesPerLocation,
      bars: [
        for (final item in state.employeesPerLocation)
          ChartData(
            label: FormatHelper.capitalize(item.category),
            value: item.count.toDouble(),
            color: AppColors.primary,
          ),
      ],
      barColor: AppColors.primary,
    );
  }
}
