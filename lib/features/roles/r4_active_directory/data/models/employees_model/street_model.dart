/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: street_model.dart
/// Purpose: Declares `Street`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Street {
  List<String?>? street;
  List<Timestamp?>? timestamps;
  Street({
    this.street,
    this.timestamps,
  });

  Street copyWith({
    List<String?>? street,
    List<Timestamp?>? timestamps,
  }) {
    return Street(
      street: street ?? this.street,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Street': street,
      'Timestamp': timestamps,
    };
  }

  factory Street.fromMap(Map<String, dynamic> map) {
    return Street(
      street: map['Street'] != null
          ? List<String?>.from(
              (map['Street']),
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

  factory Street.fromJson(String source) =>
      Street.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Street(Street: $street, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Street other) {
    if (identical(this, other)) return true;

    return listEquals(other.street, street) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => street.hashCode ^ timestamps.hashCode;
}
