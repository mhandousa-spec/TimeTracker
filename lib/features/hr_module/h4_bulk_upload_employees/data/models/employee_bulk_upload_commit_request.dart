// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_commit_request.dart
// Purpose: Carries one validated atomic employee import request.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import '../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../utils/constants/employee_bulk_upload_headers.dart';
import 'employee_bulk_upload_row.dart';

/// Fully validated values ready for one Firestore commit.
class EmployeeBulkUploadCommitRequest {
  EmployeeBulkUploadCommitRequest({
    required List<EmployeeBulkUploadRow> rows,
    required List<DepartmentModelPro> newDepartments,
    required this.editorEmail,
  })  : rows = List.unmodifiable(rows),
        newDepartments = List.unmodifiable(newDepartments);

  final List<EmployeeBulkUploadRow> rows;
  final List<DepartmentModelPro> newDepartments;
  final String editorEmail;

  int get writeCount =>
      rows.length * EmployeeBulkUploadHeaders.writesPerEmployee +
      newDepartments.length;

  bool get exceedsWriteLimit =>
      writeCount > EmployeeBulkUploadHeaders.maxWriteOperations;
}
