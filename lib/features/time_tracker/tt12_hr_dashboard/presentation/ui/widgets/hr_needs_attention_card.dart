/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_needs_attention_card.dart
/// Purpose: Declares `HrNeedsAttentionCard` — what HR should act on today:
///          approvals pending more than 2 days · employees with 3 or more
///          absences this month · missing check-outs yesterday ·
///          transactions waiting. Every row opens the right screen.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5 — owner asked to innovate, keeping the
/// Figma look)
///
/// The core `ChartCard` shell (same header as the charts). Only groups with
/// something in them are shown (owner rule: no empty noise); with nothing at
/// all the card says so. Each group: title + count pill (+ "View All" →
/// the Approvals tab on Pending, transactions only for the last group, when
/// the user has that tab), then up to [maxRows] rows (+ "+N more"):
///   * a request → its approver details when it is in the viewer's
///     Approvals, else the requester's dashboard;
///   * an absence / missing check-out → that employee's dashboard.
/// Rows: avatar · name · what is wrong; LOW haptic, no splash (owner rule).
/// Updated: 13/10/2026 - owner (redesign): four count TILES in one row
/// (Overdue Approvals · Frequent Absences · Missing Check-Outs ·
/// Transactions Waiting; a 0 tile is greyed), tap one to choose it; the
/// chosen list runs under them as a grid of people cards — 3 a row in
/// landscape, 2 in portrait, 1 on a phone; two rows, then View All. The card keeps one height whatever the numbers.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_attention.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_charts.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_navigation.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HrNeedsAttentionCard extends StatefulWidget {
  const HrNeedsAttentionCard({super.key, required this.state});

  final HrDashboardState state;

  @override
  State<HrNeedsAttentionCard> createState() => _HrNeedsAttentionCardState();
}

enum _Kind { overdue, absences, checkOuts, transactions }

class _HrNeedsAttentionCardState extends State<HrNeedsAttentionCard> {
  /// The chosen tile (null = the first one with something in it).
  _Kind? _chosen;

  HrDashboardState get state => widget.state;

  TimeTrackerEmployee _person(String email) =>
      state.employeeByEmail(email) ?? TimeTrackerEmployee(email: email.trim().toLowerCase());

