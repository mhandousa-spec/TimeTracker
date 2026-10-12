/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: secondary_color_model.dart
/// Purpose: The `Secondary_Color` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SecondaryColor {
  /// Firestore field keys.
  static const String fieldSecondaryColor = 'Secondary_Color';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? secondaryColor;
  List<Timestamp?>? timestamps;
  SecondaryColor({
    this.secondaryColor,
    this.timestamps,
  });

  SecondaryColor copyWith({
    List<String?>? secondaryColor,
    List<Timestamp?>? timestamps,
  }) {
    return SecondaryColor(
      secondaryColor: secondaryColor ?? this.secondaryColor,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldSecondaryColor: secondaryColor,
      fieldTimestamp: timestamps,
    };
  }

  factory SecondaryColor.fromMap(Map<String, dynamic> map) {
    return SecondaryColor(
      secondaryColor: map[fieldSecondaryColor] != null
          ? List<String?>.from(
              (map[fieldSecondaryColor]),
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

  factory SecondaryColor.fromJson(String source) =>
      SecondaryColor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SecondaryColor(Secondary_Color: $secondaryColor, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant SecondaryColor other) {
    if (identical(this, other)) return true;

    return listEquals(other.secondaryColor, secondaryColor) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => secondaryColor.hashCode ^ timestamps.hashCode;
}
