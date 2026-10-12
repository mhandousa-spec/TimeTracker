/// Module: todo / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: todo_entity.dart
/// Purpose: Declares `TodoEntity` — one personal to-do and every derived
///          status rule (overdue, due today, done on time, which tab it is in).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// To-dos are PERSONAL (owner decision 7/10/2026): every to-do belongs to
/// exactly one [ownerEmail] and nobody else reads or receives notifications
/// about it.
///
/// Status is derived, not stored, so a to-do turns Overdue the instant its end
/// time passes without a write. `now` is always passed in rather than read
/// here — that keeps these rules pure and lets one list render with one clock.

import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';

class TodoEntity {
  const TodoEntity({
    required this.id,
    required this.ownerEmail,
    required this.name,
    this.description = '',
    this.priority = TodoPriority.medium,
    this.isDone = false,
    this.completedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.isScheduled = false,
    this.startAt,
    this.endAt,
    this.reminders = const <TodoReminder>[],
    this.hasFrequency = false,
    this.frequency = const TodoFrequency(),
    this.items = const <TodoItem>[],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerEmail;
  final String name;
  final String description;
  final TodoPriority priority;
  final bool isDone;
  final DateTime? completedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final bool isScheduled;
  final DateTime? startAt;
  final DateTime? endAt;
  final List<TodoReminder> reminders;
  final bool hasFrequency;
  final TodoFrequency frequency;
  final List<TodoItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Checklist progress, e.g. 2 of "2/5".
  int get completedItemsCount => items.where((TodoItem i) => i.isDone).length;

  /// The date the card's footer chips show: the end date when scheduled,
  /// otherwise the creation date.
  DateTime? get displayDate => isScheduled ? (endAt ?? startAt) : createdAt;

  /// Anchor the recurrence counts from.
  DateTime? get recurrenceAnchor => startAt ?? createdAt;

  /// Red date chip: not done and the end time has passed.
  bool isOverdue(DateTime now) =>
      !isDone && !isDeleted && endAt != null && endAt!.isBefore(now);

  /// Red card border: not done, not yet overdue, and due on today's date.
  bool isDueToday(DateTime now) {
    final DateTime? end = endAt;
    if (isDone || isDeleted || end == null || isOverdue(now)) return false;
    return end.year == now.year && end.month == now.month && end.day == now.day;
  }

  /// Green date chip: completed, and on or before the end time (or no end).
  bool get isDoneOnTime {
    if (!isDone) return false;
    final DateTime? end = endAt;
    final DateTime? done = completedAt;
    return end == null || done == null || !done.isAfter(end);
  }

  /// Not soft-deleted — what the home widgets count as "all my to-dos".
  bool get isLive => !isDeleted;

  /// "Scheduled" tab: a scheduled to-do whose start time is still ahead.
  bool isUpcoming(DateTime now) =>
      !isDone && isScheduled && startAt != null && startAt!.isAfter(now);

  /// Function Name: [matchesTab]
  ///
  /// Purpose: Single source of truth for which status tab a to-do belongs to.
  /// "All" is literally everything — deleted to-dos included (owner,
  /// 7/10/2026); every other tab except "Deleted" excludes deleted ones.
  /// Callers that want "every live to-do" use [isLive] instead.
  ///
  /// Parameters:
  ///   [TodoStatusTab] tab: the tab being filtered.
  ///   [DateTime] now: the clock the whole list uses.
  ///
  /// Return type: [bool]
  bool matchesTab(TodoStatusTab tab, DateTime now) {
    if (tab == TodoStatusTab.all) return true;
    if (tab == TodoStatusTab.deleted) return isDeleted;
    if (isDeleted) return false;
    switch (tab) {
      case TodoStatusTab.all:
        return true;
      case TodoStatusTab.done:
        return isDone;
      case TodoStatusTab.overdue:
        return isOverdue(now);
      case TodoStatusTab.scheduled:
        return isUpcoming(now);
      case TodoStatusTab.toDo:
        return !isDone && !isOverdue(now) && !isUpcoming(now);
      case TodoStatusTab.deleted:
        return isDeleted;
    }
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update. Nullable dates are cleared with the
  /// matching `clear…` flag, because `null` alone means "keep".
  ///
  /// Return type: [TodoEntity]
  TodoEntity copyWith({
    String? name,
    String? description,
    TodoPriority? priority,
    bool? isDone,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    bool? isScheduled,
    DateTime? startAt,
    DateTime? endAt,
    bool clearSchedule = false,
    List<TodoReminder>? reminders,
    bool? hasFrequency,
    TodoFrequency? frequency,
    List<TodoItem>? items,
  }) =>
      TodoEntity(
        id: id,
        ownerEmail: ownerEmail,
        name: name ?? this.name,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        isDone: isDone ?? this.isDone,
        completedAt:
            clearCompletedAt ? null : (completedAt ?? this.completedAt),
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
        isScheduled: isScheduled ?? this.isScheduled,
        startAt: clearSchedule ? null : (startAt ?? this.startAt),
        endAt: clearSchedule ? null : (endAt ?? this.endAt),
        reminders: reminders ?? this.reminders,
        hasFrequency: hasFrequency ?? this.hasFrequency,
        frequency: frequency ?? this.frequency,
        items: items ?? this.items,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
