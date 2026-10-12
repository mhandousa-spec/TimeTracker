/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_base_repository.dart
/// Purpose: Domain contract for the settings shell's single write path.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SEMAIN-N05: `SettingsRepository` was a concrete class with
/// no interface, so nothing that depends on it could be mocked. The controller
/// now depends on this abstraction instead.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

abstract class SettingsBaseRepository {
  /// Function Name: [updateEmployee]
  ///
  /// Purpose: Merge-update the signed-in employee's profile document.
  ///
  /// Parameters:
  /// - [employee]: the model to persist. Its `id` is used as the document id.
  ///
  /// Returns: [Future<Either<Failure, void>>] — `Left` carries the reason the
  ///          write failed. The previous signature was an untyped `dynamic`,
  ///          so callers could not tell success from failure.
  Future<Either<Failure, void>> updateEmployee(NewEmployeeModelHistory employee);
}
