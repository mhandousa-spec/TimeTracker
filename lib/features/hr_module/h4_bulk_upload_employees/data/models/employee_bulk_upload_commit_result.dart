// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_commit_result.dart
// Purpose: Reports completed and failed employee transactions for one import.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import '../../utils/employee_bulk_upload_failure.dart';

/// Aggregates the outcome of independently committed employee rows.
class EmployeeBulkUploadCommitResult {
  EmployeeBulkUploadCommitResult({
    required this.createdEmployeeCount,
    required List<EmployeeBulkUploadFailedEmployee> failedEmployees,
  }) : failedEmployees = List.unmodifiable(failedEmployees);

  final int createdEmployeeCount;
  final List<EmployeeBulkUploadFailedEmployee> failedEmployees;

  bool get hasFailures => failedEmployees.isNotEmpty;
}

/// Identifies an employee row that could not be committed safely.
class EmployeeBulkUploadFailedEmployee {
  const EmployeeBulkUploadFailedEmployee({
    required this.excelRowNumber,
    required this.employeeId,
    required this.email,
    required this.failure,
  });

  final int excelRowNumber;
  final String employeeId;
  final String email;
  final EmployeeBulkUploadFailure failure;
}
