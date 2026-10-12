/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: primary_color_model.dart
/// Purpose: The `Primary_Color` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PrimaryColor {
  /// Firestore field keys.
  static const String fieldPrimaryColor = 'Primary_Color';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? primaryColor;
  List<Timestamp?>? timestamps;
  PrimaryColor({
    this.primaryColor,
    this.timestamps,
  });

  PrimaryColor copyWith({
    List<String?>? primaryColor,
    List<Timestamp?>? timestamps,
  }) {
    return PrimaryColor(
      primaryColor: primaryColor ?? this.primaryColor,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldPrimaryColor: primaryColor,
      fieldTimestamp: timestamps,
    };
  }

  factory PrimaryColor.fromMap(Map<String, dynamic> map) {
    return PrimaryColor(
      primaryColor: map[fieldPrimaryColor] != null
          ? List<String?>.from(
              (map[fieldPrimaryColor]),
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

  factory PrimaryColor.fromJson(String source) =>
      PrimaryColor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PrimaryColor(Primary_Color: $primaryColor, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant PrimaryColor other) {
    if (identical(this, other)) return true;

    return listEquals(other.primaryColor, primaryColor) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => primaryColor.hashCode ^ timestamps.hashCode;
}
