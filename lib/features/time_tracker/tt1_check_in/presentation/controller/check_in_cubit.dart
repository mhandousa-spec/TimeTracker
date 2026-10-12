/// Module: time_tracker / tt1_check_in / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: check_in_cubit.dart
/// Purpose: Declares `CheckInCubit` — loads the signed-in employee's day and
///          work set-up, and runs Check In / Pause / Resume / Check Out.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 5 (8/10/2026): several check-ins a day; a wrong location
/// is BLOCKED unless the employee works Remote / Client Site (allowed only
/// with `Work_From_Different_Location` + the assignment's flag); Pause =
/// Break, not counted as work. The moves are the pure
/// `AttendanceSessionRules`, the gate `CheckInGate`, the numbers
/// `AttendanceCalculator` — this cubit only orchestrates and writes through
/// `AttendanceBaseRepository`, then logs to System Logs.
///
/// The device position is read ONLY when the chosen office has its geofence
/// on (no permission prompt otherwise). A denied permission or location
/// services off is reported as its own outcome so the UI can say what to do.
///
/// Async work starts in [init] (called by the entry), never in the
/// constructor. Emit-after-close guarded (playbook §3). The clock is
/// injectable for tests.
/// Updated: 9/10/2026 - code review: every move is applied to the day AS
/// STORED (`AttendanceBaseRepository.updateDay`, one transaction) — a
/// second device's check-in or an approved correction is no longer
/// overwritten by this screen's cached day; a second tap while an action
/// runs is ignored (`CheckInOutcome.busy`); a mock-location position is
/// refused.
/// Updated: 9/10/2026 - QA KP-TT-015: ONE shared check-in state — every
/// read / write is published to `TodayAttendanceHub` and every cubit
/// follows it, so the module header and each Home quick card update
/// together (also after a change on another device). An action made on a
/// stale screen writes nothing, re-reads the stored day and answers
/// [CheckInOutcome.alreadyCheckedOut] / [CheckInOutcome.stateChanged]
/// instead of "Something went wrong".

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/today_attendance_hub.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_calculator.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_session_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/check_in_options.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_state.dart';

class CheckInCubit extends Cubit<CheckInState> {
  CheckInCubit({
    required AttendanceBaseRepository attendance,
    required WorkSetupSourceResolver resolver,
    required DeviceLocationReader location,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
    DateTime Function() clock = DateTime.now,
    TodayAttendanceHub? hub,
  })  : _attendance = attendance,
        _resolver = resolver,
        _location = location,
        _access = access,
        _log = log,
        _clock = clock,
        _hub = hub,
        super(const CheckInState());

  final AttendanceBaseRepository _attendance;
  final WorkSetupSourceResolver _resolver;
  final DeviceLocationReader _location;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;
  final DateTime Function() _clock;

  /// QA KP-TT-015 (9/10/2026): the shared check-in state (null = this
  /// control stands alone, e.g. in older tests).
  final TodayAttendanceHub? _hub;
  StreamSubscription<AttendanceDay>? _hubSub;

  @override
  void emit(CheckInState state) {
    if (isClosed) return;
    super.emit(state);
  }

  @override
  Future<void> close() async {
    await _hubSub?.cancel();
    return super.close();
  }

