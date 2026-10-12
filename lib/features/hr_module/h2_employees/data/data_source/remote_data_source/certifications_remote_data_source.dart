// ***************************** FILE INFO ***************************** //
// File Name: certifications_remote_data_source.dart
// Purpose: Reads employee certification records for the HR certification view.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../../../../core/services/firebase/repository/firebase_repository.dart';
import '../../../../h3_add_employee/data/models/employee_certification_details_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';

/// Reads certification records keyed by employee identifier.
class CertificationsRemoteDataSource {
  /// Method Name: [getCertifications]
  ///
  /// Purpose: Loads employee certification records from Firestore.
  ///
  /// Returns: Certification models keyed by employee ID.
  Future<
          Either<FirebaseFailure,
              Map<String, EmployeeCertificationDetailsModel>>>
      getCertifications() async {
    final result = await FirebaseRepository.getCollection(
      collectionPath: HrEmployeeApiConstants.certificationsPath,
    );
    return result.fold(
      Left.new,
      (certifications) => Right(_certificationsByEmployee(certifications)),
    );
  }

  /// Method Name: [_certificationsByEmployee]
  ///
  /// Purpose: Parses certification documents into an employee-keyed map.
  ///
  /// Parameters:
  /// - [data]: Raw certification collection values.
  ///
  /// Returns: Parsed certification models keyed by employee ID.
  Map<String, EmployeeCertificationDetailsModel> _certificationsByEmployee(
    dynamic data,
  ) {
    final values = <String, EmployeeCertificationDetailsModel>{};
    for (final value in data as List<dynamic>) {
      if (value is! Map<String, dynamic>) continue;
      final model = EmployeeCertificationDetailsModel.fromMap(value);
      if (model.employeeId.trim().isNotEmpty) values[model.employeeId] = model;
    }
    return values;
  }
}
