// ***************************** FILE INFO ***************************** //
// File Name: salary_bulk_upload_models.dart
// Purpose: Defines typed salary bulk-upload preflight and commit results.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import 'package:knowticed_plus/features/hr_module/shared/bulk_upload/bulk_upload_template.dart';

/// Existing HR employees available during salary workbook validation.
class SalaryBulkUploadPreflight {
  const SalaryBulkUploadPreflight(this.employeesById);

  final Map<String, HrEmployeeEntity> employeesById;
}

/// One salary row that failed its independent transaction.
class SalaryBulkUploadFailedRow {
  const SalaryBulkUploadFailedRow({
    required this.row,
    required this.message,
  });

  final BulkUploadRow row;
  final String message;
}

/// Aggregate result for independent salary-row commits.
class SalaryBulkUploadCommitResult {
  const SalaryBulkUploadCommitResult({
    required this.updatedRows,
    required this.failedRows,
  });

  final List<BulkUploadRow> updatedRows;
  final List<SalaryBulkUploadFailedRow> failedRows;

  int get updatedCount => updatedRows.length;
  bool get hasFailures => failedRows.isNotEmpty;
}
