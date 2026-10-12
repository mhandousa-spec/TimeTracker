import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// Date: 14/1/2025
// By: mohamed Mohy
// Last update: 18/1/2025
// Objectives: Enum representing different types of access management.
enum AccessManagement {
  openAccess,
  restrictedAccess,
  personalAccess,
}

/// Extension to provide additional functionalities to the AccessManagement enum.
extension AccessManagementExtension on AccessManagement {
  /// STABLE identifier — persisted on the form and compared against in
  /// `home_controller`, `create_form_data_cubit` and `publish_screen`.
  /// Deliberately NOT translated; see [label].
  String get name {
    switch (this) {
      case AccessManagement.personalAccess:
        return 'Personal Access';
      case AccessManagement.restrictedAccess:
        return 'Restricted Access';
      case AccessManagement.openAccess:
        return 'Open Access';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case AccessManagement.personalAccess:
        return s.personalAccess;
      case AccessManagement.restrictedAccess:
        return s.restrictedAccess;
      case AccessManagement.openAccess:
        return s.openAccess;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  ///
  /// ADDED 19/8/2026 — screens that read `formHeadModel.accessManagement`
  /// straight out of Firestore were printing the raw English value. Route it
  /// through here instead so the tag follows the locale. Unknown values are
  /// returned untouched rather than swallowed, so bad data stays visible.
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in AccessManagement.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }

  /// Returns the dropdown items for the enum.
  static List<DropdownMenuItem<String>> dropDownItems() {
    return AccessManagement.values.map((element) {
      return DropdownMenuItem<String>(
        value: element.name,
        child: Text(
          element.label,
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        ),
      );
    }).toList();
  }

  static List<String> dropDownStringItems() {
    return AccessManagement.values.map((element) {
      return element.name;
    }).toList();
  }
}
