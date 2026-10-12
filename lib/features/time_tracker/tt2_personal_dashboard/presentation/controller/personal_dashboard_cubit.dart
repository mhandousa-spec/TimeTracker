/// Module: time_tracker / tt2_personal_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: personal_dashboard_cubit.dart
/// Purpose: Declares `PersonalDashboardCubit` — streams the signed-in
///          employee's attendance days and requests, reads their vacation
///          balance of the current year and location names, and
///          holds the range / Late History mode of the Personal Dashboard.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Gated by `Personal_Dashboard` (the tab only exists with it). A failed
/// balance / location read degrades ("—" / ids) instead of failing the
/// whole tab.
///
/// Async work starts in [init]; streams are cancelled in [close];
/// emit-after-close guarded (playbook §3).
/// Updated: 9/10/2026 - phase 5: [init] takes another employee's e-mail
/// (the employee dashboard HR opens from a location, Figma `661:96459`;
/// their balance is rolled over in memory only — nothing is written for
/// them), and "Vacations Credit" follows the stored balance live
/// (`watchBalance`), so an HR edit / import shows at once.
/// Updated: 9/10/2026 - code review: only the employee's OWN requests are
/// streamed (finding 9 — `watchRequestsOf`); their schedule is loaded so an
/// untrusted absent row is not counted (finding 1); a failed balance read
/// shows "—" (not 0) and a failed live update is kept, not swallowed; the
/// balance read no longer writes a roll-over; no subscription is opened
/// after [close] ran during [init]'s awaits.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): "Vacations Credit" reads
/// the balance document of the CURRENT year (`{email}_{year}`; none = 0
/// days) — no roll-over; remaining is computed (Total − Used).
/// Updated: 9/10/2026 - QA KP-TT-013: the work set-up's assignment start is
/// kept, so Absence counts like the HR view (`HrDayBook`).

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/vacation_balance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_state.dart';

class PersonalDashboardCubit extends Cubit<PersonalDashboardState> {
  PersonalDashboardCubit({
    required AttendanceBaseRepository attendance,
    required RequestBaseRepository requests,
    required VacationBalanceBaseRepository balances,
    required WorkSetupSourceResolver resolver,
    required TimeTrackerAccess access,
    DateTime Function() clock = DateTime.now,
  })  : _attendance = attendance,
        _requests = requests,
        _balances = balances,
        _resolver = resolver,
        _access = access,
        _clock = clock,
        super(PersonalDashboardState());

  final AttendanceBaseRepository _attendance;
  final RequestBaseRepository _requests;
  final VacationBalanceBaseRepository _balances;
  final WorkSetupSourceResolver _resolver;
  final TimeTrackerAccess _access;
  final DateTime Function() _clock;

  StreamSubscription<List<AttendanceDay>>? _daysSub;
  StreamSubscription<List<TimeTrackerRequest>>? _requestsSub;
  StreamSubscription<VacationBalance?>? _balanceSub;
  bool _daysLoaded = false;
  bool _requestsLoaded = false;

