// ***************************** FILE INFO ***************************** //
// File Name: shift_assignment_model.dart
// Purpose: Defines simplified, trackable employee-to-shift assignments.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/shift_assignment_entity.dart';

/// Stores an employee-to-shift relationship and its audit history.
class ShiftAssignmentModel {
  ShiftAssignmentModel({
    required this.id,
    required this.employeeId,
    required this.shiftIds,
    required this.timestamps,
    required this.editors,
  });
  static const String idKey = 'Id';
  static const String employeeIdKey = 'Employee_Id';
  static const String shiftIdKey = 'Shift_Id';
  static const String timestampsKey = 'Timestamps';
  static const String editorKey = 'Editor';

  final String id;
  final String employeeId;
  final List<String> shiftIds;
  final List<Timestamp> timestamps;
  final List<String> editors;

  String get shiftId => shiftIds.last;

  /// Method Name: [toEntity]
  ///
  /// Purpose: Converts tracked persistence history into latest domain values.
  ///
  /// Returns: A current-value assignment entity.
  ShiftAssignmentEntity toEntity() => ShiftAssignmentEntity(
        id: id,
        employeeId: employeeId,
        shiftId: shiftId,
      );

  /// Method Name: [withInitialAssignment]
  ///
  /// Purpose: Creates the first audit revision for an employee and shift.
  ///
  /// Returns: A deterministic assignment record with one tracking revision.
  factory ShiftAssignmentModel.withInitialAssignment({
    required String employeeId,
    required String shiftId,
    required String editorId,
    Timestamp? timestamp,
  }) {
    return ShiftAssignmentModel(
      id: employeeId,
      employeeId: employeeId,
      shiftIds: [shiftId],
      timestamps: [timestamp ?? Timestamp.now()],
      editors: [editorId],
    );
  }

  /// Method Name: [appendTrackingRevision]
  ///
  /// Purpose: Appends an assignment audit event without changing its identity.
  ///
  /// Returns: A new model containing the appended audit event.
  ShiftAssignmentModel appendTrackingRevision({
    String? shiftId,
    required String editorId,
    Timestamp? timestamp,
  }) {
    return ShiftAssignmentModel(
      id: id,
      employeeId: employeeId,
      shiftIds: [...shiftIds, shiftId ?? this.shiftId],
      timestamps: [...timestamps, timestamp ?? Timestamp.now()],
      editors: [...editors, editorId],
    );
  }

  /// Method Name: [toMap]
  ///
  /// Purpose: Serializes only relationship and audit fields for Firestore.
  ///
  /// Returns: A Firestore-compatible assignment map.
  Map<String, dynamic> toMap() => {
        idKey: id,
        employeeIdKey: employeeId,
        shiftIdKey: shiftIds,
        timestampsKey: timestamps,
        editorKey: editors,
      };

  /// Method Name: [fromMap]
  ///
  /// Purpose: Parses current and legacy assignment documents safely.
  ///
  /// Parameters:
  /// - [map]: Firestore assignment data.
  ///
  /// Returns: A normalized assignment model.

  factory ShiftAssignmentModel.fromMap(Map<String, dynamic> map) {
    return ShiftAssignmentModel(
        id: map[idKey],
        employeeId: map[employeeIdKey],
        shiftIds: List<String>.from(map[shiftIdKey]),
        timestamps: List<Timestamp>.from(map[timestampsKey]),
        editors: List<String>.from(map[editorKey]));
  }
}
