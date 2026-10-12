// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_repository.dart
// Purpose: Provides insurance records to the HR presentation layer.
// Author: Mohamed Elrashidy
// Created At: 2026-08-14
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../h3_add_employee/data/models/employee_insurance_details_model.dart';
import '../data_source/remote_data_source/health_insurance_remote_data_source.dart';

/// Repository boundary for employee health-insurance data.
class HealthInsuranceRepository {
  HealthInsuranceRepository({HealthInsuranceRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? HealthInsuranceRemoteDataSource();

  final HealthInsuranceRemoteDataSource _remoteDataSource;

  /// Method Name: [getInsuranceDetails]
  ///
  /// Purpose: Retrieves insurance records for presentation consumers.
  ///
  /// Returns: Insurance models keyed by employee ID, or a Firebase failure.
  Future<Either<FirebaseFailure, Map<String, EmployeeInsuranceDetailsModel>>>
      getInsuranceDetails() {
    return _remoteDataSource.getInsuranceDetails();
  }
}
