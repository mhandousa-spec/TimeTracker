// ignore_for_file: unnecessary_this

/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: first_name_model.dart
/// Purpose: Declares `FirstName`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class FirstName {
  List<String?>? firstNames;
  List<Timestamp?>? timestamps;
  FirstName({
    this.firstNames,
    this.timestamps,
  });

  FirstName copyWith({
    List<String?>? fistNames,
    List<Timestamp?>? timestamps,
  }) {
    return FirstName(
      firstNames: fistNames ?? this.firstNames,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'First_Name': firstNames,
      'Timestamp': timestamps,
    };
  }

  factory FirstName.fromMap(Map<String, dynamic> map) {
    return FirstName(
      firstNames: map['First_Name'] != null
          ? List<String?>.from(
              (map['First_Name']),
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

  factory FirstName.fromJson(String source) =>
      FirstName.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyName(First_Name: $firstNames, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant FirstName other) {
    if (identical(this, other)) return true;

    return listEquals(other.firstNames, firstNames) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => firstNames.hashCode ^ timestamps.hashCode;
}
