/// Module: todo / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: todo_base_repository.dart
/// Purpose: Declares `TodoBaseRepository` — the contract the To-Do cubits
///          depend on.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.

import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';

abstract class TodoBaseRepository {
  /// Function Name: [watchTodos]
  ///
  /// Purpose: Live list of every to-do (including soft-deleted) owned by
  /// [ownerEmail].
  ///
  /// Parameters:
  ///   [String] ownerEmail: the signed-in user's email, lower-cased.
  ///
  /// Return type: [Stream<List<TodoEntity>>] — emits an error event carrying
  /// an `Exception` when the read fails.
  Stream<List<TodoEntity>> watchTodos({required String ownerEmail});

  /// Function Name: [createTodo]
  ///
  /// Purpose: Persist a new to-do.
  ///
  /// Parameters:
  ///   [TodoEntity] todo: the draft; its id is ignored.
  ///
  /// Return type: [Future<TodoEntity>] — the saved to-do with its new id.
  Future<TodoEntity> createTodo({required TodoEntity todo});

  /// Function Name: [updateTodo]
  ///
  /// Purpose: Persist every editable field of an existing to-do (name,
  /// description, priority, schedule, reminders, frequency, items, done and
  /// deleted flags).
  ///
  /// Parameters:
  ///   [TodoEntity] todo: the full updated to-do.
  ///
  /// Return type: [Future<void>]
  Future<void> updateTodo({required TodoEntity todo});
}
