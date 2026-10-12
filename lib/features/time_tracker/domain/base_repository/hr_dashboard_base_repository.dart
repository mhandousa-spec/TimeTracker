/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_base_repository.dart
/// Purpose: Declares `HrDashboardBaseRepository` — the company-wide reads of
///          the HR dashboard: many employees' attendance days for a date
///          range, and every employee's placement (location + schedule).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Kept apart from `AttendanceBaseRepository` (one employee at a time) so the
/// existing contracts and their test doubles stay unchanged. Reads stay
/// BOUNDED: attendance is read per employee as a document-id range
/// `{email}_{first}` … `{email}_{last}` (no field query on a history list —
/// FINAL SPEC §2 house rule), so only the days of the asked range are read.
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';

abstract class HrDashboardBaseRepository {
  /// Function Name: [fetchAttendance]
  ///
  /// Purpose: The stored attendance days of [employeeEmails] inside [span].
  ///
  /// Parameters:
  ///   [Iterable<String>] employeeEmails: lower-cased; blanks are skipped.
  ///   [DateSpan] span: both ends included.
  ///
  /// Return type: [Future<List<AttendanceDay>>]
  Future<List<AttendanceDay>> fetchAttendance({
    required Iterable<String> employeeEmails,
    required DateSpan span,
  });

  /// Function Name: [fetchPlacements]
  ///
  /// Purpose: Where each of [employees] works and when (HR-owned data when
  /// the company has HR, Time Tracker's otherwise). Employees with no
  /// assignment are left out.
  ///
  /// Parameters:
  ///   [List<TimeTrackerEmployee>] employees
  ///
  /// Return type: [Future<Map<String, EmployeePlacement>>] — keyed by e-mail.
  Future<Map<String, EmployeePlacement>> fetchPlacements({
    required List<TimeTrackerEmployee> employees,
  });
}
