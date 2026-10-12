// ***************************** FILE INFO ***************************** //
// File Name: validate_certification_bulk_upload.dart
// Purpose: Validates certification workbook rows before persistence.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../../../../../generated/l10n.dart';
import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../data/models/certification_bulk_upload_models.dart';
import '../../utils/certification_bulk_upload_headers.dart';

/// Pure validation for certification workbook rows.
class ValidateCertificationBulkUpload {
  const ValidateCertificationBulkUpload();

  /// Method Name: [call]
  ///
  /// Purpose: Returns workbook rows and every discoverable validation error.
  ({List<BulkUploadRow> rows, List<BulkUploadCellError> errors}) call({
    required List<BulkUploadRow> rows,
    required CertificationBulkUploadPreflight preflight,
    required S localization,
  }) {
    final errors = <BulkUploadCellError>[];
    final counts = <String, int>{};
    for (final row in rows) {
      final id = row.value(CertificationBulkUploadHeaders.employeeId);
      if (id.isNotEmpty) counts[id] = (counts[id] ?? 0) + 1;
    }
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      for (final header in CertificationBulkUploadHeaders.values.skip(1)) {
        if (!CertificationBulkUploadHeaders.template.optionalHeaders
                .contains(header) &&
            row.value(header).isEmpty) {
          errors.add(_error(index, header, localization.fieldRequired));
        }
      }
      final id = row.value(CertificationBulkUploadHeaders.employeeId);
      if ((counts[id] ?? 0) > 1) {
        errors.add(_error(index, CertificationBulkUploadHeaders.employeeId,
            localization.employeeBulkDuplicateEmployeeId));
        continue;
      }
      final employee = preflight.employeesById[id];
      if (employee == null) {
        errors.add(_error(index, CertificationBulkUploadHeaders.employeeId,
            localization.employeeBulkExistingEmployeeId));
        continue;
      }
      _match(index, row, CertificationBulkUploadHeaders.firstName,
          employee.firstName, errors, localization,
          english: true);
      _match(index, row, CertificationBulkUploadHeaders.middleName,
          employee.middleName, errors, localization,
          english: true);
      _match(index, row, CertificationBulkUploadHeaders.lastName,
          employee.lastName, errors, localization,
          english: true);
      _match(index, row, CertificationBulkUploadHeaders.firstNameArabic,
          employee.firstNameInArabic, errors, localization);
      _match(index, row, CertificationBulkUploadHeaders.middleNameArabic,
          employee.middleNameInArabic, errors, localization);
      _match(index, row, CertificationBulkUploadHeaders.lastNameArabic,
          employee.lastNameInArabic, errors, localization);
    }
    return (rows: rows, errors: errors);
  }

  void _match(
    int index,
    BulkUploadRow row,
    String header,
    String? expected,
    List<BulkUploadCellError> errors,
    S localization, {
    bool english = false,
  }) {
    final actual = _normalize(row.value(header), english: english);
    final stored = _normalize(expected ?? '', english: english);
    if (actual != stored) {
      errors.add(_error(index, header, localization.specialCharsNotAllowed));
    }
  }

  String _normalize(String value, {required bool english}) {
    final result = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return english ? result.toLowerCase() : result;
  }

  BulkUploadCellError _error(int row, String header, String message) =>
      BulkUploadCellError(rowIndex: row, header: header, message: message);
}
