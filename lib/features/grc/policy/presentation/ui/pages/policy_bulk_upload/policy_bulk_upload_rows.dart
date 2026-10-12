/// Module: GRC Policy Bulk Upload
/// Description: In-memory collection of the bulk upload preview table's
///              rows: row selection, add/remove/duplicate, and the derived
///              Total Weight / error-count / error-location values the
///              preview page and Cubit need. Deliberately has no dependency
///              on CreatePolicyUseCase or Firestore, so it can be unit
///              tested directly.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: policy_bulk_row_form.dart, policy_excel_parser.dart

import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_row_form.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_rows.dart
/// Purpose: Contains PolicyBulkUploadRows, the row-management model behind
///          the bulk upload preview table.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// class name: [PolicyBulkUploadRows]
///
/// purpose: own the editable row list, row selection, and the derived
///          Total Weight (shown for information only) and per-cell error
///          state that gates the Activate action.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadRows {
  PolicyBulkUploadRows(List<PolicyBulkRow> parsedRows)
      : rows = parsedRows.map(PolicyBulkRowForm.fromParsedRow).toList() {
    revalidateAll();
  }

  final List<PolicyBulkRowForm> rows;
  final Set<int> selectedRows = {};

  /// Field keys checked for duplicate values across the whole batch, paired
  /// with a shared error message. Policy Number/Name are each other's own
  /// identifier — En and Ar are checked independently of one another.
  static const Map<String, String> _duplicateCheckedFields = {
    'policyNumberEn': 'Duplicate Policy Number',
    'policyNumberAr': 'Duplicate Policy Number',
    'policyNameEn': 'Duplicate Policy Name',
    'policyNameAr': 'Duplicate Policy Name',
  };

  /// function name: [revalidateAll]
  ///
  /// purpose: re-run every row's own field validation, then flag duplicate
  ///          Policy Name/Number values across the batch (En/Ar checked
  ///          independently) by adding to each affected row's [errors] map.
  ///          Must be re-run after anything that adds, removes, or edits a
  ///          row's Name/Number text, since a duplicate is a property of the
  ///          whole batch, not of one row in isolation.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void revalidateAll() {
    for (final row in rows) {
      row.validate();
    }
    _flagDuplicates();
  }

  void _flagDuplicates() {
    for (final entry in _duplicateCheckedFields.entries) {
      final fieldKey = entry.key;
      final message = entry.value;
      final groups = <String, List<PolicyBulkRowForm>>{};
      for (final row in rows) {
        final value = _fieldValue(row, fieldKey).trim().toLowerCase();
        if (value.isEmpty) continue;
        groups.putIfAbsent(value, () => []).add(row);
      }
      for (final group in groups.values) {
        if (group.length < 2) continue;
        for (final row in group) {
          row.errors[fieldKey] = message;
        }
      }
    }
  }

  String _fieldValue(PolicyBulkRowForm row, String fieldKey) {
    switch (fieldKey) {
      case 'policyNumberEn':
        return row.policyNumberEnController.text;
      case 'policyNumberAr':
        return row.policyNumberArController.text;
      case 'policyNameEn':
        return row.policyNameEnController.text;
      case 'policyNameAr':
        return row.policyNameArController.text;
      default:
        return '';
    }
  }

  /// function name: [toggleSelected]
  ///
  /// purpose: select [index] if unselected, or deselect it if already selected.
  ///
  /// parameters:
  ///            [int] index: index into [rows]
  ///
  /// return type: [void]
  void toggleSelected(int index) {
    if (!selectedRows.remove(index)) {
      selectedRows.add(index);
    }
  }

  /// function name: [addBlankRow]
  ///
  /// purpose: append one empty, freshly-validated row (the "+ Row" action).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void addBlankRow() {
    rows.add(PolicyBulkRowForm());
    revalidateAll();
  }

  /// function name: [removeSelected]
  ///
  /// purpose: remove every currently-selected row (the "Remove Selection"
  ///          action) and clear the selection. No-op if nothing is selected.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if any row was removed, false if the selection was empty
  bool removeSelected() {
    if (selectedRows.isEmpty) return false;
    final sortedDescending = selectedRows.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedDescending) {
      rows[index].dispose();
      rows.removeAt(index);
    }
    selectedRows.clear();
    revalidateAll();
    return true;
  }

  /// function name: [duplicateSelected]
  ///
  /// purpose: append a copy of the single selected row (the "Duplication"
  ///          action) and clear the selection. No-op unless exactly one row
  ///          is selected.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if a row was duplicated, false otherwise
  bool duplicateSelected() {
    if (selectedRows.length != 1) return false;
    final source = rows[selectedRows.first];
    final copy = PolicyBulkRowForm(
      policyNumberEn: source.policyNumberEnController.text,
      policyNumberAr: source.policyNumberArController.text,
      policyNameEn: source.policyNameEnController.text,
      policyNameAr: source.policyNameArController.text,
      policyDescriptionEn: source.policyDescriptionEnController.text,
      policyDescriptionAr: source.policyDescriptionArController.text,
      startDate: source.startDateController.text,
      endDate: source.endDateController.text,
      policyWeight: source.policyWeightController.text,
      policyDocument: source.policyDocumentController.text,
    );
    rows.add(copy);
    selectedRows.clear();
    revalidateAll();
    return true;
  }

  /// function name: [removeAt]
  ///
  /// purpose: remove a single row by index (used after a successful bulk
  ///          create, to drop rows that don't need to be re-submitted).
  ///
  /// parameters:
  ///            [int] index: index into [rows]
  ///
  /// return type: [void]
  void removeAt(int index) {
    rows[index].dispose();
    rows.removeAt(index);
    selectedRows.remove(index);
    revalidateAll();
  }

  /// Sum of every row's Policy Weight.
  double get totalWeight => rows.fold<double>(0, (sum, row) => sum + row.weightValue);

  /// The batch-level rule: the sum of every row's Policy Weight must be exactly 100.
  bool get totalWeightValid => totalWeight == 100;

  /// Total number of per-cell errors across every row.
  int get errorCount => rows.fold<int>(0, (sum, row) => sum + row.errors.length);

  /// Every (rowIndex, fieldKey) pair currently in error, in row/field order —
  /// used to drive the "Error: N" prev/next navigation.
  List<(int, String)> get errorLocations {
    final locations = <(int, String)>[];
    for (var i = 0; i < rows.length; i++) {
      for (final fieldKey in rows[i].errors.keys) {
        locations.add((i, fieldKey));
      }
    }
    return locations;
  }

  /// Whether Activate should be enabled: no per-cell errors and there is at
  /// least one row. Total Weight is shown for information only and no
  /// longer blocks submission.
  bool get isValid => errorCount == 0 && rows.isNotEmpty;

  /// function name: [dispose]
  ///
  /// purpose: dispose every row's controllers/focus nodes.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
  }
}
