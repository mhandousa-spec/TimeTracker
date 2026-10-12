// ***************************** FILE INFO ***************************** //
// File Name: emergency_contacts_remote_data_source.dart
// Purpose: Reads supplemental HR emergency-contact records from Firestore.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../../../../core/services/firebase/repository/firebase_repository.dart';
import '../../../../h3_add_employee/data/models/employee_emergency_details_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';

/// Reads supplemental emergency-contact values keyed by employee identifier.
class EmergencyContactsRemoteDataSource {
  /// Method Name: [getEmergencyDetails]
  ///
  /// Purpose: Loads all supplemental emergency-contact records for the tenant.
  ///
  /// Returns: Emergency details keyed by their persisted employee ID.
  Future<Either<FirebaseFailure, Map<String, EmployeeEmergencyDetailsModel>>>
      getEmergencyDetails() async {
    final result = await FirebaseRepository.getCollection(
      collectionPath: HrEmployeeApiConstants.emergencyDetailsPath,
    );
    return result.fold(Left.new, (data) {
      final details = <String, EmployeeEmergencyDetailsModel>{};
      for (final value in data as List<dynamic>) {
        if (value is! Map<String, dynamic>) continue;
        final model = EmployeeEmergencyDetailsModel.fromMap(value);
        if (model.employeeId.trim().isNotEmpty) {
          details[model.employeeId] = model;
        }
      }
      return Right(details);
    });
  }
}
