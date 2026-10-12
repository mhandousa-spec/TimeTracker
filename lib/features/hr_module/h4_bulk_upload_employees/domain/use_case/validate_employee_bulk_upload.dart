// ***************************** FILE INFO ***************************** //
// File Name: validate_employee_bulk_upload.dart
// Purpose: Applies pure field and cross-row employee import validation.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/helper/hr/validator.dart';
import '../../../../../core/helper/main_helper/countries.dart';
import '../../../../../../generated/l10n.dart';
import '../../../h3_add_employee/utils/add_employee_language_option.dart';
import '../../../h3_add_employee/utils/add_employee_gender_option.dart';
import '../../../h3_add_employee/utils/add_employee_marital_status_option.dart';
import '../../../h3_add_employee/utils/add_employee_work_location_option.dart';
import '../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../data/models/employee_bulk_upload_cell_error.dart';
import '../../data/models/employee_bulk_upload_preflight.dart';
import '../../data/models/employee_bulk_upload_row.dart';
import '../../utils/constants/employee_bulk_upload_headers.dart';

/// Result of validating all employee rows against current lookup data.
class EmployeeBulkUploadValidationResult {
  EmployeeBulkUploadValidationResult({
    required List<EmployeeBulkUploadRow> rows,
    required List<EmployeeBulkUploadCellError> errors,
    required List<DepartmentModelPro> newDepartments,
  })  : rows = List.unmodifiable(rows),
        errors = List.unmodifiable(errors),
        newDepartments = List.unmodifiable(newDepartments);

  final List<EmployeeBulkUploadRow> rows;
  final List<EmployeeBulkUploadCellError> errors;
  final List<DepartmentModelPro> newDepartments;

  bool get isValid => errors.isEmpty;
}

/// Pure validation and normalization for employee spreadsheet rows.
class ValidateEmployeeBulkUpload {
  const ValidateEmployeeBulkUpload();

  EmployeeBulkUploadValidationResult call({
    required List<EmployeeBulkUploadRow> rows,
    required EmployeeBulkUploadPreflight preflight,
    required List<DepartmentModelPro> departments,
    required String editorEmail,
    required S localization,
  }) {
    final errors = <EmployeeBulkUploadCellError>[];
    final normalizedRows = <EmployeeBulkUploadRow>[];
    final idCounts = _counts(rows, EmployeeBulkUploadHeaders.employeeId);
    final emailCounts =
        _counts(rows, EmployeeBulkUploadHeaders.email, lowercase: true);

    for (var index = 0; index < rows.length; index++) {
      var row = _normalizeRow(rows[index]);
      for (final header in EmployeeBulkUploadHeaders.values.skip(1)) {
        final error = _validateCell(header, row.value(header), localization);
        if (error != null) errors.add(_error(index, header, error));
      }

      final id = row.value(EmployeeBulkUploadHeaders.employeeId);
      final email = row.value(EmployeeBulkUploadHeaders.email).toLowerCase();
      if ((idCounts[id] ?? 0) > 1) {
        errors.add(_error(index, EmployeeBulkUploadHeaders.employeeId,
            localization.employeeBulkDuplicateEmployeeId));
      } else if (preflight.employeeIds.contains(id)) {
        errors.add(_error(index, EmployeeBulkUploadHeaders.employeeId,
            localization.employeeBulkExistingEmployeeId));
      }
      if ((emailCounts[email] ?? 0) > 1) {
        errors.add(_error(index, EmployeeBulkUploadHeaders.email,
            localization.employeeBulkDuplicateEmail));
      } else if (preflight.employeeEmails.contains(email)) {
        errors.add(_error(index, EmployeeBulkUploadHeaders.email,
            localization.employeeBulkExistingEmail));
      }

      _validatePassportPair(index, row, errors, localization);
      _validateSupervisor(index, row, rows, preflight, errors, localization);
      _validateRole(index, row, preflight, errors, localization);

      final mobile =
          _parsePhone(row.value(EmployeeBulkUploadHeaders.mobilePhone));
      final home = _parsePhone(row.value(EmployeeBulkUploadHeaders.homeNumber));
      final office =
          _parsePhone(row.value(EmployeeBulkUploadHeaders.officeNumber));
      row = row.copyWith(
        mobilePhone: mobile ?? const EmployeeBulkPhoneValue(),
        homePhone: home ?? const EmployeeBulkPhoneValue(),
        officePhone: office ?? const EmployeeBulkPhoneValue(),
      );
      normalizedRows.add(row);
    }

    final departmentResult = _validateDepartments(
      rows: normalizedRows,
      existing: departments,
      editorEmail: editorEmail,
      localization: localization,
    );
    errors.addAll(departmentResult.errors);

    return EmployeeBulkUploadValidationResult(
      rows: normalizedRows,
      errors: _deduplicateErrors(errors),
      newDepartments: departmentResult.newDepartments,
    );
  }

