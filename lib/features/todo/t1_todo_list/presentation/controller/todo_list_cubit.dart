/// Module: todo / t1_todo_list / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: todo_list_cubit.dart
/// Purpose: Declares `TodoListCubit` — keeps the signed-in user's to-dos live
///          and holds the list screen's tab / priority / sort / search.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Provided ONCE at the module entry and shared (BlocProvider.value) with the
/// details screen, so a checklist tick on details updates the list card
/// without a reload. Mutations live in `TodoActionsCubit`; this cubit only
/// reads.
/// Updated: 7/10/2026 - Optimistic overrides ([applyLocal] / [revertLocal]):
///          a tick shows at once instead of after the Firestore transaction
///          round-trip; the stream confirms it, a failure reverts it.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_reminder_sweeper.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_sample_data.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';

part 'todo_list_state.dart';

class TodoListCubit extends Cubit<TodoListState> {
  TodoListCubit({
    required TodoBaseRepository repository,
    required TodoAccess access,
    required TodoReminderSweeper reminderSweeper,
  })  : _repository = repository,
        _access = access,
        _sweeper = reminderSweeper,
        super(TodoListState(now: DateTime.now()));

  final TodoBaseRepository _repository;
  final TodoAccess _access;
  final TodoReminderSweeper _sweeper;
  StreamSubscription<List<TodoEntity>>? _subscription;
  Timer? _clock;

  /// Follow-up sweep scheduled by [loadDemoTodos] (debug tools only).
  Timer? _demoSweep;

  /// Minimum gap between two reminder sweeps driven by the clock tick.
  static const Duration _sweepInterval = Duration(minutes: 15);

  /// When the last sweep started; null until the first snapshot arrives.
  DateTime? _lastSweepAt;

  /// Captured at [init] so the sweep never reads a locale from a context.
  String _languageCode = 'en';

  /// Last list the Firestore stream delivered (no local overrides applied).
  List<TodoEntity> _serverTodos = const <TodoEntity>[];

  /// Optimistic versions by to-do id, shown instead of the stream's copy
  /// until a snapshot at least as new arrives (or [revertLocal]).
  final Map<String, _LocalOverride> _overrides = <String, _LocalOverride>{};

  /// Safety net: an override no snapshot ever confirmed (e.g. a hand-edited
  /// doc without `timestamps`) is dropped after this long.
  static const Duration _overrideTtl = Duration(seconds: 30);

  /// Guard for flutter_bloc 9, which throws on emit after close.
  @override
  void emit(TodoListState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Start listening to the user's to-dos and start the one-minute
  /// clock that moves cards between To Do / Overdue / Scheduled. Called from
  /// the entry page's `initState`, never from the constructor.
  ///
  /// Also drives the reminder sweep (`TodoReminderSweeper`): once after the
  /// first snapshot, then at most every 15 minutes on the clock tick.
  ///
  /// Parameters:
  ///   [String] languageCode: the active locale's language code ('en' /
  ///   'ar'), used for the notification push language. Defaults to 'en'.
  ///
  /// Return type: [void]
  void init({String languageCode = 'en'}) {
    if (_subscription != null) return;
    _languageCode = languageCode;
    emit(state.copyWith(status: TodoListStatus.loading));
    _subscription = _repository
        .watchTodos(ownerEmail: _access.currentUserEmail)
        .listen(_onTodos, onError: _onError);
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => _onTick());
  }

  void _onTodos(List<TodoEntity> todos) {
    final bool isFirstSnapshot = state.status != TodoListStatus.loaded;
    _serverTodos = todos;
    _pruneOverrides(DateTime.now());
    emit(
      state.copyWith(
        status: TodoListStatus.loaded,
        todos: _merged(),
        now: DateTime.now(),
        clearErrorMessage: true,
      ),
    );
    if (isFirstSnapshot && _lastSweepAt == null) _sweepReminders();
  }

