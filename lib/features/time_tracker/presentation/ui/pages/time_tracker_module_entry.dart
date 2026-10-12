/// Module: time_tracker / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_module_entry.dart
/// Purpose: Declares `TimeTrackerModuleEntry` — what
///          `Modules.timeTracker.widget` returns — provides the module's
///          cubits and hosts its screens in a nested Navigator, behind the
///          View gate.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Same shape as `TodoModuleEntry`: the MultiBlocProvider sits ABOVE the
/// nested Navigator so pushed routes (phase 2) still find the cubits, and the
/// shell's rail / header (tablet) and bottom nav (phone) stay visible.
///
/// NO GlobalKey on the nested Navigator (To-Do lesson, 8/10/2026): the
/// module can be built twice at once (the shell's IndexedStack + a pushed
/// copy from Home / Notifications); a shared key made both Navigators claim
/// it ("Duplicate GlobalKey" every frame).
///
/// View gate: without a single Time Tracker switch that shows something
/// (check-in or any tab), the user sees the no-access message instead.
///
/// Updated: 8/10/2026 - phase 2: also provides `CheckInCubit` (only with
/// `Check_In_And_Out`), `PersonalDashboardCubit` and `AttendanceCubit`
/// (lazy — created the first time their tab is opened).
/// Updated: 9/10/2026 - phase 3: `LocationsCubit`, `EmployeesCubit`,
/// `RequestTypesCubit` (lazy; pushed forms / details read them).
/// Updated: 9/10/2026 - phase 4: `RequestsCubit` (shared feed of the
/// Requests + Approvals tabs) and `RequestActionsCubit`; notification deep
/// link — [initialRequestId] (phone push) / [pendingRequestId] (tablet
/// shell, same one-shot hint as `TodoModuleEntry.pendingTodoId`) opens that
/// request's details on top of the main page, as the requester or, with
/// [initialAsApproval] / [pendingAsApproval], as the approver.
/// Updated: 9/10/2026 - phase 6: [initialTab] (home quick buttons) and
/// [initialAttendanceDate] (calendar late / absent card → Attendance tab
/// filtered to that day); opening the module runs the reminder sweep
/// (`TimeTrackerReminderSweeper.runFromUi`, throttled to 15 min).
/// Updated: 9/10/2026 - phase 5: `HrDashboardCubit` (only with
/// `HR_Dashboard`) and `VacationBalancesCubit` (only with
/// `View_Vacation_Balances`), both lazy — created the first time their tab
/// is opened.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/90-app_scroll_behavior.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/pages/request_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_reminder_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_table_filter.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TimeTrackerModuleEntry extends StatelessWidget {
  const TimeTrackerModuleEntry({
    super.key,
    this.initialRequestId,
    this.initialAsApproval = false,
    this.initialTab,
    this.initialAttendanceDate,
  });

  /// Opens this request's details on top of the main page (notification
  /// View on a phone, where the module is pushed). Wins over the pending
  /// hint.
  final String? initialRequestId;

  /// [initialRequestId] opens the APPROVER's details.
  final bool initialAsApproval;

  /// ADDED 9/10/2026 (phase 6) — open on this tab (home quick buttons:
  /// Requests / Approvals). Ignored when the user may not see it.
  final TimeTrackerTab? initialTab;

  /// ADDED 9/10/2026 (phase 6) — open the Attendance tab filtered to this
  /// day (a late / absent calendar card).
  final DateTime? initialAttendanceDate;

  /// One-shot hint from the notification inbox on the tablet / desktop
  /// shell (the drawer builds `Modules.timeTracker.widget`, so nothing can
  /// be passed in). Armed just before the drawer switches; consumed and
  /// cleared — used or not — on the next build.
  static String? pendingRequestId;
  static bool pendingAsApproval = false;

  @override
  Widget build(BuildContext context) {
    final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
    final String? pending = pendingRequestId;
    final bool pendingApproval = pendingAsApproval;
    pendingRequestId = null;
    pendingAsApproval = false;
    if (!access.canView) return const _TimeTrackerNoAccess();
    final String requestId = (initialRequestId ?? pending ?? '').trim();
    final bool asApproval = initialRequestId != null ? initialAsApproval : pendingApproval;
    final bool opensRequest = requestId.isNotEmpty;
    // Read here, in build — not inside a provider's `create` (To-Do lesson).
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // Phase 6 (9/10/2026): calendar / home deep links.
    final DateTime? attendanceDay = opensRequest ? null : initialAttendanceDate;
    final TimeTrackerTab? preferredTab = opensRequest
        ? (asApproval ? TimeTrackerTab.approvals : TimeTrackerTab.requests)
        : (attendanceDay != null ? TimeTrackerTab.attendance : initialTab);
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<TimeTrackerHomeCubit>(
          create: (_) {
            // Phase 6 (9/10/2026): the time-driven reminders (throttled,
            // fire-and-forget, never throws).
            TimeTrackerReminderSweeper.runFromUi(isArabic: isArabic);
            return GetIt.instance<TimeTrackerHomeCubit>()..init(preferredTab: preferredTab);
          },
        ),
        BlocProvider<CheckInCubit>(
          lazy: !access.canCheckInAndOut,
          create: (_) => GetIt.instance<CheckInCubit>()..init(),
        ),
        BlocProvider<PersonalDashboardCubit>(
          create: (_) => GetIt.instance<PersonalDashboardCubit>()..init(),
        ),
        BlocProvider<AttendanceCubit>(
          create: (_) {
            final AttendanceCubit cubit = GetIt.instance<AttendanceCubit>()..init();
            if (attendanceDay != null) cubit.applyFilter(AttendanceFilter.day(attendanceDay));
            return cubit;
          },
        ),
        BlocProvider<LocationsCubit>(
          create: (_) => GetIt.instance<LocationsCubit>()..init(),
        ),
        // 9/10/2026 (QA KP-TT-003): the locale was read INSIDE these lazy
        // `create`s (`Localizations.localeOf(ctx)`) — a lazy provider is
        // created during a descendant's build, where listening to an
        // InheritedWidget throws ("…life-cycle that will never be called
        // again") → red screen on the Request Types / Employees tabs. Use
        // the `isArabic` read above in build, like every other provider.
        BlocProvider<EmployeesCubit>(
          create: (_) => GetIt.instance<EmployeesCubit>()..init(isArabic: isArabic),
        ),
        BlocProvider<RequestTypesCubit>(
          create: (_) => GetIt.instance<RequestTypesCubit>()..init(isArabic: isArabic),
        ),
        // Phase 4 (9/10/2026): Requests + Approvals feed, and their actions.
        BlocProvider<RequestsCubit>(
          lazy: !opensRequest,
          create: (_) => GetIt.instance<RequestsCubit>()..init(isArabic: isArabic),
        ),
        BlocProvider<RequestActionsCubit>(
          create: (_) => GetIt.instance<RequestActionsCubit>(),
        ),
        // Phase 5 (9/10/2026): HR view of the Overview tab, Vacation Balances.
        if (access.canViewHrDashboard)
          BlocProvider<HrDashboardCubit>(
            create: (_) => GetIt.instance<HrDashboardCubit>()..init(isArabic: isArabic),
          ),
        if (access.canViewVacationBalances)
          BlocProvider<VacationBalancesCubit>(
            create: (_) => GetIt.instance<VacationBalancesCubit>()..init(isArabic: isArabic),
          ),
      ],
      child: NoScrollbar(
        child: Navigator(
          onGenerateInitialRoutes: (_, __) => <Route<dynamic>>[
            MaterialPageRoute<void>(builder: (_) => const TimeTrackerHomePage()),
            if (opensRequest)
              MaterialPageRoute<void>(
                builder: (_) => RequestDetailsPage(requestId: requestId, asApprover: asApproval),
              ),
          ],
          onGenerateRoute: (RouteSettings settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const TimeTrackerHomePage(),
          ),
        ),
      ),
    );
  }
}

/// Shown instead of the module when no Time Tracker switch is on.
class _TimeTrackerNoAccess extends StatelessWidget {
  const _TimeTrackerNoAccess();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 24.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CustomEmptyState(),
              SizedBox(height: 12.sp),
              Text(
                S.of(context).timeTrackerNoAccess,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
