/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_directory_model.dart
/// Purpose: One row of the employee directory collection.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SEMAIN-N21: fields are final, the Firestore
///          keys are `static const`, `copyWith` added, `Department` moved to
///          its own file, and the instance method `fromJson` — which returned
///          a raw `Map` instead of a model — replaced with a real factory.
///
/// Ported into services_app under features/settings (source: services_app
/// features/employees/data/models/employee_model/employee_directory_model.dart).

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/email_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/first_name_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/last_name_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/supervisor_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/models/department_model.dart';

export 'package:knowticed_plus/features/settings/main_controller/data/models/department_model.dart';

@immutable
class EmployeeDirectoryModel {
  const EmployeeDirectoryModel({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.department,
    this.supervisor,
    this.dateAdded,
  });

  /// Firestore field keys. Previously inlined as string literals in both
  /// [fromMap] and [toMap], so a rename had to be made twice (§10).
  static const String fieldFirstName = 'First_Name';
  static const String fieldLastName = 'Last_Name';
  static const String fieldEmail = 'Email';
  static const String fieldPhone = 'Phone';
  static const String fieldDepartment = 'Department';
  static const String fieldSupervisor = 'Supervisor';
  static const String fieldDateAdded = 'Date_Added';

  final FirstName? firstName;
  final LastName? lastName;
  final Email? email;
  final MobilePhone? phone;
  final Department? department;
  final Supervisor? supervisor;
  final String? dateAdded;

  EmployeeDirectoryModel copyWith({
    FirstName? firstName,
    LastName? lastName,
    Email? email,
    MobilePhone? phone,
    Department? department,
    Supervisor? supervisor,
    String? dateAdded,
  }) {
    return EmployeeDirectoryModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      supervisor: supervisor ?? this.supervisor,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  factory EmployeeDirectoryModel.fromMap(Map<dynamic, dynamic>? data) {
    return EmployeeDirectoryModel(
      firstName: FirstName.fromMap(data?[fieldFirstName]),
      lastName: LastName.fromMap(data?[fieldLastName]),
      email: Email.fromMap(data?[fieldEmail]),
      phone: MobilePhone.fromMap(data?[fieldPhone]),
      department: Department.fromMap(
        (data?[fieldDepartment] as Map<dynamic, dynamic>?)
            ?.cast<String, dynamic>(),
      ),
      supervisor: Supervisor.fromMap(data?[fieldSupervisor]),
      dateAdded: data?[fieldDateAdded] as String?,
    );
  }

  /// The write stamps `Date_Added` with "now" on purpose: the directory row
  /// records when it was last written, not when the model was built.
  Map<String, dynamic> toMap() => <String, dynamic>{
        fieldFirstName: firstName?.toMap(),
        fieldLastName: lastName?.toMap(),
        fieldEmail: email?.toMap(),
        fieldPhone: phone?.toMap(),
        fieldDepartment: department?.toMap(),
        fieldSupervisor: supervisor?.toMap(),
        fieldDateAdded: DateTime.now().toString(),
      };

  String toJson() => json.encode(toMap());

  /// Was an *instance* method returning the decoded `Map` — so
  /// `model.fromJson(s)` handed back a map, never a model, and the result was
  /// unusable as one. Now a factory, matching [Department.fromJson].
  factory EmployeeDirectoryModel.fromJson(String source) =>
      EmployeeDirectoryModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'EmployeeDirectoryModel($fieldFirstName: $firstName, '
      '$fieldLastName: $lastName, $fieldEmail: $email, $fieldPhone: $phone, '
      '$fieldDepartment: $department, $fieldSupervisor: $supervisor, '
      '$fieldDateAdded: $dateAdded)';
}
