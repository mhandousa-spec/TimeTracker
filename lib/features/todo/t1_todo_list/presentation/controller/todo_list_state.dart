/// Module: todo / t1_todo_list / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: todo_list_state.dart
/// Purpose: Declares `TodoListState` — the live to-do list plus the tab,
///          priority, sort and search the user picked.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// One immutable state + copyWith + status enum (db3_create_table pattern).
/// Filtering is DERIVED in getters so counts, list and home widgets can never
/// disagree, and so a to-do changes tab when the clock ([now]) moves.

part of 'todo_list_cubit.dart';

enum TodoListStatus { initial, loading, loaded, failure }

@immutable
class TodoListState {
  const TodoListState({
    required this.now,
    this.status = TodoListStatus.initial,
    this.todos = const <TodoEntity>[],
    this.tab = TodoStatusTab.all,
    this.priority,
    this.sort,
    this.query = '',
    this.errorMessage,
  });

  final TodoListStatus status;
  final List<TodoEntity> todos;
  final TodoStatusTab tab;

  /// null = the "All" priority chip.
  final TodoPriority? priority;

  /// null = default order (newest first). Always one of
  /// `TodoSortOption.forTab(tab)` — the cubit clears it on a tab change.
  final TodoSortOption? sort;
  final String query;
  final String? errorMessage;

  /// Clock every derived rule uses; refreshed once a minute by the cubit.
  final DateTime now;

  /// Function Name: [countFor]
  ///
  /// Purpose: Number shown in a status tab's count box. Ignores the search and
  /// priority filters, like the Figma counts. "All" includes deleted to-dos.
  ///
  /// Parameters:
  ///   [TodoStatusTab] tab
  ///
  /// Return type: [int]
  int countFor(TodoStatusTab tab) =>
      todos.where((TodoEntity t) => t.matchesTab(tab, now)).length;

  /// Function Name: [byId]
  ///
  /// Purpose: Look up one to-do for the details screen (live).
  ///
  /// Parameters:
  ///   [String] id
  ///
  /// Return type: [TodoEntity?] — null once it no longer exists.
  TodoEntity? byId(String id) {
    for (final TodoEntity t in todos) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// The cards to draw: tab ∩ priority ∩ search, then sorted.
  List<TodoEntity> get visible {
    final String needle = query.trim().toLowerCase();
    final List<TodoEntity> result = todos.where((TodoEntity t) {
      if (!t.matchesTab(tab, now)) return false;
      if (priority != null && t.priority != priority) return false;
      if (needle.isEmpty) return true;
      return t.name.toLowerCase().contains(needle) ||
          t.description.toLowerCase().contains(needle) ||
          t.items.any((TodoItem i) => i.title.toLowerCase().contains(needle));
    }).toList();
    result.sort(_comparator);
    return List<TodoEntity>.unmodifiable(result);
  }

  /// Picked sort when it is valid for [tab], else the default order.
  int _comparator(TodoEntity a, TodoEntity b) {
    final TodoSortOption? picked = sort;
    if (picked == null || !picked.isValidFor(tab)) {
      return TodoSortOption.newestFirst(a, b);
    }
    return picked.compare(a, b);
  }

  /// Sort entries the toolbar offers on the current [tab].
  List<TodoSortOption> get sortOptions => TodoSortOption.forTab(tab);

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update. `clearPriority` / `clearSort` /
  /// `clearErrorMessage` reset the nullable fields.
  ///
  /// Return type: [TodoListState]
  TodoListState copyWith({
    TodoListStatus? status,
    List<TodoEntity>? todos,
    TodoStatusTab? tab,
    TodoPriority? priority,
    bool clearPriority = false,
    TodoSortOption? sort,
    bool clearSort = false,
    String? query,
    String? errorMessage,
    bool clearErrorMessage = false,
    DateTime? now,
  }) =>
      TodoListState(
        status: status ?? this.status,
        todos: todos ?? this.todos,
        tab: tab ?? this.tab,
        priority: clearPriority ? null : (priority ?? this.priority),
        sort: clearSort ? null : (sort ?? this.sort),
        query: query ?? this.query,
        errorMessage:
            clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
        now: now ?? this.now,
      );
}
