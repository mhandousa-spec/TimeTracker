/// Module: todo / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: todo_remote_data_source.dart
/// Purpose: Declares `TodoRemoteDataSource` — the only class in the module
///          that talks to the to-do documents in Firestore.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Documents live in the owner's own folder
/// `Demo/{companyId}/Modules/todo/{email}/{todoId}` (see
/// `TodoFirestorePaths.todosOf`), so reading "my to-dos" is a plain listen on
/// that collection — no owner filter, no index.
///
/// Throws on failure; turning throws into clean messages is the repository's
/// job, so there is no try/catch here (same split as db3).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/todo/data/models/todo_model.dart';
import 'package:knowticed_plus/features/todo/domain/constants/todo_firestore_paths.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';

class TodoRemoteDataSource {
  TodoRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// `Demo/{companyId}/Modules/todo/{email}`.
  ///
  /// With no company signed in the path collapses to a different, top-level
  /// collection that Firestore happily accepts — so refuse instead (db1
  /// rule). An empty email throws `StateError` in `TodoFirestorePaths`.
  CollectionReference<Map<String, dynamic>> _todosOf(String email) {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the '
        'to-do collection path cannot be resolved.',
      );
    }
    return _firestore.collection(getBaseUrl(TodoFirestorePaths.todosOf(email)));
  }

  /// Function Name: [watchTodos]
  ///
  /// Purpose: Live read of every document in the owner's `Todos`
  /// collection. Sorting is done client-side by the cubits.
  ///
  /// Parameters:
  ///   [String] ownerEmail
  ///
  /// Return type: [Stream<List<TodoEntity>>]
  Stream<List<TodoEntity>> watchTodos({required String ownerEmail}) {
    final String email = TodoFirestorePaths.emailKey(ownerEmail);
    return _todosOf(email).snapshots().map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    TodoModel.fromSnapshot(doc, ownerEmail: email),
              )
              .toList(growable: false),
        );
  }

  /// Function Name: [createTodo]
  ///
  /// Purpose: Write the first version of a new document (every field a
  /// one-entry history). The written map holds no server sentinels, so it is
  /// parsed back directly instead of re-reading the document.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [String] ownerEmail: the folder the document is written under.
  ///
  /// Return type: [Future<TodoEntity>]
  Future<TodoEntity> createTodo({
    required TodoEntity todo,
    required String ownerEmail,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _todosOf(ownerEmail).doc();
    final DateTime now = DateTime.now();
    final Map<String, dynamic> data = TodoModel.toCreateMap(
      todo,
      id: ref.id,
      now: now,
    );
    await ref.set(data);
    return TodoModel.fromMap(
      ref.id,
      data,
      ownerEmail: TodoFirestorePaths.emailKey(ownerEmail),
    );
  }

  /// Function Name: [updateTodo]
  ///
  /// Purpose: Append one history row in a transaction: read the stored
  /// document, append the new value of EVERY field + `timestamps`, and write
  /// the whole document back (a full `set`).
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [String] ownerEmail: the folder the document lives under.
  ///
  /// Return type: [Future<void>]
  Future<void> updateTodo({
    required TodoEntity todo,
    required String ownerEmail,
  }) {
    final DocumentReference<Map<String, dynamic>> ref =
        _todosOf(ownerEmail).doc(todo.id);
    return _firestore.runTransaction<void>((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> stored = await tx.get(ref);
      if (!stored.exists) {
        throw StateError('This to-do no longer exists.');
      }
      tx.set(
        ref,
        TodoModel.toAppendMap(stored.data(), todo, now: DateTime.now()),
      );
    });
  }
}
