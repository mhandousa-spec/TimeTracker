/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: driving_license_id.dart
/// Purpose: Declares `DrivingLicenseId`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class DrivingLicenseId {
  List<String?>? drivingLicenseId;
  List<Timestamp?>? timestamps;
  DrivingLicenseId({
    this.drivingLicenseId,
    this.timestamps,
  });

  DrivingLicenseId copyWith({
    List<String?>? drivingLicenseId,
    List<Timestamp?>? timestamps,
  }) {
    return DrivingLicenseId(
      drivingLicenseId: drivingLicenseId ?? this.drivingLicenseId,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Driving_License_Id': drivingLicenseId,
      'Timestamp': timestamps,
    };
  }

  factory DrivingLicenseId.fromMap(Map<String, dynamic> map) {
    return DrivingLicenseId(
      drivingLicenseId: map['Driving_License_Id'] != null
          ? List<String?>.from(
              (map['Driving_License_Id']),
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

  factory DrivingLicenseId.fromJson(String source) =>
      DrivingLicenseId.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DrivingLicenseId(Driving_License_Id: $drivingLicenseId, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant DrivingLicenseId other) {
    if (identical(this, other)) return true;

    return listEquals(other.drivingLicenseId, drivingLicenseId) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => drivingLicenseId.hashCode ^ timestamps.hashCode;
}
