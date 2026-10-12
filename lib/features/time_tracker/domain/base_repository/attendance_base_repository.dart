/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_base_repository.dart
/// Purpose: Declares `AttendanceBaseRepository` — the contract for attendance days.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.
/// Updated: 9/10/2026 - code review: [updateDay] (read-modify-write in one
/// transaction).
/// Updated: 9/10/2026 - QA KP-TT-015: [watchDay] (one day, live).

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';

abstract class AttendanceBaseRepository {
  /// Function Name: [watchEmployeeAttendance]
  ///
  /// Purpose: Live list of every attendance day of [employeeEmail].
  ///
  /// Parameters:
  ///   [String] employeeEmail
  ///
  /// Return type: [Stream<List<AttendanceDay>>] — emits an `Exception` error
  /// event when the read fails.
  Stream<List<AttendanceDay>> watchEmployeeAttendance({
    required String employeeEmail,
  });

  /// Function Name: [watchDay]
  ///
  /// Purpose: ADDED 9/10/2026 (QA KP-TT-015) — live copy of ONE stored day
  /// of [employeeEmail] (null while nothing is stored). Feeds the shared
  /// check-in state (`TodayAttendanceHub`), so a check-in / out made on
  /// another screen or device shows on every Check In & Out control.
  ///
  /// Parameters:
  ///   [String] employeeEmail
  ///   [DateTime] date: the calendar day.
  ///
  /// Return type: [Stream<AttendanceDay?>] — emits an `Exception` error
  /// event when the read fails.
  Stream<AttendanceDay?> watchDay({
    required String employeeEmail,
    required DateTime date,
  });

  /// Function Name: [fetchDay]
  ///
  /// Purpose: One day of [employeeEmail], or null when nothing is stored yet.
  ///
  /// Parameters:
  ///   [String] employeeEmail
  ///   [DateTime] date: the calendar day.
  ///
  /// Return type: [Future<AttendanceDay?>]
  Future<AttendanceDay?> fetchDay({
    required String employeeEmail,
    required DateTime date,
  });

  /// Function Name: [saveDay]
  ///
  /// Purpose: Append [day] as the next history row of its document (created
  /// on the first check-in of the day).
  ///
  /// Parameters:
  ///   [AttendanceDay] day: with its derived fields already recalculated.
  ///
  /// Return type: [Future<AttendanceDay>] — as stored.
  Future<AttendanceDay> saveDay({required AttendanceDay day});

  /// Function Name: [updateDay]
  ///
  /// Purpose: ADDED 9/10/2026 (code review) — read the STORED day of
  /// [employeeEmail] on [date] and append [change] of it, in ONE
  /// transaction: a check-in / pause / check-out never overwrites what a
  /// second device or an approved transaction wrote meanwhile.
  ///
  /// Parameters:
  ///   [String] employeeEmail / [DateTime] date
  ///   [AttendanceDay Function(AttendanceDay?)] change: the next day from the
  ///     stored one (null = none yet); throwing aborts the write.
  ///
  /// Return type: [Future<AttendanceDay>] — as stored.
  Future<AttendanceDay> updateDay({
    required String employeeEmail,
    required DateTime date,
    required AttendanceDay Function(AttendanceDay? stored) change,
  });

  /// Function Name: [createDayIfAbsent]
  ///
  /// Purpose: Create [day]'s document only when the employee has no record
  /// for that date yet (absent-day sweep, owner decision 20 — idempotent).
  ///
  /// Parameters:
  ///   [AttendanceDay] day
  ///
  /// Return type: [Future<bool>] — true when it was created.
  Future<bool> createDayIfAbsent({required AttendanceDay day});

  /// Function Name: [fetchCorrectionHistory]
  ///
  /// Purpose: The day [requestId] corrected, now and just before the first
  /// history row that request wrote (phase 4, 9/10/2026 — revert).
  ///
  /// Parameters:
  ///   [String] employeeEmail
  ///   [DateTime] date: the corrected day.
  ///   [String] requestId: the transaction.
  ///
  /// Return type: [Future<AttendanceCorrectionHistory?>] — null when the day
  /// has no row written by that request.
  Future<AttendanceCorrectionHistory?> fetchCorrectionHistory({
    required String employeeEmail,
    required DateTime date,
    required String requestId,
  });
}
