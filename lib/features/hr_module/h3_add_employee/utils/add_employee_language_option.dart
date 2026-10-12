// ***************************** FILE INFO ***************************** //
// File Name: add_employee_language_option.dart
// Purpose: Defines localized language options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

/// Defines the language values accepted by the add-employee form.
enum LanguageOption {
  arabic,
  english,
  indian,
  german,
  french,
  turkish,
  persian,
  hebrew,
  kurdish,
  urdu,
  hindi,
  malayalam,
  bengali,
  tagalog;

  /// Serializes selected language values using the bulk-upload delimiter.
  static String commaSeparated(Iterable<LanguageOption> options) =>
      options.map((option) => option.value).join(', ');

  /// Method Name: [value]
  ///
  /// Purpose: Provides the stable value stored by the form.
  ///
  /// Returns: The canonical language value.
  String get value => name;

  /// Method Name: [title]
  ///
  /// Purpose: Provides the localized display label.
  ///
  /// Returns: The localized language label.
  String get title {
    switch (this) {
      case LanguageOption.arabic:
        return S.current.arabicLanguage;
      case LanguageOption.english:
        return S.current.english;
      case LanguageOption.indian:
        return S.current.indian;
      case LanguageOption.german:
        return S.current.german;
      case LanguageOption.french:
        return S.current.french;
      case LanguageOption.turkish:
        return S.current.turkish;
      case LanguageOption.persian:
        return S.current.persianLanguage;
      case LanguageOption.hebrew:
        return S.current.hebrewLanguage;
      case LanguageOption.kurdish:
        return S.current.kurdishLanguage;
      case LanguageOption.urdu:
        return S.current.urduLanguage;
      case LanguageOption.hindi:
        return S.current.hindiLanguage;
      case LanguageOption.malayalam:
        return S.current.malayalamLanguage;
      case LanguageOption.bengali:
        return S.current.bengaliLanguage;
      case LanguageOption.tagalog:
        return S.current.tagalogLanguage;
    }
  }
}
