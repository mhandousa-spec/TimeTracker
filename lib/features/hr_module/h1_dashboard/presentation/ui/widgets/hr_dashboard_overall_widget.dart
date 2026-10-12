// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_overall_widget.dart
// Purpose: Displays overall HR dashboard statistics.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/25-custom_overall_stats_card.dart';
import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../generated/l10n.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';

class HRDashboardOverallWidget extends StatelessWidget {
  const HRDashboardOverallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();
    final data = state.overallData;
    if (!data.hasData) return const SizedBox.shrink();

    final localization = S.of(context);
    return OverallStatsCard(
      title: localization.overall,
      items: [
        _statItem(
          label: localization.totalEmployees,
          value: data.totalEmployees,
          assetPath: HRAssets.dashboardTotalEmployees,
        ),
        _statItem(
          label: localization.onboardingEmployees,
          value: data.onboardingEmployees,
          assetPath: HRAssets.dashboardOnboardingEmployees,
        ),
        _statItem(
          label: localization.scheduledLeave,
          value: data.scheduledLeave,
          assetPath: HRAssets.dashboardScheduledLeave,
        ),
        _statItem(
          label: localization.totalDepartments,
          value: data.totalDepartments,
          assetPath: HRAssets.dashboardDepartments,
        ),
        _statItem(
          label: localization.attendanceCompliance,
          value: data.attendanceCompliance,
          assetPath: HRAssets.dashboardAttendanceCompliance,
        ),
      ],
    );
  }

  /// Method Name: [_statItem]
  ///
  /// Purpose: Converts a dashboard metric to a shared statistics-card item.
  ///
  /// Parameters:
  /// - [label]: Localized metric label.
  /// - [value]: Metric value.
  /// - [assetPath]: Optional SVG icon path.
  ///
  /// Returns: A configured [StatItem].
  StatItem _statItem({
    required String label,
    required int value,
    String? assetPath,
  }) {
    return StatItem(
      label: label,
      value: value.toString(),
      icon: assetPath == null ? null : CustomSvgImage(assetPath: assetPath),
    );
  }
}
