/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_days.dart
/// Purpose: Declares `HrDayKind` and `HrDayBook` — what one employee's day
///          counts as on the HR dashboard (present / late / absent / on
///          leave), built from the stored attendance days, the approved leave
///          requests and the employee's placement.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Absent days are written by a client sweep that runs only when the
/// employee themself opens Time Tracker (owner decision 20), so HR would
/// otherwise miss most absences. The book therefore also counts an
/// UNSTORED absent day with the sweep's own rule (`AbsentDayRules`): a
/// working day of the employee's schedule, on / after the assignment start
/// (or the first recorded day when no start is known), at most
/// `AbsentDayRules.maxLookBackDays` (31) days back — no further than the
/// sweep ever writes — with no attendance and no approved leave, once it is
/// due: past days when their shift has ended, TODAY once start + "Late
/// After" has passed (the "absent today" KPI). Older missing days are not
/// guessed (Time Tracker may have been adopted after the assignment start).
/// Rules, in order, for one employee and one day (never after today):
///   1. a stored day: present → present; late → late; vacation / sick
///      leave / excused → leave; absent → leave when an approved leave
///      covers it, else absent; no status but a session → present;
///   2. covered by an approved (or under-review) leave request on a working
///      day (every day when no schedule is known) → leave;
///   3. the unstored absent day above → absent; otherwise nothing.
/// Pure Dart — unit-tested.
/// Updated: 9/10/2026 - code review findings 1 + 8: an untrusted stored
/// absent row (`AbsenceRules.isUntrustedAbsence` — e.g. a weekend written by
/// the old sweep for an HR shift) counts as no record; NO absence is guessed
/// for a schedule whose working week is unknown (HR shifts); only leave that
/// covers the WHOLE day (`AbsenceRules.wholeDayLeaves`) counts as leave.
/// Updated: 9/10/2026 - QA KP-TT-013: [kindOf] is now THE day rule of every
/// screen — the personal / employee dashboard and the Home cards count
/// through [forEmployee] (same guessed-absence rule, non-working days
/// excluded, ≤ 31 days back, whole-day leave only), so an employee's own
/// "Absence" equals what HR sees for them.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absence_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absent_day_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/reminder_sweep_rules.dart';

/// What one employee-day counts as.
enum HrDayKind { present, late, absent, leave }

class HrDayBook {
  HrDayBook._({
    required Map<String, Map<DateTime, AttendanceDay>> records,
    required Map<String, List<DayRange>> leaves,
    required Map<String, DateTime> firstRecorded,
    required Map<String, EmployeePlacement> placements,
    required this.now,
  })  : _records = records,
        _leaves = leaves,
        _firstRecorded = firstRecorded,
        _placements = placements;

  final Map<String, Map<DateTime, AttendanceDay>> _records;
  final Map<String, List<DayRange>> _leaves;
  final Map<String, DateTime> _firstRecorded;
  final Map<String, EmployeePlacement> _placements;
  final DateTime now;

  static String _norm(String v) => v.trim().toLowerCase();
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get today => _day(now);

