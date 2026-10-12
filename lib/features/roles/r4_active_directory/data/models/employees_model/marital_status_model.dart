/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: marital_status_model.dart
/// Purpose: Declares `MaritalStatus`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class MaritalStatus {
  List<String?>? maritalStatus;
  List<Timestamp?>? timestamps;
  MaritalStatus({
    this.maritalStatus,
    this.timestamps,
  });

  MaritalStatus copyWith({
    List<String?>? maritalStatus,
    List<Timestamp?>? timestamps,
  }) {
    return MaritalStatus(
      maritalStatus: maritalStatus ?? this.maritalStatus,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Marital_Status': maritalStatus,
      'Timestamp': timestamps,
    };
  }

  factory MaritalStatus.fromMap(Map<String, dynamic> map) {
    return MaritalStatus(
      maritalStatus: map['Marital_Status'] != null
          ? List<String?>.from(
              (map['Marital_Status']),
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

  factory MaritalStatus.fromJson(String source) =>
      MaritalStatus.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MaritalStatus(Marital_Status: $maritalStatus, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant MaritalStatus other) {
    if (identical(this, other)) return true;

    return listEquals(other.maritalStatus, maritalStatus) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => maritalStatus.hashCode ^ timestamps.hashCode;
}
