// ***************************** FILE INFO ***************************** //
// File Name: add_employee_marital_status_option.dart
// Purpose: Defines localized marital-status options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

/// Defines the marital-status values accepted by the add-employee form.
enum MaritalStatusOption {
  single,
  married,
  divorced,
  widowed;

  /// Method Name: [value]
  ///
  /// Purpose: Provides the stable value stored by the form.
  ///
  /// Returns: The canonical marital-status value.
  String get value => name;

  /// Method Name: [title]
  ///
  /// Purpose: Provides the localized display label.
  ///
  /// Returns: The localized marital-status label.
  String get title {
    switch (this) {
      case MaritalStatusOption.single:
        return S.current.single;
      case MaritalStatusOption.married:
        return S.current.married;
      case MaritalStatusOption.divorced:
        return S.current.divorced;
      case MaritalStatusOption.widowed:
        return S.current.widowed;
    }
  }
}
