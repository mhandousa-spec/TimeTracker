/// Module: settings/main_controller
///
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/data_source/remote_data_source/employees_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/data_source/remote_data_source/employee_backup_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/models/employee_directory_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/utils/employee_collection_paths.dart';
import 'package:knowticed_plus/features/settings/main_controller/domain/base_repository/employees_base_repository.dart';

/// ******************************** FILE INFO *****************************
/// Class Name: EmployeesRepository
/// Purpose: This file contains the class for employees repository
/// Author: Amr Mesbah
/// Created At: 5/11/2024
/// Ported into services_app under features/settings (source: services_app
/// features/employees/data/repository/employees_repository.dart).
/// Updated 11/8/2026 - implements [EmployeesBaseRepository]; data sources are
/// injected; the Firestore work that used to sit in EmployeeController (reads,
/// merges, backup rotation, destructive restore) now routes through here.
class EmployeesRepository implements EmployeesBaseRepository {
  EmployeesRepository({
    EmployeesRemoteDataSource? remoteDataSource,
    EmployeeBackupRemoteDataSource? backupDataSource,
  })  : _remoteDataSource = remoteDataSource ?? EmployeesRemoteDataSource(),
        _backupDataSource =
            backupDataSource ?? EmployeeBackupRemoteDataSource();

  final EmployeesRemoteDataSource _remoteDataSource;
  final EmployeeBackupRemoteDataSource _backupDataSource;

  /// Function Name : getAllEmployees
  /// Purpose: get all employees as NewEmployeeModelHistory and pass to controller
  /// return: Future<Either<Failure, List<NewEmployeeModelHistory>>>
  @override
  Future<Either<Failure, List<NewEmployeeModelHistory>>>
      getAllEmployees() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(EmployeeCollectionPaths.main)
          .get();

      List<NewEmployeeModelHistory> employees = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          NewEmployeeModelHistory employee =
              NewEmployeeModelHistory.fromMap(data);
          employees.add(employee);
        } catch (_) {
          // Deliberate: one malformed document must not take down the whole
          // employee list. Skipped rows are invisible by design — if you need
          // visibility, surface a count rather than throwing here.
          continue;
        }
      }

      return Right(employees);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name : getAllEmployeesDirectory
  /// Purpose: get all employees directory entries and pass to controller
  /// return: Future<Either<Failure, dynamic>>
  Future<Either<Failure, dynamic>> getAllEmployeesDirectory() async {
    Either<Failure, dynamic> result;
    result = await _remoteDataSource.getAllEmployeesDirectory();
    if (result.isLeft()) return result;
    List<EmployeeDirectoryModel> directories = [];
    List<Map<String, dynamic>> data = result.getOrElse(() => []);
    for (var element in data) {
      directories.add(EmployeeDirectoryModel.fromMap(element));
    }
    result = Right(directories);
    return result;
  }

  Future<Either<Failure, dynamic>> isEmployeeExist(
      {required String employeeId}) async {
    Either<Failure, dynamic> result =
        await _remoteDataSource.getEmployee(employeeId: employeeId);
    if (result.isLeft()) return result;
    if (result.getOrElse(() => null) == null) {
      return result = Right(false);
    }
    return result = Right(true);
  }

  Future<void> activateAccountOverview(
      String email, bool isDemoActivation) async {
    return await _remoteDataSource.activateAccountOverview(
        email, isDemoActivation);
  }

  @override
  Future<NewEmployeeModelHistory?> getEmployeeByEmail(String email) =>
      _backupDataSource.getEmployeeByEmail(email);

  @override
  Future<EmployeeDirectoryModel?> getEmployeeDirectory(String email) =>
      _backupDataSource.getEmployeeDirectory(email);

  @override
  Future<void> saveEmployee(NewEmployeeModelHistory employee) =>
      _backupDataSource.saveEmployee(employee);

  @override
  Future<void> backupCollections() => _backupDataSource.backupCollections();

  @override
  Future<List<NewEmployeeModelHistory>> getBackupEmployees(
          String backupVersion) =>
      _backupDataSource.getBackupEmployees(backupVersion);

  @override
  Future<void> restoreFromBackup(
    String backupVersion, {
    required bool confirmDestructiveRestore,
  }) =>
      _backupDataSource.restoreFromBackup(
        backupVersion,
        confirmDestructiveRestore: confirmDestructiveRestore,
      );
}
