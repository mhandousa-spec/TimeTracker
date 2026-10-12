/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: province_model.dart
/// Purpose: Declares `Province`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Province {
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
      'Province': province,
      'Timestamp': timestamps,
    };
  }

  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      province: map['Province'] != null
          ? List<String?>.from(
              (map['Province']),
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