  @override
  void emit(PersonalDashboardState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Start the streams and the one-shot reads. [employeeEmail]
  /// (9/10/2026, phase 5) shows another employee's dashboard ([employeeId]
  /// finds their HR shift); null = the signed-in user.
  ///
  /// Return type: [Future<void>]
  Future<void> init({String? employeeEmail, String employeeId = ''}) async {
    final String other = (employeeEmail ?? '').trim().toLowerCase();
    final bool self = other.isEmpty || other == _access.currentUserEmail;
    final String email = other.isNotEmpty ? other : _access.currentUserEmail;
    emit(state.copyWith(
      status: PersonalDashboardStatus.loading,
      email: email,
      now: _clock(),
      errorMessage: '',
    ));
    await _daysSub?.cancel();
    await _requestsSub?.cancel();
    // 9/10/2026: closed meanwhile → open nothing (it would never be cancelled).
    if (isClosed) return;
    _daysLoaded = false;
    _requestsLoaded = false;
    _daysSub = _attendance.watchEmployeeAttendance(employeeEmail: email).listen(
      (List<AttendanceDay> days) {
        _daysLoaded = true;
        _publish(state.copyWith(days: days, now: _clock()));
      },
      onError: _fail,
    );
    // Finding 9: only this employee's own requests.
    _requestsSub = _requests.watchRequestsOf(email: email).listen(
      (List<TimeTrackerRequest> requests) {
        _requestsLoaded = true;
        _publish(state.copyWith(requests: requests, now: _clock()));
      },
      onError: _fail,
    );
    await Future.wait(<Future<void>>[
      _loadBalance(email),
      _loadLocationNames(),
      _loadSchedule(email, self ? _access.identity.employeeId : employeeId),
    ]);
  }

  /// Function Name: [selectRange]
  ///
  /// Purpose: Day / Week / Month / Year (Custom goes through [applyCustom]).
  ///
  /// Return type: [void]
  void selectRange(DashboardRange range) {
    if (range == DashboardRange.custom) return;
    emit(state.copyWith(range: range, now: _clock()));
  }

  /// Function Name: [applyCustom]
  ///
  /// Purpose: The "Custom Data Selector" Apply — a range of days.
  ///
  /// Parameters:
  ///   [DateTime] first / [DateTime] last: swapped when reversed.
  ///
  /// Return type: [void]
  void applyCustom(DateTime first, DateTime last) {
    final bool reversed = last.isBefore(first);
    emit(state.copyWith(
      range: DashboardRange.custom,
      customSpan: DateSpan(reversed ? last : first, reversed ? first : last),
      now: _clock(),
    ));
  }

  /// Function Name: [setLateMode]
  ///
  /// Purpose: Counts / Minutes toggle of Late History.
  ///
  /// Return type: [void]
  void setLateMode(LateHistoryMode mode) => emit(state.copyWith(lateMode: mode));

  void _publish(PersonalDashboardState next) {
    final bool ready = _daysLoaded && _requestsLoaded;
    emit(next.copyWith(
      status: ready ? PersonalDashboardStatus.loaded : PersonalDashboardStatus.loading,
    ));
  }

  void _fail(Object error) {
    emit(state.copyWith(
      status: PersonalDashboardStatus.failure,
      errorMessage: error.toString(),
    ));
  }

  Future<void> _loadBalance(String email) async {
    try {
      // 9/10/2026 (data model): this year's document — no roll-over.
      final VacationBalance? balance =
          await _balances.fetchBalance(employeeEmail: email, year: _clock().year);
      emit(state.copyWith(vacationDaysLeft: _left(balance), balanceUnavailable: false));
    } catch (error) {
      // No balance readable → "—" (not a misleading 0); the rest works.
      emit(state.copyWith(vacationDaysLeft: 0, balanceUnavailable: true, errorMessage: error.toString()));
    }
    // 9/10/2026 (phase 5): follow later edits / imports / deductions.
    await _balanceSub?.cancel();
    if (isClosed) return;
    _balanceSub = _balances.watchBalance(employeeEmail: email, year: _clock().year).listen(
      (VacationBalance? b) => emit(state.copyWith(vacationDaysLeft: _left(b), balanceUnavailable: false)),
      onError: (Object error) => emit(state.copyWith(balanceUnavailable: true, errorMessage: error.toString())),
    );
  }

  /// Finding 1 (9/10/2026): the schedule decides which absent rows count.
  Future<void> _loadSchedule(String email, String employeeId) async {
    try {
      final EmployeeWorkSetup? setup = await (await _resolver.resolve())
          .loadWorkSetup(employeeEmail: email, employeeId: employeeId);
      final WorkSchedule? schedule = setup?.schedule;
      // QA KP-TT-013 (9/10/2026): + the assignment start (HR's day rule).
      if (schedule != null) {
        emit(state.copyWith(schedule: schedule, assignmentStart: setup?.startDate, now: _clock()));
      }
    } catch (error) {
      // Unknown schedule → every stored day counts (the old behaviour).
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  /// Remaining days of [b] (Total − Used; none stored = 0).
  double _left(VacationBalance? b) => b?.remainingDays ?? 0;

  Future<void> _loadLocationNames() async {
    try {
      final List<WorkLocation> locations =
          await (await _resolver.resolve()).loadLocations();
      emit(state.copyWith(locationNames: <String, String>{
        for (final WorkLocation l in locations) l.id: l.nameEn,
        for (final WorkLocation l in locations)
          if (l.nameAr.isNotEmpty) '${l.id}#ar': l.nameAr,
      }));
    } catch (error) {
      // Names unavailable → the donut shows ids; nothing else depends on it.
      emit(state.copyWith(locationNames: const <String, String>{}, errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _daysSub?.cancel();
    await _requestsSub?.cancel();
    await _balanceSub?.cancel();
    return super.close();
  }
}
