import 'assignment_control_status.dart';

/// Flat (latest-values-only) representation of one Assignment_Controls
/// document, derived from the last index of every history List in
/// [AssignmentControlModel] — same convention as ControlEntity/ChampionEntity.
class AssignmentControlEntity {
  final String submissionId;
  final String controlChampionEmail;
  final String policyId;
  final String controlId;
  final String? controlOwner;
  final String? departmentManager;

  final String submissionDocument;
  final String submissionNote;
  final AssignmentControlStatus status;
  final String? departmentManagerRejectionReason;
  final double? controlScore;
  final String? controlOwnerJustification;
  final String? controlOwnerRejectionReason;

  final String lastModifier;
  final DateTime lastModificationDate;

  const AssignmentControlEntity({
    required this.submissionId,
    required this.controlChampionEmail,
    required this.policyId,
    required this.controlId,
    required this.controlOwner,
    required this.departmentManager,
    required this.submissionDocument,
    required this.submissionNote,
    required this.status,
    required this.departmentManagerRejectionReason,
    required this.controlScore,
    required this.controlOwnerJustification,
    required this.controlOwnerRejectionReason,
    required this.lastModifier,
    required this.lastModificationDate,
  });
}
