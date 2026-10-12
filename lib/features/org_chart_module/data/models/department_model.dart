// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

// date:January/10/2024
// by:MohamedFouad
// lastUpdate:April/18/2024

class DepartmentModel {
  List<String>? departments;
  List<String>? departmentsInArabic;

  DepartmentModel({
    this.departments,
    this.departmentsInArabic,
  });

  factory DepartmentModel.fromMap(Map data) {
    return DepartmentModel(
      departments: List<String>.from(data['Departments']),
      departmentsInArabic: List<String>.from(data['Departments_In_Arabic']),
    );
  }

  Map<String, dynamic> toMap() => {
        'Departments': departments,
        'Departments_In_Arabic': departmentsInArabic,
      };

  String toJson() => json.encode(toMap());
  Map<String, dynamic> fromJson(String jsonString) => json.decode(jsonString);
}
