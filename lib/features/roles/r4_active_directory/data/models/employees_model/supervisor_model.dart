/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: supervisor_model.dart
/// Purpose: Declares `Supervisor`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Supervisor {
  List<String?>? supervisors;

  List<Timestamp?>? timestamps;
  Supervisor({
    this.supervisors,
    this.timestamps,
  });

  Supervisor copyWith({
    List<String?>? supervisors,
    List<Timestamp?>? timestamps,
  }) {
    return Supervisor(
      supervisors: supervisors ?? this.supervisors,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Supervisor': supervisors,
      'Timestamp': timestamps,
    };
  }

  factory Supervisor.fromMap(Map<String, dynamic> map) {
    return Supervisor(
      supervisors: map['Supervisor'] != null
          ? List<String?>.from(
              (map['Supervisor']),
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

  factory Supervisor.fromJson(String source) =>
      Supervisor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Supervisor(Supervisor: $supervisors, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Supervisor other) {
    if (identical(this, other)) return true;

    return listEquals(other.supervisors, supervisors) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => supervisors.hashCode ^ timestamps.hashCode;
}
