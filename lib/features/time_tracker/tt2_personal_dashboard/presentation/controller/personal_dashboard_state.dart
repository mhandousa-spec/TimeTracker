/// Module: time_tracker / tt2_personal_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: personal_dashboard_state.dart
/// Purpose: Declares `PersonalDashboardState` (+ `PersonalDashboardStatus`)
///          — the raw inputs of the Personal Dashboard tab and the derived
///          `PersonalDashboardStats` for the chosen range.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// One immutable state + `copyWith` + status enum + derived getters
/// (playbook §3). The numbers are computed by the pure
/// `PersonalDashboardStats.compute`.
/// Updated: 9/10/2026 - code review: `schedule` (untrusted absent rows are
/// not counted — finding 1) and `balanceUnavailable` (a failed balance read
/// is not shown as 0 days).
/// Updated: 9/10/2026 - QA KP-TT-013: `assignmentStart`; the numbers use the
/// HR view's day rule at [now] (same Absence as HR).

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/personal_dashboard_stats.dart';

enum PersonalDashboardStatus { initial, loading, loaded, failure }

/// Whether the Late History bars show how often or how long.
enum LateHistoryMode { counts, minutes }

class PersonalDashboardState {
  PersonalDashboardState({
    this.status = PersonalDashboardStatus.initial,
    this.email = '',
    this.days = const <AttendanceDay>[],
    this.requests = const <TimeTrackerRequest>[],
    this.vacationDaysLeft = 0,
    this.locationNames = const <String, String>{},
    this.range = DashboardRange.year,
    this.customSpan,
    this.lateMode = LateHistoryMode.minutes,
    DateTime? now,
    this.errorMessage = '',
    this.schedule,
    this.balanceUnavailable = false,
    this.assignmentStart,
  }) : now = now ?? DateTime.now();

  final PersonalDashboardStatus status;
  final String email;
  final List<AttendanceDay> days;
  final List<TimeTrackerRequest> requests;
  final double vacationDaysLeft;

  /// Location id → name (Work Locations donut).
  final Map<String, String> locationNames;
  final DashboardRange range;
  final DateSpan? customSpan;
  final LateHistoryMode lateMode;
  final DateTime now;
  final String errorMessage;

  /// ADDED 9/10/2026 (code review finding 1): the employee's schedule —
  /// absent rows it cannot trust are not counted (null = all counted).
  final WorkSchedule? schedule;

  /// ADDED 9/10/2026 (code review): the balance could not be read — the
  /// tile shows "—" instead of a misleading 0.
  final bool balanceUnavailable;

  /// ADDED 9/10/2026 (QA KP-TT-013): first day of the employee's
  /// assignment — absences are counted from it, like the HR view.
  final DateTime? assignmentStart;

  /// The days the chosen range covers.
  DateSpan get span => DateSpan.of(range, now, custom: customSpan);

  /// Every number of the tab (QA KP-TT-013: the HR view's day rule, at [now]).
  PersonalDashboardStats get stats => PersonalDashboardStats.compute(
        days: days,
        requests: requests,
        email: email,
        span: span,
        vacationDaysLeft: vacationDaysLeft,
        schedule: schedule,
        assignmentStart: assignmentStart,
        now: now,
      );

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [PersonalDashboardState]
  PersonalDashboardState copyWith({
    PersonalDashboardStatus? status,
    String? email,
    List<AttendanceDay>? days,
    List<TimeTrackerRequest>? requests,
    double? vacationDaysLeft,
    Map<String, String>? locationNames,
    DashboardRange? range,
    DateSpan? customSpan,
    LateHistoryMode? lateMode,
    DateTime? now,
    String? errorMessage,
    WorkSchedule? schedule,
    bool? balanceUnavailable,
    DateTime? assignmentStart,
  }) =>
      PersonalDashboardState(
        status: status ?? this.status,
        email: email ?? this.email,
        days: days ?? this.days,
        requests: requests ?? this.requests,
        vacationDaysLeft: vacationDaysLeft ?? this.vacationDaysLeft,
        locationNames: locationNames ?? this.locationNames,
        range: range ?? this.range,
        customSpan: customSpan ?? this.customSpan,
        lateMode: lateMode ?? this.lateMode,
        now: now ?? this.now,
        errorMessage: errorMessage ?? this.errorMessage,
        schedule: schedule ?? this.schedule,
        balanceUnavailable: balanceUnavailable ?? this.balanceUnavailable,
        assignmentStart: assignmentStart ?? this.assignmentStart,
      );
}
