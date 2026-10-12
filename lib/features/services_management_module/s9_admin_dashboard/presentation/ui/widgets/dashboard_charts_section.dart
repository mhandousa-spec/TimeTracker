// ******************* FILE INFO *******************
// File Name: dashboard_charts_section.dart
// Description: Charts section for Admin Dashboard (services offered, monthly counts, comparison)
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/comparison_chart.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/admin_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/DashBoard_widget.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/build_number_services.dart';


class DashboardChartsSection extends StatelessWidget {
  final DashboardAdminState state;

  const DashboardChartsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      children: [
        // ── Services Offered Bar Chart ─────────────────────────────────────
        _buildServicesOfferedWidget(context, lightMode, isArabic),

        SizedBox(height: 15.sp),

        // ── Monthly Comparison Chart ───────────────────────────────────────
        MonthlyComparisonChart(
          orientation: ChartOrientation.vertical,
          lightMode: lightMode,
        ),

        SizedBox(height: 15.sp),

        // ── Number of Services / Hours Card ───────────────────────────────
        NumberOfServicesCardDashBoard(
          monthCounts: state.monthCounts,
          monthHours: state.monthHours,
          isLoading: state.isLoading,
          showServiceCount: state.showServiceCount,
          // ✅ FIX (bug report p8/p12): both callbacks were empty closures, so
          // tapping "Total Hours" did nothing at all — the chart never
          // switched datasets. Wire them to the cubit's toggleServiceCount,
          // which flips the flag and loads the matching series.
          onToggleServiceCount: () =>
              context.read<DashboardAdminCubit>().toggleServiceCount(true),
          onToggleToHours: () =>
              context.read<DashboardAdminCubit>().toggleServiceCount(false),
        ),
      ],
    );
  }

  Widget _buildServicesOfferedWidget(
      BuildContext context,
      bool lightMode,
      bool isArabic,
      ) {
    final labels = <String>[];
    final values = <double>[];

    for (int i = 0; i < state.serviceNames.length; i++) {
      final label = isArabic &&
          i < state.serviceNamesArabic.length &&
          state.serviceNamesArabic[i].isNotEmpty
          ? state.serviceNamesArabic[i]
          : state.serviceNames[i];
      labels.add(label);
      values.add(state.monthCountss[i] ?? 0.0);
    }

    return CustomHorizontalBarChartWidget(
      title: S.of(context).servicesOffered,
      iconAsset: "assets/icons_assets/services_assets/headset_support.svg",
      labels: labels,
      values: values,
      lightMode: lightMode,
      height: 310,
      backgroundColor: AppColors.card,
      barColor: AppColors.primary,
    );
  }
}
