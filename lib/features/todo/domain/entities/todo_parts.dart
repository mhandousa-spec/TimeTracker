/// Module: todo / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: todo_parts.dart
/// Purpose: Declares the three value objects a to-do is built from —
///          `TodoItem` (one checklist line), `TodoReminder` (one "N units
///          before start" reminder) and `TodoFrequency` (the recurrence).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Plain immutable Dart: no Firestore, no Flutter. `TodoModel` does the
/// mapping.

import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';

/// One checklist line on a to-do ("Soft skills interview").
class TodoItem {
  const TodoItem({required this.id, required this.title, this.isDone = false});

  final String id;
  final String title;
  final bool isDone;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [TodoItem]
  TodoItem copyWith({String? title, bool? isDone}) => TodoItem(
        id: id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
      );
}

/// "Remind me [value] [unit] before the start time."
class TodoReminder {
  const TodoReminder({this.value = 1, this.unit = TodoReminderUnit.hour});

  final int value;
  final TodoReminderUnit unit;

  /// How long before the start time this reminder fires.
  Duration get offset => unit.toDuration(value);

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [TodoReminder]
  TodoReminder copyWith({int? value, TodoReminderUnit? unit}) => TodoReminder(
        value: value ?? this.value,
        unit: unit ?? this.unit,
      );
}

/// "Every [interval] [unit]", optionally on given [weekDays].
///
/// [weekDays] uses `DateTime.weekday` numbering (1 = Monday … 7 = Sunday) and
/// only applies to [TodoFrequencyUnit.weekly].
class TodoFrequency {
  const TodoFrequency({
    this.interval = 1,
    this.unit = TodoFrequencyUnit.daily,
    this.weekDays = const <int>[],
  });

  final int interval;
  final TodoFrequencyUnit unit;
  final List<int> weekDays;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [TodoFrequency]
  TodoFrequency copyWith({
    int? interval,
    TodoFrequencyUnit? unit,
    List<int>? weekDays,
  }) =>
      TodoFrequency(
        interval: interval ?? this.interval,
        unit: unit ?? this.unit,
        weekDays: weekDays ?? this.weekDays,
      );

  /// Function Name: [occursOn]
  ///
  /// Purpose: Whether the recurrence lands on [day], counting from [anchor].
  /// Used by the calendar loader and the reminder sweep.
  ///
  /// Parameters:
  ///   [DateTime] anchor: first occurrence (start date, or creation date).
  ///   [DateTime] day: the calendar day being tested.
  ///
  /// Return type: [bool]
  bool occursOn({required DateTime anchor, required DateTime day}) {
    final DateTime a = DateTime(anchor.year, anchor.month, anchor.day);
    final DateTime d = DateTime(day.year, day.month, day.day);
    if (d.isBefore(a)) return false;
    final int step = interval < 1 ? 1 : interval;
    final int daysApart = d.difference(a).inDays;

    switch (unit) {
      case TodoFrequencyUnit.daily:
        return daysApart % step == 0;
      case TodoFrequencyUnit.weekly:
        final int weeksApart = daysApart ~/ 7;
        if (weeksApart % step != 0) return false;
        final List<int> days = weekDays.isEmpty ? <int>[a.weekday] : weekDays;
        return days.contains(d.weekday);
      case TodoFrequencyUnit.monthly:
        final int monthsApart = (d.year - a.year) * 12 + d.month - a.month;
        return monthsApart % step == 0 && d.day == a.day;
    }
  }
}
