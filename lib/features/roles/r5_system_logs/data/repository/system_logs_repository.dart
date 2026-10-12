/// Module: roles / r5_system_logs / data / repository
///
/// *********************** FILE INFO ******************** ///
/// FILE NAME: system_logs_repository.dart
/// PURPOSE: handle all the operations related to the system logs.
/// Author: Amr Mesbah
/// CREATED AT: 2/2/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
// Was `package:geolocator_platform_interface/src/models/position.dart` — a
// package-internal `src/` path that is not part of the public contract and
// breaks on minor upgrades.
import 'package:geolocator/geolocator.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/data_source/remote_data_source/system_logs_remote_data_source.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';

class SystemLogsRepository {
  SystemLogsRemoteDataSource systemLogsRemoteDataSource =
      SystemLogsRemoteDataSource();

  /// Method Name: [addActivityLog]
  ///
  /// Description: this method will add the activity log to the system logs.
  ///
  /// Parameters:
  ///          [String] activity: the activity that will be added to the system logs.
  ///          [NewEmployeeModelHistory] currentEmployee: the current employee that will be added to the system logs.
  ///          [Position] currentPosition: the current position of the employee.
  ///
  /// Return Value: [Future<Either<Failure,dynamic>>] the result of the operation.
  Future<Either<Failure, dynamic>> addActivityLog(
      {required String activity,
      required Modules module,
      required NewEmployeeModelHistory currentEmployee,
      required Position? currentPosition}) async {
    SystemLogsModel systemLogsModel = SystemLogsModel(
      module: module,
      userEmail: currentEmployee.email?.lastOrNull,
      firstName: currentEmployee.firstName?.lastOrNull ?? '',
      lastName: currentEmployee.lastName?.lastOrNull ?? '',
      middleName: currentEmployee.middleName?.lastOrNull ?? '',
      firstNameInArabic:
          currentEmployee.firstNameInArabic?.lastOrNull ??
              '',
      middleNameInArabic:
          currentEmployee.middleNameInArabic?.lastOrNull ??
              '',
      lastNameInArabic:
          currentEmployee.lastNameInArabic?.lastOrNull ?? '',
      role: currentEmployee.role?.lastOrNull ?? "",
      country: currentEmployee.country?.lastOrNull ?? '',
      city: currentEmployee.city?.lastOrNull ?? '',
      // ✅ FIX: currentPosition is null on macOS (location is skipped);
      // the old `currentPosition!` crashed with a null-check error.
      lat: currentPosition?.latitude.toString() ?? '',
      long: currentPosition?.longitude.toString() ?? '',
      action: activity,
      timestamp: Timestamp.now(),
    );
    return await systemLogsRemoteDataSource.addActivityLog(systemLogsModel);
  }

  /// Method Name: [getSystemLogs]
  ///
  /// Description: this method will get the system logs from the remote data source.
  ///
  /// Return Value: [Future<Either<Failure,dynamic>>] the result of the operation.
  Future<Either<Failure, dynamic>> getSystemLogs() async {
    Either<Failure, dynamic> result =
        await systemLogsRemoteDataSource.getSystemLogs();
    if (result.isLeft()) return result;
    List<SystemLogsModel> systemLogs = [];
    result.fold((l) => null, (r) {
      r.forEach((element) {
        systemLogs.add(SystemLogsModel.fromMap(element));
      });
    });
    return result = Right(systemLogs);
  }
}
