/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_charts.dart
/// Purpose: Declares the five chart cards of the HR view:
///          `HrRequestsDonut`, `HrRequestTypesDonut`, `HrAttendanceHistoryCard`
///          (grouped bars + Status dropdown), `HrRequestTypeBarsCard`
///          (+ Request Type dropdown) and `HrRequestTimelineCard`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Figma `661:42563`: two donuts side by side (half row each — owner chart
/// rule), then three full-row monthly bar charts. Built only from the core
/// chart cards the personal dashboard uses — `DonutChartCard` (27),
/// `GroupedBarChartCard` (29), `BarChartCard` (26) — and the core
/// `CustomDropdown` (100×30 white-on-card "Status" / 151×30 "Request Type",
/// Figma `661:107425` / `661:43222`). Colours: Present green, Absent red,
/// Late orange, Vacation yellow (Figma legend); Request Types slices from
/// the Figma palette; yellow bars. Month labels localized ("Jan" / "يناير").

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/29-custom_grouped_bar_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Attendance History header icon (clock with a back arrow, as Late History).
const String _historyIcon = 'assets/icons_assets/crm_icons_assets/history.svg';

/// 12/10/2026 (owner R1 / B2): every chart has its OWN header icon (they all
/// showed the request document) and a full title.
const String _byTypeIcon = 'assets/icons_assets/home_assets/analytics_charts.svg';
const String _barsIcon = 'assets/icons_assets/organization_chart_assets/chart.svg';
const String _trendIcon = 'assets/icons_assets/crm_icons_assets/chart-line-solid.svg';

/// Month label of a bar ("Jan", localized).
String hrMonthLabel(BuildContext context, DateTime month) =>
    DateFormat('MMM', Localizations.localeOf(context).languageCode).format(month);

/// The name of a request type id in the app language ("Others" for '').
String hrTypeName(BuildContext context, HrDashboardState state, String typeId) {
  if (typeId.isEmpty) return S.of(context).timeTrackerOthers;
  final RequestType? t = state.typeById(typeId);
  if (t == null) return TimeTrackerFormat.dash;
  return t.name(isArabic: Localizations.localeOf(context).languageCode == 'ar');
}

class HrRequestsDonut extends StatelessWidget {
  const HrRequestsDonut({super.key, required this.stats});

  final HrDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DonutChartCard(
      key: const ValueKey<String>('hrRequestsDonut'),
      title: s.timeTrackerChartRequestsByStatus,
      dotIcon: ChartSvg.request,
      centerValue: TimeTrackerFormat.count(context, stats.totalRequests),
      centerLabel: s.timeTrackerTotal,
      legendMaxLines: 2,
      sections: <ChartData>[
        ChartData(label: s.timeTrackerApproved, value: stats.approved.toDouble(), color: AppColors.lightGreen),
        ChartData(label: s.timeTrackerPending, value: stats.pending.toDouble(), color: AppColors.orange),
        ChartData(label: s.timeTrackerRejected, value: stats.rejected.toDouble(), color: AppColors.red),
        ChartData(label: s.timeTrackerCanceled, value: stats.canceled.toDouble(), color: AppColors.darkRed),
      ],
    );
  }
}

class HrRequestTypesDonut extends StatelessWidget {
  const HrRequestTypesDonut({super.key, required this.state});

  final HrDashboardState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    // Figma `661:43047` palette: grey, light yellow, dark yellow, light grey,
    // slate (Others).
    final List<Color> palette = <Color>[
      AppColors.secondaryText,
      AppColors.yellow,
      AppColors.primary,
      AppColors.greyDark,
      AppColors.orange,
    ];
    final List<HrTypeSlice> slices = state.stats.typeSlices;
    return DonutChartCard(
      key: const ValueKey<String>('hrRequestTypesDonut'),
      title: s.timeTrackerChartRequestsByType,
      dotIcon: _byTypeIcon,
      centerValue: TimeTrackerFormat.count(context, state.stats.totalTypeRequests),
      centerLabel: s.timeTrackerTotal,
      legendMaxLines: 2,
      sections: <ChartData>[
        for (int i = 0; i < slices.length; i++)
          ChartData(
            label: hrTypeName(context, state, slices[i].typeId),
            value: slices[i].count.toDouble(),
            color: slices[i].isOthers ? AppColors.navyBlue : palette[i % palette.length],
          ),
      ],
    );
  }
}

/// A compact white dropdown for a chart header.
class _ChartDropdown<T> extends StatelessWidget {
  const _ChartDropdown({
    super.key,
    required this.width,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final double width;
  final String hint;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomDropdown<T>(
        hint: hint,
        height: 30,
        fillColor: AppColors.background,
        itemStyle: StyleText.fontSize12Weight400,
        value: value,
        items: items,
        onChanged: (T v) {
          HapticController.low();
          onChanged(v);
        },
      ),
    );
  }
}

