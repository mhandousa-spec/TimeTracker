/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_view.dart
/// Purpose: Declares `HrDashboardView` — the HR view of the Overview tab:
///          filters · picked employees · Today strip · Needs attention ·
///          Requests + Request Types donuts · Attendance History · Request
///          Types bars · Request Timeline.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Figma HR Dashboard `661:42563` (iPad landscape; `661:42895` one employee
/// picked, `661:43247` several), iPhone `661:47746` (cards stack). The two
/// improvements the owner asked for (Today strip, Needs attention) sit above
/// the Figma cards in the same card style. Donuts take half a row each on a
/// tablet (owner chart rule), bars a full row; on a phone everything
/// stacks. Sections slide in one after the other (animation standard); a
/// range change keeps the cards and shows a thin progress line.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_charts.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_filters.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_kpi_strip.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_needs_attention_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_picked_employees.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_ranking_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HrDashboardView extends StatelessWidget {
  const HrDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HrDashboardCubit, HrDashboardState>(
      builder: (BuildContext context, HrDashboardState state) {
        if (state.isLoading) {
          return Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
            child: const Center(child: CircleProgressMaster()),
          );
        }
        if (state.status == HrDashboardStatus.failure) {
          return Padding(
            key: const ValueKey<String>('hrDashboardError'),
            padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
            child: Text(
              S.of(context).timeTrackerLoadError,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red),
            ),
          );
        }
        final bool phone = context.isPhone;
        final Widget requests = HrRequestsDonut(stats: state.stats);
        final Widget types = HrRequestTypesDonut(state: state);
        Widget section(int i, Widget child) => SlideInContent(delay: Duration(milliseconds: 60 * i), child: child);
        return Column(
          key: const ValueKey<String>('hrDashboardView'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            section(0, HrDashboardFilterBar(state: state)),
            SizedBox(
              height: 15.h,
              child: state.attendanceLoading
                  ? Center(
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: AppColors.primary,
                        backgroundColor: AppColors.transparent,
                      ),
                    )
                  : null,
            ),
            if (state.canFilterByEmployee && state.pickedEmployees.isNotEmpty) ...<Widget>[
              section(1, HrPickedEmployees(people: state.pickedEmployees)),
              SizedBox(height: 15.h),
            ],
            section(1, HrDashboardKpiStrip(kpi: state.stats.kpi)),
            SizedBox(height: 15.h),
            section(2, HrNeedsAttentionCard(state: state)),
            SizedBox(height: 15.h),
            // 13/10/2026 (owner: "more dashboards"): who is late / absent most.
            section(2, HrRankingCard(state: state)),
            SizedBox(height: 15.h),
            section(
              3,
              phone
                  ? Column(children: <Widget>[requests, SizedBox(height: 15.h), types])
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(child: requests),
                          SizedBox(width: 15.w),
                          Expanded(child: types),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 15.h),
            section(4, HrAttendanceHistoryCard(state: state)),
            SizedBox(height: 15.h),
            section(5, HrRequestTypeBarsCard(state: state)),
            SizedBox(height: 15.h),
            section(6, HrRequestTimelineCard(stats: state.stats)),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }
}
