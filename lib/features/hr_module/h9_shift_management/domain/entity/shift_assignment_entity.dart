// ***************************** FILE INFO ***************************** //
// File Name: shift_assignment_entity.dart
// Purpose: Defines the latest business values of an employee shift assignment.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

/// Represents the latest usable values of an employee shift assignment.
class ShiftAssignmentEntity {
  const ShiftAssignmentEntity({
    required this.id,
    required this.employeeId,
    required this.shiftId,
  });

  final String id;
  final String employeeId;
  final String shiftId;

  /// Method Name: [copyWith]
  ///
  /// Purpose: Creates a copy with selected latest values replaced.
  ///
  /// Returns: A copied current-value assignment entity.
  ShiftAssignmentEntity copyWith({
    String? id,
    String? employeeId,
    String? shiftId,
  }) {
    return ShiftAssignmentEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      shiftId: shiftId ?? this.shiftId,
    );
  }
}
