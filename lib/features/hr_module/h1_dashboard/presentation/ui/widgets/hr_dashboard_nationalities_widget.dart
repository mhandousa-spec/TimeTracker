// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_nationalities_widget.dart
// Purpose: Displays the employee nationality distribution chart.
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

class HRDashboardNationalitiesWidget extends StatelessWidget {
  const HRDashboardNationalitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();

    return BarChartCard(
      title: FormatHelper.capitalize(S.of(context).nationalities),
      dotIcon: HRAssets.dashboardNationalities,
      bars: [
        for (final item in state.nationalityDistribution)
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
