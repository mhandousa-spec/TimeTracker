
/// ******************* FILE INFO *******************
/// File Name: details_pie_charts_section.dart
/// Description: Department + Status pie charts for Dashboard Details
/// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
/// Created by: Amr Mesbah
/// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/request_statistics_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/request_statistics_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';




class DetailsPieChartsSection extends StatelessWidget {
  final DashboardDetailsState state;
  final DashboardDetailsCubit cubit;
  final String locale;

  const DetailsPieChartsSection({
    super.key,
    required this.state,
    required this.cubit,
    required this.locale,
  });

  Color _yellowGradient(int index) {
    final colors = [
      AppColors.chartGold,
      AppColors.secondaryPrimary,
      AppColors.chartOrange,
      AppColors.chartAmber,
      AppColors.chartBrown,
    ];
    return colors[index.clamp(0, colors.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    final pieCharts = [
      _buildDepartmentChart(context, lightMode),
      SizedBox(height: isMobile ? 15.sp : 0, width: isMobile ? 0 : 15.sp),
      _buildStatusChart(context, lightMode),
    ];

    return isMobile
        ? Column(children: pieCharts)
        : Row(children: pieCharts.map((w) => w is SizedBox ? w : Expanded(child: w)).toList());
  }

  Widget _buildDepartmentChart(BuildContext context, bool lightMode) {
    if (state.isLoadingDepartments) {
      return Container(
        width: ContextExtension(context).isPhone ? 304.sp : null,
        height: 283.sp,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Center(child: CircleProgressMaster()),
      );
    }

    final top5 = cubit.getTop5Departments();
    final top5Entries = top5.entries.toList();
    final totalAll = state.departmentCounts.values.fold(0, (a, b) => a + b);

    return DonutChartCard(
      dotIcon: 'assets/icons_assets/main_icons_assets/Case.svg',
      title: S.of(context).department,
      centerValue: totalAll.toString(),
      sections: top5Entries.asMap().entries.map((entry) {
        final color = _yellowGradient(entry.key);
        final label = locale == 'ar'
            ? (state.enToArDepartments[entry.value.key] ?? entry.value.key)
            : entry.value.key;
        return ChartData(
          label: label,
          value: entry.value.value.toDouble(),
          color: color,
        );
      }).toList(),
    );
  }

  Widget _buildStatusChart(BuildContext context, bool lightMode) {
    if (state.isLoadingFirst) {
      return Container(
        width: ContextExtension(context).isPhone ? 304.sp : null,
        height: 283.sp,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Center(child: CircleProgressMaster()),
      );
    }

    double count(String key) => (state.statusCounts[key] ?? 0).toDouble();

    return DonutChartCard(
      dotIcon: 'assets/icons_assets/main_icons_assets/status_pulse_line.svg',
      title: S.of(context).StatusOfServices,
      centerValue: state.statusCounts.values.fold(0, (a, b) => a + b).toString(),
      sections: [
        ChartData(label: S.of(context).Done, value: count('done'), color: AppColors.lightGreen),
        ChartData(label: S.of(context).Approved, value: count('approved'), color: AppColors.green),
        ChartData(label: S.of(context).Pending, value: count('pending'), color: AppColors.pending),
        ChartData(label: S.of(context).Inprogress, value: count('inprogress'), color: AppColors.secondaryPrimary),
        ChartData(label: S.of(context).BreachedSLA, value: count('branchsla'), color: AppColors.red),
        ChartData(label: S.of(context).Rejected, value: count('rejected'), color: AppColors.block),
        ChartData(label: S.of(context).Canceled, value: count('canceled'), color: AppColors.chartDarkRed),
      ],
    );
  }
}
