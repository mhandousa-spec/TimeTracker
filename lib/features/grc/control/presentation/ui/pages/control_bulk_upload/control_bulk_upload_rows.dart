// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart
/// Module: GRC Control Bulk Upload
/// Description: In-memory collection of the Control bulk upload preview
///              table's rows — mirrors
///              lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart,
///              minus the batch-level Total Weight getters (Control has no
///              cross-row weight requirement). Also owns cross-row duplicate
///              Name/Number detection, which [ControlBulkRowForm.validate]
///              can't do on its own since it only ever sees its own row.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: control_bulk_row_form.dart, control_excel_parser.dart
library;

import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';

class ControlBulkUploadRows {
  ControlBulkUploadRows(
    List<ControlBulkRow> parsedRows, {
    required this.knownEmployeeEmails,
    required this.knownDepartmentNames,
    required this.equalWeights,
    required this.policyStartDate,
    required this.policyEndDate,
  }) : rows = parsedRows.map(ControlBulkRowForm.fromParsedRow).toList() {
    for (final row in rows) {
      _validateRow(row);
    }
    _recomputeDuplicates();
  }

  final List<ControlBulkRowForm> rows;
  final Set<int> selectedRows = {};
  final Set<String> knownEmployeeEmails;
  final Set<String> knownDepartmentNames;
  final bool equalWeights;
  final DateTime policyStartDate;
  final DateTime policyEndDate;

  /// The 4 fields checked for within-batch duplicates, independently of
  /// each other.
  static const List<String> _duplicateCheckedFields = [
    'controlNameEn',
    'controlNameAr',
    'controlNumberEn',
    'controlNumberAr',
  ];

  void _validateRow(ControlBulkRowForm row) {
    row.validate(
      knownEmployeeEmails: knownEmployeeEmails,
      knownDepartmentNames: knownDepartmentNames,
      equalWeights: equalWeights,
      policyStartDate: policyStartDate,
      policyEndDate: policyEndDate,
    );
  }

  /// function name: [revalidateRow]
  ///
  /// purpose: re-run one row's own validation (called on every cell edit),
  ///          then recompute duplicate flags across the whole batch, since
  ///          a single field edit can change which rows collide with which.
  void revalidateRow(int index) {
    _validateRow(rows[index]);
    _recomputeDuplicates();
  }

  String _fieldText(ControlBulkRowForm row, String fieldKey) {
    switch (fieldKey) {
      case 'controlNameEn':
        return row.controlNameEnController.text;
      case 'controlNameAr':
        return row.controlNameArController.text;
      case 'controlNumberEn':
        return row.controlNumberEnController.text;
      case 'controlNumberAr':
        return row.controlNumberArController.text;
      default:
        throw ArgumentError('Unknown duplicate-checked field: $fieldKey');
    }
  }

  /// function name: [_recomputeDuplicates]
  ///
  /// purpose: flag every row that shares a (trimmed, case-insensitive)
  ///          Name/Number value with another row in the batch. Clears any
  ///          stale 'Duplicate value' flags first, on every row, before
  ///          rebuilding groups — this is always safe because 'Required'
  ///          and 'Duplicate value' never coexist on the same field
  ///          (duplicate-checking skips empty values, which is exactly
  ///          when 'Required' fires instead).
  void _recomputeDuplicates() {
    for (final fieldKey in _duplicateCheckedFields) {
      for (final row in rows) {
        if (row.errors[fieldKey] == 'Duplicate value') {
          row.errors.remove(fieldKey);
        }
      }

      final groups = <String, List<int>>{};
      for (var i = 0; i < rows.length; i++) {
        final value = _fieldText(rows[i], fieldKey).trim();
        if (value.isEmpty) continue;
        groups.putIfAbsent(value.toLowerCase(), () => []).add(i);
      }

      for (final indexes in groups.values) {
        if (indexes.length < 2) continue;
        for (final i in indexes) {
          rows[i].errors[fieldKey] = 'Duplicate value';
        }
      }
    }
  }

  void toggleSelected(int index) {
    if (!selectedRows.remove(index)) {
      selectedRows.add(index);
    }
  }

  void addBlankRow() {
    final row = ControlBulkRowForm();
    _validateRow(row);
    rows.add(row);
    _recomputeDuplicates();
  }

  bool removeSelected() {
    if (selectedRows.isEmpty) return false;
    final sortedDescending = selectedRows.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedDescending) {
      rows[index].dispose();
      rows.removeAt(index);
    }
    selectedRows.clear();
    _recomputeDuplicates();
    return true;
  }

  bool duplicateSelected() {
    if (selectedRows.length != 1) return false;
    final source = rows[selectedRows.first];
    final copy = ControlBulkRowForm(
      controlNameEn: source.controlNameEnController.text,
      controlNameAr: source.controlNameArController.text,
      controlNumberEn: source.controlNumberEnController.text,
      controlNumberAr: source.controlNumberArController.text,
      controlDescriptionEn: source.controlDescriptionEnController.text,
      controlDescriptionAr: source.controlDescriptionArController.text,
      startDate: source.startDateController.text,
      endDate: source.endDateController.text,
      controlWeight: source.controlWeightController.text,
      frequency: source.frequencyController.text,
      controlChampion: source.controlChampionController.text,
      controlOwner: source.controlOwnerController.text,
      appliedDepartments: source.appliedDepartmentsController.text,
      departmentWeight: source.departmentWeightController.text,
    );
    _validateRow(copy);
    rows.add(copy);
    selectedRows.clear();
    _recomputeDuplicates();
    return true;
  }

  void removeAt(int index) {
    rows[index].dispose();
    rows.removeAt(index);
    selectedRows.remove(index);
    _recomputeDuplicates();
  }

  /// Total number of per-cell errors across every row.
  int get errorCount => rows.fold<int>(0, (sum, row) => sum + row.errors.length);

  /// Every (rowIndex, fieldKey) pair currently in error, in row/field order.
  List<(int, String)> get errorLocations {
    final locations = <(int, String)>[];
    for (var i = 0; i < rows.length; i++) {
      for (final fieldKey in rows[i].errors.keys) {
        locations.add((i, fieldKey));
      }
    }
    return locations;
  }

  /// Whether Activate should be enabled: no per-cell errors and at least one row.
  bool get isValid => errorCount == 0 && rows.isNotEmpty;

  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
  }
}
