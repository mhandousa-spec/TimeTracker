// ***************************** FILE INFO ***************************** //
// File Name: employee_history_model_parser.dart
// Purpose: Parses current and legacy supplemental employee history values.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared compatibility parsing for supplemental employee history models.
abstract final class EmployeeHistoryModelParser {
  static const _timestampsKey = 'Timestamps';
  static const _legacyTimestampsKey = 'timestamps';

  /// Method Name: [stringHistory]
  ///
  /// Purpose: Reads either a history list or a legacy scalar as history.
  ///
  /// Parameters:
  /// - [value]: Firestore field value to normalize.
  ///
  /// Returns: A string history list preserving the stored order.
  static List<String> stringHistory(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value.map((item) => item?.toString() ?? '').toList();
    }
    return <String>[value.toString()];
  }

  /// Method Name: [timestamps]
  ///
  /// Purpose: Reads current and legacy timestamp histories with compatibility
  /// for scalar documents.
  ///
  /// Parameters:
  /// - [map]: Firestore model map.
  ///
  /// Returns: Shared integer timestamps for the model histories.
  static List<int> timestamps(Map<String, dynamic> map) {
    final value = map[_timestampsKey] ?? map[_legacyTimestampsKey];
    if (value is List) {
      return value.whereType<num>().map((item) => item.toInt()).toList();
    }
    final createdAt = map['Created_At'];
    return createdAt is num ? <int>[createdAt.toInt()] : <int>[];
  }

  /// Method Name: [firestoreTimestamps]
  ///
  /// Purpose: Reads Firestore timestamps with legacy integer compatibility.
  ///
  /// Parameters:
  /// - [map]: Firestore model map.
  ///
  /// Returns: Firestore timestamp history preserving the stored order.
  static List<Timestamp> firestoreTimestamps(Map<String, dynamic> map) {
    final value = map[_timestampsKey] ?? map[_legacyTimestampsKey];
    if (value is List) {
      return value.map(_toFirestoreTimestamp).whereType<Timestamp>().toList();
    }
    final createdAt = _toFirestoreTimestamp(map['Created_At']);
    return createdAt == null ? <Timestamp>[] : <Timestamp>[createdAt];
  }

  /// Method Name: [_toFirestoreTimestamp]
  ///
  /// Purpose: Converts current or legacy timestamp values to Firestore format.
  ///
  /// Parameters:
  /// - [value]: A Firestore Timestamp or legacy epoch-millisecond number.
  ///
  /// Returns: A Firestore timestamp, or null for unsupported values.
  static Timestamp? _toFirestoreTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    if (value is num) {
      return Timestamp.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }
}
