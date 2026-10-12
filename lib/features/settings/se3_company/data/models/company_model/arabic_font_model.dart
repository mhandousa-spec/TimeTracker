/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: arabic_font_model.dart
/// Purpose: The `Arabic_Font` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ArabicFont {
  /// Firestore field keys.
  static const String fieldArabicFont = 'Arabic_Font';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? arabicFont;
  List<Timestamp?>? timestamps;
  ArabicFont({
    this.arabicFont,
    this.timestamps,
  });

  ArabicFont copyWith({
    List<String?>? arabicFont,
    List<Timestamp?>? timestamps,
  }) {
    return ArabicFont(
      arabicFont: arabicFont ?? this.arabicFont,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldArabicFont: arabicFont,
      fieldTimestamp: timestamps,
    };
  }

  factory ArabicFont.fromMap(Map<String, dynamic> map) {
    return ArabicFont(
      arabicFont: map[fieldArabicFont] != null
          ? List<String?>.from(
              (map[fieldArabicFont]),
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

  factory ArabicFont.fromJson(String source) =>
      ArabicFont.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ArabicFont(Arabic_Font: $arabicFont, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant ArabicFont other) {
    if (identical(this, other)) return true;

    return listEquals(other.arabicFont, arabicFont) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => arabicFont.hashCode ^ timestamps.hashCode;
}
