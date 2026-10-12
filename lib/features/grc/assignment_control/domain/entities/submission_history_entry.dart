import 'assignment_control_status.dart';

/// One distinct file ever submitted for a Control+Champion pair, derived by
/// [AssignmentControlModel.toSubmissionHistory]. Consecutive revisions that
/// share the same `submissionDocument` value (e.g. a Reject, which reuses
/// the previous file rather than replacing it) collapse into a single
/// entry, carrying that file's *final* status/rejection reason — whatever
/// happened to it right before a newer file replaced it, or its current
/// outcome if it's the most recent file.
class SubmissionHistoryEntry {
  final String document;
  final String note;
  final DateTime submittedDate;
  final AssignmentControlStatus status;
  final String? rejectionReason;

  const SubmissionHistoryEntry({
    required this.document,
    required this.note,
    required this.submittedDate,
    required this.status,
    required this.rejectionReason,
  });
}
