/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: request_parts.dart
/// Purpose: Declares the value objects a request is built from —
///          `RequestApprovalStep` (one step of the approval cycle),
///          `RequestComment` (one "Inquiries And Comments" entry) and
///          `RequestAttachment` (one uploaded file).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Plain immutable Dart: no Firestore, no Flutter. `RequestPartsMapper` does
/// the mapping (FINAL SPEC §2 `Approval_Steps`, `Comments`, `Attachments`).
/// Updated: 9/10/2026 - phase 4: [RequestApprovalStep.isCancellation] (a step
/// of the cancellation round an employee starts on an approved request) and
/// [RequestComment.editedAt] + `copyWith` (edit / delete own comment).
/// Updated: 9/10/2026 - code review: [RequestApprovalStep.isSkipped] /
/// [RequestApprovalStep.isCleared].
/// Updated: 9/10/2026 - data model (owner, 9 Oct): a [RequestComment] is now
/// ONE document of `Requests/{requestId}/Comments/{commentId}` (no longer an
/// entry of the request's `Comments` list): [RequestComment.attachments]
/// (optional files) and [RequestComment.isLegacy] (read from an old request
/// document's embedded list before the migration — shown, never changed).

import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';

/// One step of the approval cycle (manager, then HR).
class RequestApprovalStep {
  const RequestApprovalStep({
    required this.step,
    this.approverEmail = '',
    this.decision = ApprovalDecision.pending,
    this.decidedAt,
    this.reason = '',
    this.isCancellation = false,
  });

  final ApprovalStepKind step;

  /// Expected approver while pending (may be '' — e.g. "any HR approver");
  /// the actual approver once decided.
  final String approverEmail;
  final ApprovalDecision decision;
  final DateTime? decidedAt;

  /// Reason of rejection (or note) entered with the decision.
  final String reason;

  /// Phase 4 (9/10/2026): the step belongs to the CANCELLATION round of an
  /// approved request (approve = accept the cancellation).
  final bool isCancellation;

  bool get isPending => decision == ApprovalDecision.pending;

  /// Closed without its own decision (9/10/2026 — see `ApprovalDecision`).
  bool get isSkipped => decision == ApprovalDecision.skipped;

  /// Approved, or passed over — the cycle may go on past it.
  bool get isCleared => decision == ApprovalDecision.approved || isSkipped;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [RequestApprovalStep]
  RequestApprovalStep copyWith({
    String? approverEmail,
    ApprovalDecision? decision,
    DateTime? decidedAt,
    String? reason,
  }) =>
      RequestApprovalStep(
        step: step,
        approverEmail: approverEmail ?? this.approverEmail,
        decision: decision ?? this.decision,
        decidedAt: decidedAt ?? this.decidedAt,
        reason: reason ?? this.reason,
        isCancellation: isCancellation,
      );
}

/// One entry of the "Inquiries And Comments" thread — since 9/10/2026 one
/// document `Requests/{requestId}/Comments/{id}` (house history format).
class RequestComment {
  const RequestComment({
    required this.id,
    required this.authorEmail,
    required this.text,
    this.createdAt,
    this.isDeleted = false,
    this.editedAt,
    this.attachments = const <RequestAttachment>[],
    this.isLegacy = false,
  });

  /// The document id (never stored inside the document); '' before the first save.
  final String id;
  final String authorEmail;
  final String text;
  final DateTime? createdAt;

  /// Soft delete (`Is_Deleted`, house rule: nothing is hard-deleted).
  final bool isDeleted;

  /// Last edit by its author (null = never edited).
  final DateTime? editedAt;

  /// Optional files (`Attachments` `{Values:[…]}`).
  final List<RequestAttachment> attachments;

  /// Read from an old request's embedded `Comments` list (not migrated
  /// yet): shown in the thread, never edited / deleted.
  final bool isLegacy;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update (edit text, soft delete).
  ///
  /// Return type: [RequestComment]
  RequestComment copyWith({String? text, bool? isDeleted, DateTime? editedAt}) =>
      RequestComment(
        id: id,
        authorEmail: authorEmail,
        text: text ?? this.text,
        createdAt: createdAt,
        isDeleted: isDeleted ?? this.isDeleted,
        editedAt: editedAt ?? this.editedAt,
        attachments: attachments,
        isLegacy: isLegacy,
      );
}

/// One uploaded file ("Request Attachments" / "Transaction Document").
class RequestAttachment {
  const RequestAttachment({
    required this.name,
    required this.url,
    this.sizeBytes = 0,
    this.uploadedAt,
  });

  final String name;
  final String url;
  final int sizeBytes;
  final DateTime? uploadedAt;
}
