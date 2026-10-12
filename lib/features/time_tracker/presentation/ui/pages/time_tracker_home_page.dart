/// Module: time_tracker / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_home_page.dart
/// Purpose: Declares `TimeTrackerHomePage` — the module's MAIN PAGE:
///          "Tracking Time" + Hide / Expand · profile card with the check-in
///          control · check-in info strip · tab strip · the open tab.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
/// Updated: 8/10/2026 - phase 2: replaces the phase-1 placeholder with the
///          Figma main page (Employee iPad landscape `661:10375` primary;
///          iPad portrait `661:17426`; iPhone `661:24056`).
///
/// Tabs come from `TimeTrackerAccess.visibleTabs` (role switches + HR
/// licence): Dashboard (Personal_Dashboard), Attendance (View_Attendance)
/// are built; Requests / Approvals / Request Types / Locations / Employees /
/// Vacation Balances are phase 3–4 and show a "coming soon" panel when
/// their switch is on. Phase 3 (9/10/2026): Request Types, Locations and
/// Employees (+ Groups) are built. Phase 4 (9/10/2026): Requests and
/// Approvals are built. The collapsed header (`661:13832`) keeps the
/// check-in control in the title row. Page padding 15 start / end / top;
/// the title row stays fixed and the rest scrolls. Sections slide in.
/// Updated: 9/10/2026 - UI fix round 1: ONE start edge for the whole page
/// (owner finding 8) — [TimeTrackerHomePage.gutter] (15.sp, the same unit
/// the core `SideFrameMasterServices` uses for every pushed Time Tracker
/// page's breadcrumb and content) pads the title row and everything under
/// it, so "Tracking Time", the profile card, the tabs and the cards share
/// one start edge on iPad H / V and iPhone, mirrored in Arabic; the tab
/// strip is `TimeTrackerTabStrip` (every tab reachable, owner finding 9).
/// Updated: 9/10/2026 - phase 5: the dashboard tab is `OverviewTab` with
/// `HR_Dashboard` (HR view / My Dashboard toggle); Vacation Balances is
/// built (`VacationBalancesTab`) — no tab shows "coming soon" any more.
/// Updated: 9/10/2026 - UI quality pass: DEBUG-ONLY 🧪 demo tools at the end
/// of the title row (`TimeTrackerDemoToolsButton`, To-Do placement style).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_state.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_demo_tools.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_profile_card.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_tab_strip.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/ui/widgets/check_in_control.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/ui/widgets/check_in_info_strip.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/ui/widgets/personal_dashboard_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/ui/widgets/attendance_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/locations_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/employees_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/widgets/request_types_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt11_approvals/presentation/ui/widgets/approvals_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/requests_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/overview_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/ui/widgets/vacation_balances_tab.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TimeTrackerHomePage extends StatelessWidget {
  const TimeTrackerHomePage({super.key});

  /// The page's start / end / top padding (owner rule: 15). `.sp`, like the
  /// core frame of the module's pushed pages, so the start edge does not
  /// move between the main page and a details / form page.
  static double get gutter => 15.sp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: TimeTrackerHomePage.gutter,
            end: TimeTrackerHomePage.gutter,
            top: TimeTrackerHomePage.gutter,
          ),
          child: BlocBuilder<TimeTrackerHomeCubit, TimeTrackerHomeState>(
            builder: (BuildContext context, TimeTrackerHomeState state) {
              if (state.isLoading) {
                return const Center(child: CircleProgressMaster());
              }
              if (state.status == TimeTrackerHomeStatus.failure) {
                return _LoadError(
                  onRetry: () => context.read<TimeTrackerHomeCubit>().init(),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _TitleRow(state: state),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _Body(state: state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// "Tracking Time" · (collapsed: check-in control) · Hide / Expand.
class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.state});

  final TimeTrackerHomeState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool collapsed = !state.headerExpanded;
    return SlideInContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  s.timeTrackerTitle,
                  style: (context.isPhone
                          ? StyleText.fontSize24Weight600
                          : StyleText.fontSize28Weight600)
                      .copyWith(color: AppColors.text),
                ),
              ),
              if (collapsed && state.canCheckIn && !context.isPhone)
                const CheckInControl(compact: true),
              // DEBUG builds only (kDebugMode is a compile-time constant, so
              // this is tree-shaken from release): demo data (9/10/2026).
              if (kDebugMode) ...<Widget>[
                SizedBox(width: 10.w),
                const TimeTrackerDemoToolsButton(),
              ],
            ],
          ),
          // UI quality pass (9/10/2026): on a phone the collapsed check-in
          // control gets its own row, so "Tracking Time" never wraps.
          if (collapsed && state.canCheckIn && context.isPhone) ...<Widget>[
            SizedBox(height: 8.h),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: CheckInControl(compact: true),
            ),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            // 12/10/2026 (owner R9): `TtLink` — the underline clears the text.
            child: TtLink(
              key: const ValueKey<String>('timeTrackerHideExpand'),
              label: collapsed ? s.expand : s.hide,
              padding: EdgeInsetsDirectional.only(top: 6.h, bottom: 4.h),
              onTap: () => context.read<TimeTrackerHomeCubit>().toggleHeader(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final TimeTrackerHomeState state;

  @override
  Widget build(BuildContext context) {
    final TimeTrackerTab? tab = state.selectedTab;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ImplicitExpand(
          expanded: state.headerExpanded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SlideInContent(
                delay: const Duration(milliseconds: 60),
                child: TimeTrackerProfileCard(
                  identity: GetIt.instance<TimeTrackerAccess>().identity,
                  showCheckIn: state.canCheckIn,
                ),
              ),
              if (state.canCheckIn) ...<Widget>[
                SizedBox(height: 15.h),
                const CheckInInfoStrip(),
              ],
            ],
          ),
        ),
        SizedBox(height: 20.h),
        if (state.tabs.isNotEmpty)
          SlideInContent(
            delay: const Duration(milliseconds: 120),
            child: TimeTrackerTabStrip(
              key: const ValueKey<String>('timeTrackerTabStrip'),
              labels: <String>[
                for (final TimeTrackerTab t in state.tabs)
                  t.label(context, hasHrDashboard: state.hasHrDashboard),
              ],
              selectedIndex: tab == null ? 0 : state.tabs.indexOf(tab),
              onChanged: (int i) {
                HapticController.low();
                context.read<TimeTrackerHomeCubit>().selectTab(state.tabs[i]);
              },
            ),
          ),
        SizedBox(height: 15.h),
        if (tab != null) _TabBody(tab: tab),
      ],
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.tab});

  final TimeTrackerTab tab;

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case TimeTrackerTab.dashboard:
        // Phase 5 (9/10/2026): "Dashboard" (personal only) or "Overview"
        // (HR view, with the My Dashboard | HR toggle when both are on).
        final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
        if (access.canViewHrDashboard) {
          return const OverviewTab(key: ValueKey<String>('overviewTab'));
        }
        return access.canViewPersonalDashboard
            ? const PersonalDashboardTab(key: ValueKey<String>('personalDashboardTab'))
            : const _ComingSoon();
      case TimeTrackerTab.attendance:
        return const AttendanceTab(key: ValueKey<String>('attendanceTab'));
      case TimeTrackerTab.requestTypes:
        return const RequestTypesTab(key: ValueKey<String>('requestTypesTab'));
      case TimeTrackerTab.locations:
        return const LocationsTab(key: ValueKey<String>('locationsTab'));
      case TimeTrackerTab.employees:
        return const EmployeesTab(key: ValueKey<String>('employeesTab'));
      case TimeTrackerTab.requests:
        return const RequestsTab(key: ValueKey<String>('requestsTab'));
      case TimeTrackerTab.approvals:
        return const ApprovalsTab(key: ValueKey<String>('approvalsTab'));
      case TimeTrackerTab.vacationBalances:
        // Phase 5 (9/10/2026).
        return const VacationBalancesTab(key: ValueKey<String>('vacationBalancesTab'));
    }
  }
}

/// Placeholder of a tab whose screens come in a later phase.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey<String>('timeTrackerComingSoon'),
      padding: EdgeInsetsDirectional.symmetric(vertical: 30.h),
      child: Column(
        children: <Widget>[
          const CustomEmptyState(),
          SizedBox(height: 12.h),
          Text(
            S.of(context).timeTrackerSectionComingSoon,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

/// Load failure with a retry button.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            s.timeTrackerLoadError,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 12.h),
          customButton(title: s.timeTrackerRetry, function: onRetry),
        ],
      ),
    );
  }
}