  /// Function Name: [init]
  ///
  /// Purpose: Load the work set-up, the check-in options and the day.
  ///
  /// Return type: [Future<void>]
  Future<void> init() async {
    emit(state.copyWith(status: CheckInLoadStatus.loading, errorMessage: ''));
    try {
      final TimeTrackerIdentity me = _access.identity;
      final WorkSetupSource source = await _resolver.resolve();
      final EmployeeWorkSetup? setup = await source.loadWorkSetup(
        employeeEmail: me.email,
        employeeId: me.employeeId,
      );
      final bool elsewhere = _mayWorkElsewhere(setup);
      final List<WorkLocation> locations = setup != null && elsewhere
          ? await source.loadLocations()
          : const <WorkLocation>[];
      final AttendanceDay day = await _loadDay(me.email);
      emit(CheckInState(
        status: CheckInLoadStatus.ready,
        day: day,
        setup: setup,
        options: setup == null
            ? const <CheckInOption>[]
            : CheckInOptions.build(
                setup: setup,
                companyLocations: locations,
                mayWorkElsewhere: elsewhere,
              ),
      ));
      // QA KP-TT-015: follow the shared state from now on.
      await _follow(me.email);
    } catch (error) {
      emit(state.copyWith(
        status: CheckInLoadStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  /// QA KP-TT-015 (9/10/2026): listen to the shared check-in state and show
  /// what it knows (another control may already have written a newer day).
  Future<void> _follow(String email) async {
    final TodayAttendanceHub? hub = _hub;
    if (hub == null || isClosed) return;
    await _hubSub?.cancel();
    if (isClosed) return;
    _hubSub = hub.watch(email).listen((_) => _syncFromHub(email));
    _syncFromHub(email);
  }

  void _syncFromHub(String email) {
    final AttendanceDay? shown = _hub?.shownDay(email, _clock());
    if (shown == null || state.status != CheckInLoadStatus.ready) return;
    if (identical(shown, state.day)) return;
    emit(state.copyWith(day: shown));
  }

  /// Function Name: [checkIn]
  ///
  /// Purpose: Check in at [option] (geofence checked for an office).
  ///
  /// Parameters:
  ///   [CheckInOption] option: the sheet's choice.
  ///
  /// Return type: [Future<CheckInResult>]
  Future<CheckInResult> checkIn(CheckInOption option) async {
    if (!_access.canCheckInAndOut) {
      return const CheckInResult(CheckInOutcome.noPermission);
    }
    if (state.busy != CheckInBusy.none) return const CheckInResult(CheckInOutcome.busy);
    final EmployeeWorkSetup? setup = state.setup;
    if (setup == null) return const CheckInResult(CheckInOutcome.notAssigned);
    emit(state.copyWith(busy: CheckInBusy.checkingIn));
    try {
      final WorkLocation? chosen = option.location;
      final bool needsPosition = chosen != null &&
          chosen.isGeofenceEnabled &&
          chosen.hasCoordinates;
      GeoPoint? position;
      if (needsPosition) {
        final DeviceLocationResult read = await _location.currentPosition();
        final CheckInOutcome? issue = _issueOutcome(read.issue);
        if (issue != null) return _done(CheckInResult(issue));
        position = read.position;
      }
      final CheckInDecision decision = CheckInGate.evaluate(
        type: option.type,
        chosen: chosen,
        assignedLocationId: setup.location.id,
        allowedLocationIds: setup.rules.allowedLocationIds,
        mayWorkElsewhere: _mayWorkElsewhere(setup),
        position: position,
      );
      final CheckInOutcome? blocked = _decisionOutcome(decision);
      if (blocked != null) return _done(CheckInResult(blocked));
      final DateTime now = _clock();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final String email = _access.currentUserEmail;
      // Applied to TODAY's day as stored (one transaction) — 9/10/2026.
      await _save(email, today, now, (AttendanceDay? stored) => AttendanceSessionRules.checkIn(
            stored ?? _emptyDay(email, today),
            at: now,
            locationId: chosen?.id ?? '',
            type: option.type,
            latitude: position?.latitude,
            longitude: position?.longitude,
          ));
      _log.log(TimeTrackerLogService.actionCheckIn);
      return _done(CheckInResult(
        CheckInOutcome.success,
        locationVerified: needsPosition,
      ));
    } on _StaleDay catch (stale) {
      // QA KP-TT-015: checked in meanwhile elsewhere — show the stored day.
      await _reloadDay();
      return _done(CheckInResult(stale.outcome));
    } catch (error) {
      await _reloadDay();
      return _done(CheckInResult(CheckInOutcome.failed, message: error.toString()));
    }
  }

  /// Function Name: [pause]
  ///
  /// Purpose: Start a break (only when the rules allow pausing).
  ///
  /// Return type: [Future<CheckInResult>]
  Future<CheckInResult> pause() {
    // Not allowed by the rules: a refusal, not a stale screen (QA KP-TT-015
    // — only a stale move answers "Attendance Updated").
    if (_access.canCheckInAndOut && !state.canPause) {
      return Future<CheckInResult>.value(const CheckInResult(CheckInOutcome.failed));
    }
    return _move(
      CheckInBusy.pausing,
      TimeTrackerLogService.actionPause,
      (AttendanceDay day, DateTime at) => AttendanceSessionRules.pause(
        day,
        at: at,
        isPauseAllowed: state.canPause,
      ),
    );
  }

  /// Function Name: [resume]
  ///
  /// Purpose: End the running break.
  ///
  /// Return type: [Future<CheckInResult>]
  Future<CheckInResult> resume() => _move(
        CheckInBusy.resuming,
        TimeTrackerLogService.actionResume,
        (AttendanceDay day, DateTime at) =>
            AttendanceSessionRules.resume(day, at: at),
      );

  /// Function Name: [checkOut]
  ///
  /// Purpose: Close the open session (and a running break).
  ///
  /// Return type: [Future<CheckInResult>]
  Future<CheckInResult> checkOut() => _move(
        CheckInBusy.checkingOut,
        TimeTrackerLogService.actionCheckOut,
        (AttendanceDay day, DateTime at) =>
            AttendanceSessionRules.checkOut(day, at: at),
      );

  Future<CheckInResult> _move(
    CheckInBusy busy,
    String logAction,
    AttendanceDay Function(AttendanceDay day, DateTime at) apply,
  ) async {
    if (!_access.canCheckInAndOut) {
      return const CheckInResult(CheckInOutcome.noPermission);
    }
    if (state.busy != CheckInBusy.none) return const CheckInResult(CheckInOutcome.busy);
    final AttendanceDay? day = state.day;
    if (day == null) return const CheckInResult(CheckInOutcome.failed);
    emit(state.copyWith(busy: busy));
    try {
      final DateTime now = _clock();
      // The day holding the session (today, or yesterday's overnight one),
      // as STORED — 9/10/2026.
      final String email =
          day.employeeEmail.isEmpty ? _access.currentUserEmail : day.employeeEmail;
      await _save(email, day.date, now, (AttendanceDay? stored) => apply(stored ?? day, now));
      _log.log(logAction);
      return _done(const CheckInResult(CheckInOutcome.success));
    } on _StaleDay catch (stale) {
      // QA KP-TT-015: the stored day cannot take this move (e.g. checked out
      // from a Home card) — nothing written; show the stored day + say so.
      await _reloadDay();
      return _done(CheckInResult(stale.outcome));
    } catch (error) {
      await _reloadDay();
      return _done(CheckInResult(CheckInOutcome.failed, message: error.toString()));
    }
  }

  /// After a refused move (e.g. another device checked out meanwhile) the
  /// control shows the day as stored again (9/10/2026) — and, since QA
  /// KP-TT-015, every other control too (the re-read is shared).
  Future<void> _reloadDay() async {
    try {
      emit(state.copyWith(day: await _loadDay(_access.currentUserEmail, authoritative: true)));
    } catch (error) {
      // Keep the shown day; the next open reloads it.
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  CheckInResult _done(CheckInResult result) {
    emit(state.copyWith(busy: CheckInBusy.none));
    return result;
  }

  Future<void> _save(
    String email,
    DateTime date,
    DateTime now,
    AttendanceDay Function(AttendanceDay? stored) move,
  ) async {
    final WorkSchedule? schedule = state.setup?.schedule;
    final AttendanceDay saved = await _attendance.updateDay(
      employeeEmail: email,
      date: date,
      change: (AttendanceDay? stored) =>
          AttendanceCalculator.apply(_StaleDay.guard(stored, move), schedule: schedule, now: now),
    );
    // QA KP-TT-015: every other Check In & Out control shows it at once.
    _hub?.publish(saved);
    emit(state.copyWith(day: saved));
  }

  /// Today's document, or the open overnight session started yesterday.
  /// QA KP-TT-015 (9/10/2026): what is read is shared — a first load only
  /// fills a gap ([authoritative] false), a re-read after a refused action
  /// replaces what the other controls show.
  Future<AttendanceDay> _loadDay(String email, {bool authoritative = false}) async {
    final DateTime now = _clock();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final AttendanceDay? stored =
        await _attendance.fetchDay(employeeEmail: email, date: today);
    _share(stored, authoritative);
    if (stored != null && stored.isCheckedIn) return stored;
    final AttendanceDay? yesterday = await _attendance.fetchDay(
      employeeEmail: email,
      date: DateTime(now.year, now.month, now.day - 1),
    );
    _share(yesterday, authoritative);
    if (yesterday != null && yesterday.isCheckedIn) return yesterday;
    return stored ?? _emptyDay(email, today);
  }

  void _share(AttendanceDay? day, bool authoritative) {
    if (day != null) _hub?.publish(day, authoritative: authoritative);
  }

  AttendanceDay _emptyDay(String email, DateTime day) =>
      AttendanceDay(id: '', employeeEmail: email, date: day);

  bool _mayWorkElsewhere(EmployeeWorkSetup? setup) =>
      setup != null &&
      _access.canWorkFromDifferentLocation &&
      setup.rules.isDifferentLocationAllowed;

  static CheckInOutcome? _issueOutcome(DeviceLocationIssue? issue) {
    switch (issue) {
      case null:
        return null;
      case DeviceLocationIssue.serviceDisabled:
        return CheckInOutcome.locationServiceOff;
      case DeviceLocationIssue.denied:
      case DeviceLocationIssue.deniedForever:
        return CheckInOutcome.locationDenied;
      case DeviceLocationIssue.unavailable:
        return CheckInOutcome.locationUnavailable;
      case DeviceLocationIssue.mocked:
        return CheckInOutcome.mockedLocation;
    }
  }

  static CheckInOutcome? _decisionOutcome(CheckInDecision decision) {
    switch (decision) {
      case CheckInDecision.allowed:
        return null;
      case CheckInDecision.wrongLocation:
        return CheckInOutcome.wrongLocation;
      case CheckInDecision.positionRequired:
        return CheckInOutcome.locationUnavailable;
      case CheckInDecision.locationNotAllowed:
        return CheckInOutcome.locationNotAllowed;
      case CheckInDecision.differentLocationNotAllowed:
        return CheckInOutcome.differentLocationNotAllowed;
    }
  }
}

/// QA KP-TT-015 (9/10/2026): thrown INSIDE the write's transaction when the
/// STORED day cannot take the move the (stale) screen asked for — the write
/// is aborted and the cubit answers [outcome] after re-reading. An
/// `Exception`, so the repository passes it through unchanged.
class _StaleDay implements Exception {
  const _StaleDay({required this.notCheckedIn});

  /// The stored day has no open session (checked out elsewhere).
  final bool notCheckedIn;

  CheckInOutcome get outcome =>
      notCheckedIn ? CheckInOutcome.alreadyCheckedOut : CheckInOutcome.stateChanged;

  /// Function Name: [guard]
  ///
  /// Purpose: Apply [move] to [stored]; a refused move (`StateError` from
  /// `AttendanceSessionRules`) becomes a [_StaleDay].
  ///
  /// Return type: [AttendanceDay]
  static AttendanceDay guard(
    AttendanceDay? stored,
    AttendanceDay Function(AttendanceDay? stored) move,
  ) {
    try {
      return move(stored);
    } on StateError {
      throw _StaleDay(notCheckedIn: !(stored?.isCheckedIn ?? false));
    }
  }

  @override
  String toString() => notCheckedIn
      ? 'You have already checked out. The screen now shows your latest attendance.'
      : 'Your attendance changed on another screen or device. It has been refreshed.';
}
