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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class HrNeedsAttentionCard extends StatelessWidget {
  const HrNeedsAttentionCard({super.key, required this.state});

  final HrDashboardState state;

  /// Rows shown per group before "+N more".
  static const int maxRows = 3;

  TimeTrackerEmployee _person(String email) =>
      state.employeeByEmail(email) ?? TimeTrackerEmployee(email: email.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final HrNeedsAttention a = state.stats.attention;
    final bool approvals = HrDashboardNavigation.canOpenApprovals(context);
    return ChartCard(
      key: const ValueKey<String>('hrNeedsAttention'),
      title: s.timeTrackerNeedsAttention,
      dotIcon: ChartSvg.late,
      child: a.isEmpty
          ? Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 6.h),
              child: Text(s.timeTrackerAllClear,
                  key: const ValueKey<String>('hrAttentionAllClear'),
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (a.overdueApprovals.isNotEmpty)
                  _Group(
                    key: const ValueKey<String>('hrAttentionOverdue'),
                    title: s.timeTrackerOverdueApprovals,
                    color: AppColors.orange,
                    count: a.overdueApprovals.length,
                    onViewAll: approvals ? () => HrDashboardNavigation.openApprovals(context) : null,
                    rows: <Widget>[
                      for (final TimeTrackerRequest r in a.overdueApprovals.take(maxRows)) _requestRow(context, r, s),
                    ],
                  ),
                if (a.frequentAbsences.isNotEmpty)
                  _Group(
                    key: const ValueKey<String>('hrAttentionAbsences'),
                    title: s.timeTrackerFrequentAbsences,
                    color: AppColors.red,
                    count: a.frequentAbsences.length,
                    rows: <Widget>[
                      for (final HrAbsenceAlert x in a.frequentAbsences.take(maxRows))
                        _Row(
                          key: ValueKey<String>('hrAttentionAbsence_${x.email}'),
                          employee: _person(x.email),
                          detail: TimeTrackerFormat.absences(context, x.count),
                          onTap: () => HrDashboardNavigation.openEmployee(context, _person(x.email)),
                        ),
                    ],
                  ),
                if (a.missingCheckOuts.isNotEmpty)
                  _Group(
                    key: const ValueKey<String>('hrAttentionCheckOuts'),
                    title: s.timeTrackerMissingCheckOuts,
                    color: AppColors.darkRed,
                    count: a.missingCheckOuts.length,
                    rows: <Widget>[
                      for (final AttendanceDay d in a.missingCheckOuts.take(maxRows))
                        _Row(
                          key: ValueKey<String>('hrAttentionCheckOut_${d.employeeEmail}'),
                          employee: _person(d.employeeEmail),
                          detail: s.timeTrackerCheckedInNoCheckOut(
                              TimeTrackerFormat.time(context, d.openSession?.checkInAt)),
                          onTap: () => HrDashboardNavigation.openEmployee(context, _person(d.employeeEmail)),
                        ),
                    ],
                  ),
                if (a.waitingTransactions.isNotEmpty)
                  _Group(
                    key: const ValueKey<String>('hrAttentionTransactions'),
                    title: s.timeTrackerTransactionsWaiting,
                    color: AppColors.blue,
                    count: a.waitingTransactions.length,
                    onViewAll: approvals
                        ? () => HrDashboardNavigation.openApprovals(context, transactionsOnly: true)
                        : null,
                    rows: <Widget>[
                      for (final TimeTrackerRequest r in a.waitingTransactions.take(maxRows))
                        _requestRow(context, r, s),
                    ],
                  ),
              ],
            ),
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

/// One group: title + count pill (+ View All), its rows, "+N more".
class _Group extends StatelessWidget {
  const _Group({
    super.key,
    required this.title,
    required this.color,
    required this.count,
    required this.rows,
    this.onViewAll,
  });

  final String title;
  final Color color;
  final int count;
  final List<Widget> rows;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final int more = count - rows.length;
    final VoidCallback? viewAll = onViewAll;
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(title, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 1.h),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadiusDirectional.circular(8.r)),
                      child: Text(TimeTrackerFormat.count(context, count),
                          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.white)),
                    ),
                  ],
                ),
              ),
              // 12/10/2026 (owner N2 / R9): a clear gap between the count
              // badge and "View All"; `TtLink` keeps the underline off the text.
              if (viewAll != null) ...<Widget>[
                SizedBox(width: 12.w),
                TtLink(label: s.viewAll, style: StyleText.fontSize12Weight500, padding: EdgeInsets.zero, onTap: viewAll),
              ],
            ],
          ),
          SizedBox(height: 6.h),
          for (final Widget r in rows) Padding(padding: EdgeInsetsDirectional.only(bottom: 6.h), child: r),
          // 12/10/2026 (owner B3): no loose "+2 more" line when "View All"
          // (which opens the full list) is there — the badge already says
          // how many there are.
          if (more > 0 && viewAll == null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: viewAll,
              child: Text(s.timeTrackerMoreItems(TimeTrackerFormat.count(context, more)),
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
            ),
        ],
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
