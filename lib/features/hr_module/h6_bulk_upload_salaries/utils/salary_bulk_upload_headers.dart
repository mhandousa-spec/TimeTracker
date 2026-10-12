// ***************************** FILE INFO ***************************** //
// File Name: salary_bulk_upload_headers.dart
// Purpose: Defines the salary bulk-upload spreadsheet contract.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import '../../shared/bulk_upload/bulk_upload_template.dart';

/// Exact workbook columns accepted by the salary upload feature.
abstract final class SalaryBulkUploadHeaders {
  static const number = 'NO';
  static const employeeId = 'Employee ID';
  static const firstName = 'First Name';
  static const middleName = 'Middle Name';
  static const lastName = 'Last Name';
  static const firstNameArabic = 'الاسم الأول';
  static const middleNameArabic = 'الاسم الأوسط';
  static const lastNameArabic = 'الاسم الأخير';
  static const jobType = 'Job Type';
  static const currency = 'Currency';
  static const salary = 'Salary';
  static const workDays = 'Work Days';
  static const startTime = 'Start Time';
  static const endTime = 'End Time';

  static const values = <String>[
    number,
    employeeId,
    firstName,
    middleName,
    lastName,
    firstNameArabic,
    middleNameArabic,
    lastNameArabic,
    jobType,
    currency,
    salary,
    workDays,
    startTime,
    endTime
  ];
  static const template = BulkUploadTemplate(headers: values, maxRows: 100);
}
