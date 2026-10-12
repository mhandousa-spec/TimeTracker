// ***************************** FILE INFO ***************************** //
// File Name: add_employee_step.dart
// Purpose: Defines the ordered steps in the add-employee flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'package:knowticed_plus/generated/l10n.dart';

/// Identifies each page in the add-employee flow.
enum AddEmployeeStep {
  personalInformation,
  contactDetails,
  addressDetails,
  identificationDetails,
  positionDetails,
  certificationDetails,
  insuranceDetails,
  emergencyDetails;

  /// Method Name: [title]
  ///
  /// Purpose: Resolves the localized title for this add-employee step.
  ///
  /// Returns: The localized step title.
  String get title {
    switch (this) {
      case AddEmployeeStep.personalInformation:
        return S.current.personalInformation;
      case AddEmployeeStep.contactDetails:
        return S.current.contactDetails;
      case AddEmployeeStep.addressDetails:
        return S.current.addressDetails;
      case AddEmployeeStep.identificationDetails:
        return S.current.identificationDetails;
      case AddEmployeeStep.positionDetails:
        return S.current.positionDetails;
      case AddEmployeeStep.certificationDetails:
        return S.current.certificationDetails;
      case AddEmployeeStep.insuranceDetails:
        return S.current.insuranceDetails;
      case AddEmployeeStep.emergencyDetails:
        return S.current.emergencyDetails;
    }
  }

  /// Method Name: [fromIndex]
  ///
  /// Purpose: Resolves a step index without allowing an invalid selection.
  ///
  /// Parameters:
  /// - [index]: The requested zero-based step index.
  ///
  /// Returns: The matching step, or the first step when the index is invalid.
  static AddEmployeeStep fromIndex(int index) {
    if (index < 0 || index >= values.length) {
      return personalInformation;
    }
    return values[index];
  }
}
