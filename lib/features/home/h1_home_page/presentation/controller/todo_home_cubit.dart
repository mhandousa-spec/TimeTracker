/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: todo_home_cubit.dart
/// Purpose: Declares `TodoHomeCubit` — streams the signed-in user's to-dos
///          for the three home To-Do cards and toggles done from card 2.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// The To-Do module's own cubits live inside `TodoModuleEntry`, which a home
/// card has no access to, so this reads the same `TodoBaseRepository`
/// (through get_it) and keeps only what the cards draw. Each card creates its
/// own instance; Firestore shares one listener between identical queries.
///
/// Done / reopen mirrors `TodoActionsCubit.toggleDone`: same Edit check, same
/// `completed_at` stamp, same System Logs actions.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';

part 'todo_home_state.dart';

class TodoHomeCubit extends Cubit<TodoHomeState> {
  TodoHomeCubit({
    TodoBaseRepository? repository,
    TodoAccess? access,
    TodoLogService? logService,
  })  : _repository = repository ?? GetIt.instance<TodoBaseRepository>(),
        _access = access ?? GetIt.instance<TodoAccess>(),
        _log = logService ?? GetIt.instance<TodoLogService>(),
        super(TodoHomeState(now: DateTime.now()));

  final TodoBaseRepository _repository;
  final TodoAccess _access;
  final TodoLogService _log;

  StreamSubscription<List<TodoEntity>>? _subscription;
  Timer? _clock;

  /// Ids whose toggle is in flight — a double tap must not write twice.
  final Set<String> _busy = <String>{};

  /// Guard for flutter_bloc 9, which throws on emit after close.
  @override
  void emit(TodoHomeState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Start listening to the user's to-dos and a one-minute clock so
  /// Overdue / Scheduled counts move without a write. Idempotent.
  ///
  /// Return type: [void]
  void init() {
    if (_subscription != null) return;
    final String email = _access.currentUserEmail;
    if (email.isEmpty || !_access.canView) {
      emit(state.copyWith(status: TodoHomeStatus.noAccess));
      return;
    }
    _subscription = _repository
        .watchTodos(ownerEmail: email)
        .listen(_onTodos, onError: _onError);
    _clock = Timer.periodic(
      const Duration(minutes: 1),
      (_) => emit(state.copyWith(now: DateTime.now())),
    );
  }

  void _onTodos(List<TodoEntity> todos) {
    emit(
      state.copyWith(
        status: TodoHomeStatus.loaded,
        todos: todos,
        now: DateTime.now(),
        canEdit: _access.canEdit,
      ),
    );
  }

  void _onError(Object error) {
    emit(state.copyWith(status: TodoHomeStatus.failure));
  }

  /// Function Name: [toggleDone]
  ///
  /// Purpose: Mark [todo] done (stamping `completed_at`) or reopen it, then
  /// log it. Needs Edit; the stream re-renders the cards.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [Future<void>]
  Future<void> toggleDone(TodoEntity todo) async {
    if (!_access.canEdit) {
      emit(state.copyWith(actionError: TodoHomeActionError.noPermission));
      return;
    }
    if (!_busy.add(todo.id)) return;
    final bool done = !todo.isDone;
    final TodoEntity updated = done
        ? todo.copyWith(isDone: true, completedAt: DateTime.now())
        : todo.copyWith(isDone: false, clearCompletedAt: true);
    try {
      await _repository.updateTodo(todo: updated);
      _log.log(
        done ? TodoLogService.actionMarkDone : TodoLogService.actionReopen,
      );
    } catch (_) {
      emit(state.copyWith(actionError: TodoHomeActionError.saveFailed));
    } finally {
      _busy.remove(todo.id);
    }
  }

  /// Function Name: [clearActionError]
  ///
  /// Purpose: Called by the card once it has shown [TodoHomeState.actionError].
  ///
  /// Return type: [void]
  void clearActionError() => emit(state.copyWith(clearActionError: true));

  @override
  Future<void> close() async {
    _clock?.cancel(); // first: synchronous, so no tick fires while we wait
    await _subscription?.cancel();
    return super.close();
  }
}
