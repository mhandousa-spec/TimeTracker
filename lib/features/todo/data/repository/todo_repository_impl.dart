/// Module: todo / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: todo_repository_impl.dart
/// Purpose: Declares `TodoRepositoryImpl` — validates input and converts
///          Firestore failures into clean `Exception`s.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// try/catch lives HERE and in the cubits only (MASTER_CODE_REVIEW §11).
/// Raw `FirebaseException`s never leave this file.

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/features/todo/data/data_source/remote_data_source/todo_remote_data_source.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';

class TodoRepositoryImpl implements TodoBaseRepository {
  TodoRepositoryImpl({
    required TodoRemoteDataSource remoteDataSource,
    required TodoAccess access,
  })  : _remote = remoteDataSource,
        _access = access;

  final TodoRemoteDataSource _remote;

  /// Source of the signed-in email — the `Modules/todo/{email}` collection every
  /// read and write is scoped to.
  final TodoAccess _access;

  @override
  Stream<List<TodoEntity>> watchTodos({required String ownerEmail}) {
    if (ownerEmail.trim().isEmpty) {
      return Stream<List<TodoEntity>>.error(
        Exception('No signed-in user — cannot load to-dos.'),
      );
    }
    final Stream<List<TodoEntity>> stream;
    try {
      // Resolving the path throws synchronously (no company / bad email).
      stream = _remote.watchTodos(ownerEmail: ownerEmail);
    } catch (error) {
      return Stream<List<TodoEntity>>.error(_clean(error, 'load to-dos'));
    }
    return stream.handleError(
      (Object error) => throw _clean(error, 'load to-dos'),
    );
  }

  @override
  Future<TodoEntity> createTodo({required TodoEntity todo}) async {
    _validate(todo);
    final String owner = _ownerEmail(todo);
    try {
      return await _remote.createTodo(todo: todo, ownerEmail: owner);
    } catch (error) {
      throw _clean(error, 'create the to-do');
    }
  }

  @override
  Future<void> updateTodo({required TodoEntity todo}) async {
    if (todo.id.isEmpty) {
      throw Exception('This to-do has no id, so it cannot be saved.');
    }
    _validate(todo);
    final String owner = _ownerEmail(todo);
    try {
      await _remote.updateTodo(todo: todo, ownerEmail: owner);
    } catch (error) {
      throw _clean(error, 'save the to-do');
    }
  }

  /// Business rules the UI also checks — repeated here so a bad write can
  /// never reach Firestore from any caller.
  void _validate(TodoEntity todo) {
    if (todo.name.trim().isEmpty) {
      throw Exception('A to-do needs a name.');
    }
    if (todo.isScheduled) {
      final DateTime? start = todo.startAt;
      final DateTime? end = todo.endAt;
      if (start == null || end == null) {
        throw Exception('A scheduled to-do needs a start and an end date.');
      }
      if (!end.isAfter(start)) {
        throw Exception('The end date must be after the start date.');
      }
    }
  }

  /// Whose folder the write goes to: the signed-in user, else the to-do's
  /// owner (to-dos are personal, so they are the same person). Refuses an
  /// anonymous write — never an unscoped path.
  String _ownerEmail(TodoEntity todo) {
    final String signedIn = _access.currentUserEmail.trim().toLowerCase();
    final String owner =
        signedIn.isNotEmpty ? signedIn : todo.ownerEmail.trim().toLowerCase();
    if (owner.isEmpty) {
      throw Exception('No signed-in user — cannot save the to-do.');
    }
    return owner;
  }

  Exception _clean(Object error, String action) {
    if (error is FirebaseException) {
      return Exception('Could not $action (${error.code}).');
    }
    if (error is Exception) return error;
    return Exception('Could not $action: $error');
  }
}