  int _count(HrNeedsAttention a, _Kind k) {
    switch (k) {
      case _Kind.overdue:
        return a.overdueApprovals.length;
      case _Kind.absences:
        return a.frequentAbsences.length;
      case _Kind.checkOuts:
        return a.missingCheckOuts.length;
      case _Kind.transactions:
        return a.waitingTransactions.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final HrNeedsAttention a = state.stats.attention;
    final bool approvals = HrDashboardNavigation.canOpenApprovals(context);
    final List<(_Kind, String, Color, String)> kinds = <(_Kind, String, Color, String)>[
      (_Kind.overdue, s.timeTrackerOverdueApprovals, AppColors.orange, 'hrAttentionOverdue'),
      (_Kind.absences, s.timeTrackerFrequentAbsences, AppColors.red, 'hrAttentionAbsences'),
      (_Kind.checkOuts, s.timeTrackerMissingCheckOuts, AppColors.darkRed, 'hrAttentionCheckOuts'),
      (_Kind.transactions, s.timeTrackerTransactionsWaiting, AppColors.blue, 'hrAttentionTransactions'),
    ];
    _Kind? chosen = _chosen;
    if (chosen == null || _count(a, chosen) == 0) {
      chosen = null;
      for (final (_Kind, String, Color, String) k in kinds) {
        if (_count(a, k.$1) > 0) {
          chosen = k.$1;
          break;
        }
      }
    }
    final bool phone = context.isPhone;
    final List<Widget> tiles = <Widget>[
      for (final (_Kind, String, Color, String) k in kinds)
        _Tile(
          key: _count(a, k.$1) > 0 ? ValueKey<String>(k.$4) : null,
          label: k.$2,
          color: k.$3,
          count: _count(a, k.$1),
          selected: chosen == k.$1,
          onTap: _count(a, k.$1) == 0
              ? null
              : () {
                  HapticController.low();
                  setState(() => _chosen = k.$1);
                },
        ),
    ];
    return ChartCard(
      key: const ValueKey<String>('hrNeedsAttention'),
      title: s.timeTrackerNeedsAttention,
      dotIcon: ChartSvg.late,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (phone)
            Column(
              spacing: 10.h,
              children: <Widget>[
                for (int i = 0; i < tiles.length; i += 2)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(child: tiles[i]),
                        SizedBox(width: 10.w),
                        Expanded(child: tiles[i + 1]),
                      ],
                    ),
                  ),
              ],
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int i = 0; i < tiles.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: 10.w),
                    Expanded(child: tiles[i]),
                  ],
                ],
              ),
            ),
          SizedBox(height: 12.h),
          if (chosen == null)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 6.h),
              child: Text(s.timeTrackerAllClear,
                  key: const ValueKey<String>('hrAttentionAllClear'),
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
            )
          else
            BounceSwitcher(
              triggerValue: chosen,
              child: _list(context, s, a, chosen, approvals),
            ),
        ],
      ),
    );
  }

  /// The chosen tile's people, one sideways-scrolling row (+ View All).
  Widget _list(BuildContext context, S s, HrNeedsAttention a, _Kind k, bool approvals) {
    final List<Widget> rows;
    VoidCallback? viewAll;
    switch (k) {
      case _Kind.overdue:
        rows = <Widget>[for (final TimeTrackerRequest r in a.overdueApprovals) _requestRow(context, r, s)];
        if (approvals) viewAll = () => HrDashboardNavigation.openApprovals(context);
      case _Kind.absences:
        rows = <Widget>[
          for (final HrAbsenceAlert x in a.frequentAbsences)
            _Row(
              key: ValueKey<String>('hrAttentionAbsence_${x.email}'),
              employee: _person(x.email),
              detail: TimeTrackerFormat.absences(context, x.count),
              onTap: () => HrDashboardNavigation.openEmployee(context, _person(x.email)),
            ),
        ];
      case _Kind.checkOuts:
        rows = <Widget>[
          for (final AttendanceDay d in a.missingCheckOuts)
            _Row(
              key: ValueKey<String>('hrAttentionCheckOut_${d.employeeEmail}'),
              employee: _person(d.employeeEmail),
              detail: s.timeTrackerCheckedInNoCheckOut(TimeTrackerFormat.time(context, d.openSession?.checkInAt)),
              onTap: () => HrDashboardNavigation.openEmployee(context, _person(d.employeeEmail)),
            ),
        ];
      case _Kind.transactions:
        rows = <Widget>[for (final TimeTrackerRequest r in a.waitingTransactions) _requestRow(context, r, s)];
        if (approvals) viewAll = () => HrDashboardNavigation.openApprovals(context, transactionsOnly: true);
    }
    final VoidCallback? all = viewAll;
    final int columns = context.isPhone ? 1 : (context.isLandscape ? 3 : 2);
    final int more = rows.length - columns * 2;
    return Column(
      key: ValueKey<String>('hrAttentionList_${k.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 13/10/2026 (owner): a grid — three cards a row in landscape, two
        // in portrait, one on a phone; the first two rows, then View All.
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double gap = 10.w;
            final double w = (c.maxWidth - gap * (columns - 1)) / columns;
            final List<Widget> shown = rows.take(columns * 2).toList();
            return Wrap(
              spacing: gap,
              runSpacing: 10.h,
              children: <Widget>[for (final Widget r in shown) SizedBox(width: w, child: r)],
            );
          },
        ),
        // Without a list to open, say how many more there are.
        if (all == null && more > 0) ...<Widget>[
          SizedBox(height: 8.h),
          Text(s.timeTrackerMoreItems(TimeTrackerFormat.count(context, more)),
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
        ],
        if (all != null) ...<Widget>[
          SizedBox(height: 8.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TtLink(label: s.viewAll, style: StyleText.fontSize12Weight500, padding: EdgeInsets.zero, onTap: all),
          ),
        ],
      ],
    );
  }

  Widget _requestRow(BuildContext context, TimeTrackerRequest r, S s) {
    final TimeTrackerEmployee who = _person(r.requesterEmail);
    final String what = r.isTransaction ? s.timeTrackerTransactionButton : hrTypeName(context, state, r.requestTypeId);
    final DateTime? since = TimeTrackerHomeStatsRules.waitingSince(r);
    final int days = since == null ? 0 : state.now.difference(since).inDays;
    final String when = r.isTransaction && days <= 2
        ? TimeTrackerFormat.date(context, r.startAt)
        : s.timeTrackerWaitingDays(TimeTrackerFormat.days(context, days));
    return _Row(
      key: ValueKey<String>('hrAttentionRequest_${r.id}'),
      employee: who,
      detail: '$what · $when',
      onTap: () => HrDashboardNavigation.openRequest(context, r, who),
    );
  }
}

/// One count tile: the number big in the tile's colour, the label under it.
/// Chosen = tinted with its colour and outlined; 0 = grey (not tappable).
class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.label,
    required this.color,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool empty = count == 0;
    final Color c = empty ? AppColors.secondaryText : color;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsetsDirectional.all(10.r),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: CardStyles.radius(),
          border: Border.all(color: selected ? c : AppColors.transparent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(TimeTrackerFormat.count(context, count),
                style: StyleText.fontSize24Weight600.copyWith(color: c)),
            SizedBox(height: 4.h),
            Text(label,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: empty ? AppColors.secondaryText : AppColors.text,
                )),
          ],
        ),
      ),
    );
  }
}

/// avatar · name · detail (tap → [onTap]).
class _Row extends StatelessWidget {
  const _Row({super.key, required this.employee, required this.detail, required this.onTap});

  final TimeTrackerEmployee employee;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: CardStyles.radius()),
        child: Row(
          children: <Widget>[
            TimeTrackerAvatar(photo: employee.photo, size: 30.r),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(employee.name(isArabic: ar),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                  Text(detail,
                      maxLines: 2,
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
