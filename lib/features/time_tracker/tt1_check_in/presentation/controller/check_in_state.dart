/// Module: time_tracker / tt1_check_in / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: check_in_state.dart
/// Purpose: Declares `CheckInState` (+ `CheckInLoadStatus`, `CheckInBusy`)
///          and `CheckInResult` / `CheckInOutcome` — what the Check In &
///          Out control shows and what one action ended with.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma states (Employee iPad landscape): not checked in `661:10375` ·
/// checked in + Pause `661:12245` · checked in, pause not allowed
/// `661:12639` · paused `661:13030` · checked out `661:13423`.
/// One immutable state + `copyWith` + status enums (playbook §3).
/// Updated: 9/10/2026 - code review: outcomes `mockedLocation` / `busy`.
/// Updated: 9/10/2026 - QA KP-TT-015: outcomes `alreadyCheckedOut` /
/// `stateChanged` (a stale screen's action re-reads instead of failing).

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/check_in_options.dart';

enum CheckInLoadStatus { initial, loading, ready, failure }

/// The action currently running (buttons show a busy state).
enum CheckInBusy { none, checkingIn, pausing, resuming, checkingOut }

/// How one Check In / Pause / Resume / Check Out ended.
enum CheckInOutcome {
  success,

  /// Outside the location's geofence — blocked (Figma 661:17251).
  wrongLocation,
  locationDenied,
  locationServiceOff,
  locationUnavailable,

  /// No location assignment — cannot check in.
  notAssigned,
  locationNotAllowed,
  differentLocationNotAllowed,
  noPermission,
  failed,

  /// ADDED 9/10/2026 (code review): the position came from a mock-location
  /// app — refused.
  mockedLocation,

  /// ADDED 9/10/2026 (code review): another check-in action is still
  /// running (double tap) — ignored, nothing to show.
  busy,

  /// ADDED 9/10/2026 (QA KP-TT-015): the action was made on a stale screen —
  /// the stored day is NOT checked in any more (checked out from another
  /// card / screen / device). Nothing was written; the control now shows
  /// the stored day.
  alreadyCheckedOut,

  /// ADDED 9/10/2026 (QA KP-TT-015): the stored day changed meanwhile in
  /// another way (already checked in, already paused / resumed). Nothing was
  /// written; the control now shows the stored day.
  stateChanged,
}

class CheckInResult {
  const CheckInResult(
    this.outcome, {
    this.locationVerified = false,
    this.message = '',
  });

  final CheckInOutcome outcome;

  /// The geofence was checked and matched ("Your Location Matches the
  /// Company's Location" is shown before the success dialog).
  final bool locationVerified;

  /// Technical detail of a [CheckInOutcome.failed].
  final String message;

  bool get isSuccess => outcome == CheckInOutcome.success;
}

class CheckInState {
  const CheckInState({
    this.status = CheckInLoadStatus.initial,
    this.day,
    this.setup,
    this.options = const <CheckInOption>[],
    this.busy = CheckInBusy.none,
    this.errorMessage = '',
  });

  final CheckInLoadStatus status;

  /// The day the control shows: the open session's day (it may have started
  /// yesterday on an overnight shift), else today. Null before loading.
  final AttendanceDay? day;

  /// The employee's work set-up; null = not assigned anywhere.
  final EmployeeWorkSetup? setup;

  /// The check-in sheet's "Work Location" options.
  final List<CheckInOption> options;
  final CheckInBusy busy;
  final String errorMessage;

  bool get isCheckedIn => day?.isCheckedIn ?? false;
  bool get isPaused => day?.isPaused ?? false;
  bool get isBusy => busy != CheckInBusy.none;

  /// Checked out at least once on the shown day and not checked in again.
  bool get hasCheckedOut =>
      !isCheckedIn && (day?.sessions.isNotEmpty ?? false);

  /// The info strip (Date · Check In · Location · Break · Check Out) shows
  /// once the day has a session.
  bool get showInfoStrip => day?.sessions.isNotEmpty ?? false;

  /// Pause is offered only when the employee's rules allow it (Figma
  /// 661:12639 has no Pause button otherwise).
  bool get canPause => setup?.rules.isPauseAllowed ?? false;

  /// ADDED 13/10/2026 (owner: show the pause time left): the longest pause
  /// of a day — the employee's rules first, then the location's; 0 = no
  /// limit.
  int get allowedPauseMinutes {
    final EmployeeWorkSetup? s = setup;
    if (s == null) return 0;
    if (s.rules.isPauseAllowed && s.rules.pauseMinutes > 0) return s.rules.pauseMinutes;
    return s.location.pauseMinutes > 0 ? s.location.pauseMinutes : 0;
  }

  /// Allowed break length shown on the info strip (assignment rules first,
  /// then the location's own setting); 0 = no break.
  int get allowedBreakMinutes {
    final EmployeeWorkSetup? s = setup;
    if (s == null) return 0;
    if (s.rules.isBreakAllowed && s.rules.breakMinutes > 0) {
      return s.rules.breakMinutes;
    }
    return s.location.isBreakAllowed ? s.location.breakMinutes : 0;
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update. [clearSetup] sets [setup] to null.
  ///
  /// Return type: [CheckInState]
  CheckInState copyWith({
    CheckInLoadStatus? status,
    AttendanceDay? day,
    EmployeeWorkSetup? setup,
    bool clearSetup = false,
    List<CheckInOption>? options,
    CheckInBusy? busy,
    String? errorMessage,
  }) =>
      CheckInState(
        status: status ?? this.status,
        day: day ?? this.day,
        setup: clearSetup ? null : (setup ?? this.setup),
        options: options ?? this.options,
        busy: busy ?? this.busy,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
