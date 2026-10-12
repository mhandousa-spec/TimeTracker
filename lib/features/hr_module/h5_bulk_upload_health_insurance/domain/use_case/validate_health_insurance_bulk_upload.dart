// ***************************** FILE INFO ***************************** //
// File Name: validate_health_insurance_bulk_upload.dart
// Purpose: Validates insurance workbook rows against employee identities.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import '../../data/models/health_insurance_bulk_upload_models.dart';
import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../utils/health_insurance_bulk_upload_headers.dart';
import '../../../../../generated/l10n.dart';

/// Pure health-insurance workbook validation.
class ValidateHealthInsuranceBulkUpload {
  const ValidateHealthInsuranceBulkUpload();

  /// Method Name: [call]
  ///
  /// Purpose: Returns normalized rows and every discoverable cell error.
  ({List<BulkUploadRow> rows, List<BulkUploadCellError> errors}) call({
    required List<BulkUploadRow> rows,
    required HealthInsuranceBulkUploadPreflight preflight,
    required S localization,
  }) {
    final errors = <BulkUploadCellError>[];
    final ids = <String, int>{};
    for (final row in rows) {
      final id = row.value(HealthInsuranceBulkUploadHeaders.employeeId);
      if (id.isNotEmpty) ids[id] = (ids[id] ?? 0) + 1;
    }
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      for (final header in HealthInsuranceBulkUploadHeaders.values.skip(1)) {
        final value = row.value(header);
        if (value.isEmpty) {
          errors.add(_error(index, header, localization.fieldRequired));
        } else if (value.toLowerCase() == 'null') {
          errors.add(
              _error(index, header, localization.employeeBulkNullNotAllowed));
        }
      }
      final employeeId = row.value(HealthInsuranceBulkUploadHeaders.employeeId);
      if ((ids[employeeId] ?? 0) > 1) {
        errors.add(_error(index, HealthInsuranceBulkUploadHeaders.employeeId,
            localization.healthInsuranceBulkDuplicateEmployee));
        continue;
      }
      final employee = preflight.employeesById[employeeId];
      if (employee == null) {
        errors.add(_error(index, HealthInsuranceBulkUploadHeaders.employeeId,
            localization.healthInsuranceBulkEmployeeNotFound));
        continue;
      }
      _verify(
          index,
          HealthInsuranceBulkUploadHeaders.firstName,
          row.value(HealthInsuranceBulkUploadHeaders.firstName),
          employee.firstName,
          errors,
          localization,
          english: true);
      _verify(
          index,
          HealthInsuranceBulkUploadHeaders.middleName,
          row.value(HealthInsuranceBulkUploadHeaders.middleName),
          employee.middleName,
          errors,
          localization,
          english: true);
      _verify(
          index,
          HealthInsuranceBulkUploadHeaders.lastName,
          row.value(HealthInsuranceBulkUploadHeaders.lastName),
          employee.lastName,
          errors,
          localization,
          english: true);
      _verify(
          index,
          HealthInsuranceBulkUploadHeaders.firstNameArabic,
          row.value(HealthInsuranceBulkUploadHeaders.firstNameArabic),
          employee.firstNameInArabic,
          errors,
          localization);
      _verify(
          index,
          HealthInsuranceBulkUploadHeaders.middleNameArabic,
          row.value(HealthInsuranceBulkUploadHeaders.middleNameArabic),
          employee.middleNameInArabic,
          errors,
          localization);
      _verify(
          index,
          HealthInsuranceBulkUploadHeaders.lastNameArabic,
          row.value(HealthInsuranceBulkUploadHeaders.lastNameArabic),
          employee.lastNameInArabic,
          errors,
          localization);
    }
    return (rows: rows, errors: errors);
  }

  void _verify(int index, String header, String actual, String? expected,
      List<BulkUploadCellError> errors, S localization,
      {bool english = false}) {
    final normalizedActual = _normalize(actual, english: english);
    final normalizedExpected = _normalize(expected ?? '', english: english);
    if (normalizedActual.isNotEmpty && normalizedActual != normalizedExpected) {
      errors.add(_error(
          index, header, localization.healthInsuranceBulkIdentityMismatch));
    }
  }

  String _normalize(String value, {required bool english}) {
    final compact = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return english ? compact.toLowerCase() : compact;
  }

  BulkUploadCellError _error(int row, String header, String message) =>
      BulkUploadCellError(rowIndex: row, header: header, message: message);
}
