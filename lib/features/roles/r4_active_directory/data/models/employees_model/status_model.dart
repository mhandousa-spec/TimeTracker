/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: status_model.dart
/// Purpose: Declares `Status`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Status {
  List<String?>? status;
  List<Timestamp?>? timestamps;
  Status({
    this.status,
    this.timestamps,
  });

  Status copyWith({
    List<String?>? status,
    List<Timestamp?>? timestamps,
  }) {
    return Status(
      status: status ?? this.status,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Status': status,
      'Timestamp': timestamps,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      status: map['Status'] != null
          ? List<String?>.from(
              (map['Status']),
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

  factory Status.fromJson(String source) =>
      Status.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Status(Status: $status, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Status other) {
    if (identical(this, other)) return true;

    return listEquals(other.status, status) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => status.hashCode ^ timestamps.hashCode;
}
