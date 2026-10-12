// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_file.dart
// Purpose: Describes a parsed employee workbook and its validation results.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'employee_bulk_upload_cell_error.dart';
import 'employee_bulk_upload_row.dart';

/// Immutable parsed employee workbook.
class EmployeeBulkUploadFile {
  EmployeeBulkUploadFile({
    required this.fileName,
    required this.sheetName,
    required List<EmployeeBulkUploadRow> rows,
    List<EmployeeBulkUploadCellError> errors = const [],
  })  : rows = List.unmodifiable(rows),
        errors = List.unmodifiable(errors);

  final String fileName;
  final String sheetName;
  final List<EmployeeBulkUploadRow> rows;
  final List<EmployeeBulkUploadCellError> errors;

  int get employeeCount => rows.length;
  int get errorCount => errors.length;

  EmployeeBulkUploadFile copyWith({
    List<EmployeeBulkUploadRow>? rows,
    List<EmployeeBulkUploadCellError>? errors,
  }) {
    return EmployeeBulkUploadFile(
      fileName: fileName,
      sheetName: sheetName,
      rows: rows ?? this.rows,
      errors: errors ?? this.errors,
    );
  }
}
