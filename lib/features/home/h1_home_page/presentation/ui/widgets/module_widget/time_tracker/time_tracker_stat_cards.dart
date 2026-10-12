/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_stat_cards.dart
/// Purpose: Declares the five Time Tracker home cards that show figures —
///          `TimeTrackerPresenceCard`, `TimeTrackerTotalsCard`,
///          `TimeTrackerStatusCard`, `TimeTrackerMyRequestCard` and
///          `TimeTrackerApproverCard`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Time Tracker phase 6 (brief §A), Figma "Widgets" column (inventory §5),
/// copied 1:1 and wired to live data (`TimeTrackerHomeCardsCubit`):
///   * Presence `2583:26557` (260) — Present · Absence · Late, this month
///     (Figma "Presents" fixed to "Present");
///   * Totals `2583:27002` (405) — Total Present · Total Requests · Total
///     Late · Vacations, this month;
///   * Tracker Status `2583:26899` (260) — my requests Approved · Pending ·
///     Rejected · Canceled (Under Review counted as Pending);
///   * My Request `2583:26771` (125) — Total + rejected / approved / pending
///     (the Services "My Request" layout; Time Tracker icon, not the headset);
///   * Tracker Approver `2583:26697` (260) — the Approvals tab's Approved ·
///     Pending · Rejected; the Pending tile opens the pending approvals
///     with Reject / Approve (`showTimeTrackerPendingApprovals`).
/// Tapping a card opens the module on the matching tab.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/time_tracker_home_cards_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/time_tracker/time_tracker_home_card_parts.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/time_tracker/time_tracker_pending_approvals_sheet.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Figma "Tracker" — Present · Absence · Late (this month).
class TimeTrackerPresenceCard extends StatelessWidget {
  const TimeTrackerPresenceCard({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return TimeTrackerHomeCardScope(
      card: TimeTrackerHomeCard.presence,
      title: s.tracker,
      width: kHomeWidgetCompactWidth,
      onTap: () => openTimeTrackerModule(context, tab: TimeTrackerTab.attendance),
      builder: (BuildContext context, TimeTrackerHomeCardsState state) {
        String f(int v) => timeTrackerFigure(context, v, ready: state.isReady);
        final TimeTrackerHomeStats st = state.stats;
        return TimeTrackerTileRow(
          tiles: <TimeTrackerTile>[
            TimeTrackerTile(icon: TimeTrackerHomeSvg.present, label: s.timeTrackerPresent, value: f(st.present)),
            TimeTrackerTile(icon: TimeTrackerHomeSvg.absence, label: s.timeTrackerAbsence, value: f(st.absent)),
            TimeTrackerTile(icon: TimeTrackerHomeSvg.late, label: s.timeTrackerLate, value: f(st.late)),
          ],
        );
      },
    );
  }
}

/// Figma "Tracker" totals — Total Present · Total Requests · Total Late ·
/// Vacations (this month).
class TimeTrackerTotalsCard extends StatelessWidget {
  const TimeTrackerTotalsCard({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return TimeTrackerHomeCardScope(
      card: TimeTrackerHomeCard.totals,
      title: s.tracker,
      width: kHomeWidgetWideWidth,
      onTap: () => openTimeTrackerModule(context, tab: TimeTrackerTab.attendance),
      builder: (BuildContext context, TimeTrackerHomeCardsState state) {
        String f(int v) => timeTrackerFigure(context, v, ready: state.isReady);
        final TimeTrackerHomeStats st = state.stats;
        return TimeTrackerTileRow(
          tiles: <TimeTrackerTile>[
            TimeTrackerTile(icon: TimeTrackerHomeSvg.present, label: s.totalPresent, value: f(st.present)),
            // Figma draws the same calendar glyph as Absence on this tile.
            TimeTrackerTile(icon: TimeTrackerHomeSvg.absence, label: s.totalRequests, value: f(st.monthRequests)),
            TimeTrackerTile(icon: TimeTrackerHomeSvg.late, label: s.totalLate, value: f(st.late)),
            TimeTrackerTile(icon: TimeTrackerHomeSvg.vacation, label: s.timeTrackerVacations, value: f(st.vacationDays)),
          ],
        );
      },
    );
  }
}

/// Figma "Tracker" status — my requests Approved · Pending · Rejected ·
/// Canceled.
class TimeTrackerStatusCard extends StatelessWidget {
  const TimeTrackerStatusCard({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return TimeTrackerHomeCardScope(
      card: TimeTrackerHomeCard.trackerStatus,
      title: s.tracker,
      width: kHomeWidgetCompactWidth,
      onTap: () => openTimeTrackerModule(context, tab: TimeTrackerTab.requests),
      builder: (BuildContext context, TimeTrackerHomeCardsState state) {
        String f(RequestBucket b) => timeTrackerFigure(context, state.stats.myCount(b), ready: state.isReady);
        return _StatRow(
          children: <Widget>[
            HomeStatTile(
                icon: HomeWidgetSvg.approved,
                label: s.timeTrackerApproved,
                value: f(RequestBucket.approved),
                labelMaxLines: 1),
            HomeStatTile(
                icon: HomeWidgetSvg.pending, label: s.timeTrackerPending, value: f(RequestBucket.pending), labelMaxLines: 1),
            HomeStatTile(
                icon: HomeWidgetSvg.rejected,
                label: s.timeTrackerRejected,
                value: f(RequestBucket.rejected),
                labelMaxLines: 1),
            HomeStatTile(
              icon: TimeTrackerHomeSvg.canceled,
              iconColor: AppColors.red,
              label: s.timeTrackerCanceled,
              value: f(RequestBucket.canceled),
              labelMaxLines: 1,
            ),
          ],
        );
      },
    );
  }
}

/// Figma "My Request" — Total, then rejected / approved / pending.
class TimeTrackerMyRequestCard extends StatelessWidget {
  const TimeTrackerMyRequestCard({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return TimeTrackerHomeCardScope(
      card: TimeTrackerHomeCard.myRequest,
      title: s.myRequest,
      width: kHomeWidgetNarrowWidth,
      onTap: () => openTimeTrackerModule(context, tab: TimeTrackerTab.requests),
      builder: (BuildContext context, TimeTrackerHomeCardsState state) {
        String f(RequestBucket b) => timeTrackerFigure(context, state.stats.myCount(b), ready: state.isReady);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${s.timeTrackerTotal} ${f(RequestBucket.all)}', style: CardStyles.label(10)),
            SizedBox(height: 4.h),
            // The three glyphs in the order Figma draws them: rejected,
            // approved, still waiting.
            HomeCountLine(icon: HomeWidgetSvg.rejectedStamp, value: f(RequestBucket.rejected)),
            HomeCountLine(icon: HomeWidgetSvg.checkGreen, value: f(RequestBucket.approved)),
            HomeCountLine(icon: HomeWidgetSvg.hourglass, value: f(RequestBucket.pending)),
          ],
        );
      },
    );
  }
}

/// Figma "Tracker Approver" — the Approvals tab's Approved · Pending ·
/// Rejected; Pending opens the requests waiting for me.
class TimeTrackerApproverCard extends StatelessWidget {
  const TimeTrackerApproverCard({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return TimeTrackerHomeCardScope(
      card: TimeTrackerHomeCard.trackerApprover,
      title: s.timeTrackerTrackerApprover,
      width: kHomeWidgetCompactWidth,
      onTap: () => openTimeTrackerModule(context, tab: TimeTrackerTab.approvals),
      builder: (BuildContext context, TimeTrackerHomeCardsState state) {
        String f(RequestBucket b) => timeTrackerFigure(context, state.stats.approvalCount(b), ready: state.isReady);
        return _StatRow(
          children: <Widget>[
            HomeStatTile(
                icon: HomeWidgetSvg.approved,
                label: s.timeTrackerApproved,
                value: f(RequestBucket.approved),
                labelMaxLines: 1),
            GestureDetector(
              key: const ValueKey<String>('timeTrackerApproverPendingTile'),
              behavior: HitTestBehavior.opaque,
              onTap: state.isReady
                  ? () {
                      HapticController.low();
                      showTimeTrackerPendingApprovals(context);
                    }
                  : null,
              child: HomeStatTile(
                icon: HomeWidgetSvg.pending,
                label: s.timeTrackerPending,
                value: f(RequestBucket.pending),
                labelMaxLines: 1,
              ),
            ),
            HomeStatTile(
                icon: HomeWidgetSvg.rejected,
                label: s.timeTrackerRejected,
                value: f(RequestBucket.rejected),
                labelMaxLines: 1),
          ],
        );
      },
    );
  }
}

/// `HomeStatTileRow`'s layout (own width capped at an equal share, even
/// gaps) for any widgets — so one tile can be wrapped in a tap target.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (int i = 0; i < children.length; i++)
          Flexible(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: i == children.length - 1 ? 0 : 6.w),
              child: children[i],
            ),
          ),
      ],
    );
  }
}
