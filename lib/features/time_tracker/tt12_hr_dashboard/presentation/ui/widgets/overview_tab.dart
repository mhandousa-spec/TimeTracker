/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: overview_tab.dart
/// Purpose: Declares `OverviewTab` — the dashboard tab's body: "My
///          Dashboard | HR" toggle (when both are allowed), then the
///          personal dashboard or the HR view.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Brief §A / inventory §3.2 (switch → UI):
///   * only `Personal_Dashboard` → the tab is "Dashboard" and shows the
///     personal dashboard (no toggle);
///   * only `HR_Dashboard` → the tab is "Overview" and shows the HR view;
///   * both → "Overview" with the toggle (Figma `661:43164`: a white
///     200×40 container on the page, active tab yellow). It opens on the
///     first segment, My Dashboard (the Figma HR frames show the HR side
///     selected — decision to confirm). The choice is kept by
///     `HrDashboardCubit`, so it survives switching tabs.
/// Reopening the tab re-reads attendance older than the cache (2 min), so
/// "Checked In Now" stays current.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_view.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/ui/widgets/personal_dashboard_tab.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void initState() {
    super.initState();
    if (_access.canViewHrDashboard) context.read<HrDashboardCubit>().refreshIfStale();
  }

  @override
  Widget build(BuildContext context) {
    final bool personal = _access.canViewPersonalDashboard;
    if (!_access.canViewHrDashboard) {
      return const PersonalDashboardTab(key: ValueKey<String>('personalDashboardTab'));
    }
    return BlocBuilder<HrDashboardCubit, HrDashboardState>(
      buildWhen: (HrDashboardState a, HrDashboardState b) => a.showHr != b.showHr,
      builder: (BuildContext context, HrDashboardState state) {
        final bool hr = !personal || state.showHr;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (personal) ...<Widget>[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TtSegmentedToggle(
                  key: const ValueKey<String>('overviewToggle'),
                  compact: true,
                  tabs: <String>[S.of(context).timeTrackerMyDashboard, S.of(context).timeTrackerHrStep],
                  selectedIndex: hr ? 1 : 0,
                  onChanged: (int i) => context.read<HrDashboardCubit>().setShowHr(i == 1),
                ),
              ),
              SizedBox(height: 15.h),
            ],
            if (hr)
              const HrDashboardView()
            else
              const PersonalDashboardTab(key: ValueKey<String>('personalDashboardTab')),
          ],
        );
      },
    );
  }
}
