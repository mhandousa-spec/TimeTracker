import 'approval_status.dart';

/// Flat (latest-values-only) representation of one Approval document,
/// derived from the last index of every history List in [ApprovalModel].
class ApprovalEntity {
  final String requestId;
  final String submissionId;
  final ApprovalStatus status;
  final String? reasonOfRejection;
  final String? approvalComment;
  final String lastModifier;
  final DateTime lastModificationDate;

  const ApprovalEntity({
    required this.requestId,
    required this.submissionId,
    required this.status,
    required this.reasonOfRejection,
    required this.approvalComment,
    required this.lastModifier,
    required this.lastModificationDate,
  });
}
