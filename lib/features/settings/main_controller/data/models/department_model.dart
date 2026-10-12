/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: department_model.dart
/// Purpose: The department history entry embedded in an employee directory row.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SEMAIN-N21: split out of
///          `employee_directory_model.dart` (two classes in one model file),
///          fields made final, and the Firestore keys lifted into
///          `static const` so no call site retypes the string.
///
/// NOTE: this class is deliberately NOT the `DepartmentId` model under
/// features/roles/r4_active_directory/data/models/employees_model/department_model.dart.
/// That one uses a different field name and a different Firestore key
/// ("Department_Id" vs "Department"), so the two are not interchangeable.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Department {
  const Department({
    this.department,
    this.timestamps,
  });

  /// Firestore field keys. Previously inlined as string literals at every use
  /// site (§10).
  static const String fieldDepartment = 'Department';
  static const String fieldTimestamp = 'Timestamp';

  final List<String?>? department;
  final List<Timestamp?>? timestamps;

  Department copyWith({
    List<String?>? department,
    List<Timestamp?>? timestamps,
  }) {
    return Department(
      department: department ?? this.department,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldDepartment: department,
      fieldTimestamp: timestamps,
    };
  }

  factory Department.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Department();
    return Department(
      department: map[fieldDepartment] != null
          ? List<String?>.from(map[fieldDepartment] as Iterable<dynamic>)
          : null,
      timestamps: map[fieldTimestamp] != null
          ? List<Timestamp?>.from(map[fieldTimestamp] as Iterable<dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Department.fromJson(String source) =>
      Department.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Department(Department: $department, Timestamp: $timestamps)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Department &&
        listEquals(other.department, department) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(department ?? const <String?>[]),
        Object.hashAll(timestamps ?? const <Timestamp?>[]),
      );
}
