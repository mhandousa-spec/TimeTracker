// ignore_for_file: unnecessary_this

/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: first_name_arabic_model.dart
/// Purpose: Declares `FirstNameInArabic`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class FirstNameInArabic {
  List<String?>? firstNamesInArabic;
  List<Timestamp?>? timestamps;
  FirstNameInArabic({
    this.firstNamesInArabic,
    this.timestamps,
  });

  FirstNameInArabic copyWith({
    List<String?>? fistNames,
    List<Timestamp?>? timestamps,
  }) {
    return FirstNameInArabic(
      firstNamesInArabic: fistNames ?? this.firstNamesInArabic,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'First_Name_In_Arabic': firstNamesInArabic,
      'Timestamp': timestamps,
    };
  }

  factory FirstNameInArabic.fromMap(Map<String, dynamic> map) {
    return FirstNameInArabic(
      firstNamesInArabic: map['First_Name_In_Arabic'] != null
          ? List<String?>.from(
              (map['First_Name_In_Arabic']),
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

  factory FirstNameInArabic.fromJson(String source) =>
      FirstNameInArabic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'FirstName(First_Name_In_Arabic: $firstNamesInArabic, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant FirstNameInArabic other) {
    if (identical(this, other)) return true;

    return listEquals(other.firstNamesInArabic, firstNamesInArabic) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => firstNamesInArabic.hashCode ^ timestamps.hashCode;
}
