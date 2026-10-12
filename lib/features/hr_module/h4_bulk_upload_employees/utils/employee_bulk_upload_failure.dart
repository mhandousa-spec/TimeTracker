// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_failure.dart
// Purpose: Defines typed failures for employee spreadsheet imports.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

/// Base failure returned by employee bulk-upload boundaries.
sealed class EmployeeBulkUploadFailure {
  const EmployeeBulkUploadFailure(this.message);
  final String message;
}

final class EmployeeBulkUnsupportedFileFailure
    extends EmployeeBulkUploadFailure {
  const EmployeeBulkUnsupportedFileFailure(super.message);
}

final class EmployeeBulkNoDroppedFileFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkNoDroppedFileFailure(super.message);
}

final class EmployeeBulkFileReadFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkFileReadFailure(super.message);
}

final class EmployeeBulkCorruptWorkbookFailure
    extends EmployeeBulkUploadFailure {
  const EmployeeBulkCorruptWorkbookFailure(super.message);
}

final class EmployeeBulkEmptyWorkbookFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkEmptyWorkbookFailure(super.message);
}

final class EmployeeBulkHeaderFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkHeaderFailure(
    super.message, {
    this.missingHeaders = const [],
    this.unexpectedHeaders = const [],
    this.hasOrderMismatch = false,
  });

  /// Expected headers absent from the uploaded workbook.
  final List<String> missingHeaders;

  /// Headers present in the uploaded workbook but absent from the template.
  final List<String> unexpectedHeaders;

  /// Whether the workbook contains the expected headers in the wrong order.
  final bool hasOrderMismatch;
}

final class EmployeeBulkRowLimitFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkRowLimitFailure(super.message);
}

final class EmployeeBulkInvalidDataFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkInvalidDataFailure(super.message);
}

final class EmployeeBulkDuplicateEmployeeFailure
    extends EmployeeBulkUploadFailure {
  const EmployeeBulkDuplicateEmployeeFailure(super.message);
}

final class EmployeeBulkDuplicateEmailFailure
    extends EmployeeBulkUploadFailure {
  const EmployeeBulkDuplicateEmailFailure(super.message);
}

final class EmployeeBulkRoleLookupFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkRoleLookupFailure(super.message);
}

final class EmployeeBulkDepartmentConflictFailure
    extends EmployeeBulkUploadFailure {
  const EmployeeBulkDepartmentConflictFailure(super.message);
}

final class EmployeeBulkPreflightFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkPreflightFailure(super.message);
}

final class EmployeeBulkCommitFailure extends EmployeeBulkUploadFailure {
  const EmployeeBulkCommitFailure(super.message);
}
