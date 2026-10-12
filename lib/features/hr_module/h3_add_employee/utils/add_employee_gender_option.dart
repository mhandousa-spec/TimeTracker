// ***************************** FILE INFO ***************************** //
// File Name: add_employee_gender_option.dart
// Purpose: Defines localized gender options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

/// Defines the gender values accepted by the add-employee form.
enum GenderOption {
  male,
  female;

  /// Method Name: [value]
  ///
  /// Purpose: Provides the stable value stored by the form.
  ///
  /// Returns: The canonical gender value.
  String get value => name;

  /// Method Name: [title]
  ///
  /// Purpose: Provides the localized display label.
  ///
  /// Returns: The localized gender label.
  String get title {
    switch (this) {
      case GenderOption.male:
        return S.current.male;
      case GenderOption.female:
        return S.current.female;
    }
  }
}