  /// Function Name: [build]
  ///
  /// Purpose: Index [days] and the approved leaves of [requests] by employee.
  ///
  /// Parameters:
  ///   [List<AttendanceDay>] days: stored days (any employees).
  ///   [List<TimeTrackerRequest>] requests: any requests (leaves picked here).
  ///   [Map<String, EmployeePlacement>] placements: keyed by e-mail.
  ///   [DateTime] now
  ///
  /// Return type: [HrDayBook]
  static HrDayBook build({
    required List<AttendanceDay> days,
    required List<TimeTrackerRequest> requests,
    required Map<String, EmployeePlacement> placements,
    required DateTime now,
  }) {
    final Map<String, Map<DateTime, AttendanceDay>> records = <String, Map<DateTime, AttendanceDay>>{};
    final Map<String, DateTime> first = <String, DateTime>{};
    for (final AttendanceDay d in days) {
      final String email = _norm(d.employeeEmail);
      final DateTime key = _day(d.date);
      records.putIfAbsent(email, () => <DateTime, AttendanceDay>{})[key] = d;
      final DateTime? seen = first[email];
      if (seen == null || key.isBefore(seen)) first[email] = key;
    }
    final Map<String, EmployeePlacement> byEmail = <String, EmployeePlacement>{
      for (final MapEntry<String, EmployeePlacement> e in placements.entries) _norm(e.key): e.value,
    };
    final Map<String, List<TimeTrackerRequest>> held = <String, List<TimeTrackerRequest>>{};
    for (final TimeTrackerRequest r in requests) {
      if (!isApprovedLeave(r)) continue;
      held.putIfAbsent(_norm(r.requesterEmail), () => <TimeTrackerRequest>[]).add(r);
    }
    // Code review finding 8 (9/10/2026): only whole-day leave excuses a day.
    final Map<String, List<DayRange>> leaves = <String, List<DayRange>>{
      for (final MapEntry<String, List<TimeTrackerRequest>> e in held.entries)
        e.key: AbsenceRules.wholeDayLeaves(e.value, e.key, schedule: byEmail[e.key]?.schedule),
    };
    return HrDayBook._(
      records: records,
      leaves: leaves,
      firstRecorded: first,
      placements: byEmail,
      now: now,
    );
  }

  /// Function Name: [forEmployee]
  ///
  /// Purpose: ADDED 9/10/2026 (QA KP-TT-013) — the book of ONE employee, for
  /// the personal / employee dashboard and the Home cards, so they count a
  /// day EXACTLY like the HR view ([kindOf] is the one shared day rule).
  /// Every day in [days] is theirs, whatever its stored e-mail field says.
  ///
  /// Parameters:
  ///   [String] email
  ///   [List<AttendanceDay>] days: the employee's stored days (all of them —
  ///     the first one is the start when the assignment has none).
  ///   [List<TimeTrackerRequest>] requests: any requests (their whole-day
  ///     held leaves are picked here).
  ///   [EmployeePlacement?] placement: schedule + assignment start (null =
  ///     unknown → stored days only, nothing guessed).
  ///   [DateTime] now
  ///
  /// Return type: [HrDayBook]
  static HrDayBook forEmployee({
    required String email,
    required List<AttendanceDay> days,
    required List<TimeTrackerRequest> requests,
    required EmployeePlacement? placement,
    required DateTime now,
  }) {
    final String me = _norm(email);
    final Map<DateTime, AttendanceDay> mine = <DateTime, AttendanceDay>{};
    DateTime? first;
    for (final AttendanceDay d in days) {
      final DateTime key = _day(d.date);
      mine[key] = d;
      if (first == null || key.isBefore(first)) first = key;
    }
    final DateTime? firstDay = first;
    final EmployeePlacement? p = placement;
    return HrDayBook._(
      records: <String, Map<DateTime, AttendanceDay>>{me: mine},
      leaves: <String, List<DayRange>>{
        me: AbsenceRules.wholeDayLeaves(
          <TimeTrackerRequest>[for (final TimeTrackerRequest r in requests) if (isApprovedLeave(r)) r],
          me,
          schedule: p?.schedule,
        ),
      },
      firstRecorded: firstDay == null ? <String, DateTime>{} : <String, DateTime>{me: firstDay},
      placements: p == null ? <String, EmployeePlacement>{} : <String, EmployeePlacement>{me: p},
      now: now,
    );
  }

  /// Function Name: [isApprovedLeave]
  ///
  /// Purpose: A leave request that explains the days it covers: not a
  /// transaction, approved or under a cancellation review (still held).
  ///
  /// Return type: [bool]
  static bool isApprovedLeave(TimeTrackerRequest r) => AbsenceRules.isHeldLeave(r);

  /// Function Name: [record]
  ///
  /// Purpose: The stored day of [email] on [day], or null.
  ///
  /// Return type: [AttendanceDay?]
  AttendanceDay? record(String email, DateTime day) => _records[_norm(email)]?[_day(day)];

  /// Function Name: [placementOf]
  ///
  /// Return type: [EmployeePlacement?] — [email]'s placement, or null.
  EmployeePlacement? placementOf(String email) => _placements[_norm(email)];

