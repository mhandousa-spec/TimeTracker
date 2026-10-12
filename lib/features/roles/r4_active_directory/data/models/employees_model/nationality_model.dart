/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: nationality_model.dart
/// Purpose: Declares `Nationality`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Nationality {
  List<String?>? nationality;
  List<Timestamp?>? timestamps;
  Nationality({
    this.nationality,
    this.timestamps,
  });

  Nationality copyWith({
    List<String?>? nationality,
    List<Timestamp?>? timestamps,
  }) {
    return Nationality(
      nationality: nationality ?? this.nationality,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Nationality': nationality,
      'Timestamp': timestamps,
    };
  }

  factory Nationality.fromMap(Map<String, dynamic> map) {
    return Nationality(
      nationality: map['Nationality'] != null
          ? List<String?>.from(
              (map['Nationality']),
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

  factory Nationality.fromJson(String source) =>
      Nationality.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Nationality(Nationality: $nationality, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Nationality other) {
    if (identical(this, other)) return true;

    return listEquals(other.nationality, nationality) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => nationality.hashCode ^ timestamps.hashCode;
}
