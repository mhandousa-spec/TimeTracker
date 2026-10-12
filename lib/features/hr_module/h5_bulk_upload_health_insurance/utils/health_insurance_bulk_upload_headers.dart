// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_bulk_upload_headers.dart
// Purpose: Defines the health-insurance spreadsheet contract.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import '../../shared/bulk_upload/bulk_upload_template.dart';

/// Stable workbook columns for HR health-insurance imports.
abstract final class HealthInsuranceBulkUploadHeaders {
  static const number = 'NO';
  static const employeeId = 'Employee ID';
  static const firstName = 'First Name';
  static const middleName = 'Middle Name';
  static const lastName = 'Last Name';
  static const firstNameArabic = 'الاسم الأول';
  static const middleNameArabic = 'الاسم الأوسط';
  static const lastNameArabic = 'الاسم الأخير';
  static const insuranceName = 'Insurance Name';
  static const policyNumber = 'Insurance Policy Number';
  static const providerContact = 'Insurance Provider Contact';

  static const values = <String>[
    number,
    employeeId,
    firstName,
    middleName,
    lastName,
    firstNameArabic,
    middleNameArabic,
    lastNameArabic,
    insuranceName,
    policyNumber,
    providerContact,
  ];

  static const template = BulkUploadTemplate(headers: values, maxRows: 100);
}
