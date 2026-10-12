/// Module: services_management_module
/// Description: Pure per-cell validation rules for the bulk "upload file
///              details" (master step 1) table: required-field, format,
///              duplicate-value and cross-field (Requires Approvals /
///              Limit Service Availability) checks. Holds no widget state —
///              takes the current form rows + employee/department lookups as
///              constructor deps so it can be unit-tested independently of
///              the page. Extracted from UploadFileDetailsTabletMaster
///              (audit fix #1/#4a: business-rule logic moved to domain/usecases).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: MainCoreEmployeeController, MainCoreDepartmentCubit,
///               MasterUploadHeaders, S (l10n)
/// Revision History: Initial version.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/constants/master_upload_headers.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class UploadFileRowValidator {
  final MainCoreEmployeeController employeeController;
  final MainCoreDepartmentCubit departmentController;

  const UploadFileRowValidator({
    required this.employeeController,
    required this.departmentController,
  });

  bool validateHeaders(List<String> headers, List<String> expectedHeaders) {
    if (headers.length != expectedHeaders.length) return false;
    for (int i = 0; i < headers.length; i++) {
      if (headers[i].trim() != expectedHeaders[i].trim()) return false;
    }
    return true;
  }

  /// True when any comma-separated entry contains an internal space.
  ///
  /// `a@x.com, b@x.com` is fine (the space only separates entries), whereas
  /// `a b@x.com` is not. The previous check rejected the whole value if it
  /// contained any space at all, which made multi-email cells impossible.
  static bool _hasSpaceInsideEntry(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .any((entry) => entry.contains(' '));
  }

  /// Validates a single cell. [formData] is the full row set (needed for
  /// cross-row duplicate-name checks); [rowData] is the row this cell
  /// belongs to (needed for cross-field checks like "Approvers" depending on
  /// "Requires Approvals").
  String? validateCell(
    BuildContext context,
    String key,
    String? value, {
    required List<Map<String, TextEditingController>> formData,
    Map<String, TextEditingController>? rowData,
  }) {
    if (key == 'Approvers') {
      final requireApprovalCtrl = rowData?['Requires Approvals'];
      final requireApproval = requireApprovalCtrl?.text.trim().toLowerCase() ?? '';
      if (requireApproval == 'no') return null;
    }

    if (key == 'Departments') {
      final limitCtrl = rowData?['Limit Service Availability'];
      final limit = limitCtrl?.text.trim().toLowerCase() ?? '';
      if (limit == 'no') return null;
    }

    if (value == null || value.trim().isEmpty) {
      return S.of(context).required;
    }

    value = value.trim();

    if (value.toLowerCase() == 'null') {
      return S.of(context).cannotBeNull;
    }

    bool hasExtraSpaces(String val) => RegExp(r'\s{2,}').hasMatch(val);
    bool isArabic(String text) => RegExp(r'^[؀-ۿ\s]+$').hasMatch(text);
    bool isEnglish(String text) => RegExp(r'^[a-zA-Z\s]+$').hasMatch(text);
    bool hasSpecialChars(String text) =>
        RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$0-9]').hasMatch(text);
    bool hasNumbers(String text) => RegExp(r'\d').hasMatch(text);
    bool containsArabic(String text) => RegExp(r'[؀-ۿ]').hasMatch(text);
    bool containsEnglish(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);
    bool hasForbiddenCharsInDescription(String text) =>
        RegExp(r'[!<>?":_~;\[\]\\|=+)(*&^%]').hasMatch(text);

    if ([
      MasterUploadHeaders.serviceNameEn,
      MasterUploadHeaders.serviceNameAr,
      MasterUploadHeaders.serviceDescriptionEn,
      MasterUploadHeaders.serviceDescriptionAr,
    ].contains(key)) {
      final currentValue = value.toLowerCase();
      int count = 0;
      for (var row in formData) {
        final otherValue = row[key]?.text.toLowerCase().trim();
        if (otherValue == currentValue) count++;
      }
      if (count > 1) {
        return S.of(context).duplicateValue;
      }
    }

    switch (key.trim()) {
      case MasterUploadHeaders.serviceNameEn:
        if (!isEnglish(value)) return S.of(context).englishOnly;
        if (containsArabic(value)) return S.of(context).arabicNotAllowed;
        if (hasSpecialChars(value)) return S.of(context).specialCharsNotAllowed;
        if (hasExtraSpaces(value)) return S.of(context).extraSpaces;
        break;

      case MasterUploadHeaders.serviceNameAr:
        if (!isArabic(value)) return S.of(context).arabicOnly;
        if (containsEnglish(value)) return S.of(context).englishNotAllowed;
        if (hasSpecialChars(value)) return S.of(context).specialCharsNotAllowed;
        if (hasExtraSpaces(value)) return S.of(context).extraSpaces;
        break;

      case MasterUploadHeaders.serviceDescriptionEn:
        if (containsArabic(value)) return S.of(context).arabicNotAllowed;
        if (hasForbiddenCharsInDescription(value)) {
          return S.of(context).descriptionSpecialChars;
        }
        if (hasExtraSpaces(value)) return S.of(context).extraSpaces;
        break;

      case MasterUploadHeaders.serviceDescriptionAr:
        if (containsEnglish(value)) return S.of(context).englishNotAllowed;
        if (hasForbiddenCharsInDescription(value)) {
          return S.of(context).descriptionSpecialChars;
        }
        if (hasExtraSpaces(value)) return S.of(context).extraSpaces;
        break;

      case 'Duration of Service':
        // ✅ FIX: xlsx has no integer type — every number is stored as a
        // double, so a cell typed as `3` can arrive as "3.0". int.tryParse
        // returned null for that and flagged every row of an otherwise valid
        // sheet, which left Activate disabled and made the file unuploadable.
        // Accept any whole number however it is spelled; the page normalizes
        // the cell text to "3" when parsing, so "3.0" is never persisted.
        final numeric = num.tryParse(value);
        if (numeric == null) return S.of(context).mustBeNumber;
        if (numeric != numeric.roundToDouble()) return S.of(context).mustBeNumber;
        final parsed = numeric.toInt();
        if (parsed <= 0) return S.of(context).mustBeGreaterThanZero;
        if (parsed > 1000) return S.of(context).mustBeLessThanOrEqual;
        break;

      case 'Time Unit':
        if (hasNumbers(value)) return S.of(context).numbersNotAllowed;
        if (containsArabic(value)) return S.of(context).arabicNotAllowed;
        const allowed = ['Hours', 'Days', 'Seconds', 'Minutes'];
        if (!allowed.map((e) => e.toLowerCase()).contains(value.toLowerCase())) {
          return S.of(context).invalidTimeUnit;
        }
        break;

      case 'Service Provider':
        // ✅ FIX (bug report p4): only reject a space *inside* an email, not
        // the space after a comma. `a@x.com, b@x.com` — the natural way to
        // type a list, and what Excel produces — was rejected outright, so a
        // row could never hold more than one email. The split below already
        // trims each entry.
        if (value.contains(':') ||
            value.contains(';') ||
            value.contains("'") ||
            value.contains('"') ||
            _hasSpaceInsideEntry(value)) {
          return S.of(context).emailsCommaSeparated;
        }
        if (value.startsWith(',') || value.endsWith(',')) {
          return S.of(context).commaAtStartOrEnd;
        }
        if (value.contains(',,')) return S.of(context).doubleCommas;

        final emails = value.split(',').map((e) => e.trim()).toList();
        if (emails.toSet().length != emails.length) {
          return S.of(context).duplicateEmails;
        }
        for (final email in emails) {
          if (email.isEmpty) return S.of(context).emptyEmail;
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
            return S.of(context).invalidEmailFormat;
          }
          if (!employeeController.mapOfEmployeesWithEmailKey.containsKey(email)) {
            return S.of(context).emailDoesNotExist;
          }
        }
        break;

      case 'Approvers':
        final requireApprovalCtrl = rowData?['Requires Approvals'];
        final requireApproval = requireApprovalCtrl?.text.trim().toLowerCase() ?? '';
        if (requireApproval == 'no') return null;

        // ✅ FIX (bug report p4): same as Service Provider — a space after a
        // comma is valid separator formatting, not an invalid email.
        if (value.contains(':') ||
            value.contains(';') ||
            value.contains("'") ||
            value.contains('"') ||
            _hasSpaceInsideEntry(value)) {
          return S.of(context).emailsCommaSeparated;
        }
        if (value.startsWith(',') || value.endsWith(',')) {
          return S.of(context).commaAtStartOrEnd;
        }
        if (value.contains(',,')) return S.of(context).doubleCommas;

        final apEmails = value.split(',').map((e) => e.trim()).toList();
        if (apEmails.toSet().length != apEmails.length) {
          return S.of(context).duplicateEmails;
        }
        for (final email in apEmails) {
          if (email.isEmpty) return S.of(context).emptyEmail;
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
            return S.of(context).invalidEmailFormat;
          }
          if (!employeeController.mapOfEmployeesWithEmailKey.containsKey(email)) {
            return S.of(context).emailDoesNotExist;
          }
        }
        break;

      case 'Limit Service Availability':
      case 'Requires Approvals':
        if (!['yes', 'no'].contains(value.toLowerCase())) {
          return S.of(context).invalidYesNo;
        }
        break;

      case 'Departments':
        final limitCtrl = rowData?['Limit Service Availability'];
        final limit = limitCtrl?.text.trim().toLowerCase() ?? '';

        if (limit == 'yes') {
          if (value.isEmpty) return S.of(context).departmentRequired;
          if (value.startsWith(',') || value.endsWith(',')) {
            return S.of(context).commaAtStartOrEnd;
          }
          if (value.contains(',,')) return S.of(context).doubleCommas;
          // ✅ FIX (bug report p4): '&' removed from the forbidden set — real
          // department names use it ("Compliance & Legal"), so every row
          // naming such a department was rejected as containing invalid
          // characters.
          if (RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*^%$]').hasMatch(value)) {
            return S.of(context).invalidDepartmentChars;
          }

          final departments = value.split(',').map((e) => e.trim()).toList();

          for (final dept in departments) {
            if (dept.isEmpty) return S.of(context).emptyDepartment;
            if (dept.length < 2) return S.of(context).departmentMinLength;
            if (departmentController.getDepartmentIdFromDepartmentName(departmentName: dept) ==
                null) {
              return S.of(context).departmentDoesNotExist;
            }
          }
        }
        break;
    }

    return null;
  }
}
