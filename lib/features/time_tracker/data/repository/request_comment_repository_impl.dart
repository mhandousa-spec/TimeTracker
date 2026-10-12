/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: request_comment_repository_impl.dart
/// Purpose: Declares `RequestCommentRepositoryImpl` — the comments of a
///          request in `Modules/time_tracker/Requests/{requestId}/Comments/
///          {commentId}`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (data model — owner, 9 Oct)
///
/// Same history write as every Time Tracker collection
/// (`TimeTrackerRemoteDataSource.appendRow`: read in a transaction, append
/// one row to every field + `timestamps`). The collection depends on the
/// request, so this repository names the path on each call
/// (`TimeTrackerFirestorePaths.requestComments`) instead of extending
/// `TimeTrackerHistoryRepository` (one fixed collection). Edit / delete
/// re-check the AUTHOR on the stored comment inside the transaction
/// (`RequestCommentRules`), so a stale copy can never change someone else's
/// comment. Firestore errors become clean `Exception`s here (try/catch
/// lives in repositories and cubits only).

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_comment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_comment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_comment_rules.dart';

class RequestCommentRepositoryImpl implements RequestCommentBaseRepository {
  RequestCommentRepositoryImpl({
    required TimeTrackerRemoteDataSource remoteDataSource,
    required TimeTrackerAccess access,
  })  : _remote = remoteDataSource,
        _access = access;

  final TimeTrackerRemoteDataSource _remote;
  final TimeTrackerAccess _access;

  @override
  Stream<List<RequestComment>> watchComments({required String requestId}) {
    final Stream<List<TimeTrackerDocument>> docs;
    try {
      docs = _remote.watchCollection(TimeTrackerFirestorePaths.requestComments(requestId));
    } catch (error) {
      return Stream<List<RequestComment>>.error(_clean(error, 'load the comments'));
    }
    return docs
        .map((List<TimeTrackerDocument> list) => List<RequestComment>.unmodifiable(<RequestComment>[
              for (final TimeTrackerDocument d in list) RequestCommentModel.fromMap(d.id, d.data),
            ]))
        .handleError((Object error) => throw _clean(error, 'load the comments'));
  }

  @override
  Future<RequestComment> addComment({required String requestId, required RequestComment comment}) {
    final String text = comment.text;
    return _write(
      requestId,
      id: null,
      action: 'save the comment',
      next: (RequestComment? stored, String actor) {
        if (stored != null) throw StateError('This comment already exists.');
        if (comment.authorEmail.trim().toLowerCase() != actor) {
          throw StateError('A comment is written by the signed-in user only.');
        }
        return RequestComment(
          id: '',
          authorEmail: actor,
          text: RequestCommentRules.checked(text),
          createdAt: comment.createdAt ?? DateTime.now(),
          attachments: comment.attachments,
        );
      },
    );
  }

  @override
  Future<RequestComment> editComment({
    required String requestId,
    required String commentId,
    required String editorEmail,
    required String text,
    required DateTime now,
  }) =>
      _write(
        requestId,
        id: commentId,
        action: 'save the comment',
        next: (RequestComment? stored, String actor) =>
            RequestCommentRules.edited(_existing(stored), editorEmail: _editor(editorEmail, actor), text: text, now: now),
      );

  @override
  Future<RequestComment> deleteComment({
    required String requestId,
    required String commentId,
    required String editorEmail,
  }) =>
      _write(
        requestId,
        id: commentId,
        action: 'delete the comment',
        next: (RequestComment? stored, String actor) =>
            RequestCommentRules.deleted(_existing(stored), editorEmail: _editor(editorEmail, actor)),
      );

  static RequestComment _existing(RequestComment? stored) {
    if (stored == null) throw StateError('This comment no longer exists.');
    return stored;
  }

  /// The editor must be the signed-in user (who is stamped `Modified_By`).
  static String _editor(String editorEmail, String actor) {
    if (editorEmail.trim().toLowerCase() != actor) {
      throw StateError('Only the author can change this comment.');
    }
    return actor;
  }

  /// One history row on comment [id] (null = a new auto id) of [requestId];
  /// [next] decides the row from the STORED comment inside the transaction
  /// (throwing aborts the write).
  Future<RequestComment> _write(
    String requestId, {
    required String? id,
    required String action,
    required RequestComment Function(RequestComment? stored, String actor) next,
  }) async {
    final String actor = _access.currentUserEmail.trim().toLowerCase();
    if (actor.isEmpty) throw Exception('No signed-in user — cannot $action.');
    try {
      final TimeTrackerDocument doc = await _remote.appendRow(
        relativePath: TimeTrackerFirestorePaths.requestComments(requestId),
        id: id,
        mustExist: id != null,
        row: (String docId, Map<String, dynamic>? stored) => RequestCommentModel.row(
          next(stored == null ? null : RequestCommentModel.fromMap(docId, stored), actor),
          id: docId,
          audit: TimeTrackerAudit.next(stored, actor: actor, now: DateTime.now()),
        ),
      );
      return RequestCommentModel.fromMap(doc.id, doc.data);
    } catch (error) {
      throw _clean(error, action);
    }
  }

  static Exception _clean(Object error, String action) {
    if (error is FirebaseException) return Exception('Could not $action (${error.code}).');
    if (error is StateError) return Exception(error.message);
    if (error is Exception) return error;
    return Exception('Could not $action: $error');
  }
}
