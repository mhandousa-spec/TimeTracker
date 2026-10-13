/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_calculator.dart
/// Purpose: Declares `AttendanceCalculator` — the pure rules that turn a
///          day's sessions into late / break / total minutes and a status —
///          and `AttendanceSummary`, its result.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Rules (owner decisions 5 + 13, 8/10/2026):
///   * Total work = Σ (check-out, or now while open) − check-in − pauses.
///     Pause = Break and is NOT counted as work.
///   * Break minutes = Σ pause durations (an open pause runs until now, or
///     until the session's check-out).
///   * Late minutes = first check-in − shift start on that day, counted only
///     when the check-in is AFTER start + the location's "Late After"
///     grace (owner decision 22, 8/10/2026). 0 if on time / within the
///     grace, 0 on a non-working day, 0 with no schedule.
///   * Status: an approved leave (vacation / sick leave / excused) wins;
///     otherwise sessions → late (late minutes > 0) or present; no sessions on
///     a working day whose shift has ended → absent; else undecided (null).
///
/// `now` is always passed in — the rules stay pure and testable.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';

/// The derived numbers of one attendance day.
class AttendanceSummary {
  const AttendanceSummary({
    required this.status,
    required this.lateMinutes,
    required this.breakMinutes,
    required this.totalWorkMinutes,
  });

  final AttendanceStatus? status;
  final int lateMinutes;
  final int breakMinutes;
  final int totalWorkMinutes;
}

class AttendanceCalculator {
  const AttendanceCalculator._();

  /// Function Name: [pauseMinutes]
  ///
  /// Purpose: Minutes spent paused in [session]. An open pause runs until the
  /// session's check-out, or until [now] while still checked in.
  ///
  /// Parameters:
  ///   [AttendanceSession] session
  ///   [DateTime] now
  ///
  /// Return type: [int]
  static int pauseMinutes(AttendanceSession session, DateTime now) {
    final DateTime sessionEnd = session.checkOutAt ?? now;
    int total = 0;
    for (final AttendancePause pause in session.pauses) {
      final DateTime end = pause.endAt ?? sessionEnd;
      total += _minutesBetween(pause.startAt, end);
    }
    return total;
  }

  /// Function Name: [workMinutes]
  ///
  /// Purpose: Worked minutes of [session] — its span minus its pauses.
  ///
  /// Parameters:
  ///   [AttendanceSession] session
  ///   [DateTime] now: the end of a still-open session.
  ///
  /// Return type: [int] — never negative.
  static int workMinutes(AttendanceSession session, DateTime now) {
    final int span = _minutesBetween(session.checkInAt, session.checkOutAt ?? now);
    final int worked = span - pauseMinutes(session, now);
    return worked < 0 ? 0 : worked;
  }

  /// Function Name: [lateMinutes]
  ///
  /// Purpose: How late [firstCheckIn] was against [schedule] on [day].
  ///
  /// Parameters:
  ///   [DateTime?] firstCheckIn: null = no check-in.
  ///   [WorkSchedule?] schedule: null = no schedule known.
  ///   [DateTime] day: the attendance day.
  ///
  /// Return type: [int] — 0 when on time, off-day, or unknown.
  static int lateMinutes({
    required DateTime? firstCheckIn,
    required WorkSchedule? schedule,
    required DateTime day,
  }) {
    if (firstCheckIn == null || schedule == null) return 0;
    if (!schedule.isWorkingDay(day)) return 0;
    final DateTime start = schedule.startOn(day);
    if (!firstCheckIn.isAfter(schedule.lateThresholdOn(day))) return 0;
    return _minutesBetween(start, firstCheckIn);
  }

