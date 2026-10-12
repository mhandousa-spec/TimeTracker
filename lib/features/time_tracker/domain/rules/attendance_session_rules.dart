/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_session_rules.dart
/// Purpose: Declares `AttendanceSessionRules` — the pure Check In / Pause /
///          Resume / Check Out moves on an `AttendanceDay`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 5 (8/10/2026): several check-ins a day (each one opens a
/// new session); Pause only when the employee's rules allow it (Figma
/// `661:12639` shows no Pause button otherwise). Checking out while paused
/// closes the pause at the same moment. An invalid move throws `StateError`
/// — the cubit turns it into a message; it never reaches Firestore.
///
/// Derived numbers are NOT recalculated here; call
/// `AttendanceCalculator.apply` before saving.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';

class AttendanceSessionRules {
  const AttendanceSessionRules._();

  /// Function Name: [checkIn]
  ///
  /// Purpose: Open a new session at [at].
  ///
  /// Parameters:
  ///   [AttendanceDay] day
  ///   [DateTime] at
  ///   [String] locationId: the chosen work location ('' for remote).
  ///   [WorkLocationType] type
  ///   [double?] latitude / [double?] longitude: device position.
  ///
  /// Return type: [AttendanceDay] — throws `StateError` if already checked in.
  static AttendanceDay checkIn(
    AttendanceDay day, {
    required DateTime at,
    required String locationId,
    required WorkLocationType type,
    double? latitude,
    double? longitude,
  }) {
    if (day.isCheckedIn) throw StateError('Already checked in.');
    return day.copyWith(sessions: <AttendanceSession>[
      ...day.sessions,
      AttendanceSession(
        checkInAt: at,
        workLocationId: locationId,
        workLocationType: type,
        latitude: latitude,
        longitude: longitude,
      ),
    ]);
  }

  /// Function Name: [pause]
  ///
  /// Purpose: Start a pause in the open session.
  ///
  /// Parameters:
  ///   [AttendanceDay] day
  ///   [DateTime] at
  ///   [bool] isPauseAllowed: the employee's rules allow pausing.
  ///
  /// Return type: [AttendanceDay] — throws `StateError` when not checked in,
  /// already paused, or pausing is not allowed.
  static AttendanceDay pause(
    AttendanceDay day, {
    required DateTime at,
    required bool isPauseAllowed,
  }) {
    if (!isPauseAllowed) throw StateError('Pause is not allowed.');
    final AttendanceSession open = _open(day);
    if (open.isPaused) throw StateError('Already paused.');
    return _replaceOpen(
      day,
      open.copyWith(pauses: <AttendancePause>[
        ...open.pauses,
        AttendancePause(startAt: at),
      ]),
    );
  }

  /// Function Name: [resume]
  ///
  /// Purpose: End the running pause.
  ///
  /// Parameters:
  ///   [AttendanceDay] day
  ///   [DateTime] at
  ///
  /// Return type: [AttendanceDay] — throws `StateError` when not paused.
  static AttendanceDay resume(AttendanceDay day, {required DateTime at}) {
    final AttendanceSession open = _open(day);
    if (!open.isPaused) throw StateError('Not paused.');
    return _replaceOpen(day, open.copyWith(pauses: _closeLastPause(open, at)));
  }

  /// Function Name: [checkOut]
  ///
  /// Purpose: Close the open session (and a running pause) at [at].
  ///
  /// Parameters:
  ///   [AttendanceDay] day
  ///   [DateTime] at
  ///
  /// Return type: [AttendanceDay] — throws `StateError` when not checked in.
  static AttendanceDay checkOut(AttendanceDay day, {required DateTime at}) {
    final AttendanceSession open = _open(day);
    return _replaceOpen(
      day,
      open.copyWith(
        checkOutAt: at,
        pauses: open.isPaused ? _closeLastPause(open, at) : open.pauses,
      ),
    );
  }

  static AttendanceSession _open(AttendanceDay day) {
    final AttendanceSession? open = day.openSession;
    if (open == null) throw StateError('Not checked in.');
    return open;
  }

  static AttendanceDay _replaceOpen(AttendanceDay day, AttendanceSession next) =>
      day.copyWith(sessions: <AttendanceSession>[
        ...day.sessions.sublist(0, day.sessions.length - 1),
        next,
      ]);

  static List<AttendancePause> _closeLastPause(
    AttendanceSession session,
    DateTime at,
  ) =>
      <AttendancePause>[
        ...session.pauses.sublist(0, session.pauses.length - 1),
        AttendancePause(startAt: session.pauses.last.startAt, endAt: at),
      ];
}
