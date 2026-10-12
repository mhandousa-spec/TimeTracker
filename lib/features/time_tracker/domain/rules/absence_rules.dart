/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: absence_rules.dart
/// Purpose: Declares `AbsenceRules` — which stored absent days can be
///          trusted, and which approved leave covers a WHOLE day (so it may
///          excuse an absence or count as a leave day).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (code review fixes)
///
/// Code review finding 1 (owner rule, 9/10/2026): HR shifts carry no working
/// days, and the absent sweep used to treat EVERY day as a working day, so
/// Fridays / Saturdays of HR-licensed companies were written as `absent`
/// (create-only, never corrected). Nothing is deleted in Firestore; instead
/// every reader ignores an UNTRUSTED absent row:
///   * status `absent`, no session, not written by a transaction, AND
///   * the employee's schedule has an unknown week (HR) — then no sweep
///     absence can be trusted — or the day is not one of its working days.
/// With no schedule known nothing is decided (the row is kept).
///
/// Code review finding 8 (9/10/2026): an approved PARTIAL-day request (two
/// hours off) used to excuse the whole day. Only an all-day request, or a
/// partial one that spans the whole shift of that day, now counts as leave
/// for a day ([coversWholeDay] / [wholeDayLeaves]).
///
/// Pure Dart — unit-tested.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absent_day_rules.dart';

class AbsenceRules {
  const AbsenceRules._();

  /// A multi-day partial request is split per day; never more than this.
  static const int maxDaysPerRequest = 400;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Function Name: [isUntrustedAbsence]
  ///
  /// Purpose: [day] is an absent row the app must ignore (see the header).
  ///
  /// Parameters:
  ///   [AttendanceDay] day: a stored day.
  ///   [WorkSchedule?] schedule: the employee's schedule (null = unknown →
  ///     the row is kept).
  ///
  /// Return type: [bool]
  static bool isUntrustedAbsence(AttendanceDay day, WorkSchedule? schedule) {
    if (day.status != AttendanceStatus.absent) return false;
    if (day.sessions.isNotEmpty || day.isCorrectedByTransaction) return false;
    final WorkSchedule? s = schedule;
    if (s == null) return false;
    if (!s.isWorkingWeekKnown) return true;
    return !s.isWorkingDay(day.date);
  }

  /// Function Name: [trusted]
  ///
  /// Purpose: [days] without the untrusted absent rows.
  ///
  /// Return type: [List<AttendanceDay>]
  static List<AttendanceDay> trusted(List<AttendanceDay> days, WorkSchedule? schedule) =>
      schedule == null
          ? days
          : List<AttendanceDay>.unmodifiable(<AttendanceDay>[
              for (final AttendanceDay d in days)
                if (!isUntrustedAbsence(d, schedule)) d,
            ]);

  /// Function Name: [isHeldLeave]
  ///
  /// Purpose: A leave request that explains the days it covers: not a
  /// transaction, approved or under a cancellation review (still held).
  ///
  /// Return type: [bool]
  static bool isHeldLeave(TimeTrackerRequest r) =>
      !r.isTransaction &&
      (r.status == RequestStatus.approved || r.status == RequestStatus.underReview);

  /// Function Name: [coversWholeDay]
  ///
  /// Purpose: [request] takes the WHOLE of [day] off: an all-day request
  /// whose range covers it, or a partial one that spans that day's shift
  /// from its start to its end (needs [schedule]; unknown hours → false).
  ///
  /// Return type: [bool]
  static bool coversWholeDay(
    TimeTrackerRequest request,
    DateTime day, {
    WorkSchedule? schedule,
  }) {
    final DateTime d = _day(day);
    if (d.isBefore(_day(request.startAt)) || d.isAfter(_day(request.endAt))) return false;
    if (request.isAllDay) return true;
    final WorkSchedule? s = schedule;
    if (s == null) return false;
    return !request.startAt.isAfter(s.startOn(d)) && !request.endAt.isBefore(s.endOn(d));
  }

  /// Function Name: [wholeDayLeaves]
  ///
  /// Purpose: The day ranges [email]'s held leave requests take off
  /// completely (all-day ranges as they are; a partial request only on the
  /// days whose whole shift it spans).
  ///
  /// Parameters:
  ///   [List<TimeTrackerRequest>] requests: any requests (filtered here).
  ///   [String] email
  ///   [WorkSchedule?] schedule: the employee's shift hours.
  ///
  /// Return type: [List<DayRange>]
  static List<DayRange> wholeDayLeaves(
    List<TimeTrackerRequest> requests,
    String email, {
    WorkSchedule? schedule,
  }) {
    final String me = email.trim().toLowerCase();
    final List<DayRange> out = <DayRange>[];
    for (final TimeTrackerRequest r in requests) {
      if (!isHeldLeave(r) || r.requesterEmail.trim().toLowerCase() != me) continue;
      if (r.isAllDay) {
        out.add(DayRange(r.startAt, r.endAt));
        continue;
      }
      if (schedule == null) continue;
      DateTime d = _day(r.startAt);
      final DateTime last = _day(r.endAt);
      for (int guard = 0; !d.isAfter(last) && guard < maxDaysPerRequest; guard++) {
        if (coversWholeDay(r, d, schedule: schedule)) out.add(DayRange(d, d));
        d = DateTime(d.year, d.month, d.day + 1);
      }
    }
    return List<DayRange>.unmodifiable(out);
  }
}