  /// Function Name: [applyLocal]
  ///
  /// Purpose: OPTIMISTIC update — show [updated] in place of the stored
  /// to-do right now (list card, counts, details), before the write lands.
  /// Kept until a snapshot carries a version written at or after this call
  /// (its `updatedAt`), then the stream's copy takes over again.
  ///
  /// Parameters:
  ///   [TodoEntity] updated: the to-do as it will be once saved.
  ///
  /// Return type: [void]
  void applyLocal(TodoEntity updated) {
    if (isClosed) return;
    _overrides[updated.id] = _LocalOverride(
      todo: updated,
      appliedAt: DateTime.now(),
    );
    emit(state.copyWith(todos: _merged()));
  }

  /// Function Name: [revertLocal]
  ///
  /// Purpose: Drop the optimistic version of [id] (its write failed) so the
  /// last confirmed copy from the stream shows again.
  ///
  /// Parameters:
  ///   [String] id
  ///
  /// Return type: [void]
  void revertLocal(String id) {
    if (isClosed || _overrides.remove(id) == null) return;
    emit(state.copyWith(todos: _merged()));
  }

  /// Removes overrides the stream has caught up with: the to-do is gone, its
  /// stored `updatedAt` (last `timestamps` entry, ms) is not older than the
  /// override, or the override outlived [_overrideTtl].
  void _pruneOverrides(DateTime now) {
    if (_overrides.isEmpty) return;
    final Map<String, TodoEntity> byId = <String, TodoEntity>{
      for (final TodoEntity t in _serverTodos) t.id: t,
    };
    _overrides.removeWhere((String id, _LocalOverride o) {
      final TodoEntity? stored = byId[id];
      if (stored == null) return true;
      if (now.difference(o.appliedAt) > _overrideTtl) return true;
      final DateTime? written = stored.updatedAt;
      return written != null &&
          written.millisecondsSinceEpoch >=
              o.appliedAt.millisecondsSinceEpoch;
    });
  }

  /// The stream's list with every pending override swapped in.
  List<TodoEntity> _merged() {
    if (_overrides.isEmpty) return _serverTodos;
    return List<TodoEntity>.unmodifiable(<TodoEntity>[
      for (final TodoEntity t in _serverTodos) _overrides[t.id]?.todo ?? t,
    ]);
  }

  void _onTick() {
    final DateTime now = DateTime.now();
    emit(state.copyWith(now: now));
    final DateTime? last = _lastSweepAt;
    if (last != null && now.difference(last) >= _sweepInterval) {
      _sweepReminders();
    }
  }

  /// Fire-and-forget: the list never waits on, or fails because of, a sweep.
  void _sweepReminders() {
    if (isClosed || state.status != TodoListStatus.loaded) return;
    final DateTime now = DateTime.now();
    _lastSweepAt = now;
    unawaited(_runSweep(now));
  }

  Future<void> _runSweep(DateTime now) async {
    try {
      await _sweeper.sweep(
        todos: state.todos,
        ownerEmail: _access.currentUserEmail,
        now: now,
        isArabic: _languageCode == 'ar',
      );
    } catch (_) {
      // The sweeper resolves rather than throws for Firestore / send
      // failures; this only guards an unexpected bug so it can never surface
      // as an unhandled async error. The next 15-minute tick retries.
      _lastSweepAt = now;
    }
  }

