/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: middle_name_model.dart
/// Purpose: Declares `MiddleName`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class MiddleName {
  List<String?>? middleName;
  List<Timestamp?>? timestamps;
  MiddleName({
    this.middleName,
    this.timestamps,
  });

  MiddleName copyWith({
    List<String?>? middleName,
    List<Timestamp?>? timestamps,
  }) {
    return MiddleName(
      middleName: middleName ?? this.middleName,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Middle_Name': middleName,
      'Timestamp': timestamps,
    };
  }

  factory MiddleName.fromMap(Map<String, dynamic> map) {
    return MiddleName(
      middleName: map['Middle_Name'] != null
          ? List<String?>.from(
              (map['Middle_Name']),
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

  factory MiddleName.fromJson(String source) =>
      MiddleName.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MiddleName(Middle_Name: $middleName, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant MiddleName other) {
    if (identical(this, other)) return true;

    return listEquals(other.middleName, middleName) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => middleName.hashCode ^ timestamps.hashCode;
}
