// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_bulk_upload_models.dart
// Purpose: Models upload lookup and per-row persistence outcomes.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

/// Existing employee information used to verify an imported identity row.
class HealthInsuranceBulkUploadPreflight {
  const HealthInsuranceBulkUploadPreflight(this.employeesById);
  final Map<String, HrEmployeeEntity> employeesById;
}

/// A row persistence problem displayed after an independent commit fails.
class HealthInsuranceBulkUploadFailedRow {
  const HealthInsuranceBulkUploadFailedRow({
    required this.excelRowNumber,
    required this.employeeId,
    required this.message,
  });

  final int excelRowNumber;
  final String employeeId;
  final String message;
}

/// Aggregates all independently committed insurance updates.
class HealthInsuranceBulkUploadCommitResult {
  const HealthInsuranceBulkUploadCommitResult({
    required this.updatedCount,
    required this.failedRows,
  });

  final int updatedCount;
  final List<HealthInsuranceBulkUploadFailedRow> failedRows;
  bool get hasFailures => failedRows.isNotEmpty;
}
