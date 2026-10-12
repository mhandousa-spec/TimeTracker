/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: absent_day_sweeper.dart
/// Purpose: Declares `AbsentDaySweeper` — writes `absent` attendance days
///          for the SIGNED-IN employee's past working days with no record.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 20 (8/10/2026): absent days are filled by the app when
/// Time Tracker is opened — a client sweep, no server. It is strictly
/// per-user (even an HR viewer only sweeps their own days). Which days is
/// decided by the pure `AbsentDayRules`; this class only gathers the inputs
/// and writes. Writes are CREATE-ONLY (`{email}_{yyyy-MM-dd}` documents are
/// never overwritten), so running it twice — or on two devices at once —
/// is harmless.
///
/// Errors propagate as clean `Exception`s from the repositories; the caller
/// (the home cubit) runs it fire-and-forget.
/// Updated: 9/10/2026 - code review: reads only the employee's OWN requests
/// (finding 9); only leave covering the WHOLE day excuses it (finding 8 —
/// `AbsenceRules.wholeDayLeaves`); an HR shift (unknown week) marks nothing
/// (finding 1 — `AbsentDayRules`).

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absence_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absent_day_rules.dart';

/// Returns "now" (injectable for tests).
typedef TimeTrackerClock = DateTime Function();

class AbsentDaySweeper {
  AbsentDaySweeper({
    required AttendanceBaseRepository attendance,
    required RequestBaseRepository requests,
    required WorkSetupSourceResolver resolver,
    required TimeTrackerAccess access,
    TimeTrackerClock clock = DateTime.now,
  })  : _attendance = attendance,
        _requests = requests,
        _resolver = resolver,
        _access = access,
        _clock = clock;

  final AttendanceBaseRepository _attendance;
  final RequestBaseRepository _requests;
  final WorkSetupSourceResolver _resolver;
  final TimeTrackerAccess _access;
  final TimeTrackerClock _clock;

  /// Function Name: [approvedLeaveRanges]
  ///
  /// Purpose: The days [email]'s approved leave requests (approved, or
  /// approved and under a cancellation review) take off COMPLETELY: all-day
  /// requests, or partial ones spanning the whole shift of a day (finding 8,
  /// 9/10/2026). Transactions are corrections, not leave, so they never
  /// count.
  ///
  /// Parameters:
  ///   [List<TimeTrackerRequest>] requests
  ///   [String] email: lower-cased.
  ///   [WorkSchedule?] schedule: the employee's shift hours.
  ///
  /// Return type: [List<DayRange>]
  static List<DayRange> approvedLeaveRanges(
    List<TimeTrackerRequest> requests,
    String email, {
    WorkSchedule? schedule,
  }) =>
      AbsenceRules.wholeDayLeaves(requests, email, schedule: schedule);

  /// Function Name: [sweep]
  ///
  /// Purpose: Create the missing `absent` days of the signed-in employee.
  ///
  /// Return type: [Future<int>] — how many days were created (0 when the
  /// employee is signed out or not assigned anywhere).
  Future<int> sweep() async {
    final TimeTrackerIdentity me = _access.identity;
    if (me.email.isEmpty) return 0;
    final WorkSetupSource source = await _resolver.resolve();
    final EmployeeWorkSetup? setup = await source.loadWorkSetup(
      employeeEmail: me.email,
      employeeId: me.employeeId,
    );
    if (setup == null) return 0;
    // Unknown week (HR shift, finding 1): nothing is marked — skip the reads.
    if (!setup.schedule.isWorkingWeekKnown) return 0;
    final List<AttendanceDay> days =
        await _attendance.watchEmployeeAttendance(employeeEmail: me.email).first;
    final List<TimeTrackerRequest> requests = await _requests.watchRequestsOf(email: me.email).first;
    final List<DateTime> missing = AbsentDayRules.daysToMarkAbsent(
      now: _clock(),
      schedule: setup.schedule,
      assignmentStart: setup.startDate,
      recordedDays: <DateTime>[for (final AttendanceDay d in days) d.date],
      approvedLeaves: approvedLeaveRanges(requests, me.email, schedule: setup.schedule),
    );
    int created = 0;
    for (final DateTime day in missing) {
      final bool wrote = await _attendance.createDayIfAbsent(
        day: AttendanceDay(
          id: '',
          employeeEmail: me.email,
          date: day,
          status: AttendanceStatus.absent,
        ),
      );
      if (wrote) created++;
    }
    return created;
  }
}
