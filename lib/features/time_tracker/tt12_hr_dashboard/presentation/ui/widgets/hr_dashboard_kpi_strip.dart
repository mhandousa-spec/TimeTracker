/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_kpi_strip.dart
/// Purpose: Declares `HrDashboardKpiStrip` — the "Today" strip on top of the
///          HR view: Checked In Now · Late Today · Absent Today · On Leave
///          Today · Pending Approvals.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5 — owner asked to innovate, keeping the
/// Figma look)
///
/// Built on the core `OverallStatsCard` (25) — the same card as the
/// dashboard's "Overall" — with the module's Figma Overall icons, so the
/// strip reads as part of the design. Always TODAY, whatever the range.
/// Pending Approvals opens the Approvals tab on its Pending counter
/// (only when the user has that tab). Labels wrap instead of "…".
/// Updated: 9/10/2026 - UI quality pass: `TtStatsCard` — neutral label on
/// ONE line (never wrapped / "…"), colour only on the icon; Pending
/// Approvals keeps its link as a "›" after the number.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_stats_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_navigation.dart';
import 'package:knowticed_plus/generated/l10n.dart';

const String _ttAssets = 'assets/icons_assets/time_tracker_assets';

class HrDashboardKpiStrip extends StatelessWidget {
  const HrDashboardKpiStrip({super.key, required this.kpi});

  final HrDashboardKpi kpi;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool approvals = HrDashboardNavigation.canOpenApprovals(context);
    TtStat stat(String label, int value, String icon, {Color? tint, VoidCallback? onTap, String? key}) => TtStat(
          label: label,
          value: TimeTrackerFormat.count(context, value),
          icon: CustomSvgImage(assetPath: icon, color: tint),
          onTap: onTap,
          tileKey: key == null ? null : ValueKey<String>(key),
        );
    // UI quality pass (9/10/2026, owner 13:45 #4 / 14:17 #1–2): neutral
    // one-line labels; colour only on the icons.
    return TtStatsCard(
      key: const ValueKey<String>('hrKpiStrip'),
      title: s.today,
      stats: <TtStat>[
        stat(s.timeTrackerCheckedInNow, kpi.checkedInNow, '$_ttAssets/tt_overall_present.svg'),
        stat(s.timeTrackerLateToday, kpi.lateToday, '$_ttAssets/tt_overall_late.svg'),
        stat(s.timeTrackerAbsentToday, kpi.absentToday, '$_ttAssets/tt_overall_absence.svg',
            tint: AppTheme.isDark ? AppColors.red : null),
        stat(s.timeTrackerOnLeaveToday, kpi.onLeaveToday, '$_ttAssets/tt_overall_vacation.svg'),
        stat(
          s.timeTrackerPendingApprovals,
          kpi.pendingApprovals,
          ChartSvg.request,
          tint: AppColors.yellow,
          onTap: approvals ? () => HrDashboardNavigation.openApprovals(context) : null,
          key: 'hrKpiPendingApprovals',
        ),
      ],
    );
  }
}
