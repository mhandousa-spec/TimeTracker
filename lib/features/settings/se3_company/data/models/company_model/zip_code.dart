/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: zip_code.dart
/// Purpose: The `Zip_Code` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ZipCode {
  /// Firestore field keys.
  static const String fieldZipCode = 'Zip_Code';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? zipCode;
  List<Timestamp?>? timestamps;
  ZipCode({
    this.zipCode,
    this.timestamps,
  });

  ZipCode copyWith({
    List<String?>? zipCode,
    List<Timestamp?>? timestamps,
  }) {
    return ZipCode(
      zipCode: zipCode ?? this.zipCode,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldZipCode: zipCode,
      fieldTimestamp: timestamps,
    };
  }

  factory ZipCode.fromMap(Map<String, dynamic> map) {
    return ZipCode(
      zipCode: map[fieldZipCode] != null
          ? List<String?>.from(
              (map[fieldZipCode]),
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

  factory ZipCode.fromJson(String source) =>
      ZipCode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ZipCode(Zip_Code: $zipCode, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant ZipCode other) {
    if (identical(this, other)) return true;

    return listEquals(other.zipCode, zipCode) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => zipCode.hashCode ^ timestamps.hashCode;
}
