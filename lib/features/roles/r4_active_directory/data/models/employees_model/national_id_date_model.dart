/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: national_id_date_model.dart
/// Purpose: Declares `NationalIdExpirationDate`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class NationalIdExpirationDate {
  List<String?>? nationalIdExpirationDate;
  List<Timestamp?>? timestamps;
  NationalIdExpirationDate({
    this.nationalIdExpirationDate,
    this.timestamps,
  });

  NationalIdExpirationDate copyWith({
    List<String?>? nationalIdExpirationDate,
    List<Timestamp?>? timestamps,
  }) {
    return NationalIdExpirationDate(
      nationalIdExpirationDate:
          nationalIdExpirationDate ?? this.nationalIdExpirationDate,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'National_Id_Expiration_Date': nationalIdExpirationDate,
      'Timestamp': timestamps,
    };
  }

  factory NationalIdExpirationDate.fromMap(Map<String, dynamic> map) {
    return NationalIdExpirationDate(
      nationalIdExpirationDate: map['National_Id_Expiration_Date'] != null
          ? List<String?>.from(
              (map['National_Id_Expiration_Date']),
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

  factory NationalIdExpirationDate.fromJson(String source) =>
      NationalIdExpirationDate.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'NationalIdExpirationDate(National_Id_Expiration_Date: $nationalIdExpirationDate, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant NationalIdExpirationDate other) {
    if (identical(this, other)) return true;

    return listEquals(
            other.nationalIdExpirationDate, nationalIdExpirationDate) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => nationalIdExpirationDate.hashCode ^ timestamps.hashCode;
}
