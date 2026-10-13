/// Module: time_tracker / tt2_personal_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: personal_dashboard_tab.dart
/// Purpose: Declares `PersonalDashboardTab` — the "Dashboard" tab: range
///          menu · Overall tiles · Requests donut · (iPad portrait) Work
///          Locations donut · Late History bars with Counts / Minutes.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma: iPad landscape `661:10375`, iPad portrait `661:17426` (adds the
/// Work Locations donut beside Requests), iPhone `661:24056` (cards stack;
/// the Late History axis shows MONTHS — the Figma department names are a
/// copy slip fixed per FINAL SPEC §3). Built only from core chart cards:
/// `OverallStatsCard` (25), `DonutChartCard` (27), `BarChartCard` (26),
/// `CustomSegmentedTabs` (9). Each card slides in (animation standard).
///
/// Overall icons: the four Figma illustrations (Present 661:10498, Absence
/// 661:10555, Late 661:10575, Vacations Credit 661:10621), exported as SVG
/// into assets/icons_assets/time_tracker_assets/ (8/10/2026). They keep
/// their own Figma colours; only the Absence one is tinted red in dark mode,
/// because its #2D2D2D strokes would vanish on the dark card.
///
/// Updated: 9/10/2026 - UI fix round 1 (owner review on iPad):
/// - Overall labels never end in "…" (finding 2): they wrap onto a second
///   line where the tile is narrow (iPad portrait, iPhone) and take the
///   Figma colours (Present green, Absence / Late red, Vacations Credit
///   yellow).
/// - Donut legends wrap instead of truncating (finding 10: "Work Locati…").
/// - Late History "Counts / Minutes" sits in its own page-colour container
///   (`TtSegmentedToggle`, Figma `661:10741`, finding 1).
/// Updated: 9/10/2026 - code review: "Vacations Credit" reads "-" when the
/// balance could not be read (it used to claim 0 days).
/// Updated: 9/10/2026 - UI quality pass (owner 13:45 #4, 14:17 #1–2): the
/// Overall tiles are `TtStatsCard` — neutral label on ONE line, colour on
/// the icon only; Work Locations gets distinct colours per place (Remote
/// slate, Client Site dark grey, offices yellow shades — Figma 661:17426).
/// Updated: 13/10/2026 - owner review: donuts sit at the card's end edge
/// (legend names get the room, "Citizen Services" on one line); Late History
/// bars animate between Counts and Minutes.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/personal_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_stats_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/ui/widgets/dashboard_range_menu.dart';
import 'package:knowticed_plus/generated/l10n.dart';

const String _ttAssets = 'assets/icons_assets/time_tracker_assets';
const String _presentIcon = '$_ttAssets/tt_overall_present.svg';
const String _absenceIcon = '$_ttAssets/tt_overall_absence.svg';
const String _lateIcon = '$_ttAssets/tt_overall_late.svg';
const String _vacationIcon = '$_ttAssets/tt_overall_vacation.svg';

/// Late History header icon (clock with a back arrow).
const String _historyIcon = 'assets/icons_assets/crm_icons_assets/history.svg';

/// 12/10/2026 (owner R1 / A3): Work Locations gets its own map icon (it
/// shared the request document with Requests).
const String _locationsIcon = 'assets/icons_assets/main_icons_assets/map_new.svg';

class PersonalDashboardTab extends StatelessWidget {
  const PersonalDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalDashboardCubit, PersonalDashboardState>(
      builder: (BuildContext context, PersonalDashboardState state) {
        if (state.status == PersonalDashboardStatus.initial ||
            state.status == PersonalDashboardStatus.loading) {
          return Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
            child: const Center(child: CircleProgressMaster()),
          );
        }
        if (state.status == PersonalDashboardStatus.failure) {
          return Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
            child: Text(
              S.of(context).timeTrackerLoadError,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red),
            ),
          );
        }
        final PersonalDashboardStats stats = state.stats;
        final bool portraitTablet = !context.isPhone && !context.isLandscape;
        final Widget requests = _RequestsDonut(stats: stats);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DashboardRangeMenu(),
            ),
            SizedBox(height: 15.h),
            SlideInContent(child: _OverallCard(stats: stats, balanceUnavailable: state.balanceUnavailable)),
            SizedBox(height: 15.h),
            SlideInContent(
              delay: const Duration(milliseconds: 80),
              child: portraitTablet
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(child: _WorkLocationsDonut(state: state)),
                          SizedBox(width: 15.w),
                          Expanded(child: requests),
                        ],
                      ),
                    )
                  : requests,
            ),
            SizedBox(height: 15.h),
            SlideInContent(
              delay: const Duration(milliseconds: 160),
              child: _LateHistoryCard(state: state),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.stats, this.balanceUnavailable = false});

  final PersonalDashboardStats stats;

  /// 9/10/2026 (code review): the balance could not be read → "—", not 0.
  final bool balanceUnavailable;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final double left = stats.vacationDaysLeft;
    final num credit = left == left.roundToDouble() ? left.round() : double.parse(left.toStringAsFixed(1));
    // UI quality pass (9/10/2026, owner 14:17): neutral one-line labels,
    // colour on the icon only (`TtStatsCard`).
    return TtStatsCard(
      key: const ValueKey<String>('timeTrackerOverallCard'),
      title: s.timeTrackerChartAttendanceSummary,
      stats: <TtStat>[
        TtStat(
          label: s.timeTrackerPresent,
          value: TimeTrackerFormat.count(context, stats.present),
          icon: const CustomSvgImage(assetPath: _presentIcon),
        ),
        TtStat(
          label: s.timeTrackerAbsence,
          value: TimeTrackerFormat.count(context, stats.absent),
          icon: CustomSvgImage(assetPath: _absenceIcon, color: AppTheme.isDark ? AppColors.red : null),
        ),
        TtStat(
          label: s.timeTrackerLate,
          value: TimeTrackerFormat.count(context, stats.late),
          icon: const CustomSvgImage(assetPath: _lateIcon),
        ),
        TtStat(
          label: s.timeTrackerVacationsCredit,
          value: balanceUnavailable ? TimeTrackerFormat.dash : TimeTrackerFormat.count(context, credit),
          icon: const CustomSvgImage(assetPath: _vacationIcon),
        ),
      ],
    );
  }
}

