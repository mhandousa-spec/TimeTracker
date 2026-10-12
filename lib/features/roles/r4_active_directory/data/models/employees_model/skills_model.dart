/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: skills_model.dart
/// Purpose: Declares `Skills`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Skills {
  List<String?>? skills;
  List<String?>? status;
  List<Timestamp?>? timestamps;
  Skills({
    this.skills,
    this.status,
    this.timestamps,
  });

  Skills copyWith({
    List<String?>? skills,
    List<String?>? status,
    List<Timestamp?>? timestamps,
  }) {
    return Skills(
      skills: skills ?? this.skills,
      status: status ?? this.status,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Skills': skills,
      'Status': status,
      'Timestamp': timestamps,
    };
  }

  factory Skills.fromMap(Map<String, dynamic> map) {
    return Skills(
      skills: map['Skills'] != null
          ? List<String?>.from(
              (map['Skills']),
            )
          : null,
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

  factory Skills.fromJson(String source) =>
      Skills.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Skills(Skills: $skills, Status: $status,  Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Skills other) {
    if (identical(this, other)) return true;

    return listEquals(other.skills, skills) &&
        listEquals(other.status, status) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => skills.hashCode ^ status.hashCode ^ timestamps.hashCode;
}
