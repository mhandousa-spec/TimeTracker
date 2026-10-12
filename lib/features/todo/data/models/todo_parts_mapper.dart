/// Module: todo / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: todo_parts_mapper.dart
/// Purpose: Declares `TodoPartsMapper` — Firestore <-> value-object mapping
///          for ONE history entry of the list/map fields of a to-do
///          (`Checklist_Items`, `Reminders`, `Recurrence`).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Firestore cannot store an array directly inside an array, so in the
/// history model a list-valued field stores each history entry as a MAP
/// wrapping the list under [fListValues]:
///   `Reminders: [ {Values: [{Reminder_Value: 1, Reminder_Unit: 'hour'}]}, … ]`
///
/// Every reader also accepts the pre-history flat shape (a bare list, and the
/// old snake_case keys) so to-dos written before the switch still open.

import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';

class TodoPartsMapper {
  const TodoPartsMapper._();

  /// Key wrapping the list inside one history entry of a list-valued field.
  static const String fListValues = 'Values';

  static const String fItemId = 'Item_Id';
  static const String fItemTitle = 'Item_Title';
  static const String fItemIsDone = 'Is_Item_Completed';
  static const String fReminderValue = 'Reminder_Value';
  static const String fReminderUnit = 'Reminder_Unit';
  static const String fRecurrenceInterval = 'Recurrence_Interval';
  static const String fRecurrenceUnit = 'Recurrence_Unit';
  static const String fRecurrenceWeekDays = 'Recurrence_Week_Days';

  /// Function Name: [itemsFrom]
  ///
  /// Purpose: Parse one `Checklist_Items` history entry.
  ///
  /// Parameters:
  ///   [Object?] raw: `{Values: [...]}` (or a legacy bare list).
  ///
  /// Return type: [List<TodoItem>] — unmodifiable, empty when absent.
  static List<TodoItem> itemsFrom(Object? raw) {
    final List<Map<String, dynamic>> entries = _entries(raw);
    return List<TodoItem>.unmodifiable(<TodoItem>[
      for (int i = 0; i < entries.length; i++)
        TodoItem(
          id: _string(entries[i], fItemId, 'id').isNotEmpty
              ? _string(entries[i], fItemId, 'id')
              : 'item_$i',
          title: _string(entries[i], fItemTitle, 'title'),
          isDone: (_read(entries[i], fItemIsDone, 'is_done') as bool?) ?? false,
        ),
    ]);
  }

  /// Function Name: [itemsTo]
  ///
  /// Purpose: Serialise checklist items as one history entry.
  ///
  /// Parameters:
  ///   [List<TodoItem>] items
  ///
  /// Return type: [Map<String, dynamic>] — `{Values: [...]}`.
  static Map<String, dynamic> itemsTo(List<TodoItem> items) =>
      <String, dynamic>{
        fListValues: <Map<String, dynamic>>[
          for (final TodoItem item in items)
            <String, dynamic>{
              fItemId: item.id,
              fItemTitle: item.title,
              fItemIsDone: item.isDone,
            },
        ],
      };

  /// Function Name: [remindersFrom]
  ///
  /// Purpose: Parse one `Reminders` history entry.
  ///
  /// Parameters:
  ///   [Object?] raw: `{Values: [...]}` (or a legacy bare list).
  ///
  /// Return type: [List<TodoReminder>]
  static List<TodoReminder> remindersFrom(Object? raw) =>
      List<TodoReminder>.unmodifiable(<TodoReminder>[
        for (final Map<String, dynamic> entry in _entries(raw))
          TodoReminder(
            value:
                (_read(entry, fReminderValue, 'value') as num?)?.toInt() ?? 1,
            unit: TodoReminderUnit.fromStorageKey(
              _read(entry, fReminderUnit, 'unit') as String?,
            ),
          ),
      ]);

  /// Function Name: [remindersTo]
  ///
  /// Purpose: Serialise reminders as one history entry.
  ///
  /// Parameters:
  ///   [List<TodoReminder>] reminders
  ///
  /// Return type: [Map<String, dynamic>] — `{Values: [...]}`.
  static Map<String, dynamic> remindersTo(List<TodoReminder> reminders) =>
      <String, dynamic>{
        fListValues: <Map<String, dynamic>>[
          for (final TodoReminder r in reminders)
            <String, dynamic>{
              fReminderValue: r.value,
              fReminderUnit: r.unit.storageKey,
            },
        ],
      };

  /// Function Name: [frequencyFrom]
  ///
  /// Purpose: Parse one `Recurrence` history entry.
  ///
  /// Parameters:
  ///   [Object?] raw
  ///
  /// Return type: [TodoFrequency] — defaults when absent.
  static TodoFrequency frequencyFrom(Object? raw) {
    if (raw is! Map<String, dynamic>) return const TodoFrequency();
    final Object? days = _read(raw, fRecurrenceWeekDays, 'week_days');
    return TodoFrequency(
      interval:
          (_read(raw, fRecurrenceInterval, 'interval') as num?)?.toInt() ?? 1,
      unit: TodoFrequencyUnit.fromStorageKey(
        _read(raw, fRecurrenceUnit, 'unit') as String?,
      ),
      weekDays: days is List<dynamic>
          ? List<int>.unmodifiable(days.whereType<num>().map((n) => n.toInt()))
          : const <int>[],
    );
  }

  /// Function Name: [frequencyTo]
  ///
  /// Purpose: Serialise the recurrence as one history entry (a map, so its
  /// week-days array is legal inside the history array).
  ///
  /// Parameters:
  ///   [TodoFrequency] frequency
  ///
  /// Return type: [Map<String, dynamic>]
  static Map<String, dynamic> frequencyTo(TodoFrequency frequency) =>
      <String, dynamic>{
        fRecurrenceInterval: frequency.interval,
        fRecurrenceUnit: frequency.unit.storageKey,
        fRecurrenceWeekDays: List<int>.of(frequency.weekDays),
      };

  /// The map entries of a list-valued history entry, in either shape.
  static List<Map<String, dynamic>> _entries(Object? raw) {
    final Object? list = raw is Map<String, dynamic> ? raw[fListValues] : raw;
    if (list is! List<dynamic>) return const <Map<String, dynamic>>[];
    return list.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  /// [key] first, then the pre-history [legacyKey].
  static Object? _read(
          Map<String, dynamic> map, String key, String legacyKey) =>
      map.containsKey(key) ? map[key] : map[legacyKey];

  static String _string(Map<String, dynamic> map, String key, String legacy) =>
      (_read(map, key, legacy) as String?) ?? '';
}
