/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_ranking_card.dart
/// Purpose: Declares `HrRankingCard` — "Late & Absent Ranking": the five
///          employees with the most late (or absent) days in the chosen
///          period, each with a bar against the top one. Late | Absent
///          switch; a row opens that employee's dashboard.
/// Author: Knowticed Plus team
/// Created at: 13/10/2026 (owner: "more dashboards")
///
/// The core `ChartCard` shell (same header as the charts) and the module's
/// `TtSegmentedToggle` (slides, LOW haptic). Data: `HrDashboardStats.ranking`
/// (pure, the same day book as every other HR number). Bars grow in
/// (`TweenAnimationBuilder`); no splash, LOW haptic on a row.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_navigation.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HrRankingCard extends StatefulWidget {
  const HrRankingCard({super.key, required this.state});

  final HrDashboardState state;

  @override
  State<HrRankingCard> createState() => _HrRankingCardState();
}

class _HrRankingCardState extends State<HrRankingCard> {
  bool _late = true;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<HrEmployeeAttendance> top = widget.state.stats.ranking(late: _late);
    final int max = top.isEmpty ? 1 : (_late ? top.first.late : top.first.absent);
    final Color color = _late ? AppColors.orange : AppColors.red;
    return ChartCard(
      key: const ValueKey<String>('hrRankingCard'),
      title: s.timeTrackerLateAbsentRanking,
      dotIcon: ChartSvg.late,
      trailing: TtSegmentedToggle(
        key: const ValueKey<String>('hrRankingToggle'),
        onCard: true,
        tabs: <String>[s.timeTrackerLate, s.timeTrackerAbsent],
        selectedIndex: _late ? 0 : 1,
        onChanged: (int i) => setState(() => _late = i == 0),
      ),
      child: top.isEmpty
          ? Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 6.h),
              child: Text(s.timeTrackerRankingEmpty,
                  key: const ValueKey<String>('hrRankingEmpty'),
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
            )
          : Column(
              key: ValueKey<bool>(_late),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < top.length; i++)
                  _rankRow(context, i, top[i], max, color, ar),
              ],
            ),
    );
  }

  Widget _rankRow(BuildContext context, int i, HrEmployeeAttendance e, int max, Color color, bool ar) {
    final TimeTrackerEmployee who =
        widget.state.employeeByEmail(e.email) ?? TimeTrackerEmployee(email: e.email);
    final int n = _late ? e.late : e.absent;
    final String department = who.department(isArabic: ar).trim();
    return GestureDetector(
      key: ValueKey<String>('hrRankingRow_${e.email}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        HrDashboardNavigation.openEmployee(context, who);
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(bottom: 10.h),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 22.w,
              child: Text(TimeTrackerFormat.count(context, i + 1),
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText)),
            ),
            TimeTrackerAvatar(photo: who.photo, size: 32.r),
            SizedBox(width: 10.w),
            // Name and bar share the row (fits a phone too).
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(who.name(isArabic: ar), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                  if (department.isNotEmpty)
                    Text(department, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  height: 10.h,
                  color: AppColors.background,
                  alignment: AlignmentDirectional.centerStart,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey<String>('${_late}_${e.email}'),
                    tween: Tween<double>(begin: 0, end: n / max),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (BuildContext context, double t, Widget? _) => FractionallySizedBox(
                      widthFactor: t,
                      child: Container(
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4.r)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 60.w,
              child: Text(TimeTrackerFormat.days(context, n),
                  textAlign: TextAlign.end,
                  style: StyleText.fontSize14Weight500.copyWith(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
