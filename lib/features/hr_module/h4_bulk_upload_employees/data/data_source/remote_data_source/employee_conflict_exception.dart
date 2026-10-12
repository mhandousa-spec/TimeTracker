// ***************************** FILE INFO ***************************** //
// File Name: employee_conflict_exception.dart
// Purpose: Represents a duplicate employee conflict during bulk persistence.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

/// Exception raised when an employee identifier already exists.
class EmployeeConflictException implements Exception {
  const EmployeeConflictException(this.employeeId);

  final String employeeId;

  /// Method Name: [toString]
  ///
  /// Purpose: Provides the conflict message used by failure mapping.
  ///
  /// Returns: A human-readable duplicate employee message.
  @override
  String toString() => 'Employee ID $employeeId already exists.';
}
