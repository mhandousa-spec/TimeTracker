/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: org_chart_manager_resolver.dart
/// Purpose: Declares `OrgChartManagerResolver` — `ManagerResolver` backed by
///          the Org Chart's `Supervisor` link.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 18 (8/10/2026). Lookup order:
///   1. the signed-in company's in-memory employee directory (loaded at
///      login by `MainCoreEmployeeController`, keyed by email) — no network;
///   2. when that has no answer and the employee id is known,
///      `Employees_Info/{employeeId}.Supervisor` in Firestore.
/// The answer is trimmed + lower-cased; the employee's own email (a
/// self-reference the org chart also ignores) counts as "no manager".
///
/// The directory lookup is injectable so the rules can be unit-tested
/// without GetX controllers.

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/employee_directory_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/manager_resolver.dart';

/// The `Supervisor` of the employee with [email] in memory, or null when the
/// employee is not in the directory.
typedef SupervisorLookup = String? Function(String email);

class OrgChartManagerResolver implements ManagerResolver {
  OrgChartManagerResolver({
    required EmployeeDirectoryRemoteDataSource remoteDataSource,
    SupervisorLookup lookup = _fromSignedInDirectory,
  })  : _remote = remoteDataSource,
        _lookup = lookup;

  final EmployeeDirectoryRemoteDataSource _remote;
  final SupervisorLookup _lookup;

  @override
  Future<String> managerEmailOf({
    required String employeeEmail,
    String employeeId = '',
  }) async {
    final String email = employeeEmail.trim().toLowerCase();
    String? supervisor = _lookup(employeeEmail.trim()) ?? _lookup(email);
    if ((supervisor ?? '').trim().isEmpty && employeeId.trim().isNotEmpty) {
      try {
        supervisor = await _remote.fetchSupervisorEmail(employeeId);
      } catch (error) {
        throw _clean(error);
      }
    }
    final String manager = (supervisor ?? '').trim().toLowerCase();
    if (manager.isEmpty || manager == email) return '';
    return manager;
  }

  Exception _clean(Object error) {
    if (error is FirebaseException) {
      return Exception('Could not read your direct manager (${error.code}).');
    }
    if (error is StateError) return Exception(error.message);
    if (error is Exception) return error;
    return Exception('Could not read your direct manager: $error');
  }

  static String? _fromSignedInDirectory(String email) {
    if (!AppControllers.isEmployeeRegistered) return null;
    return AppControllers.employee.getLocaleEmployee(email)?.supervisor;
  }
}
