// ***************************** FILE INFO ***************************** //
// File Name: employee_operations.dart
// Purpose: Defines localized employee operation options for HR actions.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:knowticed_plus/generated/l10n.dart';

/// Defines the actions available from the HR employee operations button.
enum EmployeeOperation {
  addEmployee,
  bulkUpload;

  /// Method Name: [title]
  ///
  /// Purpose: Resolves the localized label displayed in the employee popup.
  ///
  /// Returns: The localized operation label.
  String get title {
    switch (this) {
      case EmployeeOperation.addEmployee:
        return S.current.addEmployee;
      case EmployeeOperation.bulkUpload:
        return S.current.bulkUpload;
    }
  }

  /// Method Name: [value]
  ///
  /// Purpose: Provides a stable value for the shared popup menu component.
  ///
  /// Returns: The persistent operation identifier.
  String get value {
    switch (this) {
      case EmployeeOperation.addEmployee:
        return 'add_employee';
      case EmployeeOperation.bulkUpload:
        return 'bulk_upload';
    }
  }

  /// Method Name: [fromValue]
  ///
  /// Purpose: Resolves a popup selection into its typed employee operation.
  ///
  /// Parameters:
  /// - [value]: The selected popup option identifier.
  ///
  /// Returns: The matching operation, or null for an unknown identifier.
  static EmployeeOperation? fromValue(String value) {
    for (final operation in values) {
      if (operation.value == value) return operation;
    }
    return null;
  }
}
