/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: title_arabic_model.dart
/// Purpose: Declares `TitleInArabic`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class TitleInArabic {
  List<String?>? titleInArabic;
  List<Timestamp?>? timestamps;
  TitleInArabic({
    this.titleInArabic,
    this.timestamps,
  });

  TitleInArabic copyWith({
    List<String?>? titleInArabic,
    List<Timestamp?>? timestamps,
  }) {
    return TitleInArabic(
      titleInArabic: titleInArabic ?? this.titleInArabic,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Title_In_Arabic': titleInArabic,
      'Timestamp': timestamps,
    };
  }

  factory TitleInArabic.fromMap(Map<String, dynamic> map) {
    return TitleInArabic(
      titleInArabic: map['Title_In_Arabic'] != null
          ? List<String?>.from(
              (map['Title_In_Arabic']),
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

  factory TitleInArabic.fromJson(String source) =>
      TitleInArabic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TitleInArabic(Title_In_Arabic: $titleInArabic, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant TitleInArabic other) {
    if (identical(this, other)) return true;

    return listEquals(other.titleInArabic, titleInArabic) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => titleInArabic.hashCode ^ timestamps.hashCode;
}
