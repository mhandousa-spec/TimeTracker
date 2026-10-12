// ***************************** FILE INFO ***************************** //
// File Name: branch_model.dart
// Purpose: Defines a localized HR shift-management branch.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:get/get.dart';

/// Represents a branch belonging to an HR shift-management location.
class BranchModel {
  const BranchModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.locationId,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String locationId;

  /// Method Name: [name]
  ///
  /// Purpose: Returns the branch name for the active application language.
  ///
  /// Returns: The Arabic or English branch name.
  String get name => Get.locale?.languageCode == 'ar' ? nameAr : nameEn;
}
