/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: english_font_model.dart
/// Purpose: The `English_Font` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class EnglishFont {
  /// Firestore field keys.
  static const String fieldEnglishFont = 'English_Font';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? englishFont;
  List<Timestamp?>? timestamps;
  EnglishFont({
    this.englishFont,
    this.timestamps,
  });

  EnglishFont copyWith({
    List<String?>? englishFont,
    List<Timestamp?>? timestamps,
  }) {
    return EnglishFont(
      englishFont: englishFont ?? this.englishFont,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldEnglishFont: englishFont,
      fieldTimestamp: timestamps,
    };
  }

  factory EnglishFont.fromMap(Map<String, dynamic> map) {
    return EnglishFont(
      englishFont: map[fieldEnglishFont] != null
          ? List<String?>.from(
              (map[fieldEnglishFont]),
            )
          : null,
      timestamps: map[fieldTimestamp] != null
          ? List<Timestamp?>.from(
              (map[fieldTimestamp]),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EnglishFont.fromJson(String source) =>
      EnglishFont.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'EnglishFont(English_Font: $englishFont, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant EnglishFont other) {
    if (identical(this, other)) return true;

    return listEquals(other.englishFont, englishFont) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => englishFont.hashCode ^ timestamps.hashCode;
}
