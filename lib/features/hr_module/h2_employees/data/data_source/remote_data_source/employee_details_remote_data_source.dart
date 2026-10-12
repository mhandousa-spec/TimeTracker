// ***************************** FILE INFO ***************************** //
// File Name: employee_details_remote_data_source.dart
// Purpose: Reads one employee's supplemental HR detail documents.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../../../../core/services/firebase/repository/firebase_repository.dart';
import '../../../../h3_add_employee/data/models/employee_attachments_model.dart';
import '../../../../h3_add_employee/data/models/employee_certification_details_model.dart';
import '../../../../h3_add_employee/data/models/employee_contact_details_model.dart';
import '../../../../h3_add_employee/data/models/employee_emergency_details_model.dart';
import '../../../../h3_add_employee/data/models/employee_insurance_details_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';
import '../../../domain/entity/employee_details_view_data.dart';

/// Firebase boundary for employee-scoped HR detail documents.
class EmployeeDetailsRemoteDataSource {
  /// Method Name: [getSupplementalData]
  ///
  /// Purpose: Loads every optional employee detail document concurrently.
  ///
  /// Parameters:
  /// - [employeeId]: The selected employee document identifier.
  ///
  /// Returns: Typed supplemental detail models or the first Firebase failure.
  Future<Either<FirebaseFailure, EmployeeDetailsSupplementalData>>
      getSupplementalData(String employeeId) async {
    final results = await Future.wait<Either<FirebaseFailure, dynamic>>([
      _getDocument(
        collection: HrEmployeeApiConstants.contactDetailsPath,
        documentId: employeeId,
      ),
      _getDocument(
        collection: HrEmployeeApiConstants.certificationsPath,
        documentId: employeeId,
      ),
      _getDocument(
        collection: HrEmployeeApiConstants.insuranceDetailsPath,
        documentId: employeeId,
      ),
      _getDocument(
        collection: HrEmployeeApiConstants.emergencyDetailsPath,
        documentId: employeeId,
      ),
      _getDocument(
        collection: HrEmployeeApiConstants.attachmentsPath,
        documentId: employeeId,
      ),
    ]);

    for (final result in results) {
      final failure = result.fold<FirebaseFailure?>(
        (value) => value,
        (_) => null,
      );
      if (failure != null) return Left(failure);
    }

    Map<String, dynamic>? mapAt(int index) {
      return results[index].fold(
        (_) => null,
        (value) => value is Map<String, dynamic> ? value : null,
      );
    }

    final contact = mapAt(0);
    final certification = mapAt(1);
    final insurance = mapAt(2);
    final emergency = mapAt(3);
    final attachments = mapAt(4);
    return Right(
      EmployeeDetailsSupplementalData(
        contactDetails: contact == null
            ? null
            : EmployeeContactDetailsModel.fromMap(contact),
        certificationDetails: certification == null
            ? null
            : EmployeeCertificationDetailsModel.fromMap(certification),
        insuranceDetails: insurance == null
            ? null
            : EmployeeInsuranceDetailsModel.fromMap(insurance),
        emergencyDetails: emergency == null
            ? null
            : EmployeeEmergencyDetailsModel.fromMap(emergency),
        attachments: attachments == null
            ? null
            : EmployeeAttachmentsModel.fromMap(attachments),
      ),
    );
  }

  /// Method Name: [_getDocument]
  ///
  /// Purpose: Gives the legacy shared document read an explicit typed contract.
  ///
  /// Parameters:
  /// - [collection]: Tenant-scoped collection path.
  /// - [documentId]: Employee document identifier.
  ///
  /// Returns: The document data or a Firebase failure.
  Future<Either<FirebaseFailure, dynamic>> _getDocument({
    required String collection,
    required String documentId,
  }) async {
    return await FirebaseRepository.getDocumentWithId(
      collection: collection,
      documentId: documentId,
    );
  }
}
