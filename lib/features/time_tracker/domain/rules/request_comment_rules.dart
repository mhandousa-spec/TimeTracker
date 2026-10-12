/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: request_comment_rules.dart
/// Purpose: Declares `RequestCommentRules` — the "Inquiries And Comments"
///          thread of a request: what is shown, add, edit / delete your OWN
///          comment.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Inventory §C (`661:30544`): comment bubbles (author, date "24 Jan 2024 At
/// 12:00 PM"), own comments have Edit / Delete, input "Write a Comment".
/// Delete is soft (house rule: nothing is hard-deleted). Who may comment at
/// all (`Comment_On_Requests` for the requester, `Comment_On_Approvals` for
/// an involved approver) is checked by the service. Pure Dart, unit-tested.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): each comment is its own
/// document (`Requests/{id}/Comments/{commentId}`), so the rules work on ONE
/// comment ([create] / [edited] / [deleted]) instead of rewriting the
/// request; [thread] merges the sub-collection with an old request's
/// embedded list (read-only, until the migration moves it — same id wins).

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';

class RequestCommentRules {
  const RequestCommentRules._();

  /// Longest comment (same 500 as every text area of the module).
  static const int maxLength = 500;

  static String _norm(String email) => email.trim().toLowerCase();

  /// Function Name: [thread]
  ///
  /// Purpose: The thread as shown: the stored comments plus the [legacy]
  /// ones not stored yet (a migrated comment keeps its id), without deleted
  /// ones, oldest first.
  ///
  /// Return type: [List<RequestComment>]
  static List<RequestComment> thread(
    List<RequestComment> stored, {
    List<RequestComment> legacy = const <RequestComment>[],
  }) {
    final Set<String> ids = <String>{for (final RequestComment c in stored) c.id};
    final List<RequestComment> all = <RequestComment>[
      ...stored,
      for (final RequestComment c in legacy)
        if (!ids.contains(c.id)) c,
    ].where((RequestComment c) => !c.isDeleted).toList();
    final DateTime never = DateTime.fromMillisecondsSinceEpoch(0);
    all.sort((RequestComment a, RequestComment b) {
      final int byTime = (a.createdAt ?? never).compareTo(b.createdAt ?? never);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return List<RequestComment>.unmodifiable(all);
  }

  /// Function Name: [canModify]
  ///
  /// Purpose: Only the author edits / deletes a (not deleted, not legacy)
  /// comment.
  ///
  /// Return type: [bool]
  static bool canModify(RequestComment comment, String viewerEmail) =>
      !comment.isDeleted &&
      !comment.isLegacy &&
      _norm(viewerEmail).isNotEmpty &&
      _norm(comment.authorEmail) == _norm(viewerEmail);

  /// Function Name: [create]
  ///
  /// Purpose: A new comment by [authorEmail] (id '' — the repository
  /// assigns the document id).
  ///
  /// Return type: [RequestComment] — throws `StateError` for an empty or
  /// too-long text.
  static RequestComment create({
    required String authorEmail,
    required String text,
    required DateTime now,
    List<RequestAttachment> attachments = const <RequestAttachment>[],
  }) =>
      RequestComment(
        id: '',
        authorEmail: _norm(authorEmail),
        text: checked(text),
        createdAt: now,
        attachments: List<RequestAttachment>.unmodifiable(attachments),
      );

  /// Function Name: [edited]
  ///
  /// Purpose: [stored] re-worded by its author [editorEmail].
  ///
  /// Return type: [RequestComment] — throws `StateError` when it is not
  /// [editorEmail]'s comment or the text is invalid.
  static RequestComment edited(
    RequestComment stored, {
    required String editorEmail,
    required String text,
    required DateTime now,
  }) {
    _requireAuthor(stored, editorEmail);
    return stored.copyWith(text: checked(text), editedAt: now);
  }

  /// Function Name: [deleted]
  ///
  /// Purpose: [stored] soft-deleted by its author [editorEmail].
  ///
  /// Return type: [RequestComment] — throws `StateError` when it is not
  /// [editorEmail]'s comment.
  static RequestComment deleted(RequestComment stored, {required String editorEmail}) {
    _requireAuthor(stored, editorEmail);
    return stored.copyWith(isDeleted: true);
  }

  static void _requireAuthor(RequestComment comment, String editorEmail) {
    if (!canModify(comment, editorEmail)) {
      throw StateError('Only the author can change this comment.');
    }
  }

  /// Function Name: [checked]
  ///
  /// Purpose: The trimmed text, refused when empty or longer than
  /// [maxLength].
  ///
  /// Return type: [String] — throws `StateError`.
  static String checked(String text) {
    final String body = text.trim();
    if (body.isEmpty) throw StateError('Write a comment first.');
    if (body.length > maxLength) throw StateError('The comment is too long.');
    return body;
  }
}
