/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: passport_date_model.dart
/// Purpose: Declares `PassportExpirationDate`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class PassportExpirationDate {
  List<String?>? passportExpirationDate;
  List<Timestamp?>? timestamps;
  PassportExpirationDate({
    this.passportExpirationDate,
    this.timestamps,
  });

  PassportExpirationDate copyWith({
    List<String?>? passportExpirationDate,
    List<Timestamp?>? timestamps,
  }) {
    return PassportExpirationDate(
      passportExpirationDate:
          passportExpirationDate ?? this.passportExpirationDate,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Passport_Expiration_Date': passportExpirationDate,
      'Timestamp': timestamps,
    };
  }

  factory PassportExpirationDate.fromMap(Map<String, dynamic> map) {
    return PassportExpirationDate(
      passportExpirationDate: map['Passport_Expiration_Date'] != null
          ? List<String?>.from(
              (map['Passport_Expiration_Date']),
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

  factory PassportExpirationDate.fromJson(String source) =>
      PassportExpirationDate.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PassportExpirationDate(Passport_Expiration_Date: $passportExpirationDate, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant PassportExpirationDate other) {
    if (identical(this, other)) return true;

    return listEquals(other.passportExpirationDate, passportExpirationDate) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => passportExpirationDate.hashCode ^ timestamps.hashCode;
}
