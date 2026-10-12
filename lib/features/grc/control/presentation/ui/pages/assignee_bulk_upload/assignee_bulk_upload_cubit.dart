/// Module: GRC Assignee Bulk Upload (shared by Control Owner + Control Champion)
/// Description: BLoC Cubit driving the bulk upload preview table: owns the
///              editable [AssigneeBulkUploadRows], forwards row-management
///              actions to it, and on submit calls the caller-supplied
///              [AssigneeBulkCreateCallback] once per row, best-effort (one
///              row's failure doesn't stop the rest). The callback is how
///              this stays shared between Control Owner and Control
///              Champion — each entry point adapts its own
///              CreateOwnerUseCase/CreateChampionUseCase into this shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-26
/// Dependencies: flutter_bloc, get, dartz, AssigneeBulkUploadRows

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_rows.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_excel_parser.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'assignee_bulk_upload_state.dart';

/// Adapter the caller supplies so this shared cubit can create either a
/// Control Owner or a Control Champion without knowing which.
typedef AssigneeBulkCreateCallback = Future<Either<Failure, dynamic>> Function({
  required String moduleId,
  required String email,
  required List<AssigningControlEntity> assigningControls,
  required String editorId,
});

class AssigneeBulkUploadCubit extends Cubit<AssigneeBulkUploadState> {
  AssigneeBulkUploadCubit({
    required AssigneeBulkCreateCallback createAssignee,
    required List<AssigneeBulkRow> parsedRows,
    required List<EmployeeEntityPro> employees,
    required List<PolicyEntity> allPolicies,
    required Map<String, List<ControlEntity>> policyControls,
  })  : _createAssignee = createAssignee,
        _rows = AssigneeBulkUploadRows(
          parsedRows,
          employees: employees,
          allPolicies: allPolicies,
          policyControls: policyControls,
        ),
        super(AssigneeBulkUploadEditing());

  final AssigneeBulkCreateCallback _createAssignee;
  final AssigneeBulkUploadRows _rows;

  /// The editable row collection backing the preview table.
  AssigneeBulkUploadRows get rowsData => _rows;

  void toggleRowSelected(int index) {
    _rows.toggleSelected(index);
    emit(AssigneeBulkUploadEditing());
  }

  void addRow() {
    _rows.addBlankRow();
    emit(AssigneeBulkUploadEditing());
  }

  void removeSelectedRows() {
    _rows.removeSelected();
    emit(AssigneeBulkUploadEditing());
  }

  void duplicateSelectedRow() {
    _rows.duplicateSelected();
    emit(AssigneeBulkUploadEditing());
  }

  /// Re-runs validation across the whole batch (called on every cell edit) —
  /// see [AssigneeBulkUploadRows.revalidateAll] for why a full re-scan (not
  /// just row [index]) is required.
  void revalidateRow(int index) {
    _rows.revalidateAll();
    emit(AssigneeBulkUploadEditing());
  }

  /// function name: [submit]
  ///
  /// purpose: create every valid row via the caller-supplied
  ///          [AssigneeBulkCreateCallback], best-effort — one row's failure
  ///          does not stop the others. Rows that succeed are removed from
  ///          [rowsData]; rows that fail stay, in order, so
  ///          [AssigneeBulkUploadSubmitResult.failed] lines up 1:1 with the
  ///          remaining rows in [rowsData] afterward.
  Future<void> submit({required String moduleId}) async {
    emit(AssigneeBulkUploadSubmitting());

    var succeededCount = 0;
    final failed = <AssigneeBulkRowFailure>[];
    final indexesToRemove = <int>[];
    final editorId = currentGrcUserEmail();

    for (var i = 0; i < _rows.rows.length; i++) {
      final row = _rows.rows[i];
      final email = row.emailController.text.trim();
      final policyId = row.resolvedPolicyId;
      final controlIds = row.resolvedControlIds;

      if (policyId == null || controlIds.isEmpty) {
        failed.add(const AssigneeBulkRowFailure(reason: 'Invalid row data'));
        continue;
      }

      final assigningControls = controlIds
          .map((cid) =>
              AssigningControlEntity(policyId: policyId, controlId: cid))
          .toList();

      final result = await _createAssignee(
        moduleId: moduleId,
        email: email,
        assigningControls: assigningControls,
        editorId: editorId,
      );

      result.fold(
        (failure) => failed.add(AssigneeBulkRowFailure(reason: failure.message)),
        (_) {
          succeededCount++;
          indexesToRemove.add(i);
        },
      );
    }

    indexesToRemove.sort((a, b) => b.compareTo(a));
    for (final index in indexesToRemove) {
      _rows.removeAt(index);
    }

    emit(AssigneeBulkUploadSubmitResult(
        succeededCount: succeededCount, failed: failed));
  }

  @override
  Future<void> close() {
    _rows.dispose();
    return super.close();
  }
}
