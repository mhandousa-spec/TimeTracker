/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: reminder_sweep_rules.dart
/// Purpose: Declares `TimeTrackerReminderRules` — the pure half of the
///          client-side reminder sweep: which time-driven notification is
///          due now — and `TimeTrackerDueReminder`, one such notification.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 6 (brief §C). Three reminders, each sent ONCE (the sweeper claims
/// a marker in `Modules/time_tracker/Notification_Log` first, like To-Do):
///   * missed check-in — a working day of the employee's schedule (assigned
///     location, assignment already started), start + grace ("Late After")
///     has passed, no check-in today and no approved leave covering today
///     → the employee. Marker: today's attendance id + the threshold time.
///   * forgot to check out — still checked in 30 minutes after the end of
///     the shift the open session belongs to (an overnight shift ends the
///     next day; a session started AFTER the shift ended is extra work and
///     gets no reminder) → the employee. Marker: that day's id + end time.
///   * pending approvals — requests whose current step waits for the
///     approver for more than 2 days → the approver, at most once a day,
///     with how many and the oldest one as the deep link. Marker: the
///     approver + the day.
/// Pure Dart — unit-tested; the I/O lives in `TimeTrackerReminderSweeper`.
/// Updated: 9/10/2026 - code review finding 1: no missed check-in reminder
/// on a schedule whose working week is unknown (HR shifts).

import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absent_day_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';

/// Which reminder.
enum TimeTrackerReminderKind { missedCheckIn, missedCheckOut, pendingApprovals }

/// One reminder the sweep decided is due.
class TimeTrackerDueReminder {
  const TimeTrackerDueReminder({
    required this.kind,
    required this.refId,
    required this.dueAt,
    this.requestId = '',
    this.count = 0,
  });

  final TimeTrackerReminderKind kind;

  /// The `{refId}` of the Notification_Log marker (attendance day id, or
  /// `approvals_{email}`).
  final String refId;

  /// The moment the reminder became due (part of the marker id).
  final DateTime dueAt;

  /// Pending approvals: the oldest waiting request (View opens it).
  final String requestId;

  /// Pending approvals: how many wait for more than two days.
  final int count;
}

class TimeTrackerReminderRules {
  const TimeTrackerReminderRules._();

  /// "Still checked in 30 min after the end time" (brief §C).
  static const Duration checkOutGrace = Duration(minutes: 30);

  /// "Pending > 2 days" (brief §C).
  static const Duration approvalOverdueAfter = Duration(days: 2);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Function Name: [missedCheckIn]
  ///
  /// Purpose: "Check-In Not Recorded" for today, if due.
  ///
  /// Parameters:
  ///   [String] email: the employee.
  ///   [WorkSchedule] schedule: their location's / shift's hours.
  ///   [DateTime?] assignmentStart: first day the assignment applies.
  ///   [AttendanceDay?] today: today's stored day (null = none).
  ///   [List<DayRange>] approvedLeaves: their approved leave ranges.
  ///   [DateTime] now
  ///
  /// Return type: [TimeTrackerDueReminder?] — null when not due.
  static TimeTrackerDueReminder? missedCheckIn({
    required String email,
    required WorkSchedule schedule,
    required AttendanceDay? today,
    required List<DayRange> approvedLeaves,
    required DateTime now,
    DateTime? assignmentStart,
  }) {
    final DateTime day = _day(now);
    // 9/10/2026 (code review finding 1): unknown week (HR shift) → no
    // "Check-In Not Recorded" on what may be a weekend.
    if (!schedule.isWorkingWeekKnown || !schedule.isWorkingDay(day)) return null;
    final DateTime? start = assignmentStart;
    if (start != null && day.isBefore(_day(start))) return null;
    final DateTime due = schedule.lateThresholdOn(day);
    if (now.isBefore(due)) return null;
    final AttendanceDay? stored = today;
    if (stored != null && (stored.sessions.isNotEmpty || (stored.status?.isLeave ?? false))) {
      return null;
    }
    if (approvedLeaves.any((DayRange r) => r.covers(day))) return null;
    return TimeTrackerDueReminder(
      kind: TimeTrackerReminderKind.missedCheckIn,
      refId: TimeTrackerFirestorePaths.attendanceDocId(email, day),
      dueAt: due,
    );
  }

  /// Function Name: [missedCheckOut]
  ///
  /// Purpose: "Check-Out Not Recorded" for the open session, if due.
  ///
  /// Parameters:
  ///   [String] email
  ///   [WorkSchedule] schedule
  ///   [AttendanceDay?] openDay: the day holding the running session (today,
  ///   or yesterday for an overnight one); null = not checked in.
  ///   [DateTime] now
  ///
  /// Return type: [TimeTrackerDueReminder?]
  static TimeTrackerDueReminder? missedCheckOut({
    required String email,
    required WorkSchedule schedule,
    required AttendanceDay? openDay,
    required DateTime now,
  }) {
    final AttendanceDay? day = openDay;
    final AttendanceSession? open = day?.openSession;
    if (day == null || open == null) return null;
    final DateTime end = schedule.endOn(_day(day.date));
    if (open.checkInAt.isAfter(end)) return null;
    final DateTime due = end.add(checkOutGrace);
    if (now.isBefore(due)) return null;
    return TimeTrackerDueReminder(
      kind: TimeTrackerReminderKind.missedCheckOut,
      refId: TimeTrackerFirestorePaths.attendanceDocId(email, day.date),
      dueAt: due,
    );
  }

  /// Function Name: [overdueApprovals]
  ///
  /// Purpose: The once-a-day "Pending Approvals" reminder of [approverEmail].
  ///
  /// Parameters:
  ///   [String] approverEmail
  ///   [List<TimeTrackerRequest>] requests: the company's requests.
  ///   [bool Function(TimeTrackerRequest)] waitsForMe: the current step
  ///   waits for the approver (`ApprovalService.mayDecide`).
  ///   [DateTime] now
  ///
  /// Return type: [TimeTrackerDueReminder?] — null when nothing waits > 2 days.
  static TimeTrackerDueReminder? overdueApprovals({
    required String approverEmail,
    required List<TimeTrackerRequest> requests,
    required bool Function(TimeTrackerRequest request) waitsForMe,
    required DateTime now,
  }) {
    final List<(TimeTrackerRequest, DateTime)> overdue = <(TimeTrackerRequest, DateTime)>[];
    for (final TimeTrackerRequest r in requests) {
      if (!waitsForMe(r)) continue;
      final DateTime? since = TimeTrackerHomeStatsRules.waitingSince(r);
      if (since == null || now.difference(since) <= approvalOverdueAfter) continue;
      overdue.add((r, since));
    }
    if (overdue.isEmpty) return null;
    overdue.sort(((TimeTrackerRequest, DateTime) a, (TimeTrackerRequest, DateTime) b) {
      final int bySince = a.$2.compareTo(b.$2);
      return bySince != 0 ? bySince : a.$1.id.compareTo(b.$1.id);
    });
    return TimeTrackerDueReminder(
      kind: TimeTrackerReminderKind.pendingApprovals,
      refId: 'approvals_${TimeTrackerFirestorePaths.emailKey(approverEmail)}',
      dueAt: _day(now),
      requestId: overdue.first.$1.id,
      count: overdue.length,
    );
  }
}
