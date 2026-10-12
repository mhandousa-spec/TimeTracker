/// Module: todo / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: todo_time_unit.dart
/// Purpose: Declares `TodoReminderUnit` (Hour / Day / Week, used by "First
///          Reminder" and "+ Reminder") and `TodoFrequencyUnit` (Daily /
///          Weekly / Monthly, used by "Set Frequency").
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma shows Hour for reminders and Daily / Week for frequency; Day, Week and
/// Monthly were added on the owner's instruction (7/10/2026) so the form
/// matches the Calendar spec (Daily / Weekly / Monthly recurrence).
///
/// ⚠️ [storageKey] is stored in Firestore — never rename it.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';

enum TodoReminderUnit {
  hour('hour'),
  day('day'),
  week('week');

  const TodoReminderUnit(this.storageKey);

  final String storageKey;

  /// Function Name: [toDuration]
  ///
  /// Purpose: How far before the start time a reminder of [value] units fires.
  ///
  /// Parameters:
  ///   [int] value: the stepper value (≥ 1).
  ///
  /// Return type: [Duration]
  Duration toDuration(int value) {
    switch (this) {
      case TodoReminderUnit.hour:
        return Duration(hours: value);
      case TodoReminderUnit.day:
        return Duration(days: value);
      case TodoReminderUnit.week:
        return Duration(days: 7 * value);
    }
  }

  /// Function Name: [label]
  ///
  /// Purpose: Localised dropdown label.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///
  /// Return type: [String]
  String label(BuildContext context) {
    switch (this) {
      case TodoReminderUnit.hour:
        return S.of(context).hour;
      case TodoReminderUnit.day:
        return S.of(context).day;
      case TodoReminderUnit.week:
        return S.of(context).todoWeekUnit;
    }
  }

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown reads as [hour].
  ///
  /// Parameters:
  ///   [String?] key
  ///
  /// Return type: [TodoReminderUnit]
  static TodoReminderUnit fromStorageKey(String? key) {
    for (final TodoReminderUnit value in TodoReminderUnit.values) {
      if (value.storageKey == key) return value;
    }
    return TodoReminderUnit.hour;
  }
}

enum TodoFrequencyUnit {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  const TodoFrequencyUnit(this.storageKey);

  final String storageKey;

  /// Function Name: [label]
  ///
  /// Purpose: Localised label — dropdown entries and the "Frequency: …" badge.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///
  /// Return type: [String]
  String label(BuildContext context) {
    switch (this) {
      case TodoFrequencyUnit.daily:
        return S.of(context).daily;
      case TodoFrequencyUnit.weekly:
        return S.of(context).weekly;
      case TodoFrequencyUnit.monthly:
        return S.of(context).monthly;
    }
  }

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown reads as [daily].
  ///
  /// Parameters:
  ///   [String?] key
  ///
  /// Return type: [TodoFrequencyUnit]
  static TodoFrequencyUnit fromStorageKey(String? key) {
    for (final TodoFrequencyUnit value in TodoFrequencyUnit.values) {
      if (value.storageKey == key) return value;
    }
    return TodoFrequencyUnit.daily;
  }
}
