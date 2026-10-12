/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: last_name_model.dart
/// Purpose: Declares `LastName`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class LastName {
  List<String?>? lastNames;
  List<Timestamp?>? timestamps;
  LastName({
    this.lastNames,
    this.timestamps,
  });

  LastName copyWith({
    List<String?>? lastNames,
    List<Timestamp?>? timestamps,
  }) {
    return LastName(
      lastNames: lastNames ?? this.lastNames,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Last_Name': lastNames,
      'Timestamp': timestamps,
    };
  }

  factory LastName.fromMap(Map<String, dynamic> map) {
    return LastName(
      lastNames: map['Last_Name'] != null
          ? List<String?>.from(
              (map['Last_Name']),
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

  factory LastName.fromJson(String source) =>
      LastName.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'lastName(Last_Name: $lastNames, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant LastName other) {
    if (identical(this, other)) return true;

    return listEquals(other.lastNames, lastNames) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => lastNames.hashCode ^ timestamps.hashCode;
}
