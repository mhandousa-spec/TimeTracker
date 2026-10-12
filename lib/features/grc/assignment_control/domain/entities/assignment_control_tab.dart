/// The 6 tabs shown on the Champion's Assignment Controls list. Unlike
/// AssignmentControlStatus, `pending` and `overdue` here are real, always
/// re-derived UI states — see computeAssignmentControlTab.
enum AssignmentControlTab {
  pending,
  submitted,
  inReview,
  rejected,
  approved,
  overdue;

  String get label {
    switch (this) {
      case AssignmentControlTab.pending:
        return 'Pending';
      case AssignmentControlTab.submitted:
        return 'Submitted';
      case AssignmentControlTab.inReview:
        return 'In Review';
      case AssignmentControlTab.rejected:
        return 'Rejected';
      case AssignmentControlTab.approved:
        return 'Approved';
      case AssignmentControlTab.overdue:
        return 'Overdue';
    }
  }
}
