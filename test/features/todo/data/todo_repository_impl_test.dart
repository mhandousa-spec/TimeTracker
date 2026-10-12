/// Module: test / todo / data
///
///*************************** FILE INFO ****************************///
/// File Name: todo_repository_impl_test.dart
/// Purpose: Unit tests for `TodoRepositoryImpl`'s per-email scoping — every
///          read and write goes to the signed-in user's own folder, and an
///          anonymous call never reaches the data source.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/data/data_source/remote_data_source/todo_remote_data_source.dart';
import 'package:knowticed_plus/features/todo/data/repository/todo_repository_impl.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';

/// Records the folder email of every call; touches no Firestore.
class _RecordingRemote implements TodoRemoteDataSource {
  final List<String> owners = <String>[];

  @override
  Stream<List<TodoEntity>> watchTodos({required String ownerEmail}) {
    owners.add(ownerEmail);
    return const Stream<List<TodoEntity>>.empty();
  }

  @override
  Future<TodoEntity> createTodo({
    required TodoEntity todo,
    required String ownerEmail,
  }) async {
    owners.add(ownerEmail);
    return TodoEntity(id: 'new', ownerEmail: ownerEmail, name: todo.name);
  }

  @override
  Future<void> updateTodo({
    required TodoEntity todo,
    required String ownerEmail,
  }) async {
    owners.add(ownerEmail);
  }
}

class _Access implements TodoAccess {
  _Access(this.currentUserEmail);

  @override
  final String currentUserEmail;
  @override
  bool get canView => true;
  @override
  bool get canCreate => true;
  @override
  bool get canEdit => true;
  @override
  bool get canDelete => true;
  @override
  bool get canRestore => true;
}

void main() {
  const TodoEntity draft = TodoEntity(id: '', ownerEmail: '', name: 'Task');

  test('create / update write under the signed-in email, lower-cased', () async {
    final _RecordingRemote remote = _RecordingRemote();
    final TodoRepositoryImpl repo = TodoRepositoryImpl(
      remoteDataSource: remote,
      access: _Access('Me@Co.COM'),
    );
    final TodoEntity saved = await repo.createTodo(todo: draft);
    await repo.updateTodo(todo: saved);
    expect(remote.owners, <String>['me@co.com', 'me@co.com']);
  });

  test('falls back to the to-do owner when no one is signed in', () async {
    final _RecordingRemote remote = _RecordingRemote();
    final TodoRepositoryImpl repo =
        TodoRepositoryImpl(remoteDataSource: remote, access: _Access(''));
    await repo.createTodo(
      todo: const TodoEntity(id: '', ownerEmail: 'Owner@Co.com', name: 'T'),
    );
    expect(remote.owners, <String>['owner@co.com']);
  });

  test('refuses an anonymous write (no unscoped path)', () async {
    final _RecordingRemote remote = _RecordingRemote();
    final TodoRepositoryImpl repo =
        TodoRepositoryImpl(remoteDataSource: remote, access: _Access(''));
    await expectLater(repo.createTodo(todo: draft), throwsException);
    expect(remote.owners, isEmpty);
  });

  test('watchTodos with an empty email emits an error, no listen', () async {
    final _RecordingRemote remote = _RecordingRemote();
    final TodoRepositoryImpl repo =
        TodoRepositoryImpl(remoteDataSource: remote, access: _Access(''));
    await expectLater(repo.watchTodos(ownerEmail: ' '), emitsError(isException));
    expect(remote.owners, isEmpty);
  });
}
