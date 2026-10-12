import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_entity.dart';

abstract class MyAuditRepository {
  Future<Either<Failure, List<MyAuditEntity>>> getAllMyAudits({
    required String moduleId,
  });

  /// Creates the My_Audit doc (first time a manager approves this
  /// control+champion's request) or, if one already exists (a prior cycle
  /// was rejected and resubmitted/re-approved), appends a fresh "Pending"
  /// revision.
  Future<Either<Failure, MyAuditEntity>> createOrUpdatePending({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String editorEmail,
  });

  /// Records the Owner's Pending-stage decision: [status] should be
  /// `MyAuditStatus.outstanding.value` (Approve) or
  /// `MyAuditStatus.rejected.value` (Reject, with [reasonOfRejection] required).
  Future<Either<Failure, MyAuditEntity>> decide({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String status,
    String? reasonOfRejection,
    required String editorEmail,
  });

  /// Records a score (Outstanding/Scored -> Scored). [justification] is optional.
  Future<Either<Failure, MyAuditEntity>> applyScore({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required double score,
    String? justification,
    required String editorEmail,
  });
}
