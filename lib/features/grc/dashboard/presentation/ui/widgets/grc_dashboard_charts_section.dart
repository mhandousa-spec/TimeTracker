/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: grc_dashboard_charts_section.dart
/// Purpose: Declares `GrcDashboardChartsSection` — the dashboard body as the
///          Figma frame draws it (MAGDY, "MAIN PAGE : Main Dashboard"):
///
///            [Color Coding]                          [Department ▾]
///            [ Policies donut ]      [ Controls donut ]
///            [ Policy Compliance        Sort · Department ▾        ]
///            [ Departments              Sort · Policies ▾ · Controls ▾ ]
///            [ Department Performance   Policies ▾ · Controls ▾ · Top|Least ]
///            [ Compliance Timeline      Baseline · Policies · Controls · Department ]
///
///          Charts are ONLY the shared cards in lib/core/custom
///          (DonutChartCard 27, BarChartCard 26, HorizontalBarChartCard 28,
///          BaseLineChartCard 94). Nothing is drawn here.
/// Author: Amr Mesbah
/// Created: 16/9/2026
/// Updated: 16/9/2026 — rebuilt against the Figma frame.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/28-custom_horizontal_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/94-custom_base_line_chart_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_color_coding.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_dashboard_stats.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/controller/grc_dashboard_cubit.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/controller/grc_dashboard_state.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/ui/widgets/grc_color_coding_dialog.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/ui/widgets/grc_dashboard_filters.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class GrcDashboardChartsSection extends StatelessWidget {
  final GrcDashboardLoaded state;

  const GrcDashboardChartsSection({super.key, required this.state});

  static const String _icon = 'assets/icons_assets/data_grc_assets/module.svg';

  GrcDashboardData get _data => state.data;
  GrcDashboardFilters get _f => state.filters;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GrcDashboardCubit>();
    final gap = SizedBox(height: 15.sp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _topBar(context, cubit),
        gap,
        _pair(context, _policiesDonut(context), _controlsDonut(context)),
        gap,
        _policyCompliance(context, cubit),
        gap,
        _departments(context, cubit),
        gap,
        _departmentPerformance(context, cubit),
        gap,
        _timeline(context, cubit),
        SizedBox(height: 5.sp),
      ],
    );
  }

  // ── Layout helpers ─────────────────────────────────────────────────────

  bool _isPhone(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.mobile;

  /// Filters sit on the title row only on desktop (≥1024). On tablet (768)
  /// three or four 130-wide controls plus the title do not fit one row —
  /// the trailing slot is unbounded and would overflow — so there, as on a
  /// phone, they go in the card's own header slot under the title, where
  /// [GrcFilterBar] has the full width and can wrap.
  bool _filtersInline(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.desktop;

  /// A Wrap shrinks to its content, so on its own row it would sit at the
  /// start; full width lets GrcFilterBar's end alignment take effect.
  Widget _fullWidth(Widget child) =>
      SizedBox(width: double.infinity, child: child);

  Widget _pair(BuildContext context, Widget first, Widget second) {
    if (_isPhone(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, SizedBox(height: 15.sp), second],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        SizedBox(width: 15.sp),
        Expanded(child: second),
      ],
    );
  }

  String _n(BuildContext context, num v) =>
      LocalizedNumber.digits(context, v.toStringAsFixed(v % 1 == 0 ? 0 : 1));

  Color _controlColor(double value, String? policyFilter) {
    final rule = state.colorRules[GrcColorCategory.control];
    return rule != null && rule.appliesTo(policyFilter)
        ? rule.colorFor(value)
        : AppColors.primary;
  }

  Widget _noData(BuildContext context, String title, Widget filters) =>
      ChartCard(
        title: title,
        dotIcon: _icon,
        trailing: _filtersInline(context) ? filters : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_filtersInline(context)) filters,
            SizedBox(
              height: 120.sp,
              child: Center(
                child: Text(
                  S.of(context).noData,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText),
                ),
              ),
            ),
          ],
        ),
      );

  // ── Top bar: Color Coding + Department ─────────────────────────────────

  Widget _topBar(BuildContext context, GrcDashboardCubit cubit) {
    final s = S.of(context);
    return Row(
      children: [
        // customButtonWithSvg (6), not customButton (5): only the SVG button
        // takes its own radius and height, so it can match the Department
        // dropdown beside it — 4.r corners, 30 / 37 tall.
        customButtonWithSvg(
          title: s.colorCoding,
          image: '',
          widthImage: 0,
          heightImage: 0,
          fixedWidth: 135.w,
          fixedHeight: grcDashboardFilterHeight(context),
          fixedRadius: 4.r,
          color: AppColors.primary,
          colorBorder: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
          function: () async {
            final rule = await showGrcColorCodingDialog(
              context,
              data: _data,
              current: state.colorRules,
            );
            if (rule != null) cubit.saveColorRule(rule);
          },
        ),
        const Spacer(),
        GrcDashboardDropdown(
          hint: s.department,
          value: _f.department,
          options: GrcDashboardDropdown.departments(context, _data),
          onChanged: cubit.setDepartment,
          width: 150,
          fillColor: AppColors.card,
        ),
      ],
    );
  }

  // ── Donuts ─────────────────────────────────────────────────────────────

  Widget _policiesDonut(BuildContext context) {
    final counts = _data.policyStatusCounts(department: _f.department);
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    const always = [
      PolicyStatus.active,
      PolicyStatus.inactive,
      PolicyStatus.expired,
      PolicyStatus.draft,
    ];
    return DonutChartCard(
      title: S.of(context).policies,
      dotIcon: _icon,
      centerValue: _n(context, total),
      centerLabel: S.of(context).total,
      sections: [
        for (final st in [...always, PolicyStatus.scheduled])
          if (always.contains(st) || (counts[st] ?? 0) > 0)
            ChartData(
              label: grcTr(context, st.value),
              value: (counts[st] ?? 0).toDouble(),
              color: _policyStatusColor(st),
            ),
      ],
    );
  }

  Widget _controlsDonut(BuildContext context) {
    final counts = _data.controlStatusCounts(department: _f.department);
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    const always = [
      ControlStatus.active,
      ControlStatus.inactive,
      ControlStatus.expired,
      ControlStatus.draft,
    ];
    return DonutChartCard(
      title: S.of(context).controls,
      dotIcon: _icon,
      centerValue: _n(context, total),
      centerLabel: S.of(context).total,
      sections: [
        for (final st in [
          ...always,
          ControlStatus.scheduled,
          ControlStatus.unassigned,
        ])
          if (always.contains(st) || (counts[st] ?? 0) > 0)
            ChartData(
              label: grcTr(context, st.value),
              value: (counts[st] ?? 0).toDouble(),
              color: _controlStatusColor(st),
            ),
      ],
    );
  }

  // ── Policy Compliance ──────────────────────────────────────────────────

  Widget _policyCompliance(BuildContext context, GrcDashboardCubit cubit) {
    final s = S.of(context);
    final filters = GrcFilterBar(children: [
      GrcDashboardSortButton(
        ascending: _f.complianceAscending,
        onChanged: cubit.setComplianceSort,
      ),
      GrcDashboardDropdown(
        hint: s.department,
        value: _f.department,
        options: GrcDashboardDropdown.departments(context, _data),
        onChanged: cubit.setDepartment,
      ),
    ]);

    final bars = _data.policyCompliance(
      department: _f.department,
      ascending: _f.complianceAscending,
    );
    if (bars.isEmpty) return _noData(context, s.policyCompliance, filters);

    final rule = state.colorRules[GrcColorCategory.policy];
    final isArabic = context.isArabic;
    return BarChartCard(
      title: s.policyCompliance,
      dotIcon: _icon,
      trailing: _filtersInline(context) ? filters : null,
      header: _filtersInline(context) ? null : _fullWidth(filters),
      chartHeight: 220,
      bars: [
        for (final b in bars)
          ChartData(
            label: b.label(isArabic: isArabic),
            value: b.value,
            color: rule != null && rule.appliesTo(b.id)
                ? rule.colorFor(b.value)
                : AppColors.primary,
          ),
      ],
    );
  }

  // ── Departments ────────────────────────────────────────────────────────

  Widget _departments(BuildContext context, GrcDashboardCubit cubit) {
    final s = S.of(context);
    final filters = GrcFilterBar(children: [
      GrcDashboardSortButton(
        ascending: _f.departmentsAscending,
        onChanged: cubit.setDepartmentsSort,
      ),
      GrcDashboardDropdown(
        hint: s.policies,
        value: _f.departmentsPolicyId,
        options: GrcDashboardDropdown.policies(context, _data),
        onChanged: cubit.setDepartmentsPolicy,
      ),
      GrcDashboardDropdown(
        hint: s.controls,
        value: _f.departmentsControlId,
        options: GrcDashboardDropdown.controls(
            context, _data, _f.departmentsPolicyId),
        onChanged: cubit.setDepartmentsControl,
      ),
    ]);

    final bars = _data.departmentScores(
      policyId: _f.departmentsPolicyId,
      controlId: _f.departmentsControlId,
      ascending: _f.departmentsAscending,
    );
    if (bars.isEmpty) return _noData(context, s.departments, filters);

    return BarChartCard(
      title: s.departments,
      dotIcon: _icon,
      trailing: _filtersInline(context) ? filters : null,
      header: _filtersInline(context) ? null : _fullWidth(filters),
      chartHeight: 220,
      bars: [
        for (final b in bars)
          ChartData(
            label: grcTr(context, b.id),
            value: b.value,
            color: _controlColor(b.value, _f.departmentsPolicyId),
          ),
      ],
    );
  }

  // ── Department Performance ─────────────────────────────────────────────

  Widget _departmentPerformance(
      BuildContext context, GrcDashboardCubit cubit) {
    final s = S.of(context);
    final filters = GrcFilterBar(children: [
      GrcDashboardDropdown(
        hint: s.policies,
        value: _f.performancePolicyId,
        options: GrcDashboardDropdown.policies(context, _data),
        onChanged: cubit.setPerformancePolicy,
      ),
      GrcDashboardDropdown(
        hint: s.controls,
        value: _f.performanceControlId,
        options: GrcDashboardDropdown.controls(
            context, _data, _f.performancePolicyId),
        onChanged: cubit.setPerformanceControl,
      ),
      GrcTopLeastToggle(
        top: _f.performanceTop,
        onChanged: cubit.setPerformanceTop,
      ),
    ]);

    final bars = _data.departmentPerformance(
      policyId: _f.performancePolicyId,
      controlId: _f.performanceControlId,
      top: _f.performanceTop,
    );
    if (bars.isEmpty) {
      return _noData(context, s.departmentPerformance, filters);
    }

    final inline = _filtersInline(context);
    return HorizontalBarChartCard(
      title: s.departmentPerformance,
      dotIcon: _icon,
      trailing: inline ? filters : null,
      header: inline ? null : _fullWidth(filters),
      maxX: 100,
      divisions: 4,
      bars: [
        for (final b in bars)
          ChartData(
            label: grcTr(context, b.id),
            value: b.value,
            color: _controlColor(b.value, _f.performancePolicyId),
          ),
      ],
    );
  }

  // ── Compliance Timeline ────────────────────────────────────────────────

  Widget _timeline(BuildContext context, GrcDashboardCubit cubit) {
    final s = S.of(context);
    final filters = GrcFilterBar(children: [
      GrcBaselineButton(
        active: _f.timelineBaseline,
        onTap: cubit.toggleTimelineBaseline,
      ),
      GrcDashboardDropdown(
        hint: s.policies,
        value: _f.timelinePolicyId,
        options: GrcDashboardDropdown.policies(context, _data),
        onChanged: cubit.setTimelinePolicy,
      ),
      GrcDashboardDropdown(
        hint: s.controls,
        value: _f.timelineControlId,
        options: GrcDashboardDropdown.controls(
            context, _data, _f.timelinePolicyId),
        onChanged: cubit.setTimelineControl,
      ),
      GrcDashboardDropdown(
        hint: s.department,
        value: _f.timelineDepartment,
        options: GrcDashboardDropdown.departments(context, _data),
        onChanged: cubit.setTimelineDepartment,
      ),
    ]);

    final locale = Localizations.localeOf(context).languageCode;
    final points = _data.timeline(
      policyId: _f.timelinePolicyId,
      controlId: _f.timelineControlId,
      department: _f.timelineDepartment,
      now: DateTime.now(),
    );
    final bars = [
      for (final p in points)
        ChartData(
          label: DateFormat.MMM(locale).format(p.month),
          value: p.value,
          color: _controlColor(p.value, _f.timelinePolicyId),
        ),
    ];

    if (_f.timelineBaseline) {
      // BaseLineChartCard has no header slot; on phone / tablet the filters
      // go under the chart instead of squeezing the title.
      final inline = _filtersInline(context);
      return BaseLineChartCard(
        title: s.complianceTimeline,
        dotIcon: _icon,
        trailing: inline ? filters : null,
        footer: inline ? null : _fullWidth(filters),
        maxY: 100,
        bars: bars,
      );
    }

    return BarChartCard(
      title: s.complianceTimeline,
      dotIcon: _icon,
      trailing: _filtersInline(context) ? filters : null,
      header: _filtersInline(context) ? null : _fullWidth(filters),
      chartHeight: 220,
      bars: bars,
    );
  }

  // ── Status colours (match the list screens' status text) ───────────────

  Color _policyStatusColor(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.active:
        return AppColors.green;
      case PolicyStatus.inactive:
        return AppColors.orange;
      case PolicyStatus.expired:
        return AppColors.red;
      case PolicyStatus.scheduled:
        return AppColors.chartYellow;
      case PolicyStatus.draft:
      case PolicyStatus.removed:
        return AppColors.colorGrey;
    }
  }

  Color _controlStatusColor(ControlStatus status) {
    switch (status) {
      case ControlStatus.active:
        return AppColors.green;
      case ControlStatus.inactive:
        return AppColors.orange;
      case ControlStatus.expired:
        return AppColors.red;
      case ControlStatus.scheduled:
        return AppColors.chartYellow;
      case ControlStatus.draft:
        return AppColors.colorGrey;
      case ControlStatus.unassigned:
        return AppColors.primary;
    }
  }
}
