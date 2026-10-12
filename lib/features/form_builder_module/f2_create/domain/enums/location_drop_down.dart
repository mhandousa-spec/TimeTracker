import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// Date: 14/1/2025
// By: mohamed Mohy
// Last update: 18/1/2025
// Objectives:  Enum representing different types of location dropdown options.
enum LocationDropDown {
  latitudeAndLongitude,
  link,
}

/// Extension to provide additional functionalities to the LocationDropDown enum.
extension LocationDropDownExtension on LocationDropDown {
  /// STABLE identifier — persisted on the field and parsed back by [fromName].
  /// NOT translated; see [label].
  String get name {
    switch (this) {
      case LocationDropDown.latitudeAndLongitude:
        return 'Latitude And Longitude';
      case LocationDropDown.link:
        return 'Link';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case LocationDropDown.latitudeAndLongitude:
        return s.latitudeAndLongitude;
      case LocationDropDown.link:
        return s.fieldTypeLink;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in LocationDropDown.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }

  /// Returns an enum item based on its name.
  static LocationDropDown? fromName(String name) {
    return LocationDropDown.values.firstWhere((element) => element.name == name,
        orElse: () => LocationDropDown.latitudeAndLongitude);
  }

  /// Returns the dropdown items for the enum.
  static List<DropdownMenuItem<String>> get dropDownItems {
    return LocationDropDown.values.map((element) {
      return DropdownMenuItem<String>(
        value: element.name,
        child: Text(
          element.label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
        ),
      );
    }).toList();
  }
}
