// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_department_employees_widget.dart
// Purpose: Displays employee counts grouped by department.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/24-custom_chart_card.dart';
import '../../../../../../core/custom/26-custom_bar_chart_card.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../../../../generated/l10n.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';

class HRDashboardDepartmentEmployeesWidget extends StatelessWidget {
  const HRDashboardDepartmentEmployeesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();

    final departmentCubit = Get.find<MainCoreDepartmentCubit>();
    final isEnglish = !context.isArabic;

    return BarChartCard(
      title: FormatHelper.capitalize(S.of(context).departmentEmployees),
      dotIcon: HRAssets.dashboardDepartmentEmployees,
      bars: [
        for (final item in state.departmentEmployees)
          ChartData(
            label: FormatHelper.capitalize(
              _departmentName(
                departmentCubit,
                item.category,
                isEnglish,
              ),
            ),
            value: item.count.toDouble(),
            color: AppColors.primary,
          ),
      ],
      barColor: AppColors.primary,
    );
  }

  /// Method Name: [_departmentName]
  ///
  /// Purpose: Resolves a department chart label in the active language.
  ///
  /// Parameters:
  /// - [departmentCubit]: Shared source for department display names.
  /// - [departmentId]: Stable department identifier from chart data.
  /// - [isEnglish]: Whether the English department label is required.
  ///
  /// Returns: A localized department name or the original ID as fallback.
  String _departmentName(
    MainCoreDepartmentCubit departmentCubit,
    String departmentId,
    bool isEnglish,
  ) {
    final department = departmentCubit.departmentModels.firstWhereOrNull(
      (model) => model.departmentID?.trim() == departmentId,
    );
    if (department == null) return departmentId;
    return isEnglish
        ? (department.departmentName?.trim().isNotEmpty ?? false
            ? department.departmentName!.trim()
            : departmentId)
        : (department.departmentNameInArabic?.trim().isNotEmpty ?? false
            ? department.departmentNameInArabic!.trim()
            : departmentId);
  }
}
