// ***************************** FILE INFO ***************************** //
// File Name: employee_main_tabs.dart
// Purpose: Defines HR employee module tabs and their page mappings.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../presentation/ui/pages/certifications_tab_page.dart';
import '../../../presentation/ui/pages/emergency_contacts_tab_page.dart';
import '../../../presentation/ui/pages/employees_tab_page.dart';
import '../../../presentation/ui/pages/health_insurance_tab_page.dart';
import '../../../presentation/ui/pages/salary_tab_page.dart';

enum EmployeeMainTabs {
  employees,
  healthInsurance,
  emergencyContacts,
  salaries,
  certifications;

  /// Method Name: [title]
  ///
  /// Purpose: Resolves the localized label for the main employee tab.
  ///
  /// Returns: A centralized localization value for this tab.
  String get title {
    switch (this) {
      case EmployeeMainTabs.employees:
        return S.current.employees;
      case EmployeeMainTabs.healthInsurance:
        return S.current.healthInsurance;
      case EmployeeMainTabs.emergencyContacts:
        return S.current.emergencyContact;
      case EmployeeMainTabs.salaries:
        return S.current.salary;
      case EmployeeMainTabs.certifications:
        return S.current.certificate;
    }
  }

  /// Method Name: [widget]
  ///
  /// Purpose: Creates the page associated with this main employee tab.
  ///
  /// Returns: The matching employee tab page.
  Widget get widget {
    switch (this) {
      case EmployeeMainTabs.employees:
        return const EmployeesTabPage();
      case EmployeeMainTabs.healthInsurance:
        return const HealthInsuranceTabPage();
      case EmployeeMainTabs.emergencyContacts:
        return const EmergencyContactsTabPage();
      case EmployeeMainTabs.salaries:
        return const SalaryTabPage();
      case EmployeeMainTabs.certifications:
        return const CertificationsTabPage();
    }
  }

  /// Method Name: [fromIndex]
  ///
  /// Purpose: Safely resolves a main tab enum value from a selected index.
  ///
  /// Parameters:
  /// - [index]: Selected main tab index.
  ///
  /// Returns: The matching tab, or [employees] for an invalid index.
  static EmployeeMainTabs fromIndex(int index) {
    if (index < 0 || index >= values.length) return employees;
    return values[index];
  }
}
