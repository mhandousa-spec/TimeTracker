/// Module: todo / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: todo_priority.dart
/// Purpose: Declares `TodoPriority` — the High / Medium / Low a to-do carries.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma: LIST TO DO → priority chips under the search bar (All · ⚠ High ·
/// ↑ Medium · ↓ Low) and the Priority dropdown on Creating To Do List.
///
/// ⚠️ [storageKey] is what Firestore stores. Renaming a constant is free;
/// renaming its storage key orphans every to-do already written with it.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';

enum TodoPriority {
  high('high', 'assets/icons_assets/home_assets/priority_high_red.svg', 0),
  medium(
    'medium',
    'assets/icons_assets/home_assets/priority_medium_important.svg',
    1,
  ),
  low('low', 'assets/icons_assets/home_assets/priority_low_blue.svg', 2);

  const TodoPriority(this.storageKey, this.iconPath, this.rank);

  /// Value written to the `priority` field.
  final String storageKey;

  /// Icon drawn in front of the label on the priority chip.
  final String iconPath;

  /// Sort weight — High first.
  final int rank;

  /// Function Name: [label]
  ///
  /// Purpose: Localised label for chips and the dropdown.
  ///
  /// Parameters:
  ///   [BuildContext] context: used to resolve `S.of(context)`.
  ///
  /// Return type: [String] — the localised "High" / "Medium" / "Low".
  String label(BuildContext context) {
    switch (this) {
      case TodoPriority.high:
        return S.of(context).high;
      case TodoPriority.medium:
        return S.of(context).medium;
      case TodoPriority.low:
        return S.of(context).low;
    }
  }

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown or missing reads as [medium] so an
  /// old or hand-edited document still renders instead of throwing.
  ///
  /// Parameters:
  ///   [String?] key: the raw Firestore value.
  ///
  /// Return type: [TodoPriority]
  static TodoPriority fromStorageKey(String? key) {
    for (final TodoPriority value in TodoPriority.values) {
      if (value.storageKey == key) return value;
    }
    return TodoPriority.medium;
  }
}
