// ***************************** FILE INFO ***************************** //
// File Name: certification_bulk_upload_remote_data_source.dart
// Purpose: Reads employees and transactionally appends certification history.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import '../../../../h3_add_employee/data/models/employee_certification_details_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';
import '../../../../../roles/r4_active_directory/domain/entities/employee_entity.dart';
import '../../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../../utils/certification_bulk_upload_headers.dart';

/// Firestore boundary for certification workbook operations.
class CertificationBulkUploadRemoteDataSource {
  CertificationBulkUploadRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Method Name: [loadEmployees]
  ///
  /// Purpose: Loads current employee identities for workbook validation.
  Future<Map<String, HrEmployeeEntity>> loadEmployees() async {
    final snapshot = await _firestore
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .get();
    return {
      for (final document in snapshot.docs)
        document.id.trim(): EmployeeEntityController()
            .fromHistoryModel(NewEmployeeModelHistory.fromMap(document.data()))
    };
  }

  /// Method Name: [appendCertification]
  ///
  /// Purpose: Appends one certification history without changing attachments.
  Future<void> appendCertification({required BulkUploadRow row}) async {
    final employeeId = row.value(CertificationBulkUploadHeaders.employeeId);
    final reference = _firestore
        .collection(HrEmployeeApiConstants.certificationsPath)
        .doc(employeeId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final previous = snapshot.exists
          ? EmployeeCertificationDetailsModel.fromMap(snapshot.data()!)
          : EmployeeCertificationDetailsModel(
              employeeId: employeeId,
              timestamps: const [],
              institutionName: const [],
              degree: const [],
              fieldOfStudy: const [],
              startDate: const [],
              endDate: const [],
              gradeOrScore: const [],
              certificateId: const [],
              issuingAuthority: const [],
              certificationDocumentUrl: const [],
              notes: const [],
            );
      final timestamp = Timestamp.now();
      transaction.set(
        reference,
        EmployeeCertificationDetailsModel(
          employeeId: employeeId,
          timestamps: [...previous.timestamps, timestamp],
          institutionName: [
            ...previous.institutionName,
            row.value(CertificationBulkUploadHeaders.institutionName)
          ],
          degree: [
            ...previous.degree,
            row.value(CertificationBulkUploadHeaders.degree)
          ],
          fieldOfStudy: [
            ...previous.fieldOfStudy,
            row.value(CertificationBulkUploadHeaders.fieldOfStudy)
          ],
          startDate: [
            ...previous.startDate,
            row.value(CertificationBulkUploadHeaders.startDate)
          ],
          endDate: [
            ...previous.endDate,
            row.value(CertificationBulkUploadHeaders.endDate)
          ],
          gradeOrScore: [
            ...previous.gradeOrScore,
            row.value(CertificationBulkUploadHeaders.gradeOrScore)
          ],
          certificateId: [
            ...previous.certificateId,
            row.value(CertificationBulkUploadHeaders.certificateId)
          ],
          issuingAuthority: [
            ...previous.issuingAuthority,
            row.value(CertificationBulkUploadHeaders.issuingAuthority)
          ],
          certificationDocumentUrl: previous.certificationDocumentUrl,
          notes: [
            ...previous.notes,
            row.value(CertificationBulkUploadHeaders.notes)
          ],
        ).toMap(),
      );
    });
  }
}
