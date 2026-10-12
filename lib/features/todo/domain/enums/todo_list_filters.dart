/// Module: todo / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: todo_list_filters.dart
/// Purpose: Declares `TodoStatusTab` (All · To Do · Done · Overdue ·
///          Scheduled · Deleted) and `TodoSortOption` (per-tab sort entries,
///          see `TodoSortOption.forTab`) — the two list controls on the To Do
///          List screen.
/// Updated: 7/10/2026 - Sort entries now depend on the tab; "All" includes
///          deleted to-dos.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Tabs are DERIVED, never stored: a to-do moves from "To Do" to "Overdue" the
/// moment its end time passes without anyone writing to it. The membership
/// rule lives on `TodoEntity.matchesTab` so the list, the counts and the home
/// widgets can never disagree.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum TodoStatusTab {
  all('all'),
  toDo('to_do'),
  done('done'),
  overdue('overdue'),
  scheduled('scheduled'),
  deleted('deleted');

  const TodoStatusTab(this.key);

  /// Stable key used by `StatusChipFilter`'s `selectedKey`.
  final String key;

  /// Function Name: [label]
  ///
  /// Purpose: Localised chip label.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///
  /// Return type: [String]
  String label(BuildContext context) {
    switch (this) {
      case TodoStatusTab.all:
        return S.of(context).all;
      case TodoStatusTab.toDo:
        return S.of(context).toDo;
      case TodoStatusTab.done:
        return S.of(context).done;
      case TodoStatusTab.overdue:
        return S.of(context).overdue;
      case TodoStatusTab.scheduled:
        return S.of(context).scheduled;
      case TodoStatusTab.deleted:
        return S.of(context).deleted;
    }
  }

  /// Function Name: [fromKey]
  ///
  /// Purpose: Reverse of [key]; unknown reads as [all].
  ///
  /// Parameters:
  ///   [String] key
  ///
  /// Return type: [TodoStatusTab]
  static TodoStatusTab fromKey(String key) {
    for (final TodoStatusTab value in TodoStatusTab.values) {
      if (value.key == key) return value;
    }
    return TodoStatusTab.all;
  }
}

/// Sort entries of the To Do List screen. Which ones are offered depends on
/// the selected status tab ([forTab]) — e.g. "Completion Date" only makes
/// sense on "Done" (owner, 7/10/2026: Done offering "Scheduled" made no
/// sense). The ordering rule itself is [compare], pure so it is unit-tested.
enum TodoSortOption {
  /// End date, soonest first. On "Overdue" that is the MOST overdue first.
  dueDate,

  /// High → Medium → Low, then due date.
  priority,

  /// Newest first.
  creationDate,

  /// Most recently completed first.
  completionDate,

  /// Soonest start first.
  startDate,

  /// Daily → Weekly → Monthly (then the shorter interval), then start date.
  frequency,

  /// Most recently deleted first.
  deletionDate;

  /// Function Name: [forTab]
  ///
  /// Purpose: The sort entries that make sense on [tab], in dropdown order.
  ///
  /// Parameters:
  ///   [TodoStatusTab] tab
  ///
  /// Return type: [List<TodoSortOption>]
  static List<TodoSortOption> forTab(TodoStatusTab tab) {
    switch (tab) {
      case TodoStatusTab.all:
        return const <TodoSortOption>[dueDate, priority, creationDate];
      case TodoStatusTab.toDo:
        return const <TodoSortOption>[dueDate, priority, creationDate];
      case TodoStatusTab.done:
        return const <TodoSortOption>[completionDate, priority];
      case TodoStatusTab.overdue:
        return const <TodoSortOption>[dueDate, priority];
      case TodoStatusTab.scheduled:
        return const <TodoSortOption>[startDate, frequency];
      case TodoStatusTab.deleted:
        return const <TodoSortOption>[deletionDate, priority];
    }
  }

  /// Function Name: [isValidFor]
  ///
  /// Purpose: Whether this entry is offered on [tab].
  ///
  /// Parameters:
  ///   [TodoStatusTab] tab
  ///
  /// Return type: [bool]
  bool isValidFor(TodoStatusTab tab) => forTab(tab).contains(this);

  /// Function Name: [label]
  ///
  /// Purpose: Localised entry in the Sort dropdown.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///
  /// Return type: [String]
  String label(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case TodoSortOption.dueDate:
        return s.dueDate;
      case TodoSortOption.priority:
        return s.priority;
      case TodoSortOption.creationDate:
        return s.creationDate;
      case TodoSortOption.completionDate:
        return s.todoCompletionDate;
      case TodoSortOption.startDate:
        return s.startDate;
      case TodoSortOption.frequency:
        return s.frequency;
      case TodoSortOption.deletionDate:
        return s.todoDeletionDate;
    }
  }

  /// Function Name: [compare]
  ///
  /// Purpose: Ordering of two to-dos under this entry. Missing dates always
  /// sort last; ties fall back to newest-created first so the order is
  /// stable between rebuilds.
  ///
  /// Parameters:
  ///   [TodoEntity] a
  ///   [TodoEntity] b
  ///
  /// Return type: [int] — negative when [a] comes first.
  int compare(TodoEntity a, TodoEntity b) {
    final int primary;
    switch (this) {
      case TodoSortOption.dueDate:
        primary = _ascending(a.endAt, b.endAt);
      case TodoSortOption.priority:
        final int byRank = a.priority.rank.compareTo(b.priority.rank);
        primary = byRank != 0 ? byRank : _ascending(a.endAt, b.endAt);
      case TodoSortOption.creationDate:
        primary = _descending(a.createdAt, b.createdAt);
      case TodoSortOption.completionDate:
        primary = _descending(a.completedAt, b.completedAt);
      case TodoSortOption.startDate:
        primary = _ascending(a.startAt, b.startAt);
      case TodoSortOption.frequency:
        primary = _compareFrequency(a, b);
      case TodoSortOption.deletionDate:
        primary = _descending(a.deletedAt, b.deletedAt);
    }
    return primary != 0 ? primary : newestFirst(a, b);
  }

  /// Function Name: [newestFirst]
  ///
  /// Purpose: Default list order (no sort picked): newest created first.
  ///
  /// Parameters:
  ///   [TodoEntity] a
  ///   [TodoEntity] b
  ///
  /// Return type: [int]
  static int newestFirst(TodoEntity a, TodoEntity b) =>
      _descending(a.createdAt, b.createdAt);

  static int _compareFrequency(TodoEntity a, TodoEntity b) {
    if (a.hasFrequency != b.hasFrequency) return a.hasFrequency ? -1 : 1;
    if (a.hasFrequency) {
      final int byUnit =
          a.frequency.unit.index.compareTo(b.frequency.unit.index);
      if (byUnit != 0) return byUnit;
      final int byInterval =
          a.frequency.interval.compareTo(b.frequency.interval);
      if (byInterval != 0) return byInterval;
    }
    return _ascending(a.startAt, b.startAt);
  }

  /// Oldest first, missing last.
  static int _ascending(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  /// Newest first, missing last.
  static int _descending(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }
}
