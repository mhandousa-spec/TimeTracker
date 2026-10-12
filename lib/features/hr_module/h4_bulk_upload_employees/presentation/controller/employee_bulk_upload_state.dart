// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_state.dart
// Purpose: Defines immutable state for the employee bulk-upload flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import '../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../data/models/employee_bulk_upload_cell_error.dart';
import '../../data/models/employee_bulk_upload_commit_result.dart';
import '../../data/models/employee_bulk_upload_file.dart';
import '../../utils/employee_bulk_upload_failure.dart';

/// Finite employee bulk-upload flow status.
sealed class EmployeeBulkUploadStatus {
  const EmployeeBulkUploadStatus();
}

final class EmployeeBulkUploadInitial extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadInitial();
}

final class EmployeeBulkUploadPicking extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadPicking();
}

final class EmployeeBulkUploadParsing extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadParsing();
}

final class EmployeeBulkUploadEditing extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadEditing();
}

final class EmployeeBulkUploadValidating extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadValidating();
}

final class EmployeeBulkUploadReady extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadReady();
}

final class EmployeeBulkUploadSubmitting extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadSubmitting();
}

final class EmployeeBulkUploadSuccess extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadSuccess();
}

final class EmployeeBulkUploadCompletedWithFailures
    extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadCompletedWithFailures();
}

final class EmployeeBulkUploadFailureStatus extends EmployeeBulkUploadStatus {
  const EmployeeBulkUploadFailureStatus();
}

/// Complete immutable state exposed to the employee upload page.
class EmployeeBulkUploadState {
  EmployeeBulkUploadState({
    this.status = const EmployeeBulkUploadInitial(),
    this.file,
    this.selectedRows = const {},
    this.focusedError,
    this.newDepartments = const [],
    this.createdEmployeeCount = 0,
    this.failedEmployees = const [],
    this.failure,
    this.failureMessage,
  });

  final EmployeeBulkUploadStatus status;
  final EmployeeBulkUploadFile? file;
  final Set<int> selectedRows;
  final EmployeeBulkUploadCellError? focusedError;
  final List<DepartmentModelPro> newDepartments;
  final int createdEmployeeCount;
  final List<EmployeeBulkUploadFailedEmployee> failedEmployees;
  final EmployeeBulkUploadFailure? failure;
  final String? failureMessage;

  bool get canSubmit =>
      file != null &&
      file!.rows.isNotEmpty &&
      file!.errors.isEmpty &&
      status is! EmployeeBulkUploadSubmitting &&
      status is! EmployeeBulkUploadSuccess &&
      status is! EmployeeBulkUploadCompletedWithFailures;

  EmployeeBulkUploadState copyWith({
    EmployeeBulkUploadStatus? status,
    EmployeeBulkUploadFile? file,
    bool clearFile = false,
    Set<int>? selectedRows,
    EmployeeBulkUploadCellError? focusedError,
    bool clearFocusedError = false,
    List<DepartmentModelPro>? newDepartments,
    int? createdEmployeeCount,
    List<EmployeeBulkUploadFailedEmployee>? failedEmployees,
    EmployeeBulkUploadFailure? failure,
    String? failureMessage,
    bool clearFailure = false,
  }) {
    return EmployeeBulkUploadState(
      status: status ?? this.status,
      file: clearFile ? null : file ?? this.file,
      selectedRows: selectedRows ?? this.selectedRows,
      focusedError:
          clearFocusedError ? null : focusedError ?? this.focusedError,
      newDepartments: newDepartments ?? this.newDepartments,
      createdEmployeeCount: createdEmployeeCount ?? this.createdEmployeeCount,
      failedEmployees: failedEmployees ?? this.failedEmployees,
      failure: clearFailure ? null : failure ?? this.failure,
      failureMessage:
          clearFailure ? null : failureMessage ?? this.failureMessage,
    );
  }
}
