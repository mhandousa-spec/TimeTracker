/// Module: time_tracker / tt3_attendance / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_cubit.dart
/// Purpose: Declares `AttendanceCubit` — streams the signed-in employee's
///          attendance days and holds the Attendance tab's search + filter.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Gated by `View_Attendance` (the tab only exists with it). Owner decision
/// 8: the tab is read-only — corrections go through "+ Transaction".
/// Async work starts in [init]; the stream is cancelled in [close];
/// emit-after-close guarded (playbook §3).
/// Updated: 9/10/2026 - code review finding 1: with the employee's schedule
/// (`resolver`), an untrusted absent row — written by the old sweep on a
/// non-working day / an HR shift's unknown week (`AbsenceRules`) — is not
/// listed; nothing is deleted in Firestore. No subscription is opened after
/// [close] ran during [init].

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absence_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_table_filter.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit({
    required AttendanceBaseRepository attendance,
    required TimeTrackerAccess access,
    WorkSetupSourceResolver? resolver,
  })  : _attendance = attendance,
        _access = access,
        _resolver = resolver,
        super(const AttendanceState());

  final AttendanceBaseRepository _attendance;
  final TimeTrackerAccess _access;
  final WorkSetupSourceResolver? _resolver;
  StreamSubscription<List<AttendanceDay>>? _sub;

  /// The stored days as streamed, and the schedule that filters them.
  List<AttendanceDay> _raw = const <AttendanceDay>[];
  WorkSchedule? _schedule;

  @override
  void emit(AttendanceState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Start streaming the employee's days.
  ///
  /// Return type: [Future<void>]
  Future<void> init() async {
    emit(state.copyWith(status: AttendanceLoadStatus.loading, errorMessage: ''));
    await _sub?.cancel();
    if (isClosed) return;
    _sub = _attendance
        .watchEmployeeAttendance(employeeEmail: _access.currentUserEmail)
        .listen(
      (List<AttendanceDay> days) {
        _raw = days;
        emit(state.copyWith(
          status: AttendanceLoadStatus.loaded,
          days: AbsenceRules.trusted(days, _schedule),
        ));
      },
      onError: (Object error) => emit(state.copyWith(
        status: AttendanceLoadStatus.failure,
        errorMessage: error.toString(),
      )),
    );
    await _loadSchedule();
  }

  /// Finding 1: the schedule that tells which absent rows to trust.
  Future<void> _loadSchedule() async {
    final WorkSetupSourceResolver? resolver = _resolver;
    if (resolver == null) return;
    try {
      final TimeTrackerIdentity me = _access.identity;
      final EmployeeWorkSetup? setup = await (await resolver.resolve())
          .loadWorkSetup(employeeEmail: me.email, employeeId: me.employeeId);
      _schedule = setup?.schedule;
      if (state.status == AttendanceLoadStatus.loaded) {
        emit(state.copyWith(days: AbsenceRules.trusted(_raw, _schedule)));
      }
    } catch (error) {
      // Without the schedule every stored row is listed (old behaviour).
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  /// Function Name: [searchChanged]
  ///
  /// Purpose: The search box text.
  ///
  /// Return type: [void]
  void searchChanged(String query) => emit(state.copyWith(query: query));

  /// Function Name: [applyFilter]
  ///
  /// Purpose: The filter popup's Apply.
  ///
  /// Return type: [void]
  void applyFilter(AttendanceFilter filter) => emit(state.copyWith(filter: filter));

  /// Function Name: [resetFilter]
  ///
  /// Purpose: The filter popup's Reset.
  ///
  /// Return type: [void]
  void resetFilter() => emit(state.copyWith(filter: AttendanceFilter.none));

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
