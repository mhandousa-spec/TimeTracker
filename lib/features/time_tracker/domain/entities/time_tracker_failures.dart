/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_failures.dart
/// Purpose: Declares the business refusals a Time Tracker save can end in —
///          `TimeTrackerRecordChanged` (someone else saved the record first)
///          and `TimeTrackerNoVacationBalance` (a deducting request without
///          a stored balance).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (code review fixes)
///
/// Code review finding 2 (9/10/2026): a decision is a compare-and-set — it
/// is written only when the stored request still is the one the approver
/// read; otherwise nothing is saved and [TimeTrackerRecordChanged] tells
/// the user to look again (two approvers / a double tap can no longer
/// deduct twice or drop a comment).
/// Code review finding 10 (owner rule, 9/10/2026): a missing vacation
/// balance means 0 days remaining for a deducting request type — the
/// employee is told to contact HR, the approver to set the balance first.
/// Updated: 9/10/2026 - owner round 9 option b: balances are kept per year
/// and a request may span two years — each year must cover its share:
/// [TimeTrackerNoVacationBalance.year] names a year with no balance and
/// [TimeTrackerYearBalanceShort] a year with too few days left. (The earlier
/// cross-year block, `TimeTrackerCrossYearLeave`, is gone.)
///
/// Plain Dart (no Firestore, no Flutter). Messages are English fallbacks;
/// the screens show their own translated text for each type.

/// The record was changed by someone else since it was read.
class TimeTrackerRecordChanged implements Exception {
  const TimeTrackerRecordChanged();

  @override
  String toString() => 'This request was just changed by someone else. Please check it and try again.';
}

/// A request type that deducts from the vacation balance, for an employee
/// who has no balance stored (0 days remaining).
class TimeTrackerNoVacationBalance implements Exception {
  const TimeTrackerNoVacationBalance({this.year});

  /// The year with no balance document (null = not known).
  final int? year;

  @override
  String toString() => year == null
      ? 'No vacation balance is set for this employee yet. Please contact HR.'
      : 'No vacation balance is set for $year. Please contact HR.';
}

/// ADDED 9/10/2026 (owner round 9 option b): a year that cannot cover its
/// share of a deducting request ("2027 has only 2 days left") — refused by
/// the form, the submit and the final approval (nothing written).
class TimeTrackerYearBalanceShort implements Exception {
  const TimeTrackerYearBalanceShort({required this.year, required this.daysLeft});

  final int year;
  final double daysLeft;

  @override
  String toString() => '$year has only $daysLeft vacation days left.';
}
