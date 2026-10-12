/// Module: roles / r4_active_directory / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: edit_by_model.dart
/// Purpose: Declares `EditBy`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:March/31/2024
// by:MohamedFouad
// lastUpdate:March/31/2024
class EditBy {
  List<String?>? editorEmail;
  List<Timestamp?>? timestamps;
  EditBy({
    this.editorEmail,
    this.timestamps,
  });

  EditBy copyWith({
    List<String?>? editorEmail,
    List<Timestamp?>? timestamps,
  }) {
    return EditBy(
      editorEmail: editorEmail ?? this.editorEmail,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Editor_Email': editorEmail,
      'Timestamp': timestamps,
    };
  }

  factory EditBy.fromMap(Map<String, dynamic> map) {
    return EditBy(
      editorEmail: map['Editor_Email'] != null
          ? List<String?>.from(
              (map['Editor_Email']),
            )
          : null,
      timestamps: map['Timestamp'] != null
          ? List<Timestamp?>.from(
              (map['Timestamp']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EditBy.fromJson(String source) =>
      EditBy.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'EditBy(Editor_Email: $editorEmail, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant EditBy other) {
    if (identical(this, other)) return true;

    return listEquals(other.editorEmail, editorEmail) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => editorEmail.hashCode ^ timestamps.hashCode;
}
