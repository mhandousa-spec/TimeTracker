/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: gender_model.dart
/// Purpose: Declares `Gender`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Gender {
  List<String?>? gender;
  List<Timestamp?>? timestamps;
  Gender({
    this.gender,
    this.timestamps,
  });

  Gender copyWith({
    List<String?>? gender,
    List<Timestamp?>? timestamps,
  }) {
    return Gender(
      gender: gender ?? this.gender,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Gender': gender,
      'Timestamp': timestamps,
    };
  }

  factory Gender.fromMap(Map<String, dynamic> map) {
    return Gender(
      gender: map['Gender'] != null
          ? List<String?>.from(
              (map['Gender']),
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

  factory Gender.fromJson(String source) =>
      Gender.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Gender(Gender: $gender, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Gender other) {
    if (identical(this, other)) return true;

    return listEquals(other.gender, gender) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => gender.hashCode ^ timestamps.hashCode;
}
