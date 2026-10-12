import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// Date: 14/1/2025
// By: mohamed Mohy
// Last update: 18/1/2025
// Objectives: Enum representing different types of orientations.
enum OrientationEnum {
  landscape,
  portrait,
}

/// Extension to provide additional functionalities to the OrientationEnum enum.
extension OrientationExtension on OrientationEnum {
  /// STABLE identifier — persisted on the form. NOT translated; see [label].
  String get name {
    switch (this) {
      case OrientationEnum.landscape:
        return 'Landscape';
      case OrientationEnum.portrait:
        return 'Portrait';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case OrientationEnum.landscape:
        return s.orientationLandscape;
      case OrientationEnum.portrait:
        return s.orientationPortrait;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in OrientationEnum.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }

  /// Returns the dropdown items for the enum.
  static List<DropdownMenuItem<String>> get dropDownItems {
    return OrientationEnum.values.map((element) {
      return DropdownMenuItem<String>(
        value: element.name,
        child: Text(
          element.label,
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        ),
      );
    }).toList();
  }
}