class HrAttendanceHistoryCard extends StatelessWidget {
  const HrAttendanceHistoryCard({super.key, required this.state});

  final HrDashboardState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final HrAttendanceSeries series = state.series;
    final List<(HrAttendanceSeries, String, Color, int Function(HrMonthAttendance))> all =
        <(HrAttendanceSeries, String, Color, int Function(HrMonthAttendance))>[
      (HrAttendanceSeries.present, s.timeTrackerPresent, AppColors.lightGreen, (HrMonthAttendance m) => m.present),
      (HrAttendanceSeries.absent, s.timeTrackerAbsent, AppColors.red, (HrMonthAttendance m) => m.absent),
      (HrAttendanceSeries.late, s.timeTrackerLate, AppColors.orange, (HrMonthAttendance m) => m.late),
      (HrAttendanceSeries.vacation, s.timeTrackerVacation, AppColors.yellow, (HrMonthAttendance m) => m.leave),
    ];
    final List<(HrAttendanceSeries, String, Color, int Function(HrMonthAttendance))> shown = <
        (HrAttendanceSeries, String, Color, int Function(HrMonthAttendance))>[
      for (final (HrAttendanceSeries, String, Color, int Function(HrMonthAttendance)) e in all)
        if (series == HrAttendanceSeries.all || series == e.$1) e,
    ];
    return GroupedBarChartCard(
      key: const ValueKey<String>('hrAttendanceHistory'),
      title: s.timeTrackerChartMonthlyAttendance,
      dotIcon: _historyIcon,
      barWidth: 15,
      trailing: _ChartDropdown<HrAttendanceSeries>(
        key: const ValueKey<String>('hrAttendanceStatus'),
        width: 110.w,
        hint: s.timeTrackerStatus,
        value: series == HrAttendanceSeries.all ? null : series,
        items: <DropdownItem<HrAttendanceSeries>>[
          DropdownItem<HrAttendanceSeries>(value: HrAttendanceSeries.all, label: s.timeTrackerAll),
          for (final (HrAttendanceSeries, String, Color, int Function(HrMonthAttendance)) e in all)
            DropdownItem<HrAttendanceSeries>(value: e.$1, label: e.$2),
        ],
        onChanged: context.read<HrDashboardCubit>().setSeries,
      ),
      series: <ChartData>[
        for (final (HrAttendanceSeries, String, Color, int Function(HrMonthAttendance)) e in shown)
          ChartData(label: e.$2, value: 0, color: e.$3),
      ],
      groups: <GroupedBarData>[
        for (final HrMonthAttendance m in state.stats.attendanceByMonth)
          GroupedBarData(
            label: hrMonthLabel(context, m.month),
            values: <double>[
              for (final (HrAttendanceSeries, String, Color, int Function(HrMonthAttendance)) e in shown)
                e.$4(m).toDouble(),
            ],
          ),
      ],
    );
  }
}

class HrRequestTypeBarsCard extends StatelessWidget {
  const HrRequestTypeBarsCard({super.key, required this.state});

  final HrDashboardState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<RequestType> types = <RequestType>[...state.types]
      ..sort((RequestType a, RequestType b) =>
          a.name(isArabic: ar).toLowerCase().compareTo(b.name(isArabic: ar).toLowerCase()));
    return BarChartCard(
      key: const ValueKey<String>('hrRequestTypeBars'),
      title: s.timeTrackerChartMonthlyRequestsByType,
      dotIcon: _barsIcon,
      barColor: AppColors.yellow,
      barWidth: 40,
      trailing: _ChartDropdown<String>(
        key: const ValueKey<String>('hrRequestTypeFilter'),
        width: 151.w,
        hint: s.timeTrackerRequestType,
        value: state.requestTypeId.isEmpty ? null : state.requestTypeId,
        items: <DropdownItem<String>>[
          DropdownItem<String>(value: '', label: s.timeTrackerAll),
          for (final RequestType t in types) DropdownItem<String>(value: t.id, label: t.name(isArabic: ar)),
        ],
        onChanged: context.read<HrDashboardCubit>().setRequestType,
      ),
      bars: <ChartData>[
        for (final HrMonthCount m in state.stats.typeByMonth)
          ChartData(label: hrMonthLabel(context, m.month), value: m.count.toDouble()),
      ],
    );
  }
}

class HrRequestTimelineCard extends StatelessWidget {
  const HrRequestTimelineCard({super.key, required this.stats});

  final HrDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return BarChartCard(
      key: const ValueKey<String>('hrRequestTimeline'),
      title: S.of(context).timeTrackerChartMonthlyRequestsVolume,
      dotIcon: _trendIcon,
      barColor: AppColors.yellow,
      barWidth: 40,
      bars: <ChartData>[
        for (final HrMonthCount m in stats.timelineByMonth)
          ChartData(label: hrMonthLabel(context, m.month), value: m.count.toDouble()),
      ],
    );
  }
}
