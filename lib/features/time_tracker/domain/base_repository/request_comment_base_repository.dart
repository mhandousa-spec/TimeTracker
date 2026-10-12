/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: request_comment_base_repository.dart
/// Purpose: Declares `RequestCommentBaseRepository` — the contract for the
///          comments of a request (`Requests/{requestId}/Comments`).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (data model — owner, 9 Oct)
///
/// One document per comment (house history format): a comment no longer
/// rewrites the request (its status / steps) and a request no longer drags
/// its whole thread along on every write. Edit = a new revision of the
/// comment's document; delete = a revision with `Is_Deleted` (soft, house
/// rule). The author check of an edit / delete runs INSIDE the write's
/// transaction against the stored comment. Who may comment at all is the
/// service's gate (`RequestService.mayComment`).
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';

abstract class RequestCommentBaseRepository {
  /// Function Name: [watchComments]
  ///
  /// Purpose: Live list of every comment of [requestId] (deleted ones
  /// included — `RequestCommentRules.thread` hides them).
  ///
  /// Return type: [Stream<List<RequestComment>>]
  Stream<List<RequestComment>> watchComments({required String requestId});

  /// Function Name: [addComment]
  ///
  /// Purpose: Create a new comment document (auto id = the comment id; the
  /// id is never stored inside the document).
  ///
  /// Return type: [Future<RequestComment>] — as stored.
  Future<RequestComment> addComment({required String requestId, required RequestComment comment});

  /// Function Name: [editComment]
  ///
  /// Purpose: Append a revision with the new text, refused (`StateError`,
  /// nothing written) unless the STORED comment is [editorEmail]'s and not
  /// deleted.
  ///
  /// Return type: [Future<RequestComment>] — as stored.
  Future<RequestComment> editComment({
    required String requestId,
    required String commentId,
    required String editorEmail,
    required String text,
    required DateTime now,
  });

  /// Function Name: [deleteComment]
  ///
  /// Purpose: Soft delete (a revision with `Is_Deleted: true`), same author
  /// check as [editComment].
  ///
  /// Return type: [Future<RequestComment>] — as stored.
  Future<RequestComment> deleteComment({
    required String requestId,
    required String commentId,
    required String editorEmail,
  });
}
