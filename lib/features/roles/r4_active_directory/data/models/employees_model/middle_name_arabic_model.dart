/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: middle_name_arabic_model.dart
/// Purpose: Declares `MiddleNameInArabic`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class MiddleNameInArabic {
  List<String?>? middleNameInArabic;
  List<Timestamp?>? timestamps;
  MiddleNameInArabic({
    this.middleNameInArabic,
    this.timestamps,
  });

  MiddleNameInArabic copyWith({
    List<String?>? middleNameInArabic,
    List<Timestamp?>? timestamps,
  }) {
    return MiddleNameInArabic(
      middleNameInArabic: middleNameInArabic ?? this.middleNameInArabic,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Middle_Name_In_Arabic': middleNameInArabic,
      'Timestamp': timestamps,
    };
  }

  factory MiddleNameInArabic.fromMap(Map<String, dynamic> map) {
    return MiddleNameInArabic(
      middleNameInArabic: map['Middle_Name_In_Arabic'] != null
          ? List<String?>.from(
              (map['Middle_Name_In_Arabic']),
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

  factory MiddleNameInArabic.fromJson(String source) =>
      MiddleNameInArabic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MiddleNameInArabic(Middle_Name_In_Arabic: $middleNameInArabic, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant MiddleNameInArabic other) {
    if (identical(this, other)) return true;

    return listEquals(other.middleNameInArabic, middleNameInArabic) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => middleNameInArabic.hashCode ^ timestamps.hashCode;
}
