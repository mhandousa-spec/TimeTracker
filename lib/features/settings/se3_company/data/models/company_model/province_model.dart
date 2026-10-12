/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: province_model.dart
/// Purpose: The `Province` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Province {
  /// Firestore field keys.
  static const String fieldProvince = 'Province';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? province;
  List<Timestamp?>? timestamps;
  Province({
    this.province,
    this.timestamps,
  });

  Province copyWith({
    List<String?>? province,
    List<Timestamp?>? timestamps,
  }) {
    return Province(
      province: province ?? this.province,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldProvince: province,
      fieldTimestamp: timestamps,
    };
  }

  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      province: map[fieldProvince] != null
          ? List<String?>.from(
              (map[fieldProvince]),
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

  factory Province.fromJson(String source) =>
      Province.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Province(Province: $province, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Province other) {
    if (identical(this, other)) return true;

    return listEquals(other.province, province) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => province.hashCode ^ timestamps.hashCode;
}
