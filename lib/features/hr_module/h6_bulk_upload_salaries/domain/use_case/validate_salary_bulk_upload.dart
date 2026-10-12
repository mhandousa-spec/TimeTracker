// ***************************** FILE INFO ***************************** //
// File Name: validate_salary_bulk_upload.dart
// Purpose: Validates salary workbook rows against HR employee and enum data.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/hr_module/h3_add_employee/utils/add_employee_currency_option.dart';
import 'package:knowticed_plus/features/hr_module/h3_add_employee/utils/add_employee_days_off_option.dart';
import 'package:knowticed_plus/features/hr_module/h3_add_employee/utils/add_employee_job_type_option.dart';
import 'package:knowticed_plus/features/hr_module/h6_bulk_upload_salaries/data/models/salary_bulk_upload_models.dart';
import 'package:knowticed_plus/features/hr_module/h6_bulk_upload_salaries/utils/salary_bulk_upload_headers.dart';
import 'package:knowticed_plus/features/hr_module/shared/bulk_upload/bulk_upload_template.dart';

/// Pure validator for salary workbook rows.
class ValidateSalaryBulkUpload {
  const ValidateSalaryBulkUpload();

  ({List<BulkUploadRow> rows, List<BulkUploadCellError> errors}) call({
    required List<BulkUploadRow> rows,
    required SalaryBulkUploadPreflight preflight,
    required S localization,
  }) {
    final errors = <BulkUploadCellError>[];
    final counts = <String, int>{};
    for (final row in rows) {
      final id = row.value(SalaryBulkUploadHeaders.employeeId);
      if (id.isNotEmpty) counts[id] = (counts[id] ?? 0) + 1;
    }

    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      _validateRequired(index, row, errors, localization);
      final employeeId = row.value(SalaryBulkUploadHeaders.employeeId);
      if (employeeId.isEmpty) continue;
      if ((counts[employeeId] ?? 0) > 1) {
        errors.add(_error(index, SalaryBulkUploadHeaders.employeeId,
            localization.employeeBulkDuplicateEmployeeId));
        continue;
      }
      final employee = preflight.employeesById[employeeId];
      if (employee == null) {
        errors.add(_error(index, SalaryBulkUploadHeaders.employeeId,
            localization.employeeBulkExistingEmployeeId));
        continue;
      }
      _match(index, row, SalaryBulkUploadHeaders.firstName, employee.firstName,
          errors, localization,
          english: true);
      _match(index, row, SalaryBulkUploadHeaders.middleName,
          employee.middleName, errors, localization,
          english: true);
      _match(index, row, SalaryBulkUploadHeaders.lastName, employee.lastName,
          errors, localization,
          english: true);
      _match(index, row, SalaryBulkUploadHeaders.firstNameArabic,
          employee.firstNameInArabic, errors, localization);
      _match(index, row, SalaryBulkUploadHeaders.middleNameArabic,
          employee.middleNameInArabic, errors, localization);
      _match(index, row, SalaryBulkUploadHeaders.lastNameArabic,
          employee.lastNameInArabic, errors, localization);

      _validateOption(
          index,
          SalaryBulkUploadHeaders.jobType,
          row.value(SalaryBulkUploadHeaders.jobType),
          JobTypeOption.values.map((option) => option.value).toSet(),
          errors,
          localization);
      _validateOption(
          index,
          SalaryBulkUploadHeaders.workDays,
          row.value(SalaryBulkUploadHeaders.workDays),
          DaysOffOption.values.map((option) => option.value).toSet(),
          errors,
          localization);
      _validateOption(
          index,
          SalaryBulkUploadHeaders.currency,
          row.value(SalaryBulkUploadHeaders.currency),
          CurrencyOption.values.map((option) => option.value).toSet(),
          errors,
          localization);
      if (!RegExp(r'^\d{1,10}$')
          .hasMatch(row.value(SalaryBulkUploadHeaders.salary))) {
        errors.add(_error(index, SalaryBulkUploadHeaders.salary,
            localization.onlyNumbersAllowed));
      }
      for (final header in [
        SalaryBulkUploadHeaders.startTime,
        SalaryBulkUploadHeaders.endTime,
      ]) {
        if (!RegExp(r'^(0?[1-9]|1[0-2]):[0-5]\d (AM|PM)$')
            .hasMatch(row.value(header))) {
          errors.add(_error(index, header, localization.invalidDate));
        }
      }
    }
    return (rows: rows, errors: errors);
  }

  void _validateRequired(int index, BulkUploadRow row,
      List<BulkUploadCellError> errors, S localization) {
    for (final header in SalaryBulkUploadHeaders.values.skip(1)) {
      final value = row.value(header);
      if (value.isEmpty || value.toLowerCase() == 'null') {
        errors.add(_error(index, header, localization.fieldRequired));
      }
    }
  }

  void _match(int index, BulkUploadRow row, String header, String? expected,
      List<BulkUploadCellError> errors, S localization,
      {bool english = false}) {
    String normalize(String value) =>
        value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final actual = normalize(row.value(header));
    final stored = normalize(expected ?? '');
    if ((english ? actual.toLowerCase() : actual) !=
        (english ? stored.toLowerCase() : stored)) {
      errors.add(_error(index, header, localization.specialCharsNotAllowed));
    }
  }

  void _validateOption(int index, String header, String value,
      Set<String> options, List<BulkUploadCellError> errors, S localization) {
    if (!options.contains(value)) {
      errors.add(_error(index, header, localization.specialCharsNotAllowed));
    }
  }

  BulkUploadCellError _error(int row, String header, String message) =>
      BulkUploadCellError(rowIndex: row, header: header, message: message);
}
