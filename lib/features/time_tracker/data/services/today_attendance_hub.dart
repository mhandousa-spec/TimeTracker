/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: today_attendance_hub.dart
/// Purpose: Declares `TodayAttendanceHub` — the ONE in-app source of truth
///          for the signed-in employee's check-in state (today's attendance
///          day, and yesterday's while an overnight session is open).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (QA KP-TT-015)
///
/// QA KP-TT-015 (Major): every Check In & Out control (the module header and
/// each Home "Tracker" quick card) had its OWN `CheckInCubit` that read the
/// day once. After a Check Out from one card, the other card and the module
/// header kept showing "checked in" (timer, Pause, Check Out) and their
/// actions failed with "Something went wrong".
///
/// Now every `CheckInCubit` publishes what it reads / writes here and
/// listens here, so a check-in / pause / resume / check-out made by ANY
/// control updates all of them at once. While at least one control listens
/// for an employee, the hub also follows that employee's stored today and
/// yesterday documents in Firestore (`AttendanceBaseRepository.watchDay`), so
/// a change made on another device shows too. Registered as a lazy singleton
/// in get_it (`time_tracker_get_it.dart`).
///
/// Which copy wins:
///   * a Firestore snapshot or a day the app just WROTE is authoritative —
///     it always replaces what the hub knew;
///   * a one-shot READ (a control's first load) only fills a gap — it never
///     overwrites a newer copy another control already published.
/// The shown day is the same rule as the cubit's load: the open session's
/// day (today, or yesterday's overnight one), else today.
///
/// No `try` here (house rule: repositories and cubits only) — stream errors
/// are kept in [lastError] and the controls keep what they show.

import 'dart:async';

import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';

class TodayAttendanceHub {
  TodayAttendanceHub({
    required AttendanceBaseRepository attendance,
    DateTime Function() clock = DateTime.now,
  })  : _attendance = attendance,
        _clock = clock;

  final AttendanceBaseRepository _attendance;
  final DateTime Function() _clock;

  /// Latest known copy per `{email}|{yyyy-M-d}`.
  final Map<String, AttendanceDay> _days = <String, AttendanceDay>{};

  /// Every accepted copy, for every listening control.
  final StreamController<AttendanceDay> _changes = StreamController<AttendanceDay>.broadcast();

  /// Per e-mail: how many controls listen, and the Firestore listeners.
  final Map<String, _Follow> _follows = <String, _Follow>{};

  /// Why the live Firestore copy could not be read (kept, not swallowed).
  Object? lastError;

  static String _norm(String email) => email.trim().toLowerCase();
  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _key(String email, DateTime date) =>
      '${_norm(email)}|${date.year}-${date.month}-${date.day}';

  /// Function Name: [dayOf]
  ///
  /// Purpose: The latest copy of [email]'s day [date] the hub knows.
  ///
  /// Return type: [AttendanceDay?] — null when nothing is known.
  AttendanceDay? dayOf(String email, DateTime date) => _days[_key(email, _dayOf(date))];

  /// Function Name: [shownDay]
  ///
  /// Purpose: The day a Check In & Out control must show for [email] at
  /// [now]: today when it is checked in, else yesterday's open (overnight)
  /// session, else today as stored (or an empty today when only yesterday is
  /// known).
  ///
  /// Return type: [AttendanceDay?] — null when the hub knows neither day.
  AttendanceDay? shownDay(String email, DateTime now) {
    final DateTime today = _dayOf(now);
    final AttendanceDay? t = dayOf(email, today);
    if (t != null && t.isCheckedIn) return t;
    final AttendanceDay? y = dayOf(email, DateTime(today.year, today.month, today.day - 1));
    if (y != null && y.isCheckedIn) return y;
    if (t != null) return t;
    if (y == null) return null;
    return AttendanceDay(id: '', employeeEmail: _norm(email), date: today);
  }

  /// Function Name: [publish]
  ///
  /// Purpose: Share a day a control read ([authoritative] false — fills a
  /// gap only) or wrote / re-read after a refused action (true — always
  /// replaces). A day that was never stored (empty id) is ignored.
  ///
  /// Return type: [void]
  void publish(AttendanceDay day, {bool authoritative = true}) {
    if (day.id.isEmpty || day.employeeEmail.trim().isEmpty) return;
    final String key = _key(day.employeeEmail, _dayOf(day.date));
    if (!authoritative && _days.containsKey(key)) return;
    _days[key] = day;
    _changes.add(day);
  }

  /// Function Name: [watch]
  ///
  /// Purpose: Every accepted copy of [email]'s days. While at least one
  /// listener exists the hub follows the stored today / yesterday documents
  /// in Firestore (another device's check-in / out arrives here).
  ///
  /// Return type: [Stream<AttendanceDay>]
  Stream<AttendanceDay> watch(String email) {
    final String who = _norm(email);
    StreamSubscription<AttendanceDay>? relay;
    late final StreamController<AttendanceDay> out;
    out = StreamController<AttendanceDay>(
      onListen: () {
        relay = _changes.stream
            .where((AttendanceDay d) => _norm(d.employeeEmail) == who)
            .listen(out.add);
        _retain(who);
      },
      onCancel: () async {
        await relay?.cancel();
        await _release(who);
      },
    );
    return out.stream;
  }

  /// Number of controls following [email] (tests).
  int listenersOf(String email) => _follows[_norm(email)]?.count ?? 0;

  void _retain(String email) {
    final _Follow follow = _follows.putIfAbsent(email, _Follow.new);
    follow.count++;
    _followDays(email, follow);
  }

  Future<void> _release(String email) async {
    final _Follow? follow = _follows[email];
    if (follow == null) return;
    follow.count--;
    if (follow.count > 0) return;
    _follows.remove(email);
    for (final StreamSubscription<AttendanceDay?> sub in follow.subs.values) {
      await sub.cancel();
    }
  }

  /// Follows today's and yesterday's documents (re-checked on every new
  /// listener, so a control opened after midnight follows the new day).
  void _followDays(String email, _Follow follow) {
    final DateTime today = _dayOf(_clock());
    final List<DateTime> wanted = <DateTime>[DateTime(today.year, today.month, today.day - 1), today];
    final Set<String> keep = <String>{for (final DateTime d in wanted) _key(email, d)};
    for (final String old in follow.subs.keys.where((String k) => !keep.contains(k)).toList()) {
      unawaited(follow.subs.remove(old)?.cancel());
    }
    for (final DateTime d in wanted) {
      final String key = _key(email, d);
      if (follow.subs.containsKey(key)) continue;
      follow.subs[key] = _attendance.watchDay(employeeEmail: email, date: d).listen(
        (AttendanceDay? stored) {
          if (stored != null) publish(stored);
        },
        onError: (Object error) => lastError = error,
      );
    }
  }
}

/// The controls following one employee and their Firestore listeners.
class _Follow {
  int count = 0;
  final Map<String, StreamSubscription<AttendanceDay?>> subs = <String, StreamSubscription<AttendanceDay?>>{};
}
