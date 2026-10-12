/// Module: roles / r4_active_directory / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: main_core_employee_repository.dart
/// Purpose: Declares `MainCoreEmployeeRepository`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/data_source/remote_data_source/department_and_employee_remote_data_source.dart';

import '../models/employees_model/new_employee_model.dart';
import 'package:flutter/foundation.dart';

class MainCoreEmployeeRepository {
  MainCoreEmployeeRemoteDataSource remoteDataSource =
  MainCoreEmployeeRemoteDataSource();

  Future<Either<Failure, List<NewEmployeeModelHistory>>> getEmployees() async {
    Either<Failure, dynamic> result = await remoteDataSource.getAllEmployees();
    if (result.isLeft()) return Left(result.fold((l) => l, (r) => FirebaseFailure('Unknown error')));
    List<Map<String, dynamic>> employees = result.getOrElse(() => []);
    // ✅ FIX: one malformed document used to throw inside .map() and lose
    // ALL employees. Parse each record separately and skip the bad ones.
    List<NewEmployeeModelHistory> newEmployees = [];
    for (var employee in employees) {
      try {
        newEmployees.add(NewEmployeeModelHistory.fromMap(employee));
      } catch (e) {
        // Was an empty `catch {}` — the failure is deliberately
        // non-fatal here, but it must not vanish silently (§11.5).
        debugPrint('main_core_employee_repository.dart: non-fatal failure: $e');
      }
    }
    return Right(newEmployees);
  }
}


// class MainCoreEmployeeRepository {
//   MainCoreEmployeeRemoteDataSource remoteDataSource =
//       MainCoreEmployeeRemoteDataSource();
//   getEmployees() async {
//     Either<Failure, dynamic> result = await remoteDataSource.getAllEmployees();
//     if (result.isLeft()) return result;
//     List<Map<String, dynamic>> employees = result.getOrElse(() => []);
//     List<NewEmployeeModel> newEmployees = employees
//         .map((employee) => NewEmployeeModel.fromMap(employee))
//         .toList();
//   return result = Right(newEmployees);
//   }
// }
