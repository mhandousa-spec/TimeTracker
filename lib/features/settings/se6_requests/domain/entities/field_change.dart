/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: field_change.dart
/// Purpose: One edited field inside a change request.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N03. A change was a bare `Map<String, dynamic>` with
/// three string keys, built and re-read by index in four different files.

import 'package:flutter/foundation.dart';

@immutable
class FieldChange {
  const FieldChange({
    required this.fieldName,
    this.oldValue = '',
    this.newValue = '',
  });

  /// Firestore keys inside the `changes` array.
  static const String keyFieldName = 'fieldName';
  static const String keyOldValue = 'oldValue';
  static const String keyNewValue = 'newValue';

  final String fieldName;
  final String oldValue;
  final String newValue;

  Map<String, dynamic> toMap() => <String, dynamic>{
        keyFieldName: fieldName,
        keyOldValue: oldValue,
        keyNewValue: newValue,
      };

  factory FieldChange.fromMap(Map<dynamic, dynamic> map) => FieldChange(
        fieldName: map[keyFieldName]?.toString() ?? '',
        oldValue: map[keyOldValue]?.toString() ?? '',
        newValue: map[keyNewValue]?.toString() ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldChange &&
          other.fieldName == fieldName &&
          other.oldValue == oldValue &&
          other.newValue == newValue;

  @override
  int get hashCode => Object.hash(fieldName, oldValue, newValue);

  @override
  String toString() => 'FieldChange($fieldName: $oldValue -> $newValue)';
}
