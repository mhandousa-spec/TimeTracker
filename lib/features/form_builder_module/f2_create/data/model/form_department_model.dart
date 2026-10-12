import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of form department model
class FormDepartmentModel {
  List<String?>? departments;
  List<Timestamp?>? timestamps;
  FormDepartmentModel({
    this.departments,
    this.timestamps,
  });

  FormDepartmentModel copyWith({
    List<String?>? departments,
    List<Timestamp?>? timestamps,
  }) {
    return FormDepartmentModel(
      departments: departments ?? this.departments,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Department': departments,
      'Timestamp': timestamps,
    };
  }

  factory FormDepartmentModel.fromMap(Map<String, dynamic> map) {
    return FormDepartmentModel(
      departments: map['Department'] != null
          ? List<String?>.from(
              (map['Department']),
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

  factory FormDepartmentModel.fromJson(String source) =>
      FormDepartmentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'FormDepartmentModel(Department: $departments, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant FormDepartmentModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.departments, departments) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => departments.hashCode ^ timestamps.hashCode;
}
