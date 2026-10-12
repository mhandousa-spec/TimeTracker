/// Module: GRC Policy Bulk Upload
/// Description: One editable row in the bulk upload preview table. Wraps a
///              TextEditingController per field (so the user can edit any
///              cell in place, mirroring the pattern already used by
///              lib/features/roles/user_management/ui/widgets/upload_build_page.dart),
///              plus the FocusNode/GlobalKey needed for the "jump to next
///              error" navigation and its own required-field / date-order /
///              weight validation.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: flutter/material.dart, policy_excel_parser.dart, policy_bulk_date_format.dart

import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';
import 'package:flutter/material.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_row_form.dart
/// Purpose: Contains PolicyBulkRowForm, the editable-row view-model backing
///          one row of the bulk upload preview table.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// class name: [PolicyBulkRowForm]
///
/// purpose: hold the live-editable state of one bulk-upload policy row and
///          validate it against the same rules as the single-policy Add
///          Policy flow (required fields, Start < End Date, positive
///          Weight).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkRowForm {
  PolicyBulkRowForm({
    String policyNumberEn = '',
    String policyNumberAr = '',
    String policyNameEn = '',
    String policyNameAr = '',
    String policyDescriptionEn = '',
    String policyDescriptionAr = '',
    String startDate = '',
    String endDate = '',
    String policyWeight = '',
    String policyDocument = '',
  })  : policyNumberEnController = TextEditingController(text: policyNumberEn),
        policyNumberArController = TextEditingController(text: policyNumberAr),
        policyNameEnController = TextEditingController(text: policyNameEn),
        policyNameArController = TextEditingController(text: policyNameAr),
        policyDescriptionEnController =
            TextEditingController(text: policyDescriptionEn),
        policyDescriptionArController =
            TextEditingController(text: policyDescriptionAr),
        startDateController = TextEditingController(text: startDate),
        endDateController = TextEditingController(text: endDate),
        policyWeightController = TextEditingController(text: policyWeight),
        policyDocumentController = TextEditingController(text: policyDocument);

  /// function name: [fromParsedRow]
  ///
  /// purpose: build an editable row pre-filled from a parsed sheet row.
  ///
  /// parameters:
  ///            [PolicyBulkRow] row: the raw parsed row from [parsePolicyExcel]
  ///
  /// return type: [PolicyBulkRowForm] - the editable row, not yet validated
  factory PolicyBulkRowForm.fromParsedRow(PolicyBulkRow row) => PolicyBulkRowForm(
        policyNumberEn: row.policyNumberEn,
        policyNumberAr: row.policyNumberAr,
        policyNameEn: row.policyNameEn,
        policyNameAr: row.policyNameAr,
        policyDescriptionEn: row.policyDescriptionEn,
        policyDescriptionAr: row.policyDescriptionAr,
        startDate: row.startDate,
        endDate: row.endDate,
        policyWeight: row.policyWeight,
        policyDocument: row.policyDocument,
      );

  final TextEditingController policyNumberEnController;
  final TextEditingController policyNumberArController;
  final TextEditingController policyNameEnController;
  final TextEditingController policyNameArController;
  final TextEditingController policyDescriptionEnController;
  final TextEditingController policyDescriptionArController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController policyWeightController;
  final TextEditingController policyDocumentController;

  /// Scroll target for the "jump to next error" navigation.
  final GlobalKey key = GlobalKey();

  /// One [FocusNode] per editable field, keyed the same as [errors].
  final Map<String, FocusNode> focusNodes = {
    'policyNumberEn': FocusNode(),
    'policyNumberAr': FocusNode(),
    'policyNameEn': FocusNode(),
    'policyNameAr': FocusNode(),
    'policyDescriptionEn': FocusNode(),
    'policyDescriptionAr': FocusNode(),
    'startDate': FocusNode(),
    'endDate': FocusNode(),
    'policyWeight': FocusNode(),
    'policyDocument': FocusNode(),
  };

  /// The result of the most recent [validate] call.
  Map<String, String> errors = {};

  /// function name: [validate]
  ///
  /// purpose: recompute [errors] from the controllers' current text:
  ///          required fields must be non-empty, Start Date must parse and
  ///          be strictly before End Date (when End Date is filled in), and
  ///          Policy Weight must parse as a number > 0. End Date and Policy
  ///          Document are optional.
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, String>] - the recomputed [errors] map (field key -> message)
  Map<String, String> validate() {
    final next = <String, String>{};

    void requireField(String key, String value) {
      if (value.trim().isEmpty) next[key] = 'Required';
    }

    requireField('policyNumberEn', policyNumberEnController.text);
    requireField('policyNumberAr', policyNumberArController.text);
    requireField('policyNameEn', policyNameEnController.text);
    requireField('policyNameAr', policyNameArController.text);
    requireField('policyDescriptionEn', policyDescriptionEnController.text);
    requireField('policyDescriptionAr', policyDescriptionArController.text);
    requireField('startDate', startDateController.text);

    final start = parsePolicyBulkDate(startDateController.text);
    if (!next.containsKey('startDate') && start == null) {
      next['startDate'] = 'Invalid date (dd-MM-yyyy)';
    }

    final endText = endDateController.text.trim();
    final end = endText.isEmpty ? null : parsePolicyBulkDate(endText);
    if (endText.isNotEmpty && end == null) {
      next['endDate'] = 'Invalid date (dd-MM-yyyy)';
    }

    if (start != null && end != null && !start.isBefore(end)) {
      next['startDate'] = 'Start Date must be before End Date';
      next['endDate'] = 'Start Date must be before End Date';
    }

    final weight = double.tryParse(policyWeightController.text.trim());
    if (weight == null || weight <= 0) {
      next['policyWeight'] = 'Must be a positive number';
    }

    errors = next;
    return errors;
  }

  /// The current Policy Weight as a number, or 0 if it doesn't parse.
  double get weightValue => double.tryParse(policyWeightController.text.trim()) ?? 0;

  /// function name: [dispose]
  ///
  /// purpose: release every controller and focus node owned by this row.
  ///          Must be called whenever a row is removed from the table or
  ///          the bulk upload page closes.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    policyNumberEnController.dispose();
    policyNumberArController.dispose();
    policyNameEnController.dispose();
    policyNameArController.dispose();
    policyDescriptionEnController.dispose();
    policyDescriptionArController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    policyWeightController.dispose();
    policyDocumentController.dispose();
    for (final node in focusNodes.values) {
      node.dispose();
    }
  }
}
