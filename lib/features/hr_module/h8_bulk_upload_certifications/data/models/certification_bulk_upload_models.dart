// ***************************** FILE INFO ***************************** //
// File Name: certification_bulk_upload_models.dart
// Purpose: Defines certification upload preflight and commit results.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../shared/bulk_upload/bulk_upload_template.dart';

/// Existing employees available for certification identity validation.
class CertificationBulkUploadPreflight {
  const CertificationBulkUploadPreflight(this.employeesById);
  final Map<String, HrEmployeeEntity> employeesById;
}

/// One certification row that could not be persisted.
class CertificationBulkUploadFailedRow {
  const CertificationBulkUploadFailedRow({
    required this.row,
    required this.message,
  });

  final BulkUploadRow row;
  final String message;
}

/// Aggregates independent certification row transactions.
class CertificationBulkUploadCommitResult {
  const CertificationBulkUploadCommitResult({
    required this.updatedRows,
    required this.failedRows,
  });

  final List<BulkUploadRow> updatedRows;
  final List<CertificationBulkUploadFailedRow> failedRows;
  int get updatedCount => updatedRows.length;
  bool get hasFailures => failedRows.isNotEmpty;
}
