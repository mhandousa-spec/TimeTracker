// ***************************** FILE INFO ***************************** //
// File Name: employee_details_tabs.dart
// Purpose: Defines localized tabs for the employee details page.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import '../../../../../generated/l10n.dart';

/// Defines the read-only employee profile areas.
enum EmployeeDetailsTabs {
  personalInformation,
  services,
  tasks,
  attendance,
  assets;

  /// Method Name: [title]
  ///
  /// Purpose: Resolves the localized label displayed in the details tabs.
  ///
  /// Returns: A centralized localized tab title.
  String get title {
    switch (this) {
      case EmployeeDetailsTabs.personalInformation:
        return S.current.personalInformation;
      case EmployeeDetailsTabs.services:
        return S.current.services;
      case EmployeeDetailsTabs.tasks:
        return S.current.tasks;
      case EmployeeDetailsTabs.attendance:
        return S.current.attendance;
      case EmployeeDetailsTabs.assets:
        return S.current.assets;
    }
  }

  /// Method Name: [fromIndex]
  ///
  /// Purpose: Safely resolves a tab from its selected index.
  ///
  /// Parameters:
  /// - [index]: Selected tab index.
  ///
  /// Returns: The matching tab or personal information for an invalid index.
  static EmployeeDetailsTabs fromIndex(int index) {
    if (index < 0 || index >= values.length) return personalInformation;
    return values[index];
  }
}
