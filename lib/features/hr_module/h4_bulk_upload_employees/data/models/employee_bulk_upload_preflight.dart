// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_preflight.dart
// Purpose: Holds immutable Firebase lookup values for employee validation.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import '../../../../roles/r4_active_directory/data/models/department_model.dart';

/// Database lookup values required to validate an employee workbook.
class EmployeeBulkUploadPreflight {
  EmployeeBulkUploadPreflight({
    required Set<String> employeeIds,
    required Set<String> employeeEmails,
    required Set<String> activeRoles,
    Map<String, DepartmentModelPro> departmentsById = const {},
  })  : employeeIds = Set.unmodifiable(employeeIds),
        employeeEmails = Set.unmodifiable(employeeEmails),
        activeRoles = Set.unmodifiable(activeRoles),
        departmentsById = Map.unmodifiable(departmentsById);

  final Set<String> employeeIds;
  final Set<String> employeeEmails;
  final Set<String> activeRoles;
  final Map<String, DepartmentModelPro> departmentsById;
}
