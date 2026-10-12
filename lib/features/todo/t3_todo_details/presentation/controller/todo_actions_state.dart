/// Module: todo / t3_todo_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: todo_actions_state.dart
/// Purpose: Declares `TodoActionsState` — outcome of the last mutation
///          (mark done, delete, restore, checklist edits).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

part of 'todo_actions_cubit.dart';

enum TodoActionStatus { idle, submitting, success, failure }

/// Which mutation the status refers to — the UI picks the success dialog from
/// it (Deleted / Restored) and ignores the silent ones (checklist ticks).
enum TodoActionKind {
  toggleDone,
  delete,
  restore,
  addItem,
  removeItem,
  toggleItem,
}

@immutable
class TodoActionsState {
  const TodoActionsState({
    this.status = TodoActionStatus.idle,
    this.kind,
    this.errorMessage,
  });

  final TodoActionStatus status;
  final TodoActionKind? kind;
  final String? errorMessage;

  bool get isSubmitting => status == TodoActionStatus.submitting;
}
