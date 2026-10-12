// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_cell_error.dart
// Purpose: Identifies one localized employee spreadsheet validation error.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

/// Validation failure associated with one spreadsheet cell.
class EmployeeBulkUploadCellError {
  const EmployeeBulkUploadCellError({
    required this.rowIndex,
    required this.header,
    required this.message,
  });

  final int rowIndex;
  final String header;
  final String message;

  @override
  bool operator ==(Object other) =>
      other is EmployeeBulkUploadCellError &&
      other.rowIndex == rowIndex &&
      other.header == header &&
      other.message == message;

  @override
  int get hashCode => Object.hash(rowIndex, header, message);
}
