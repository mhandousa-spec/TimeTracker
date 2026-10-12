// ***************************** FILE INFO ***************************** //
// File Name: department_conflict_exception.dart
// Purpose: Represents a department conflict during bulk persistence.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

/// Exception raised when a department conflicts with current data.
class DepartmentConflictException implements Exception {
  const DepartmentConflictException(this.departmentId);

  final String departmentId;

  /// Method Name: [toString]
  ///
  /// Purpose: Provides the conflict message used by failure mapping.
  ///
  /// Returns: A human-readable department conflict message.
  @override
  String toString() => 'Department $departmentId conflicts with current data.';
}
