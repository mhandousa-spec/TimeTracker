import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_entity.dart';

abstract class ApprovalRepository {
  Future<Either<Failure, List<ApprovalEntity>>> getAllApprovals({
    required String moduleId,
  });

  /// Creates the Approval doc (first submission) or, if one already exists
  /// for this control+champion pair, appends a fresh "Pending" revision
  /// (a resubmit after a prior rejection).
  Future<Either<Failure, ApprovalEntity>> createOrUpdatePending({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String editorEmail,
  });

  /// Records the manager's decision. [reasonOfRejection] is required when
  /// rejecting; [approvalComment] is an optional extra when approving.
  Future<Either<Failure, ApprovalEntity>> decide({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String status,
    String? reasonOfRejection,
    String? approvalComment,
    required String editorEmail,
  });
}
