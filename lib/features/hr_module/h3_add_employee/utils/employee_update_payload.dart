// ***************************** FILE INFO ***************************** //
// File Name: employee_update_payload.dart
// Purpose: Carries one selected employee section through the update boundary.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'add_employee_step.dart';

/// Immutable update data produced by the reusable employee edit form.
class EmployeeUpdatePayload {
  const EmployeeUpdatePayload({
    required this.employeeId,
    required this.section,
    required this.values,
    this.profileImage,
    this.passportDocument,
    this.nationalIdFrontDocument,
    this.nationalIdBackDocument,
    this.drivingLicenseDocument,
    this.certificationDocument,
  });

  final String employeeId;
  final AddEmployeeStep section;
  final Map<String, dynamic> values;
  final File? profileImage;
  final File? passportDocument;
  final File? nationalIdFrontDocument;
  final File? nationalIdBackDocument;
  final File? drivingLicenseDocument;
  final PlatformFile? certificationDocument;
}