  /// Function Name: [summarize]
  ///
  /// Purpose: Every derived number of one day (see the file header rules).
  ///
  /// Parameters:
  ///   [DateTime] day: the attendance day.
  ///   [List<AttendanceSession>] sessions: in check-in order.
  ///   [WorkSchedule?] schedule: the employee's schedule, if known.
  ///   [DateTime] now: the clock.
  ///   [AttendanceStatus?] leaveStatus: set when an approved leave request
  ///     covers the day.
  ///
  /// Return type: [AttendanceSummary]
  static AttendanceSummary summarize({
    required DateTime day,
    required List<AttendanceSession> sessions,
    required WorkSchedule? schedule,
    required DateTime now,
    AttendanceStatus? leaveStatus,
  }) {
    int worked = 0;
    int paused = 0;
    for (final AttendanceSession session in sessions) {
      worked += workMinutes(session, now);
      paused += pauseMinutes(session, now);
    }
    final int late = lateMinutes(
      firstCheckIn: sessions.isEmpty ? null : sessions.first.checkInAt,
      schedule: schedule,
      day: day,
    );
    return AttendanceSummary(
      status: _status(
        day: day,
        hasSessions: sessions.isNotEmpty,
        lateMinutes: late,
        schedule: schedule,
        now: now,
        leaveStatus: leaveStatus,
      ),
      lateMinutes: late,
      breakMinutes: paused,
      totalWorkMinutes: worked,
    );
  }

  /// Function Name: [apply]
  ///
  /// Purpose: [day] with its derived fields recalculated (call before every
  /// save).
  ///
  /// Parameters:
  ///   [AttendanceDay] day
  ///   [WorkSchedule?] schedule
  ///   [DateTime] now
  ///   [AttendanceStatus?] leaveStatus
  ///
  /// Return type: [AttendanceDay]
  static AttendanceDay apply(
    AttendanceDay day, {
    required WorkSchedule? schedule,
    required DateTime now,
    AttendanceStatus? leaveStatus,
  }) {
    final AttendanceSummary summary = summarize(
      day: day.date,
      sessions: day.sessions,
      schedule: schedule,
      now: now,
      leaveStatus: leaveStatus,
    );
    return day.copyWith(
      status: summary.status,
      clearStatus: summary.status == null,
      lateMinutes: summary.lateMinutes,
      breakMinutes: summary.breakMinutes,
      totalWorkMinutes: summary.totalWorkMinutes,
    );
  }

  static AttendanceStatus? _status({
    required DateTime day,
    required bool hasSessions,
    required int lateMinutes,
    required WorkSchedule? schedule,
    required DateTime now,
    required AttendanceStatus? leaveStatus,
  }) {
    if (leaveStatus != null && leaveStatus.isLeave) return leaveStatus;
    if (hasSessions) {
      return lateMinutes > 0 ? AttendanceStatus.late : AttendanceStatus.present;
    }
    if (schedule == null || !schedule.isWorkingDay(day)) return null;
    return now.isBefore(schedule.endOn(day)) ? null : AttendanceStatus.absent;
  }

  /// Function Name: [pauseSeconds] / [workSeconds]
  ///
  /// Purpose: ADDED 13/10/2026 (owner: the live timer shows seconds) — the
  /// same as [pauseMinutes] / [workMinutes], to the second.
  ///
  /// Return type: [int] — never negative.
  static int pauseSeconds(AttendanceSession session, DateTime now) {
    final DateTime sessionEnd = session.checkOutAt ?? now;
    int total = 0;
    for (final AttendancePause pause in session.pauses) {
      total += _secondsBetween(pause.startAt, pause.endAt ?? sessionEnd);
    }
    return total;
  }

  static int workSeconds(AttendanceSession session, DateTime now) {
    final int span = _secondsBetween(session.checkInAt, session.checkOutAt ?? now);
    final int worked = span - pauseSeconds(session, now);
    return worked < 0 ? 0 : worked;
  }

  static int _secondsBetween(DateTime from, DateTime to) {
    final int seconds = to.difference(from).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  static int _minutesBetween(DateTime from, DateTime to) {
    final int minutes = to.difference(from).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }
}