  /// Function Name: [onLeave]
  ///
  /// Purpose: An approved leave of [email] covers [day].
  ///
  /// Return type: [bool]
  bool onLeave(String email, DateTime day) =>
      (_leaves[_norm(email)] ?? const <DayRange>[]).any((DayRange r) => r.covers(day));

  /// Function Name: [kindOf]
  ///
  /// Purpose: What [email]'s [day] counts as (see the file header).
  ///
  /// Return type: [HrDayKind?] — null = nothing to count (future day, no
  /// record and not due, not a working day…).
  HrDayKind? kindOf(String email, DateTime day) {
    final DateTime d = _day(day);
    if (d.isAfter(today)) return null;
    final bool leave = onLeave(email, d);
    final EmployeePlacement? p = placementOf(email);
    final AttendanceDay? stored = record(email, d);
    // Finding 1 (9/10/2026): an untrusted absent row counts as no record.
    final AttendanceDay? rec =
        stored != null && AbsenceRules.isUntrustedAbsence(stored, p?.schedule) ? null : stored;
    if (rec != null) {
      final AttendanceStatus? status = rec.status;
      if (status == AttendanceStatus.present) return HrDayKind.present;
      if (status == AttendanceStatus.late) return HrDayKind.late;
      if (status != null && status.isLeave) return HrDayKind.leave;
      if (status == AttendanceStatus.absent) return leave ? HrDayKind.leave : HrDayKind.absent;
      if (rec.sessions.isNotEmpty) return HrDayKind.present;
    }
    final bool working = p == null || p.schedule.isWorkingDay(d);
    if (leave && working) return HrDayKind.leave;
    if (p == null || !working) return null;
    // Finding 1 (9/10/2026): never guess an absence on an unknown week.
    if (!p.schedule.isWorkingWeekKnown) return null;
    final DateTime? startAt = p.startDate;
    final DateTime? start = startAt != null ? _day(startAt) : _firstRecorded[_norm(email)];
    if (start == null || d.isBefore(start)) return null;
    // Never further back than the sweep itself writes (31 days).
    if (d.isBefore(DateTime(today.year, today.month, today.day - AbsentDayRules.maxLookBackDays))) return null;
    final DateTime due = d == today ? p.schedule.lateThresholdOn(d) : p.schedule.endOn(d);
    return now.isBefore(due) ? null : HrDayKind.absent;
  }

  /// Function Name: [countIn]
  ///
  /// Purpose: How many of [email]'s days inside [span] fall in each kind
  /// (days after today are never counted).
  ///
  /// Return type: [Map<HrDayKind, int>]
  Map<HrDayKind, int> countIn(String email, DateSpan span) {
    final Map<HrDayKind, int> out = <HrDayKind, int>{for (final HrDayKind k in HrDayKind.values) k: 0};
    final DateTime last = span.last.isAfter(today) ? today : span.last;
    // Calendar arithmetic (not +24h) so DST never skips or repeats a day.
    for (DateTime d = span.first; !d.isAfter(last); d = DateTime(d.year, d.month, d.day + 1)) {
      final HrDayKind? k = kindOf(email, d);
      if (k != null) out[k] = out[k]! + 1;
    }
    return out;
  }

  /// Function Name: [runningNow]
  ///
  /// Purpose: [day] holds a session that is running NOW: today's open
  /// session, or yesterday's on an overnight shift that has not ended yet
  /// (end + the 30-minute check-out grace of the reminders).
  ///
  /// Return type: [bool]
  bool runningNow(AttendanceDay day) {
    if (day.openSession == null) return false;
    final DateTime d = _day(day.date);
    if (d == today) return true;
    if (d != DateTime(today.year, today.month, today.day - 1)) return false;
    final EmployeePlacement? p = placementOf(day.employeeEmail);
    if (p == null || !p.schedule.isOvernight) return false;
    return now.isBefore(p.schedule.endOn(d).add(TimeTrackerReminderRules.checkOutGrace));
  }
}
