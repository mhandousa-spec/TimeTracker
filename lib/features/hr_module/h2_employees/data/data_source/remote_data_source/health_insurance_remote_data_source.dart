// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_remote_data_source.dart
// Purpose: Reads supplemental employee insurance records from Firestore.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../../../../core/services/firebase/repository/firebase_repository.dart';
import '../../../../h3_add_employee/data/models/employee_insurance_details_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';

/// Reads insurance-detail models keyed by employee identifier.
class HealthInsuranceRemoteDataSource {
  /// Method Name: [getInsuranceDetails]
  ///
  /// Purpose: Loads complete supplemental employee insurance records.
  ///
  /// Returns: Insurance-detail models keyed by the persisted employee ID.
  Future<Either<FirebaseFailure, Map<String, EmployeeInsuranceDetailsModel>>>
      getInsuranceDetails() async {
    final result = await FirebaseRepository.getCollection(
      collectionPath: HrEmployeeApiConstants.insuranceDetailsPath,
    );
    return result.fold(
      Left.new,
      (data) {
        final insuranceDetails = <String, EmployeeInsuranceDetailsModel>{};
        for (final value in data as List<dynamic>) {
          if (value is! Map<String, dynamic>) continue;
          final model = EmployeeInsuranceDetailsModel.fromMap(value);
          if (model.employeeId.trim().isEmpty) continue;
          insuranceDetails[model.employeeId] = model;
        }
        return Right(insuranceDetails);
      },
    );
  }
}
