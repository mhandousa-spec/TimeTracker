import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// Date: 14/1/2025
// By: mohamed Mohy
// Last update: 18/1/2025
// Objectives: Enum representing different types of alignments.
enum AlignmentEnum {
  left,
  right,
  center,
  expand,
}

/// Extension to provide additional functionalities to the AlignmentEnum enum.
extension AlignmentEnumExtension on AlignmentEnum {
  /// STABLE identifier — persisted on the field and parsed back by
  /// [AlignmentFromStringExtension.alignment]. NOT translated; see [label].
  String get name {
    switch (this) {
      case AlignmentEnum.left:
        return 'Left';
      case AlignmentEnum.right:
        return 'Right';
      case AlignmentEnum.center:
        return 'Center';
      case AlignmentEnum.expand:
        return 'Expand';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case AlignmentEnum.left:
        return s.alignmentLeft;
      case AlignmentEnum.right:
        return s.alignmentRight;
      case AlignmentEnum.center:
        return s.alignmentCenter;
      case AlignmentEnum.expand:
        return s.alignmentExpand;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in AlignmentEnum.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }

  /// Returns the dropdown items for the enum.
  static List<DropdownMenuItem<String>> get dropDownItems {
    return AlignmentEnum.values.map((element) {
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

/// Extension to provide alignment conversion from string.
extension AlignmentFromStringExtension on String {
  /// Returns the alignment corresponding to the string.
  Alignment get alignment {
    final value = this; // Store the current value

    if (value == 'Left') {
      return Alignment.centerLeft;
    } else if (value == 'Right') {
      return Alignment.centerRight;
    } else if (value == 'Center') {
      return Alignment.center;
    } else if (value == 'Expand') {
      return Alignment.centerLeft;
    }
    return Alignment.center;
  }
}
