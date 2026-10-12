/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: postal_code_model.dart
/// Purpose: Declares `PostalCode`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class PostalCode {
  List<String?>? postalCode;
  List<Timestamp?>? timestamps;
  PostalCode({
    this.postalCode,
    this.timestamps,
  });

  PostalCode copyWith({
    List<String?>? postalCode,
    List<Timestamp?>? timestamps,
  }) {
    return PostalCode(
      postalCode: postalCode ?? this.postalCode,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Postal_Code': postalCode,
      'Timestamp': timestamps,
    };
  }

  factory PostalCode.fromMap(Map<String, dynamic> map) {
    return PostalCode(
      postalCode: map['Postal_Code'] != null
          ? List<String?>.from(
              (map['Postal_Code']),
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

  factory PostalCode.fromJson(String source) =>
      PostalCode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PostalCode(Postal_Code: $postalCode, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant PostalCode other) {
    if (identical(this, other)) return true;

    return listEquals(other.postalCode, postalCode) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => postalCode.hashCode ^ timestamps.hashCode;
}
