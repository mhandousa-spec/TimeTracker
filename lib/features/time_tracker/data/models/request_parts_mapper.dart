/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: request_parts_mapper.dart
/// Purpose: Declares `RequestPartsMapper` — Firestore <-> value-object mapping
///          for ONE history entry of a request's list fields
///          (`Approval_Steps`, `Comments`, `Attachments`).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Each history entry is wrapped as `{Values: [...]}` (Firestore forbids an
/// array directly inside an array). Step keys are FINAL SPEC §2 verbatim
/// (`Step`, `Approver_Email`, `Decision`, `Decision_Date_Time`, `Reason`);
/// comment / attachment keys follow the house rule "keys inside lists repeat
/// their owner" (the spec leaves them open — STATUS.md assumption A6).
/// Updated: 9/10/2026 - phase 4: `Is_Cancellation_Step` inside a step (the
/// cancellation round of an approved request; missing → false) and
/// `Comment_Edited_Date_Time` inside a comment (missing → never edited).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): the request no longer
/// stores `Comments` (they are documents of `Requests/{id}/Comments` —
/// `RequestCommentModel`); [commentsFrom] only reads an OLD document's
/// embedded list (marked `isLegacy`, read-only) and `commentsTo` is gone.

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';

typedef _F = TimeTrackerFieldCodec;

class RequestPartsMapper {
  const RequestPartsMapper._();

  static const String fStep = 'Step';
  static const String fApproverEmail = 'Approver_Email';
  static const String fDecision = 'Decision';
  static const String fDecisionDate = 'Decision_Date_Time';
  static const String fReason = 'Reason';
  static const String fIsCancellationStep = 'Is_Cancellation_Step';

  static const String fCommentId = 'Comment_Id';
  static const String fCommentAuthor = 'Comment_Author_Email';
  static const String fCommentText = 'Comment_Text';
  static const String fCommentDate = 'Comment_Date_Time';
  static const String fCommentIsDeleted = 'Is_Comment_Deleted';
  static const String fCommentEdited = 'Comment_Edited_Date_Time';

  static const String fAttachmentName = 'Attachment_Name';
  static const String fAttachmentUrl = 'Attachment_Url';
  static const String fAttachmentSize = 'Attachment_Size_Bytes';
  static const String fAttachmentDate = 'Attachment_Upload_Date';

  /// Function Name: [stepsFrom]
  ///
  /// Purpose: Parse one `Approval_Steps` entry; unknown step kinds are dropped.
  ///
  /// Return type: [List<RequestApprovalStep>]
  static List<RequestApprovalStep> stepsFrom(Object? raw) =>
      List<RequestApprovalStep>.unmodifiable(<RequestApprovalStep>[
        for (final Map<String, dynamic> m in _F.maps(raw))
          if (ApprovalStepKind.fromStorageKey(_F.string(m[fStep])) != null)
            RequestApprovalStep(
              step: ApprovalStepKind.fromStorageKey(_F.string(m[fStep]))!,
              approverEmail: _F.string(m[fApproverEmail]),
              decision: ApprovalDecision.fromStorageKey(_F.string(m[fDecision])),
              decidedAt: _F.date(m[fDecisionDate]),
              reason: _F.string(m[fReason]),
              isCancellation: _F.boolean(m[fIsCancellationStep]),
            ),
      ]);

  /// Function Name: [stepsTo]
  ///
  /// Purpose: Serialise the approval steps as one history entry.
  ///
  /// Return type: [Map<String, Object?>] — `{Values: [...]}`.
  static Map<String, Object?> stepsTo(List<RequestApprovalStep> steps) =>
      _F.wrap(<Object?>[
        for (final RequestApprovalStep s in steps)
          <String, Object?>{
            fStep: s.step.storageKey,
            fApproverEmail: s.approverEmail,
            fDecision: s.decision.storageKey,
            fDecisionDate: _F.timestamp(s.decidedAt),
            fReason: s.reason,
            fIsCancellationStep: s.isCancellation,
          },
      ]);

  /// Function Name: [commentsFrom]
  ///
  /// Purpose: Parse one entry of an OLD request's embedded `Comments` list
  /// (before the 9/10/2026 migration) — every comment is `isLegacy`.
  ///
  /// Return type: [List<RequestComment>]
  static List<RequestComment> commentsFrom(Object? raw) =>
      List<RequestComment>.unmodifiable(<RequestComment>[
        for (final Map<String, dynamic> m in _F.maps(raw))
          RequestComment(
            id: _F.string(m[fCommentId]),
            authorEmail: _F.string(m[fCommentAuthor]),
            text: _F.string(m[fCommentText]),
            createdAt: _F.date(m[fCommentDate]),
            isDeleted: _F.boolean(m[fCommentIsDeleted]),
            editedAt: _F.date(m[fCommentEdited]),
            isLegacy: true,
          ),
      ]);

  /// Function Name: [attachmentsFrom]
  ///
  /// Purpose: Parse one `Attachments` entry.
  ///
  /// Return type: [List<RequestAttachment>]
  static List<RequestAttachment> attachmentsFrom(Object? raw) =>
      List<RequestAttachment>.unmodifiable(<RequestAttachment>[
        for (final Map<String, dynamic> m in _F.maps(raw))
          RequestAttachment(
            name: _F.string(m[fAttachmentName]),
            url: _F.string(m[fAttachmentUrl]),
            sizeBytes: _F.integer(m[fAttachmentSize]),
            uploadedAt: _F.date(m[fAttachmentDate]),
          ),
      ]);

  /// Function Name: [attachmentsTo]
  ///
  /// Purpose: Serialise the attachments as one history entry.
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> attachmentsTo(List<RequestAttachment> files) =>
      _F.wrap(<Object?>[
        for (final RequestAttachment a in files)
          <String, Object?>{
            fAttachmentName: a.name,
            fAttachmentUrl: a.url,
            fAttachmentSize: a.sizeBytes,
            fAttachmentDate: _F.timestamp(a.uploadedAt),
          },
      ]);
}
