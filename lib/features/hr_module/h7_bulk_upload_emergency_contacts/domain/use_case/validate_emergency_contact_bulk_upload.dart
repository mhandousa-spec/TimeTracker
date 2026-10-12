// ***************************** FILE INFO ***************************** //
// File Name: validate_emergency_contact_bulk_upload.dart
// Purpose: Validates emergency-contact workbook rows.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import '../../../../../generated/l10n.dart';
import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../utils/emergency_contact_bulk_upload_headers.dart';
import '../../data/models/emergency_contact_bulk_upload_models.dart';
import '../../../h3_add_employee/utils/add_employee_language_option.dart';
import '../../../h3_add_employee/utils/add_employee_relationship_option.dart';

/// Performs pure workbook validation before persistence.
class ValidateEmergencyContactBulkUpload {
  const ValidateEmergencyContactBulkUpload();

  EmergencyContactValidationResult call(
      {required List<BulkUploadRow> rows,
      required EmergencyContactBulkUploadPreflight preflight,
      required S localization}) {
    final errors = <BulkUploadCellError>[];
    final counts = <String, int>{};
    for (final row in rows) {
      final id = row.value(EmergencyContactBulkUploadHeaders.employeeId);
      if (id.isNotEmpty) counts[id] = (counts[id] ?? 0) + 1;
    }
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      final id = row.value(EmergencyContactBulkUploadHeaders.employeeId);
      if (id.isEmpty) {
        errors.add(_error(index, EmergencyContactBulkUploadHeaders.employeeId,
            localization.fieldRequired));
      } else if ((counts[id] ?? 0) > 1) {
        errors.add(_error(index, EmergencyContactBulkUploadHeaders.employeeId,
            localization.employeeBulkNullNotAllowed));
      } else if (!preflight.employeeIds.contains(id)) {
        errors.add(_error(index, EmergencyContactBulkUploadHeaders.employeeId,
            localization.healthInsuranceBulkEmployeeNotFound));
      }
      for (final header in EmergencyContactBulkUploadHeaders.values.skip(2)) {
        if (!EmergencyContactBulkUploadHeaders.template.optionalHeaders
                .contains(header) &&
            row.value(header).isEmpty) {
          errors.add(_error(index, header, localization.fieldRequired));
        }
      }
      _validateEnum(
          index,
          EmergencyContactBulkUploadHeaders.firstRelationship,
          row.value(EmergencyContactBulkUploadHeaders.firstRelationship),
          RelationshipOption.values.map((value) => value.value).toSet(),
          errors,
          localization);
      _validateEnum(
          index,
          EmergencyContactBulkUploadHeaders.secondRelationship,
          row.value(EmergencyContactBulkUploadHeaders.secondRelationship),
          RelationshipOption.values.map((value) => value.value).toSet(),
          errors,
          localization);
      _validateEnum(
          index,
          EmergencyContactBulkUploadHeaders.firstLanguage,
          row.value(EmergencyContactBulkUploadHeaders.firstLanguage),
          LanguageOption.values.map((value) => value.value).toSet(),
          errors,
          localization);
      _validateEnum(
          index,
          EmergencyContactBulkUploadHeaders.secondLanguage,
          row.value(EmergencyContactBulkUploadHeaders.secondLanguage),
          LanguageOption.values.map((value) => value.value).toSet(),
          errors,
          localization);
      _validatePhone(
          index,
          EmergencyContactBulkUploadHeaders.firstPhone,
          EmergencyContactBulkUploadHeaders.firstPhoneCountryCode,
          row,
          errors,
          localization);
      _validatePhone(
          index,
          EmergencyContactBulkUploadHeaders.secondPhone,
          EmergencyContactBulkUploadHeaders.secondPhoneCountryCode,
          row,
          errors,
          localization);
    }
    return (rows: rows, errors: errors);
  }

  BulkUploadCellError _error(int row, String header, String message) =>
      BulkUploadCellError(rowIndex: row, header: header, message: message);

  void _validateEnum(int index, String header, String value,
      Set<String> allowed, List<BulkUploadCellError> errors, S localization) {
    if (value.isNotEmpty && !allowed.contains(value))
      errors
          .add(_error(index, header, localization.employeeBulkNullNotAllowed));
  }

  void _validatePhone(int index, String phoneHeader, String countryHeader,
      BulkUploadRow row, List<BulkUploadCellError> errors, S localization) {
    final phone = row.value(phoneHeader);
    final country = row.value(countryHeader);
    if (phone.isNotEmpty && !RegExp(r'^\d+$').hasMatch(phone))
      errors.add(
          _error(index, phoneHeader, localization.employeeBulkNullNotAllowed));
    if (country.isNotEmpty && !RegExp(r'^\+?\d+$').hasMatch(country))
      errors.add(_error(
          index, countryHeader, localization.employeeBulkNullNotAllowed));
  }
}
