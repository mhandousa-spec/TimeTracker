// ***************************** FILE INFO ***************************** //
// File Name: employee_update_failure.dart
// Purpose: Defines typed failures returned by employee updates.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

/// Base failure for direct employee profile updates.
sealed class EmployeeUpdateFailure {
  const EmployeeUpdateFailure(this.message);

  final String message;
}

/// Failure raised when Firestore cannot commit the employee update.
final class EmployeeUpdateTransactionFailure extends EmployeeUpdateFailure {
  const EmployeeUpdateTransactionFailure(super.message);
}

/// Failure raised when the selected edit form does not pass validation.
final class EmployeeUpdateValidationFailure extends EmployeeUpdateFailure {
  const EmployeeUpdateValidationFailure() : super('');
}
