/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: todo_home_state.dart
/// Purpose: Declares `TodoHomeState` — the live to-dos behind the three
///          To-Do cards on the home page, plus the counts they show.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Every count goes through `TodoEntity.matchesTab` (and `priority`), the same
/// rule the To-Do list's tabs use, so a card can never disagree with the list
/// it opens.

part of 'todo_home_cubit.dart';

enum TodoHomeStatus { loading, loaded, failure, noAccess }

/// One-shot feedback for a failed checkbox tap.
enum TodoHomeActionError { noPermission, saveFailed }

@immutable
class TodoHomeState {
  const TodoHomeState({
    this.status = TodoHomeStatus.loading,
    this.todos = const <TodoEntity>[],
    required this.now,
    this.canEdit = false,
    this.actionError,
  });

  final TodoHomeStatus status;

  /// Every to-do the user owns, soft-deleted ones included.
  final List<TodoEntity> todos;

  /// The one clock all counts are taken against.
  final DateTime now;

  /// Whether the card-2 checkbox may write.
  final bool canEdit;

  /// Set after a failed toggle; cleared once the card has shown it.
  final TodoHomeActionError? actionError;

  /// Function Name: [countFor]
  ///
  /// Purpose: How many to-dos sit in [tab] — identical to the list tab count,
  /// except "All": the list's All tab now includes deleted to-dos (owner,
  /// 7/10/2026), but the home total stays "live (not deleted) to-dos".
  ///
  /// Parameters:
  ///   [TodoStatusTab] tab
  ///
  /// Return type: [int]
  int countFor(TodoStatusTab tab) => tab == TodoStatusTab.all
      ? todos.where((TodoEntity t) => t.isLive).length
      : todos.where((TodoEntity t) => t.matchesTab(tab, now)).length;

  /// Function Name: [countPriority]
  ///
  /// Purpose: How many live (not deleted) to-dos carry [priority].
  ///
  /// Parameters:
  ///   [TodoPriority] priority
  ///
  /// Return type: [int]
  int countPriority(TodoPriority priority) =>
      todos.where((TodoEntity t) => t.isLive && t.priority == priority).length;

  /// Function Name: [openTodos]
  ///
  /// Purpose: The first [limit] not-done, not-deleted to-dos, newest first —
  /// the list's default (unsorted) order.
  ///
  /// Parameters:
  ///   [int] limit
  ///
  /// Return type: [List<TodoEntity>]
  List<TodoEntity> openTodos(int limit) {
    final List<TodoEntity> open = todos
        .where((TodoEntity t) => t.isLive && !t.isDone)
        .toList()
      ..sort(_newestFirst);
    return open.take(limit).toList();
  }

  static int _newestFirst(TodoEntity a, TodoEntity b) {
    final DateTime? x = a.createdAt;
    final DateTime? y = b.createdAt;
    if (x == null && y == null) return 0;
    if (x == null) return 1;
    if (y == null) return -1;
    return y.compareTo(x);
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update; [clearActionError] drops [actionError].
  ///
  /// Return type: [TodoHomeState]
  TodoHomeState copyWith({
    TodoHomeStatus? status,
    List<TodoEntity>? todos,
    DateTime? now,
    bool? canEdit,
    TodoHomeActionError? actionError,
    bool clearActionError = false,
  }) =>
      TodoHomeState(
        status: status ?? this.status,
        todos: todos ?? this.todos,
        now: now ?? this.now,
        canEdit: canEdit ?? this.canEdit,
        actionError:
            clearActionError ? null : (actionError ?? this.actionError),
      );
}
