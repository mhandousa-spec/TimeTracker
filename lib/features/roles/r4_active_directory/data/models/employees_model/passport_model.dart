/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: passport_model.dart
/// Purpose: Declares `Passport`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Passport {
  List<String?>? passport;
  List<Timestamp?>? timestamps;
  Passport({
    this.passport,
    this.timestamps,
  });

  Passport copyWith({
    List<String?>? passport,
    List<Timestamp?>? timestamps,
  }) {
    return Passport(
      passport: passport ?? this.passport,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Passport': passport,
      'Timestamp': timestamps,
    };
  }

  factory Passport.fromMap(Map<String, dynamic> map) {
    return Passport(
      passport: map['Passport'] != null
          ? List<String?>.from(
              (map['Passport']),
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

  factory Passport.fromJson(String source) =>
      Passport.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Passport(Passport: $passport, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Passport other) {
    if (identical(this, other)) return true;

    return listEquals(other.passport, passport) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => passport.hashCode ^ timestamps.hashCode;
}
