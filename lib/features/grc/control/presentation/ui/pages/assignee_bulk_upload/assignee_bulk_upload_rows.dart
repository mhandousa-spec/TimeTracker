/// Module: GRC Assignee Bulk Upload (shared by Control Owner + Control Champion)
/// Description: In-memory collection of the bulk upload preview table's
///              rows: row selection, add/remove/duplicate, and the derived
///              error-count / error-location values the preview page and
///              Cubit need. Mirrors policy_bulk_upload_rows.dart's shape,
///              except the batch-level rule here is "no duplicate Email"
///              instead of duplicate Policy Name/Number — an uploader must
///              consolidate every control for one person into a single row
///              (comma-separated Control Name), not spread across rows.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-26
/// Dependencies: assignee_bulk_row_form.dart, assignee_excel_parser.dart

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_row_form.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_excel_parser.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';

class AssigneeBulkUploadRows {
  AssigneeBulkUploadRows(
    List<AssigneeBulkRow> parsedRows, {
    required this.employees,
    required this.allPolicies,
    required this.policyControls,
  }) : rows = parsedRows.map(AssigneeBulkRowForm.fromParsedRow).toList() {
    revalidateAll();
  }

  final List<AssigneeBulkRowForm> rows;
  final Set<int> selectedRows = {};
  final List<EmployeeEntityPro> employees;
  final List<PolicyEntity> allPolicies;
  final Map<String, List<ControlEntity>> policyControls;

  /// function name: [revalidateAll]
  ///
  /// purpose: re-run every row's own field validation, then flag duplicate
  ///          Email values across the batch. Must be re-run after anything
  ///          that adds, removes, or edits a row's Email text, since a
  ///          duplicate is a property of the whole batch, not of one row in
  ///          isolation.
  void revalidateAll() {
    for (final row in rows) {
      row.validate(
        employees: employees,
        allPolicies: allPolicies,
        policyControls: policyControls,
      );
    }
    _flagDuplicateEmails();
  }

  void _flagDuplicateEmails() {
    final groups = <String, List<AssigneeBulkRowForm>>{};
    for (final row in rows) {
      final value = row.emailController.text.trim().toLowerCase();
      if (value.isEmpty) continue;
      groups.putIfAbsent(value, () => []).add(row);
    }
    for (final group in groups.values) {
      if (group.length < 2) continue;
      for (final row in group) {
        row.errors['email'] = 'Duplicate Email';
      }
    }
  }

  void toggleSelected(int index) {
    if (!selectedRows.remove(index)) {
      selectedRows.add(index);
    }
  }

  void addBlankRow() {
    rows.add(AssigneeBulkRowForm());
    revalidateAll();
  }

  bool removeSelected() {
    if (selectedRows.isEmpty) return false;
    final sortedDescending = selectedRows.toList()
      ..sort((a, b) => b.compareTo(a));
    for (final index in sortedDescending) {
      rows[index].dispose();
      rows.removeAt(index);
    }
    selectedRows.clear();
    revalidateAll();
    return true;
  }

  bool duplicateSelected() {
    if (selectedRows.length != 1) return false;
    final source = rows[selectedRows.first];
    final copy = AssigneeBulkRowForm(
      email: source.emailController.text,
      policyName: source.policyNameController.text,
      controlNames: source.controlNamesController.text,
    );
    rows.add(copy);
    selectedRows.clear();
    revalidateAll();
    return true;
  }

  void removeAt(int index) {
    rows[index].dispose();
    rows.removeAt(index);
    selectedRows.remove(index);
    revalidateAll();
  }

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
  /// least one row.
  bool get isValid => errorCount == 0 && rows.isNotEmpty;

  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
  }
}
