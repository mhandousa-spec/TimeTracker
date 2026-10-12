/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: employees_base_repository.dart
/// Purpose: Domain contract for employee reads, writes and backups.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added so the controllers depend on an abstraction rather than a concrete
/// repository they construct themselves.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/models/employee_directory_model.dart';

abstract class EmployeesBaseRepository {
  /// Every employee in the tenant.
  Future<Either<Failure, dynamic>> getAllEmployees();

  /// Look an employee up by email. `null` when there is no match.
  Future<NewEmployeeModelHistory?> getEmployeeByEmail(String email);

  /// The directory entry for an email. `null` when absent.
  Future<EmployeeDirectoryModel?> getEmployeeDirectory(String email);

  /// Create or merge-update an employee document.
  Future<void> saveEmployee(NewEmployeeModelHistory employee);

  /// Roll the two-level backup: backup1 → backup2, main → backup1.
  Future<void> backupCollections();

  /// Every employee held in one backup collection.
  ///
  /// ADDED 30/8/2026 for the Restore dialog, which previews a backup before
  /// the destructive [restoreFromBackup]. [backupVersion] follows the same
  /// convention as [restoreFromBackup]: `'second'` is backup two, anything
  /// else is backup one.
  Future<List<NewEmployeeModelHistory>> getBackupEmployees(
    String backupVersion,
  );

  /// Replace the main collection with a backup's contents.
  ///
  /// **Destructive.** [confirmDestructiveRestore] must be `true`; see the
  /// implementation for why the guard exists.
  Future<void> restoreFromBackup(
    String backupVersion, {
    required bool confirmDestructiveRestore,
  });
}
