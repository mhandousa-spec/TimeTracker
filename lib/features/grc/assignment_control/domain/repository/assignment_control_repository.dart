import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/submission_history_entry.dart';

abstract class AssignmentControlRepository {
  /// Returns Right(null) — not an error — when no submission has ever been
  /// made for this control+champion pair yet (the Pending/Overdue state).
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControl({
    required String moduleId,
    required String controlId,
    required String championEmail,
  });

  /// Fetches an Assignment Control directly by its Firestore doc id (the
  /// same id as [AssignmentControlEntity.submissionId]) — used by the
  /// Approvals feature, which only has that raw id (an
  /// [ApprovalEntity.submissionId]), not the separate controlId/championEmail
  /// pair the other lookup method needs.
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControlById({
    required String moduleId,
    required String id,
  });

  /// Records a Department Manager's (or, in a future spec, Control Owner's)
  /// decision by appending one more revision to the Assignment Control.
  /// [newStatus] should be [AssignmentControlStatus.inReview] (Approve) or
  /// [AssignmentControlStatus.rejected] (Reject); [rejectionReason] is
  /// required for the latter.
  Future<Either<Failure, AssignmentControlEntity>> applyManagerDecision({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required AssignmentControlStatus newStatus,
    String? rejectionReason,
    required String editorEmail,
  });

  /// Records the Control Owner's score (from My Audits), appending one more
  /// revision to the Assignment Control and setting its status to the
  /// terminal [AssignmentControlStatus.approved] — the final state of the
  /// whole Champion/Manager/Owner workflow. [justification] is optional.
  Future<Either<Failure, AssignmentControlEntity>> applyOwnerScore({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required double score,
    String? justification,
    required String editorEmail,
  });

  Future<Either<Failure, AssignmentControlEntity>> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required String? controlOwnerEmail,
    required String? departmentManagerEmail,
    required File documentFile,
    required String note,
    required String editorEmail,
  });

  /// Derives one entry per distinct file ever submitted for this
  /// control+champion pair, newest file first — see
  /// [AssignmentControlModel.toSubmissionHistory]. Returns an empty list
  /// (not a failure) when nothing has ever been submitted.
  Future<Either<Failure, List<SubmissionHistoryEntry>>> getSubmissionHistory({
    required String moduleId,
    required String controlId,
    required String championEmail,
  });
}
