import 'my_audit_status.dart';

/// Flat (latest-values-only) representation of one My_Audit document,
/// derived from the last index of every history List in [MyAuditModel].
class MyAuditEntity {
  final String auditId;
  final String requestId;
  final String submissionId;
  final MyAuditStatus status;
  final double? controlScore;
  final String? controlOwnerJustification;
  final String? controlOwnerReasonOfRejection;
  final String lastModifier;
  final DateTime lastModificationDate;

  const MyAuditEntity({
    required this.auditId,
    required this.requestId,
    required this.submissionId,
    required this.status,
    required this.controlScore,
    required this.controlOwnerJustification,
    required this.controlOwnerReasonOfRejection,
    required this.lastModifier,
    required this.lastModificationDate,
  });
}
