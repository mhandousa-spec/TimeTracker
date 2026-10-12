/// Module: time_tracker / tt3_attendance / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_state.dart
/// Purpose: Declares `AttendanceState` (+ `AttendanceLoadStatus`) — the
///          signed-in employee's attendance days, the search text and the
///          filter of the Attendance tab.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// One immutable state + `copyWith` + status enum + derived getters
/// (playbook §3). Filtering / tile counts are the pure `AttendanceTable`.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_table_filter.dart';

enum AttendanceLoadStatus { initial, loading, loaded, failure }

class AttendanceState {
  const AttendanceState({
    this.status = AttendanceLoadStatus.initial,
    this.days = const <AttendanceDay>[],
    this.query = '',
    this.filter = AttendanceFilter.none,
    this.errorMessage = '',
  });

  final AttendanceLoadStatus status;
  final List<AttendanceDay> days;
  final String query;
  final AttendanceFilter filter;
  final String errorMessage;

  /// Present / Absent / Late / Vacation / Sick Leave / Excuse Leave.
  AttendanceTileCounts get tiles => AttendanceTable.tiles(days);

  /// Function Name: [rows]
  ///
  /// Purpose: The rows to show (see `AttendanceTable.rows`).
  ///
  /// Parameters:
  ///   [String Function(AttendanceDay)] describe: the row's visible text.
  ///
  /// Return type: [List<AttendanceDay>]
  List<AttendanceDay> rows(String Function(AttendanceDay day) describe) =>
      AttendanceTable.rows(
        days: days,
        filter: filter,
        query: query,
        describe: describe,
      );

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [AttendanceState]
  AttendanceState copyWith({
    AttendanceLoadStatus? status,
    List<AttendanceDay>? days,
    String? query,
    AttendanceFilter? filter,
    String? errorMessage,
  }) =>
      AttendanceState(
        status: status ?? this.status,
        days: days ?? this.days,
        query: query ?? this.query,
        filter: filter ?? this.filter,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
