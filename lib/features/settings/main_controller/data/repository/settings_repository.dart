/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_repository.dart
/// Purpose: Implements [SettingsBaseRepository] over the remote data source.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SEMAIN-N05/N19: header added, the data source
///          is now `final` and injectable, explicit return types everywhere,
///          and the class implements a domain contract so it can be faked.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/data_source/remote_data_source/settings_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/main_controller/domain/base_repository/settings_base_repository.dart';

class SettingsRepository implements SettingsBaseRepository {
  SettingsRepository({SettingsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? SettingsRemoteDataSource();

  final SettingsRemoteDataSource _remoteDataSource;

  /// Function Name: [updateEmployee]
  ///
  /// Purpose: Merge-update the employee profile document.
  ///
  /// Returns: [Future<Either<Failure, void>>] — `Left(FirebaseFailure)` when
  ///          the model has no id, instead of the previous `employee.id!`
  ///          force-unwrap, which threw for an unsaved model.
  @override
  Future<Either<Failure, void>> updateEmployee(
      NewEmployeeModelHistory employee) async {
    final String? employeeId = employee.id;
    if (employeeId == null || employeeId.isEmpty) {
      return Left<Failure, void>(
        FirebaseFailure('Cannot update an employee that has no document id.'),
      );
    }

    return _remoteDataSource.updateEmployeeModel(
      employeeId: employeeId,
      employee: employee,
    );
  }
}
