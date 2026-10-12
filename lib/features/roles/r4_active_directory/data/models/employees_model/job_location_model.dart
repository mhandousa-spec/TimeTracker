/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: job_location_model.dart
/// Purpose: Declares `WorkLocation`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class WorkLocation {
  List<String?>? workLocation;
  List<Timestamp?>? timestamps;
  WorkLocation({
    this.workLocation,
    this.timestamps,
  });

  WorkLocation copyWith({
    List<String?>? workLocation,
    List<Timestamp?>? timestamps,
  }) {
    return WorkLocation(
      workLocation: workLocation ?? this.workLocation,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Work_Location': workLocation,
      'Timestamp': timestamps,
    };
  }

  factory WorkLocation.fromMap(Map<String, dynamic> map) {
    return WorkLocation(
      workLocation: map['Work_Location'] != null
          ? List<String?>.from(
              (map['Work_Location']),
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

  factory WorkLocation.fromJson(String source) =>
      WorkLocation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'WorkLocation(Work_Location: $workLocation, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant WorkLocation other) {
    if (identical(this, other)) return true;

    return listEquals(other.workLocation, workLocation) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => workLocation.hashCode ^ timestamps.hashCode;
}
