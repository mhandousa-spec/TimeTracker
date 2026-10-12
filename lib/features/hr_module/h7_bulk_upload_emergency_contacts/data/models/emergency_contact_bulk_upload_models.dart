// ***************************** FILE INFO ***************************** //
// File Name: emergency_contact_bulk_upload_models.dart
// Purpose: Defines emergency-upload preflight, validation, and results.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import '../../../shared/bulk_upload/bulk_upload_template.dart';

class EmergencyContactBulkUploadPreflight {
  const EmergencyContactBulkUploadPreflight(this.employeeIds);
  final Set<String> employeeIds;
}

class EmergencyContactBulkUploadFailedRow {
  const EmergencyContactBulkUploadFailedRow(
      {required this.rowNumber,
      required this.employeeId,
      required this.message});
  final int rowNumber;
  final String employeeId;
  final String message;
}

class EmergencyContactBulkUploadCommitResult {
  const EmergencyContactBulkUploadCommitResult(
      {required this.updatedCount, required this.failedRows});
  final int updatedCount;
  final List<EmergencyContactBulkUploadFailedRow> failedRows;
  bool get hasFailures => failedRows.isNotEmpty;
}

typedef EmergencyContactValidationResult = ({
  List<BulkUploadRow> rows,
  List<BulkUploadCellError> errors,
});
