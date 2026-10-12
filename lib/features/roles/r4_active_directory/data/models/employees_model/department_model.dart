/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: department_model.dart
/// Purpose: Declares `DepartmentId`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class DepartmentId {
  List<String?>? departmentId;
  List<Timestamp?>? timestamps;
  DepartmentId({
    this.departmentId,
    this.timestamps,
  });

  DepartmentId copyWith({
    List<String?>? departmentId,
    List<Timestamp?>? timestamps,
  }) {
    return DepartmentId(
      departmentId: departmentId ?? this.departmentId,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Department_Id': departmentId,
      'Timestamp': timestamps,
    };
  }

  factory DepartmentId.fromMap(Map<String, dynamic> map) {
    return DepartmentId(
      departmentId: map['Department_Id'] != null
          ? List<String?>.from(
              (map['Department_Id']),
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

  factory DepartmentId.fromJson(String source) =>
      DepartmentId.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Department_Id(Department_Id: $departmentId, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant DepartmentId other) {
    if (identical(this, other)) return true;

    return listEquals(other.departmentId, departmentId) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => departmentId.hashCode ^ timestamps.hashCode;
}
