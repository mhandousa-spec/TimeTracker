// ***************************** FILE INFO ***************************** //
// File Name: employee_filter_model.dart
// Purpose: Defines employee filter values and localized filter options.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

/// Immutable employee filter values submitted by the filter dialog.
class EmployeeFilterModel {
  const EmployeeFilterModel({
    this.departmentId,
    this.jobTitle,
    this.startDate,
  });

  final String? departmentId;
  final String? jobTitle;
  final DateTime? startDate;

  /// Whether no employee filters are currently selected.
  bool get isEmpty =>
      departmentId == null && jobTitle == null && startDate == null;
}

/// A stable filter value with a localized display label.
class EmployeeFilterOption {
  const EmployeeFilterOption({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}
