// ***************************** FILE INFO ***************************** //
// File Name: emergency_contacts_repository.dart
// Purpose: Provides emergency-contact records to the HR presentation layer.
// Author: Mohamed Elrashidy
// Created At: 2026-08-14
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../h3_add_employee/data/models/employee_emergency_details_model.dart';
import '../data_source/remote_data_source/emergency_contacts_remote_data_source.dart';

/// Repository boundary for employee emergency-contact data.
class EmergencyContactsRepository {
  EmergencyContactsRepository(
      {EmergencyContactsRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? EmergencyContactsRemoteDataSource();

  final EmergencyContactsRemoteDataSource _remoteDataSource;

  /// Method Name: [getEmergencyDetails]
  ///
  /// Purpose: Retrieves emergency-contact records for presentation consumers.
  ///
  /// Returns: Emergency models keyed by employee ID, or a Firebase failure.
  Future<Either<FirebaseFailure, Map<String, EmployeeEmergencyDetailsModel>>>
      getEmergencyDetails() {
    return _remoteDataSource.getEmergencyDetails();
  }
}
