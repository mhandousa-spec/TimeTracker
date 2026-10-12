/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: personal_dashboard_stats.dart
/// Purpose: Declares `PersonalDashboardStats` — every number of the Personal
///          Dashboard tab for one employee and one date span — and
///          `MonthLate` (one Late History bar).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma Employee main page (`661:10375`): Overall (Present / Absence / Late
/// / Vacations Credit), Requests donut (Approved / Pending / Rejected /
/// Canceled + total), Late History bars BY MONTH (Counts or Minutes), and on
/// iPad portrait a Work Locations donut. Rules (phase-2 assumptions,
/// STATUS.md):
///   * Present counts every attended day (present + late); Late counts late
///     days; Absence counts absent days — all inside the span.
///   * Vacations Credit is the remaining balance (not span-bound).
///   * Requests are the employee's own leave requests (not transactions)
///     whose start falls inside the span; Pending includes "under review",
///     Canceled includes "canceled by HR".
///   * Late History has one bar per calendar month the span touches.
///   * Work Locations counts check-in sessions per place in the span.
///
/// Pure Dart — unit-tested.
/// Updated: 9/10/2026 - code review finding 1: an untrusted absent row (a
/// day the old sweep wrote on a non-working / unknown-week day —
/// `AbsenceRules`) is not counted as an absence when [compute] gets the
/// employee's schedule.
/// Updated: 9/10/2026 - QA KP-TT-013: Present / Absence / Late are counted
/// by the HR view's day rule (`HrDayBook.forEmployee` → `kindOf`) — the
/// employee dashboard showed Absence 0 where HR showed "5 absences" for
/// the same person (HR also counts the working days the absent sweep has
/// not written yet). [compute] takes the assignment start and the clock.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_days.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

/// Late arrivals of one calendar month.
class MonthLate {
  const MonthLate({required this.month, this.count = 0, this.minutes = 0});

  /// First day of the month.
  final DateTime month;
  final int count;
  final int minutes;
}

class PersonalDashboardStats {
  const PersonalDashboardStats({
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.vacationDaysLeft = 0,
    this.approved = 0,
    this.pending = 0,
    this.rejected = 0,
    this.canceled = 0,
    this.lateByMonth = const <MonthLate>[],
    this.sessionsByPlace = const <String, int>{},
  });

  final int present;
  final int absent;
  final int late;
  final double vacationDaysLeft;
  final int approved;
  final int pending;
  final int rejected;
  final int canceled;
  final List<MonthLate> lateByMonth;

  /// Location id (office) or `remote` / `client_site` → sessions.
  final Map<String, int> sessionsByPlace;

  int get totalRequests => approved + pending + rejected + canceled;

  /// Function Name: [compute]
  ///
  /// Purpose: The dashboard numbers of [email] inside [span].
  ///
  /// Parameters:
  ///   [List<AttendanceDay>] days: the employee's attendance days.
  ///   [List<TimeTrackerRequest>] requests: any requests (filtered here).
  ///   [String] email: lower-cased.
  ///   [DateSpan] span
  ///   [double] vacationDaysLeft
  ///   [WorkSchedule?] schedule: the employee's schedule (9/10/2026).
  ///   [DateTime?] assignmentStart: first day of the assignment (QA
  ///     KP-TT-013; null = the first recorded day).
  ///   [DateTime?] now: the clock (null = the end of [span] — every stored
  ///     day counts, nothing is guessed after it).
  ///
  /// Return type: [PersonalDashboardStats]
  static PersonalDashboardStats compute({
    required List<AttendanceDay> days,
    required List<TimeTrackerRequest> requests,
    required String email,
    required DateSpan span,
    double vacationDaysLeft = 0,
    WorkSchedule? schedule,
    DateTime? assignmentStart,
    DateTime? now,
  }) {
    // QA KP-TT-013 (9/10/2026): Present / Absence / Late come from the SAME
    // day rule as the HR view (`HrDayBook.kindOf`): stored days, an absent
    // row covered by whole-day leave = leave, and a working day the absent
    // sweep has not written yet (≤ 31 days back, after the assignment
    // start, shift over) = absent.
    final String me = email.trim().toLowerCase();
    final WorkSchedule? week = schedule;
    final Map<HrDayKind, int> kinds = HrDayBook.forEmployee(
      email: me,
      days: days,
      requests: requests,
      placement: week == null
          ? null
          : EmployeePlacement(email: me, locationId: '', schedule: week, startDate: assignmentStart),
      now: now ?? DateTime(span.last.year, span.last.month, span.last.day, 23, 59, 59),
    ).countIn(me, span);
    final int late = kinds[HrDayKind.late] ?? 0;
    final int present = (kinds[HrDayKind.present] ?? 0) + late;
    final int absent = kinds[HrDayKind.absent] ?? 0;
    final Map<String, int> places = <String, int>{};
    final Map<DateTime, MonthLate> months = <DateTime, MonthLate>{
      for (DateTime m = DateTime(span.first.year, span.first.month);
          !m.isAfter(span.last);
          m = DateTime(m.year, m.month + 1))
        m: MonthLate(month: m),
    };
    for (final AttendanceDay d in days) {
      if (!span.contains(d.date)) continue;
      if (d.status == AttendanceStatus.late) {
        final DateTime key = DateTime(d.date.year, d.date.month);
        final MonthLate m = months[key] ?? MonthLate(month: key);
        months[key] = MonthLate(
          month: key,
          count: m.count + 1,
          minutes: m.minutes + d.lateMinutes,
        );
      }
      for (final AttendanceSession s in d.sessions) {
        final String place = s.workLocationType == WorkLocationType.office
            ? s.workLocationId
            : s.workLocationType.storageKey;
        places[place] = (places[place] ?? 0) + 1;
      }
    }
    int approved = 0, pending = 0, rejected = 0, canceled = 0;
    for (final TimeTrackerRequest r in requests) {
      if (r.isTransaction || r.requesterEmail.trim().toLowerCase() != email) {
        continue;
      }
      if (!span.contains(r.startAt)) continue;
      switch (r.status) {
        case RequestStatus.approved:
          approved++;
        case RequestStatus.pending:
        case RequestStatus.underReview:
          pending++;
        case RequestStatus.rejected:
          rejected++;
        case RequestStatus.canceled:
        case RequestStatus.canceledByHr:
          canceled++;
      }
    }
    final List<MonthLate> lateByMonth = months.values.toList()
      ..sort((MonthLate a, MonthLate b) => a.month.compareTo(b.month));
    return PersonalDashboardStats(
      present: present,
      absent: absent,
      late: late,
      vacationDaysLeft: vacationDaysLeft,
      approved: approved,
      pending: pending,
      rejected: rejected,
      canceled: canceled,
      lateByMonth: List<MonthLate>.unmodifiable(lateByMonth),
      sessionsByPlace: Map<String, int>.unmodifiable(places),
    );
  }
}