  void _onError(Object error) {
    emit(
      state.copyWith(
        status: TodoListStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }

  /// Function Name: [selectTab]
  ///
  /// Purpose: Switch status tab. The picked sort survives only when the new
  /// tab offers it (`TodoSortOption.forTab`); otherwise it resets to the
  /// default order.
  ///
  /// Parameters:
  ///   [TodoStatusTab] tab
  ///
  /// Return type: [void]
  void selectTab(TodoStatusTab tab) {
    final TodoSortOption? sort = state.sort;
    emit(
      state.copyWith(
        tab: tab,
        clearSort: sort != null && !sort.isValidFor(tab),
      ),
    );
  }

  /// Function Name: [selectPriority]
  ///
  /// Purpose: Filter by priority; null = "All".
  ///
  /// Parameters:
  ///   [TodoPriority?] priority
  ///
  /// Return type: [void]
  void selectPriority(TodoPriority? priority) => emit(
        priority == null
            ? state.copyWith(clearPriority: true)
            : state.copyWith(priority: priority),
      );

  /// Function Name: [selectSort]
  ///
  /// Purpose: Choose sort; null clears it (tapping the selected entry again).
  ///
  /// Parameters:
  ///   [TodoSortOption?] sort
  ///
  /// Return type: [void]
  void selectSort(TodoSortOption? sort) => emit(
        sort == null
            ? state.copyWith(clearSort: true)
            : state.copyWith(sort: sort),
      );

  /// Function Name: [searchChanged]
  ///
  /// Purpose: Update the search text.
  ///
  /// Parameters:
  ///   [String] query
  ///
  /// Return type: [void]
  void searchChanged(String query) => emit(state.copyWith(query: query));

  /// Function Name: [forceSweep]
  ///
  /// Purpose: Run the reminder sweep NOW, ignoring the 15-minute gap — used
  /// by the debug "Send due reminders now" tool. Events still only go out
  /// when due (see `TodoReminderSweeper`), and never twice.
  ///
  /// Return type: [Future<TodoSweepReport?>] — null when the list is not
  /// loaded yet or the sweep failed unexpectedly.
  Future<TodoSweepReport?> forceSweep() async {
    if (isClosed || state.status != TodoListStatus.loaded) return null;
    final DateTime now = DateTime.now();
    _lastSweepAt = now;
    try {
      return await _sweeper.sweep(
        todos: state.todos,
        ownerEmail: _access.currentUserEmail,
        now: now,
        isArabic: _languageCode == 'ar',
      );
    } catch (_) {
      // Same guard as the periodic sweep: report "failed" to the caller.
      return null;
    }
  }

  /// Function Name: [loadDemoTodos]
  ///
  /// Purpose: DEBUG tool — write the demo to-dos of `TodoSampleData` for the
  /// signed-in user (in the current language), then schedule one sweep just
  /// after their events fall due so the notifications arrive by themselves.
  ///
  /// Return type: [Future<({int count, bool ok})>] — how many were written,
  /// and whether all of them were.
  Future<({int count, bool ok})> loadDemoTodos() async {
    final String owner = _access.currentUserEmail;
    if (owner.isEmpty) return (count: 0, ok: false);
    final List<TodoEntity> drafts = TodoSampleData.build(
      ownerEmail: owner,
      now: DateTime.now(),
      isArabic: _languageCode == 'ar',
    );
    int count = 0;
    try {
      for (final TodoEntity draft in drafts) {
        await _repository.createTodo(todo: draft);
        count++;
      }
    } catch (_) {
      return (count: count, ok: false);
    }
    _demoSweep?.cancel();
    _demoSweep = Timer(
      TodoSampleData.fireDelay + const Duration(minutes: 1),
      () => unawaited(forceSweep()),
    );
    return (count: count, ok: true);
  }

  /// Function Name: [removeDemoTodos]
  ///
  /// Purpose: DEBUG tool — SOFT-delete every live demo to-do (matched by its
  /// exact sample title, `TodoSampleData.isSample`). Nothing is hard-deleted.
  ///
  /// Return type: [Future<({int count, bool ok})>] — how many were removed,
  /// and whether every write succeeded.
  Future<({int count, bool ok})> removeDemoTodos() async {
    final DateTime now = DateTime.now();
    final List<TodoEntity> targets = state.todos
        .where((TodoEntity t) => !t.isDeleted && TodoSampleData.isSample(t))
        .toList();
    int count = 0;
    try {
      for (final TodoEntity todo in targets) {
        await _repository.updateTodo(
          todo: todo.copyWith(isDeleted: true, deletedAt: now),
        );
        count++;
      }
    } catch (_) {
      return (count: count, ok: false);
    }
    return (count: count, ok: true);
  }

  @override
  Future<void> close() async {
    _demoSweep?.cancel();
    _clock?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}

/// One optimistic version and when it was applied.
class _LocalOverride {
  const _LocalOverride({required this.todo, required this.appliedAt});

  final TodoEntity todo;
  final DateTime appliedAt;
}