class _RequestsDonut extends StatelessWidget {
  const _RequestsDonut({required this.stats});

  final PersonalDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DonutChartCard(
      key: const ValueKey<String>('timeTrackerRequestsDonut'),
      title: s.timeTrackerChartRequestsByStatus,
      dotIcon: ChartSvg.request,
      centerValue: TimeTrackerFormat.count(context, stats.totalRequests),
      centerLabel: s.timeTrackerTotal,
      legendMaxLines: 2,
      ringAtEnd: true,
      sections: <ChartData>[
        ChartData(label: s.timeTrackerApproved, value: stats.approved.toDouble(), color: AppColors.lightGreen),
        ChartData(label: s.timeTrackerPending, value: stats.pending.toDouble(), color: AppColors.orange),
        ChartData(label: s.timeTrackerRejected, value: stats.rejected.toDouble(), color: AppColors.red),
        ChartData(label: s.timeTrackerCanceled, value: stats.canceled.toDouble(), color: AppColors.darkRed),
      ],
    );
  }
}

/// iPad portrait only: sessions per place in the range.
class _WorkLocationsDonut extends StatelessWidget {
  const _WorkLocationsDonut({required this.state});

  final PersonalDashboardState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Map<String, int> places = state.stats.sessionsByPlace;
    // Figma 661:17426: Remote slate, Client Site dark grey, offices in
    // yellow shades — every place its own colour (9/10/2026).
    final List<Color> offices = <Color>[AppColors.yellow, AppColors.primary, AppColors.orange, AppColors.lightGreen];
    int index = 0;
    int total = 0;
    final List<ChartData> sections = <ChartData>[];
    for (final MapEntry<String, int> e in places.entries) {
      total += e.value;
      final Color color = e.key == WorkLocationType.remote.storageKey
          ? AppColors.navyBlue
          : e.key == WorkLocationType.clientSite.storageKey
              ? AppColors.colorGreyDark
              : offices[index++ % offices.length];
      sections.add(ChartData(label: _placeName(context, e.key), value: e.value.toDouble(), color: color));
    }
    return DonutChartCard(
      title: s.timeTrackerChartWorkLocationDistribution,
      dotIcon: _locationsIcon,
      centerValue: TimeTrackerFormat.count(context, total),
      centerLabel: s.timeTrackerTotal,
      legendMaxLines: 2,
      ringAtEnd: true,
      sections: sections,
    );
  }

  String _placeName(BuildContext context, String key) {
    if (key == WorkLocationType.remote.storageKey) {
      return TimeTrackerFormat.placeLabel(context, WorkLocationType.remote);
    }
    if (key == WorkLocationType.clientSite.storageKey) {
      return TimeTrackerFormat.placeLabel(context, WorkLocationType.clientSite);
    }
    final String ar = state.locationNames['$key#ar'] ?? '';
    final String name = context.isArabic && ar.isNotEmpty
        ? ar
        : (state.locationNames[key] ?? '');
    return TimeTrackerFormat.placeLabel(context, WorkLocationType.office, officeName: name);
  }
}

class _LateHistoryCard extends StatelessWidget {
  const _LateHistoryCard({required this.state});

  final PersonalDashboardState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool minutes = state.lateMode == LateHistoryMode.minutes;
    final String locale = Localizations.localeOf(context).languageCode;
    return BarChartCard(
      key: const ValueKey<String>('timeTrackerLateHistory'),
      title: s.timeTrackerChartLateArrivalsHistory,
      dotIcon: _historyIcon,
      barColor: AppColors.primary,
      barWidth: 40,
      // 13/10/2026 (owner): Counts ↔ Minutes morphs the bars smoothly.
      animationDuration: const Duration(milliseconds: 450),
      animationCurve: Curves.easeInOutCubic,
      trailing: TtSegmentedToggle(
        key: const ValueKey<String>('timeTrackerLateModeToggle'),
        onCard: true,
        tabs: <String>[s.timeTrackerCounts, s.timeTrackerMinutes],
        selectedIndex: minutes ? 1 : 0,
        onChanged: (int i) => context.read<PersonalDashboardCubit>().setLateMode(
              i == 1 ? LateHistoryMode.minutes : LateHistoryMode.counts,
            ),
      ),
      bars: <ChartData>[
        for (final MonthLate m in state.stats.lateByMonth)
          ChartData(
            label: DateFormat('MMM', locale).format(m.month),
            value: (minutes ? m.minutes : m.count).toDouble(),
          ),
      ],
    );
  }
}
