// ***************************** FILE INFO ***************************** //
// File Name: employee_details_row.dart
// Purpose: Defines shared employee identity and search behavior for detail rows.
// Author: Mohamed Elrashidy
// Created At: 2026-08-14
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

/// Base projection for an employee joined with feature-specific detail data.
abstract class EmployeeDetailsRow {
  const EmployeeDetailsRow({required this.employee});

  final HrEmployeeEntity employee;

  /// Employee identity values in the shared HR table-column order.
  List<String> get employeeIdentityValues => [
        employee.id ?? '',
        employee.firstName ?? '',
        employee.middleName ?? '',
        employee.lastName ?? '',
        employee.firstNameInArabic ?? '',
        employee.middleNameInArabic ?? '',
        employee.lastNameInArabic ?? '',
      ];

  /// Feature-specific values included in table-wide text search.
  List<String> get detailSearchValues;

  /// All normalized employee and feature values included in text search.
  List<String> get searchValues => [
        ...employeeIdentityValues,
        ...detailSearchValues,
      ];

  /// Method Name: [latestHistoryValue]
  ///
  /// Purpose: Selects the current value from an optional history list.
  ///
  /// Parameters:
  /// - [values]: Ordered history values, or null when details are unavailable.
  ///
  /// Returns: The latest value, or an empty string when none exists.
  String latestHistoryValue(List<String>? values) =>
      values?.isNotEmpty == true ? values!.last : '';
}
