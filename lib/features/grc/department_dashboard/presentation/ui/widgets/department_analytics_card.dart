/// Module: GRC / Dashboard Of All Departments
/// Description: The Analytics view of the Departments tab — a six-month
///              score bar chart (BarChartCard, core/custom/26), coloured by
///              score band.
///            * Policies: "<Policy Name>" + a Policies picker.
///            * Controls: "<Control Name> Score" + Policies and Controls
///              pickers.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/domain/entities/department_dashboard_data.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/controller/department_dashboard_cubit.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/widgets/department_common_widgets.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [DepartmentAnalyticsCard]
class DepartmentAnalyticsCard extends StatelessWidget {
  final DepartmentDashboardState state;
  final DepartmentDashboardData data;

  const DepartmentAnalyticsCard({
    super.key,
    required this.state,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final cubit = context.read<DepartmentDashboardCubit>();
    final bool ar = context.isArabic;
    final String? dept = state.department;
    final List<PolicyEntity> policies = data.policiesFor(department: dept);

    if (policies.isEmpty) return const Center(child: CustomEmptyState());

    // Default to the first policy / control so the chart is never blank.
    final PolicyEntity policy = policies.firstWhere(
      (p) => p.id == state.chartPolicyId,
      orElse: () => policies.first,
    );

    final Widget policyPicker = DepartmentPicker(
      hint: s.policies,
      value: state.chartPolicyId,
      includeAll: false,
      width: 110,
      fillColor: AppColors.background,
      items: DepartmentPicker.policyItems(context, data, dept),
      onChanged: cubit.setChartPolicy,
    );

    final DateTime now = DateTime.now();
    final String locale = ar ? 'ar' : 'en';
    String monthLabel(DateTime m) => DateFormat('MMM', locale).format(m);

    late final String title;
    late final List<DepartmentMonthScore> points;
    late final Widget trailing;

    if (state.tab == DepartmentListTab.policies) {
      title = ar && policy.policyNameAr.trim().isNotEmpty
          ? policy.policyNameAr
          : policy.policyNameEn;
      points = data.policyTimeline(policy.id,
          department: dept, now: now);
      trailing = policyPicker;
    } else {
      final refs = data.controlsFor(department: dept, policyId: policy.id);
      if (refs.isEmpty) {
        return _emptyCard(context, s.controls,
            _pickers(policyPicker, const SizedBox.shrink()));
      }
      final ref = refs.firstWhere(
        (r) => r.control.id == state.chartControlId,
        orElse: () => refs.first,
      );
      final String name = ar && ref.control.controlsNameAr.trim().isNotEmpty
          ? ref.control.controlsNameAr
          : ref.control.controlsNameEn;
      title = '$name ${s.score}';
      points = data.controlTimeline(ref.control, now: now);
      trailing = _pickers(
        policyPicker,
        DepartmentPicker(
          hint: s.controls,
          value: state.chartControlId,
          includeAll: false,
          width: 110,
          fillColor: AppColors.background,
          items: DepartmentPicker.controlItems(context, data, dept, policy.id),
          onChanged: cubit.setChartControl,
        ),
      );
    }

    return BarChartCard(
      title: title,
      trailing: trailing,
      chartHeight: 240,
      barWidth: 40,
      bars: [
        for (final p in points)
          ChartData(
            label: monthLabel(p.month),
            value: p.value.roundToDouble(),
            color: departmentScoreColor(p.value),
          ),
      ],
    );
  }

  Widget _pickers(Widget a, Widget b) => Wrap(
        spacing: 15.sp,
        runSpacing: 8.sp,
        alignment: WrapAlignment.end,
        children: [a, b],
      );

  Widget _emptyCard(BuildContext context, String title, Widget trailing) {
    return BarChartCard(
      title: title,
      trailing: trailing,
      chartHeight: 240,
      bars: const <ChartData>[],
    );
  }
}
