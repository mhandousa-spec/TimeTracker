/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: role_model.dart
/// Purpose: Declares `Role`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Role {
  List<String?>? role;
  List<Timestamp?>? timestamps;
  Role({
    this.role,
    this.timestamps,
  });

  Role copyWith({
    List<String?>? role,
    List<Timestamp?>? timestamps,
  }) {
    return Role(
      role: role ?? this.role,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Role': role,
      'Timestamp': timestamps,
    };
  }

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      role: map['Role'] != null
          ? List<String?>.from(
              (map['Role']),
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

  factory Role.fromJson(String source) =>
      Role.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Role(Role: $role, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Role other) {
    if (identical(this, other)) return true;

    return listEquals(other.role, role) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => role.hashCode ^ timestamps.hashCode;
}
