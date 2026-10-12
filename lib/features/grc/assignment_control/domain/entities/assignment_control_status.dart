import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

/// Lifecycle status of one Assignment_Controls submission cycle. Only
/// `submitted`, `inReview`, `rejected`, and `approved` are ever persisted by
/// this feature (Pending/Overdue are always derived, never stored — see the
/// design spec) — `pending`/`overdue` exist here only so `fromString` stays
/// total and forward-compatible with the future Approvals/My Audits specs.
enum AssignmentControlStatus {
  pending,
  submitted,
  inReview,
  rejected,
  approved,
  overdue;

  String get value {
    switch (this) {
      case AssignmentControlStatus.pending:
        return 'Pending';
      case AssignmentControlStatus.submitted:
        return 'Submitted';
      case AssignmentControlStatus.inReview:
        return 'In review';
      case AssignmentControlStatus.rejected:
        return 'Rejected';
      case AssignmentControlStatus.approved:
        return 'Approved';
      case AssignmentControlStatus.overdue:
        return 'Overdue';
    }
  }

  /// Display label for this status — same strings as [value] except
  /// "In review" is title-cased, matching `AssignmentControlTab.label`'s
  /// existing convention (both feed a `GrcStatusPill`, one for a page-level
  /// tab, one for a single Submission History card via
  /// [AssignmentControlStatusStyle]).
  String get label {
    switch (this) {
      case AssignmentControlStatus.pending:
        return 'Pending';
      case AssignmentControlStatus.submitted:
        return 'Submitted';
      case AssignmentControlStatus.inReview:
        return 'In Review';
      case AssignmentControlStatus.rejected:
        return 'Rejected';
      case AssignmentControlStatus.approved:
        return 'Approved';
      case AssignmentControlStatus.overdue:
        return 'Overdue';
    }
  }

  static AssignmentControlStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'submitted':
        return AssignmentControlStatus.submitted;
      case 'in review':
        return AssignmentControlStatus.inReview;
      case 'rejected':
        return AssignmentControlStatus.rejected;
      case 'approved':
        return AssignmentControlStatus.approved;
      case 'overdue':
        return AssignmentControlStatus.overdue;
      case 'pending':
      default:
        return AssignmentControlStatus.pending;
    }
  }
}

/// Visual identity (color + icon) for one [AssignmentControlStatus] at the
/// single-revision level — used by the Submission History cards (one pill
/// per past submission). Unlike `AssignmentControlTabStyle`/`MyAuditTabStyle`,
/// which style a page's overall *current* tab, this styles one specific
/// historical revision's own outcome.
class AssignmentControlStatusStyle {
  final Color color;
  final IconData icon;

  const AssignmentControlStatusStyle({required this.color, required this.icon});

  static AssignmentControlStatusStyle of(AssignmentControlStatus status) {
    switch (status) {
      case AssignmentControlStatus.submitted:
        return AssignmentControlStatusStyle(
            color: AppColors.warning, icon: Icons.upload_file);
      case AssignmentControlStatus.rejected:
        return const AssignmentControlStatusStyle(
            color: Colors.red, icon: Icons.block);
      case AssignmentControlStatus.approved:
        return const AssignmentControlStatusStyle(
            color: Colors.green, icon: Icons.check_circle);
      case AssignmentControlStatus.pending:
      case AssignmentControlStatus.inReview:
      case AssignmentControlStatus.overdue:
        return AssignmentControlStatusStyle(
            color: AppColors.warning, icon: Icons.schedule);
    }
  }
}
