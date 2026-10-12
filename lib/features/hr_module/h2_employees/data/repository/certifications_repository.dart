// ***************************** FILE INFO ***************************** //
// File Name: certifications_repository.dart
// Purpose: Provides certification records to the HR presentation layer.
// Author: Mohamed Elrashidy
// Created At: 2026-08-14
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../h3_add_employee/data/models/employee_certification_details_model.dart';
import '../data_source/remote_data_source/certifications_remote_data_source.dart';

/// Repository boundary for employee certification data.
class CertificationsRepository {
  CertificationsRepository({CertificationsRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? CertificationsRemoteDataSource();

  final CertificationsRemoteDataSource _remoteDataSource;

  /// Method Name: [getCertifications]
  ///
  /// Purpose: Retrieves certification records for presentation consumers.
  ///
  /// Returns: Certification models keyed by employee ID, or a Firebase failure.
  Future<
      Either<FirebaseFailure,
          Map<String, EmployeeCertificationDetailsModel>>> getCertifications() {
    return _remoteDataSource.getCertifications();
  }
}
