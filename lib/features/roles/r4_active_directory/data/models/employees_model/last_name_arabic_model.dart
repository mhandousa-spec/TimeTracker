/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: last_name_arabic_model.dart
/// Purpose: Declares `LastNameInArabic`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class LastNameInArabic {
  List<String?>? lastNamesInArabic;
  List<Timestamp?>? timestamps;
  LastNameInArabic({
    this.lastNamesInArabic,
    this.timestamps,
  });

  LastNameInArabic copyWith({
    List<String?>? lastNamesInArabic,
    List<Timestamp?>? timestamps,
  }) {
    return LastNameInArabic(
      lastNamesInArabic: lastNamesInArabic ?? this.lastNamesInArabic,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Last_Name_In_Arabic': lastNamesInArabic,
      'Timestamp': timestamps,
    };
  }

  factory LastNameInArabic.fromMap(Map<String, dynamic> map) {
    return LastNameInArabic(
      lastNamesInArabic: map['Last_Name_In_Arabic'] != null
          ? List<String?>.from(
              (map['Last_Name_In_Arabic']),
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

  factory LastNameInArabic.fromJson(String source) =>
      LastNameInArabic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'lastName(Last_Name_In_Arabic: $lastNamesInArabic, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant LastNameInArabic other) {
    if (identical(this, other)) return true;

    return listEquals(other.lastNamesInArabic, lastNamesInArabic) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => lastNamesInArabic.hashCode ^ timestamps.hashCode;
}
