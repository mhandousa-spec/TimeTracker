/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: absent_day_rules.dart
/// Purpose: Declares `AbsentDayRules` — the pure date logic of the absent-day
///          sweep: which past days must get an `absent` attendance record.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 20 (8/10/2026): absent days are filled automatically by
/// the app when Time Tracker is opened (client sweep, no server), per user.
/// A day is marked absent when ALL of these hold:
///   * it is in the past — before today, and its shift has already ended
///     (an overnight shift that started yesterday may still be running);
///   * it is a WORKING day of the employee's schedule (location
///     `Working_Days`); a schedule whose week is unknown (HR shifts store no
///     working days — `WorkSchedule.isWorkingWeekKnown`, code review finding
///     1, 9/10/2026) marks NOTHING;
///   * it is on / after the assignment's start date — or, when no start date
///     is known (HR shifts carry none), on / after the employee's FIRST
///     recorded attendance day; with neither, nothing is marked (a brand-new
///     employee is never back-filled with absences);
///   * the employee has no attendance record for it;
///   * no approved leave / vacation request covers it.
/// At most [maxLookBackDays] (31) days back per run, so one open never writes
/// more than a month (later runs continue where the records stop).
///
/// `now` is always passed in — the rules stay pure and testable.

import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

/// A closed range of calendar days (both ends included).
class DayRange {
  const DayRange(this.first, this.last);

  final DateTime first;
  final DateTime last;

  /// Whether [day] (any time on it) falls inside the range.
  bool covers(DateTime day) {
    final DateTime d = AbsentDayRules.dayOf(day);
    return !d.isBefore(AbsentDayRules.dayOf(first)) &&
        !d.isAfter(AbsentDayRules.dayOf(last));
  }
}

class AbsentDayRules {
  const AbsentDayRules._();

  /// Look-back cap per run (owner brief, 8/10/2026).
  static const int maxLookBackDays = 31;

  /// Function Name: [dayOf]
  ///
  /// Purpose: Local midnight of [d].
  ///
  /// Return type: [DateTime]
  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Function Name: [daysToMarkAbsent]
  ///
  /// Purpose: The past days that need an `absent` record (oldest first).
  ///
  /// Parameters:
  ///   [DateTime] now: the clock.
  ///   [WorkSchedule] schedule: the employee's schedule.
  ///   [DateTime?] assignmentStart: the assignment's Start_Date.
  ///   [List<DateTime>] recordedDays: days that already have a record.
  ///   [List<DayRange>] approvedLeaves: approved leave / vacation ranges.
  ///   [int] lookBackDays: cap (default [maxLookBackDays]).
  ///
  /// Return type: [List<DateTime>] — local midnights.
  static List<DateTime> daysToMarkAbsent({
    required DateTime now,
    required WorkSchedule schedule,
    required DateTime? assignmentStart,
    required List<DateTime> recordedDays,
    required List<DayRange> approvedLeaves,
    int lookBackDays = maxLookBackDays,
  }) {
    // 9/10/2026 (code review finding 1): an unknown working week (HR shifts
    // store none) would turn every weekend into an absence — mark nothing.
    if (!schedule.isWorkingWeekKnown) return const <DateTime>[];
    final Set<DateTime> recorded = recordedDays.map(dayOf).toSet();
    final DateTime? start = _startOf(assignmentStart, recorded);
    if (start == null || lookBackDays <= 0) return const <DateTime>[];
    final DateTime today = dayOf(now);
    final DateTime cap = DateTime(today.year, today.month, today.day - lookBackDays);
    DateTime day = start.isAfter(cap) ? start : cap;
    final List<DateTime> out = <DateTime>[];
    // Calendar arithmetic (not +24h) so DST never skips or repeats a day.
    for (; day.isBefore(today); day = DateTime(day.year, day.month, day.day + 1)) {
      if (!schedule.isWorkingDay(day)) continue;
      if (now.isBefore(schedule.endOn(day))) continue;
      if (recorded.contains(day)) continue;
      if (approvedLeaves.any((DayRange r) => r.covers(day))) continue;
      out.add(day);
    }
    return List<DateTime>.unmodifiable(out);
  }

  static DateTime? _startOf(DateTime? assignmentStart, Set<DateTime> recorded) {
    if (assignmentStart != null) return dayOf(assignmentStart);
    if (recorded.isEmpty) return null;
    return recorded.reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);
  }
}
