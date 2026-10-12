// ***************************** FILE INFO ***************************** //
// File Name: certification_bulk_upload_headers.dart
// Purpose: Defines the certification bulk-upload workbook contract.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../../shared/bulk_upload/bulk_upload_template.dart';

/// Stable workbook columns for appending employee certification histories.
abstract final class CertificationBulkUploadHeaders {
  static const number = 'NO';
  static const employeeId = 'Employee ID';
  static const firstName = 'First Name';
  static const middleName = 'Middle Name';
  static const lastName = 'Last Name';
  static const firstNameArabic = 'الاسم الأول';
  static const middleNameArabic = 'الاسم الأوسط';
  static const lastNameArabic = 'الاسم الأخير';
  static const institutionName = 'Institution Name';
  static const degree = 'Degree or Certification';
  static const fieldOfStudy = 'Field of Study';
  static const startDate = 'Start Date';
  static const endDate = 'End Date';
  static const gradeOrScore = 'Grade or Score';
  static const certificateId = 'Certificate ID';
  static const issuingAuthority = 'Issuing Authority';
  static const notes = 'Notes';

  static const values = <String>[
    number,
    employeeId,
    firstName,
    middleName,
    lastName,
    firstNameArabic,
    middleNameArabic,
    lastNameArabic,
    institutionName,
    degree,
    fieldOfStudy,
    startDate,
    endDate,
    gradeOrScore,
    certificateId,
    issuingAuthority,
    notes,
  ];

  static const template = BulkUploadTemplate(
    headers: values,
    maxRows: 100,
    optionalHeaders: {
      middleName,
      middleNameArabic,
      gradeOrScore,
      notes,
    },
  );
}
