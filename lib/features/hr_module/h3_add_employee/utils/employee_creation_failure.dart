// ***************************** FILE INFO ***************************** //
// File Name: employee_creation_failure.dart
// Purpose: Defines typed failures for employee profile creation.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import '../../../../../core/network/failure_model.dart';

/// Base failure returned by the employee creation repository.
sealed class EmployeeCreationFailure extends Failure {
  const EmployeeCreationFailure(String message) : super(message: message);
}

final class DuplicateEmployeeIdFailure extends EmployeeCreationFailure {
  const DuplicateEmployeeIdFailure(super.message);
}

final class DuplicateBusinessEmailFailure extends EmployeeCreationFailure {
  const DuplicateBusinessEmailFailure(super.message);
}

final class DuplicatePersonalEmailFailure extends EmployeeCreationFailure {
  const DuplicatePersonalEmailFailure(super.message);
}

final class MatchingEmployeeEmailsFailure extends EmployeeCreationFailure {
  const MatchingEmployeeEmailsFailure(super.message);
}

final class EmployeeFileUploadFailure extends EmployeeCreationFailure {
  const EmployeeFileUploadFailure(super.message);
}

final class EmployeeTransactionFailure extends EmployeeCreationFailure {
  const EmployeeTransactionFailure(super.message);
}

final class EmployeeRefreshFailure extends EmployeeCreationFailure {
  const EmployeeRefreshFailure(super.message);
}

final class UnknownEmployeeCreationFailure extends EmployeeCreationFailure {
  const UnknownEmployeeCreationFailure(super.message);
}
