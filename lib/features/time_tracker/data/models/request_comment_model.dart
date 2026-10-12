/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: request_comment_model.dart
/// Purpose: Declares `RequestCommentModel` — Firestore <-> `RequestComment`
///          mapping for one `Requests/{requestId}/Comments/{commentId}`
///          history document.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (data model — owner, 9 Oct)
///
/// One document per comment, house indexed-history format (every field a
/// list + `timestamps`, current value = last entry):
///   `Comment_Text` (≤ 500) ·
///   `Author_Email` · `Created_At` · `Attachments` (optional, each history
///   entry wrapped `{Values:[…]}` like the request's attachments) ·
///   `Is_Deleted` (soft delete, house rule) + the audit trio
///   (`Created_By`, `Creation_Date`, `Modified_By`).
/// An EDIT appends a revision with the new text (the old text stays in the
/// history); [editedAtOf] is the time of the last revision that changed the
/// text. A DELETE appends a revision with `Is_Deleted: true`.
/// Owner standing rule (9/10/2026): a document never stores its own id —
/// the comment id is the document id (snapshot id); an old document that
/// still has `Comment_Id` is read as before (fallback when the id is empty).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/request_parts_mapper.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';

typedef _F = TimeTrackerFieldCodec;

class RequestCommentModel {
  const RequestCommentModel._();

  /// LEGACY, read-tolerated only — never written (no self-id, 9/10/2026).
  static const String fLegacyCommentId = 'Comment_Id';
  static const String fCommentText = 'Comment_Text';
  static const String fAuthorEmail = 'Author_Email';
  static const String fCreatedAt = 'Created_At';
  static const String fAttachments = 'Attachments';
  static const String fIsDeleted = 'Is_Deleted';

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  ///
  /// Return type: [RequestComment]
  static RequestComment fromMap(String id, Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    final String storedId = _F.string(now(fLegacyCommentId));
    return RequestComment(
      id: id.isNotEmpty ? id : storedId,
      authorEmail: _F.string(now(fAuthorEmail)).trim().toLowerCase(),
      text: _F.string(now(fCommentText)),
      createdAt: _F.date(now(fCreatedAt)),
      isDeleted: _F.boolean(now(fIsDeleted)),
      editedAt: editedAtOf(map),
      attachments: RequestPartsMapper.attachmentsFrom(now(fAttachments)),
    );
  }

  /// Function Name: [editedAtOf]
  ///
  /// Purpose: When the text last changed (the write time of the latest
  /// revision whose `Comment_Text` differs from the one before), or null
  /// when it never changed.
  ///
  /// Return type: [DateTime?]
  static DateTime? editedAtOf(Map<String, dynamic> map) {
    final List<Object?> texts = TimeTrackerHistoryCodec.historyOf(map, fCommentText);
    final List<Timestamp> stamps = TimeTrackerHistoryCodec.timestampsOf(map);
    // Histories are aligned from the END (front padding).
    final int shift = stamps.length - texts.length;
    for (int i = texts.length - 1; i > 0; i--) {
      if (texts[i] != texts[i - 1]) {
        final int at = i + shift;
        if (at < 0 || at >= stamps.length) return null;
        final Timestamp t = stamps[at];
        return t.millisecondsSinceEpoch <= 0 ? null : t.toDate();
      }
    }
    return null;
  }

  /// Function Name: [row]
  ///
  /// Purpose: Field name -> new value for every field of one history row
  /// (no self-id — the document id IS the comment id).
  ///
  /// Parameters:
  ///   [RequestComment] comment
  ///   [String] id: the document id (not stored inside the document).
  ///   [TimeTrackerAudit] audit
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> row(
    RequestComment comment, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fCommentText: comment.text,
        fAuthorEmail: comment.authorEmail.trim().toLowerCase(),
        fCreatedAt: _F.timestamp(comment.createdAt),
        fAttachments: RequestPartsMapper.attachmentsTo(comment.attachments),
        fIsDeleted: comment.isDeleted,
        ...audit.fields,
      };
}
