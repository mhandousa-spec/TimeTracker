/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_remote_data_source.dart
/// Purpose: The remote write path for the signed-in employee's profile.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SEMAIN-N02/N19: renamed from
///          `settings_remot_data_source.dart`, header added, the unused
///          `cloud_firestore` import dropped, and the implicit `dynamic`
///          return replaced with `Either<Failure, void>`.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

class SettingsRemoteDataSource {
  /// Function Name: [updateEmployeeModel]
  ///
  /// Purpose: Merge-write the employee document under the profiles collection.
  ///
  /// Parameters:
  /// - [employeeId]: Firestore document id.
  /// - [employee]: the model to persist.
  ///
  /// Returns: [Future<Either<Failure, void>>].
  Future<Either<Failure, void>> updateEmployeeModel({
    required String employeeId,
    required NewEmployeeModelHistory employee,
  }) async {
    final dynamic result = await FirebaseRepository.setDocumentWithId(
      collection: ApiConstants.employeesProfile,
      data: employee.toMap(),
      documentId: employeeId,
    );

    // FirebaseRepository.setDocumentWithId is untyped (`static setDocumentWithId`)
    // and returns Either<FirebaseFailure, void>. Narrowed here so the rest of
    // the layer sees one Failure type.
    if (result is Either<FirebaseFailure, void>) {
      return result.fold(
        (FirebaseFailure failure) => Left<Failure, void>(failure),
        (_) => const Right<Failure, void>(null),
      );
    }
    return const Right<Failure, void>(null);
  }
}
