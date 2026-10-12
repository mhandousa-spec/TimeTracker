/// Module: todo / t3_todo_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: todo_actions_cubit.dart
/// Purpose: Declares `TodoActionsCubit` — every mutation that is not the
///          create/edit form: mark done / reopen, soft delete, restore, and
///          checklist add / remove / tick.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Permission checks are repeated here (not only by hiding buttons) so a
/// stale screen cannot write after the admin revoked a switch. Every
/// successful mutation is written to System Logs.
///
/// The list re-renders from the Firestore stream (`TodoListCubit`), so this
/// cubit never holds a copy of the to-do.
/// Updated: 7/10/2026 - Optimistic ticks: mark done / reopen and checklist
///          edits call the bound `apply` hook before the write and `revert`
///          on failure (see [TodoActionsCubit.bindOptimistic]).

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';

part 'todo_actions_state.dart';

class TodoActionsCubit extends Cubit<TodoActionsState> {
  TodoActionsCubit({
    required TodoBaseRepository repository,
    required TodoAccess access,
    required TodoLogService logService,
  })  : _repository = repository,
        _access = access,
        _log = logService,
        super(const TodoActionsState());

  final TodoBaseRepository _repository;
  final TodoAccess _access;
  final TodoLogService _log;

  /// Optimistic hooks, wired by the module entry to `TodoListCubit`
  /// (`applyLocal` / `revertLocal`). Null = no optimistic display (tests,
  /// or a cubit used without a list).
  void Function(TodoEntity updated)? _applyLocal;
  void Function(String id)? _revertLocal;

  /// Function Name: [bindOptimistic]
  ///
  /// Purpose: Plug in the list's local-override hooks so quick actions
  /// (done checkbox, checklist tick / add / remove) show instantly. Passed
  /// as plain callbacks so this cubit stays independent of the list cubit.
  ///
  /// Parameters:
  ///   [void Function(TodoEntity)] apply: show the to-do as saved, now.
  ///   [void Function(String)] revert: undo [apply] for that id.
  ///
  /// Return type: [void]
  void bindOptimistic({
    required void Function(TodoEntity updated) apply,
    required void Function(String id) revert,
  }) {
    _applyLocal = apply;
    _revertLocal = revert;
  }

  @override
  void emit(TodoActionsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [toggleDone]
  ///
  /// Purpose: Mark a to-do done (stamping `completed_at`, which drives the
  /// green "done on time" chip) or reopen it. Needs Edit.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [Future<void>]
  Future<void> toggleDone(TodoEntity todo) {
    final bool done = !todo.isDone;
    return _run(
      kind: TodoActionKind.toggleDone,
      allowed: _access.canEdit,
      optimistic: true,
      updated: done
          ? todo.copyWith(isDone: true, completedAt: DateTime.now())
          : todo.copyWith(isDone: false, clearCompletedAt: true),
      logAction:
          done ? TodoLogService.actionMarkDone : TodoLogService.actionReopen,
    );
  }

  /// Function Name: [delete]
  ///
  /// Purpose: Soft delete — the to-do moves to the Deleted tab and can be
  /// restored. Needs Delete.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [Future<void>]
  Future<void> delete(TodoEntity todo) => _run(
        kind: TodoActionKind.delete,
        allowed: _access.canDelete,
        updated: todo.copyWith(isDeleted: true, deletedAt: DateTime.now()),
        logAction: TodoLogService.actionDelete,
      );

  /// Function Name: [restore]
  ///
  /// Purpose: Undo a soft delete. Needs Restore.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [Future<void>]
  Future<void> restore(TodoEntity todo) => _run(
        kind: TodoActionKind.restore,
        allowed: _access.canRestore,
        updated: todo.copyWith(isDeleted: false, clearDeletedAt: true),
        logAction: TodoLogService.actionRestore,
      );

  /// Function Name: [addItem]
  ///
  /// Purpose: Append a checklist line ("+ item"). Blank titles are ignored.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [String] title
  ///
  /// Return type: [Future<void>]
  Future<void> addItem(TodoEntity todo, String title) async {
    final String clean = title.trim();
    if (clean.isEmpty) return;
    final TodoItem item = TodoItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: clean,
    );
    await _run(
      kind: TodoActionKind.addItem,
      allowed: _access.canEdit,
      optimistic: true,
      updated: todo.copyWith(items: <TodoItem>[...todo.items, item]),
      logAction: TodoLogService.actionUpdate,
    );
  }

  /// Function Name: [removeItem]
  ///
  /// Purpose: Remove a checklist line (red ⊖).
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [String] itemId
  ///
  /// Return type: [Future<void>]
  Future<void> removeItem(TodoEntity todo, String itemId) async {
    // Nothing to remove (already gone, e.g. double tap) → no write, no log.
    if (!todo.items.any((TodoItem i) => i.id == itemId)) return;
    await _run(
      kind: TodoActionKind.removeItem,
      allowed: _access.canEdit,
      optimistic: true,
      updated: todo.copyWith(
        items: todo.items.where((TodoItem i) => i.id != itemId).toList(),
      ),
      logAction: TodoLogService.actionUpdate,
    );
  }

  /// Function Name: [toggleItem]
  ///
  /// Purpose: Tick / untick one checklist line. Silent (no log) — it is the
  /// most frequent action and would flood System Logs.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [String] itemId
  ///
  /// Return type: [Future<void>]
  Future<void> toggleItem(TodoEntity todo, String itemId) => _run(
        kind: TodoActionKind.toggleItem,
        allowed: _access.canEdit,
        optimistic: true,
        updated: todo.copyWith(
          items: <TodoItem>[
            for (final TodoItem i in todo.items)
              i.id == itemId ? i.copyWith(isDone: !i.isDone) : i,
          ],
        ),
      );

  /// Function Name: [reset]
  ///
  /// Purpose: Back to idle after the UI consumed a success/failure.
  ///
  /// Return type: [void]
  void reset() => emit(const TodoActionsState());

  Future<void> _run({
    required TodoActionKind kind,
    required bool allowed,
    required TodoEntity updated,
    String? logAction,
    bool optimistic = false,
  }) async {
    if (!allowed) {
      emit(
        TodoActionsState(
          status: TodoActionStatus.failure,
          kind: kind,
          errorMessage: TodoActionsCubit.permissionDenied,
        ),
      );
      return;
    }
    if (optimistic) _applyLocal?.call(updated);
    emit(TodoActionsState(status: TodoActionStatus.submitting, kind: kind));
    try {
      await _repository.updateTodo(todo: updated);
      if (logAction != null) _log.log(logAction);
      emit(TodoActionsState(status: TodoActionStatus.success, kind: kind));
    } catch (error) {
      // Undo the instant display; the failure toast follows from the state.
      if (optimistic) _revertLocal?.call(updated.id);
      emit(
        TodoActionsState(
          status: TodoActionStatus.failure,
          kind: kind,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Sentinel the UI maps to `S.of(context).todoNoPermission`.
  static const String permissionDenied = 'permission_denied';
}
