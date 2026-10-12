// ***************************** FILE INFO ***************************** //
// File Name: location_model.dart
// Purpose: Defines a localized HR shift-management location.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:get/get.dart';

/// Represents a location used by HR shift management.
class LocationModel {
  const LocationModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  /// Method Name: [name]
  ///
  /// Purpose: Returns the location name for the active application language.
  ///
  /// Returns: The Arabic or English location name.
  String get name => Get.locale?.languageCode == 'ar' ? nameAr : nameEn;
}
