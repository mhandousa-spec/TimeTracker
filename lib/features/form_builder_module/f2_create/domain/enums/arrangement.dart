import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// Date: 14/1/2025
// By: mohamed Mohy
// Last update: 18/1/2025
// Objectives: Enum representing different types of arrangements.
enum Arrangement {
  vertical,
  horizontal,
}

/// Extension to provide additional functionalities to the Arrangement enum.
extension ArrangementExtension on Arrangement {
  /// STABLE identifier — persisted on the field. NOT translated; see [label].
  String get name {
    switch (this) {
      case Arrangement.vertical:
        return 'Vertical';
      case Arrangement.horizontal:
        return 'Horizontal';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case Arrangement.vertical:
        return s.arrangementVertical;
      case Arrangement.horizontal:
        return s.arrangementHorizontal;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in Arrangement.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }

  /// Returns the dropdown items for the enum.
  static List<DropdownMenuItem<String>> get dropDownItems {
    return Arrangement.values.map((element) {
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
