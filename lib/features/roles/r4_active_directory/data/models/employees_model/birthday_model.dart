/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: birthday_model.dart
/// Purpose: Declares `BirthDay`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class BirthDay {
  List<String?>? birthDays;
  List<Timestamp?>? timestamps;
  BirthDay({
    this.birthDays,
    this.timestamps,
  });

  BirthDay copyWith({
    List<String?>? birthDays,
    List<Timestamp?>? timestamps,
  }) {
    return BirthDay(
      birthDays: birthDays ?? this.birthDays,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Birth_Day': birthDays,
      'Timestamp': timestamps,
    };
  }

  factory BirthDay.fromMap(Map<String, dynamic> map) {
    return BirthDay(
      birthDays: map['Birth_Day'] != null
          ? List<String?>.from(
              (map['Birth_Day']),
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

  factory BirthDay.fromJson(String source) =>
      BirthDay.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BirthDay(BirthDay: $birthDays, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant BirthDay other) {
    if (identical(this, other)) return true;

    return listEquals(other.birthDays, birthDays) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => birthDays.hashCode ^ timestamps.hashCode;
}
