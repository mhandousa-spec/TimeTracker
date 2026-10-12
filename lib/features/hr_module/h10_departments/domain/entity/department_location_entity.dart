// ***************************** FILE INFO ***************************** //
// File Name: department_location_entity.dart
// Purpose: Defines the latest Department location values for the UI layer.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

/// Represents the current user-facing values of a Department location.
class DepartmentLocationEntity {
  const DepartmentLocationEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.countryCode,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String countryCode;

  /// Method Name: [localizedName]
  ///
  /// Purpose: Resolves the location name for the active language.
  ///
  /// Parameters:
  /// - [languageCode]: Active application language code.
  ///
  /// Returns: The Arabic name for Arabic, otherwise the English name.
  String localizedName(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }
}
