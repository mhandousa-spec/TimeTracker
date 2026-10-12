/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: employee_directory_base_repository.dart
/// Purpose: Declares `EmployeeDirectoryBaseRepository` — the contract for
///          reading the company's employees (Employees / Groups screens).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Read-only: Time Tracker never writes employees.

import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';

abstract class EmployeeDirectoryBaseRepository {
  /// Function Name: [fetchEmployees]
  ///
  /// Purpose: Every active employee of the signed-in company.
  ///
  /// Parameters:
  ///   [bool] isArabic: the language department names are read in.
  ///
  /// Return type: [Future<List<TimeTrackerEmployee>>] — e-mails lower-cased,
  /// one entry per e-mail, sorted by name.
  Future<List<TimeTrackerEmployee>> fetchEmployees({required bool isArabic});

  /// Function Name: [fetchDepartments]
  ///
  /// Purpose: The company's departments, id → name in the app language
  /// (Request Types "Limit Department Availability").
  ///
  /// Return type: [Future<Map<String, String>>]
  Future<Map<String, String>> fetchDepartments({required bool isArabic});
}