  String? _validateCell(String header, String value, S l10n) {
    if (value.toLowerCase() == 'null') return l10n.employeeBulkNullNotAllowed;
    if (value.isEmpty) {
      return EmployeeBulkUploadHeaders.isRequired(header)
          ? l10n.fieldRequired
          : null;
    }
    if (value != value.trim() || RegExp(r'\s{2,}').hasMatch(value)) {
      return l10n.specialCharsNotAllowed;
    }

    switch (header) {
      case EmployeeBulkUploadHeaders.employeeId:
        return HrValidator.employeeId(value, l10n);
      case EmployeeBulkUploadHeaders.firstName:
      case EmployeeBulkUploadHeaders.middleName:
      case EmployeeBulkUploadHeaders.lastName:
        return _validName(value, arabic: false) ? null : l10n.englishOnly;
      case EmployeeBulkUploadHeaders.firstNameArabic:
      case EmployeeBulkUploadHeaders.middleNameArabic:
      case EmployeeBulkUploadHeaders.lastNameArabic:
        return _validName(value, arabic: true) ? null : l10n.arabicOnly;
      case EmployeeBulkUploadHeaders.departmentArabic:
      case EmployeeBulkUploadHeaders.titleArabic:
        return _validName(value, arabic: true, maxLength: 100)
            ? null
            : l10n.arabicOnly;
      case EmployeeBulkUploadHeaders.nationalId:
        return HrValidator.nationalId(value, l10n);
      case EmployeeBulkUploadHeaders.nationalIdExpiration:
        return HrValidator.exactDate(
          value,
          l10n,
          minimum: _today(),
        );
      case EmployeeBulkUploadHeaders.passport:
        return HrValidator.passport(value, l10n);
      case EmployeeBulkUploadHeaders.passportExpiration:
        return HrValidator.exactDate(
          value,
          l10n,
          required: false,
          minimum: _today(),
        );
      case EmployeeBulkUploadHeaders.email:
      case EmployeeBulkUploadHeaders.supervisor:
        return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)
            ? null
            : l10n.validEmailRequired;
      case EmployeeBulkUploadHeaders.mobilePhone:
      case EmployeeBulkUploadHeaders.homeNumber:
      case EmployeeBulkUploadHeaders.officeNumber:
        return HrValidator.internationalPhone(value, l10n);
      case EmployeeBulkUploadHeaders.extension:
        return RegExp(r'^\d{1,10}$').hasMatch(value)
            ? null
            : l10n.onlyNumbersAllowed;
      case EmployeeBulkUploadHeaders.birthDate:
        return _validBirthDate(value) ? null : l10n.invalidDate;
      case EmployeeBulkUploadHeaders.nationality:
        return _validNationality(value) ? null : l10n.specialCharsNotAllowed;
      case EmployeeBulkUploadHeaders.gender:
        return GenderOption.values
                .map((option) => option.value)
                .contains(value.toLowerCase())
            ? null
            : l10n.employeeBulkInvalidGender;
      case EmployeeBulkUploadHeaders.postalCode:
        return RegExp(r'^\d{5}(?:[-\s]?\d{4})?$').hasMatch(value)
            ? null
            : l10n.employeeBulkInvalidPostalCode;
      case EmployeeBulkUploadHeaders.maritalStatus:
        return MaritalStatusOption.values
                .map((option) => option.value)
                .contains(value.toLowerCase())
            ? null
            : l10n.employeeBulkInvalidMaritalStatus;
      case EmployeeBulkUploadHeaders.departmentId:
        return RegExp(r'^\d+$').hasMatch(value)
            ? null
            : l10n.onlyNumbersAllowed;
      case EmployeeBulkUploadHeaders.departmentName:
      case EmployeeBulkUploadHeaders.title:
        return RegExp(r'^[A-Za-z][A-Za-z0-9 .,&()/-]*$').hasMatch(value)
            ? null
            : l10n.englishOnly;
      case EmployeeBulkUploadHeaders.drivingLicenseId:
        return RegExp(r'^[A-Za-z0-9-]+$').hasMatch(value)
            ? null
            : l10n.specialCharsNotAllowed;
      case EmployeeBulkUploadHeaders.language:
        final languages = value.split(',').map((item) => item.trim()).toList();
        final supported =
            LanguageOption.values.map((option) => option.value).toSet();
        return languages.any(
          (item) => item.isEmpty || !supported.contains(item.toLowerCase()),
        )
            ? l10n.employeeBulkInvalidList
            : languages.map((item) => item.toLowerCase()).toSet().length !=
                    languages.length
                ? l10n.employeeBulkInvalidList
                : null;
      case EmployeeBulkUploadHeaders.carPlates:
        final parts = value.split(',').map((item) => item.trim()).toList();
        return parts.any((item) => item.isEmpty) ||
                parts.toSet().length != parts.length ||
                parts.any((item) => !RegExp(
                      r'^[\p{L}\d]+(?:[ -][\p{L}\d]+)*$',
                      unicode: true,
                    ).hasMatch(item))
            ? l10n.employeeBulkInvalidList
            : null;
      case EmployeeBulkUploadHeaders.country:
      case EmployeeBulkUploadHeaders.province:
      case EmployeeBulkUploadHeaders.city:
        return RegExp(r"^[\p{L}]+(?:[ .,'-][\p{L}]+)*$", unicode: true)
                .hasMatch(value)
            ? null
            : l10n.specialCharsNotAllowed;
      case EmployeeBulkUploadHeaders.workLocation:
        return WorkLocationOption.values
                .map((option) => option.value)
                .contains(value)
            ? null
            : l10n.specialCharsNotAllowed;
      case EmployeeBulkUploadHeaders.street:
        return RegExp(r"^[\p{L}\d]+(?:[ .,'/#-][\p{L}\d]+)*$", unicode: true)
                .hasMatch(value)
            ? null
            : l10n.specialCharsNotAllowed;
      default:
        return null;
    }
  }

  void _validatePassportPair(
    int index,
    EmployeeBulkUploadRow row,
    List<EmployeeBulkUploadCellError> errors,
    S l10n,
  ) {
    final passport = row.value(EmployeeBulkUploadHeaders.passport);
    final expiration = row.value(EmployeeBulkUploadHeaders.passportExpiration);
    if (passport.isNotEmpty && expiration.isEmpty) {
      errors.add(_error(index, EmployeeBulkUploadHeaders.passportExpiration,
          l10n.fieldRequired));
    } else if (passport.isEmpty && expiration.isNotEmpty) {
      errors.add(_error(
          index, EmployeeBulkUploadHeaders.passport, l10n.fieldRequired));
    }
  }

  void _validateSupervisor(
    int index,
    EmployeeBulkUploadRow row,
    List<EmployeeBulkUploadRow> rows,
    EmployeeBulkUploadPreflight preflight,
    List<EmployeeBulkUploadCellError> errors,
    S l10n,
  ) {
    final supervisor =
        row.value(EmployeeBulkUploadHeaders.supervisor).toLowerCase();
    if (supervisor.isEmpty ||
        errors.any((error) =>
            error.rowIndex == index &&
            error.header == EmployeeBulkUploadHeaders.supervisor)) {
      return;
    }
    final importedEmails = rows
        .map(
            (item) => item.value(EmployeeBulkUploadHeaders.email).toLowerCase())
        .toSet();
    if (!preflight.employeeEmails.contains(supervisor) &&
        !importedEmails.contains(supervisor)) {
      errors.add(_error(index, EmployeeBulkUploadHeaders.supervisor,
          l10n.employeeBulkSupervisorNotFound));
    }
  }

  void _validateRole(
    int index,
    EmployeeBulkUploadRow row,
    EmployeeBulkUploadPreflight preflight,
    List<EmployeeBulkUploadCellError> errors,
    S l10n,
  ) {
    final role = row.value(EmployeeBulkUploadHeaders.role).toLowerCase();
    if (role.isNotEmpty && !preflight.activeRoles.contains(role)) {
      errors.add(_error(index, EmployeeBulkUploadHeaders.role,
          l10n.employeeBulkRoleNotFound));
    }
  }

  _DepartmentValidation _validateDepartments({
    required List<EmployeeBulkUploadRow> rows,
    required List<DepartmentModelPro> existing,
    required String editorEmail,
    required S localization,
  }) {
    final errors = <EmployeeBulkUploadCellError>[];
    final newDepartments = <String, DepartmentModelPro>{};
    final byId = <String, DepartmentModelPro>{};
    final byEnglish = <String, DepartmentModelPro>{};
    final byArabic = <String, DepartmentModelPro>{};

    for (final department in existing) {
      final id = department.departmentID?.trim() ?? '';
      final english = department.departmentName?.trim().toLowerCase() ?? '';
      final arabic = department.departmentNameInArabic?.trim() ?? '';
      if (id.isNotEmpty) byId[id] = department;
      if (english.isNotEmpty) byEnglish[english] = department;
      if (arabic.isNotEmpty) byArabic[arabic] = department;
    }

    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      final id = row.value(EmployeeBulkUploadHeaders.departmentId);
      final english =
          row.value(EmployeeBulkUploadHeaders.departmentName).toLowerCase();
      final arabic = row.value(EmployeeBulkUploadHeaders.departmentArabic);
      if (id.isEmpty || english.isEmpty || arabic.isEmpty) continue;

      final matches = <DepartmentModelPro>{
        if (byId[id] != null) byId[id]!,
        if (byEnglish[english] != null) byEnglish[english]!,
        if (byArabic[arabic] != null) byArabic[arabic]!,
      };
      if (matches.isEmpty) {
        final department = DepartmentModelPro(
          departmentID: id,
          departmentName: row.value(EmployeeBulkUploadHeaders.departmentName),
          departmentNameInArabic: arabic,
          creationDate: Timestamp.now(),
          addedBy: editorEmail,
        );
        byId[id] = department;
        byEnglish[english] = department;
        byArabic[arabic] = department;
        newDepartments[id] = department;
        continue;
      }

      final match = matches.first;
      final isExact = matches.length == 1 &&
          match.departmentID?.trim() == id &&
          match.departmentName?.trim().toLowerCase() == english &&
          match.departmentNameInArabic?.trim() == arabic;
      if (!isExact) {
        for (final header in const [
          EmployeeBulkUploadHeaders.departmentId,
          EmployeeBulkUploadHeaders.departmentName,
          EmployeeBulkUploadHeaders.departmentArabic,
        ]) {
          errors.add(_error(
              index, header, localization.employeeBulkDepartmentConflict));
        }
      }
    }

    return _DepartmentValidation(errors, newDepartments.values.toList());
  }

  Map<String, int> _counts(
    List<EmployeeBulkUploadRow> rows,
    String header, {
    bool lowercase = false,
  }) {
    final counts = <String, int>{};
    for (final row in rows) {
      var value = row.value(header);
      if (lowercase) value = value.toLowerCase();
      if (value.isNotEmpty) counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }

  bool _validName(
    String value, {
    required bool arabic,
    int maxLength = 20,
  }) {
    if (value.length > maxLength || (!arabic && value.length < 2)) {
      return false;
    }
    final pattern = arabic
        ? RegExp(
            r'^[\u0621-\u063A\u0641-\u064A]+(?:[ -][\u0621-\u063A\u0641-\u064A]+)*$')
        : RegExp(r'^[A-Za-z]+(?:[ -][A-Za-z]+)*$');
    return pattern.hasMatch(value);
  }

  bool _validBirthDate(String value) {
    return HrValidator.exactDate(
          value,
          S.current,
          maximum: DateTime(2010, 12, 31),
        ) ==
        null;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  EmployeeBulkPhoneValue? _parsePhone(String raw) {
    final parsed = HrValidator.parseInternationalPhone(raw);
    if (parsed == null) return null;
    return EmployeeBulkPhoneValue(
      countryCode: parsed.countryCode,
      number: parsed.number,
      countryApp: parsed.countryApp ?? '',
    );
  }

  EmployeeBulkUploadRow _normalizeRow(EmployeeBulkUploadRow row) {
    final values = <String, String>{
      for (final header in EmployeeBulkUploadHeaders.values)
        header: row.values[header]?.trim() ?? '',
    };
    for (final header in const [
      EmployeeBulkUploadHeaders.email,
      EmployeeBulkUploadHeaders.supervisor,
      EmployeeBulkUploadHeaders.gender,
      EmployeeBulkUploadHeaders.maritalStatus,
      EmployeeBulkUploadHeaders.role,
    ]) {
      values[header] = values[header]!.toLowerCase();
    }
    for (final header in const [
      EmployeeBulkUploadHeaders.language,
      EmployeeBulkUploadHeaders.carPlates,
    ]) {
      values[header] =
          values[header]!.split(',').map((item) => item.trim()).join(', ');
    }
    return row.copyWith(values: values);
  }

  bool _validNationality(String value) {
    final normalized = value.toLowerCase();
    return countries.any((country) =>
        country.code.toLowerCase() == normalized ||
        country.name.toLowerCase() == normalized ||
        country.nameTranslations.values
            .any((name) => name.toLowerCase() == normalized));
  }

  EmployeeBulkUploadCellError _error(
          int rowIndex, String header, String message) =>
      EmployeeBulkUploadCellError(
          rowIndex: rowIndex, header: header, message: message);

  List<EmployeeBulkUploadCellError> _deduplicateErrors(
      List<EmployeeBulkUploadCellError> errors) {
    final keys = <String>{};
    return errors
        .where((error) => keys.add('${error.rowIndex}|${error.header}'))
        .toList();
  }
}

class _DepartmentValidation {
  const _DepartmentValidation(this.errors, this.newDepartments);
  final List<EmployeeBulkUploadCellError> errors;
  final List<DepartmentModelPro> newDepartments;
}
