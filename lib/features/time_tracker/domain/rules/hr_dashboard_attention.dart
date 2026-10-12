/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_attention.dart
/// Purpose: Declares `HrNeedsAttention` (+ `HrAbsenceAlert`) — the HR
///          dashboard's "Needs attention" card: what HR should act on today.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5 — owner asked to innovate)
///
/// Four lists, all inside the dashboard's scope and filters:
///   * approvals pending more than 2 days — requests whose CURRENT step has
///     waited longer than `TimeTrackerReminderRules.approvalOverdueAfter`
///     (same clock as the phase-6 reminder: since the previous step's
///     decision, else the submission), oldest first;
///   * employees with 3+ absences this month — `HrDayBook` absences of the
///     current calendar month (stored and unstored, see that file), most
///     first;
///   * missing check-outs yesterday — yesterday's days that still hold an
///     open session which is not an overnight shift still running;
///   * transactions waiting — attendance corrections still pending (or
///     under review), oldest first.
/// Pure Dart — unit-tested.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_days.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/reminder_sweep_rules.dart';

/// One employee with too many absences this month.
class HrAbsenceAlert {
  const HrAbsenceAlert({required this.email, required this.count});

  final String email;
  final int count;
}

class HrNeedsAttention {
  const HrNeedsAttention({
    this.overdueApprovals = const <TimeTrackerRequest>[],
    this.frequentAbsences = const <HrAbsenceAlert>[],
    this.missingCheckOuts = const <AttendanceDay>[],
    this.waitingTransactions = const <TimeTrackerRequest>[],
  });

  /// "3+ absences this month" (brief §A).
  static const int absenceThreshold = 3;

  final List<TimeTrackerRequest> overdueApprovals;
  final List<HrAbsenceAlert> frequentAbsences;
  final List<AttendanceDay> missingCheckOuts;
  final List<TimeTrackerRequest> waitingTransactions;

  static const HrNeedsAttention empty = HrNeedsAttention();

  bool get isEmpty =>
      overdueApprovals.isEmpty && frequentAbsences.isEmpty && missingCheckOuts.isEmpty && waitingTransactions.isEmpty;

  static String _norm(String v) => v.trim().toLowerCase();

  /// Function Name: [compute]
  ///
  /// Purpose: The four lists for the employees in [emails].
  ///
  /// Parameters:
  ///   [Set<String>] emails: the scoped employees (lower-cased).
  ///   [HrDayBook] book: their days (must hold this month + yesterday).
  ///   [List<TimeTrackerRequest>] requests: any requests (scoped here).
  ///
  /// Return type: [HrNeedsAttention]
  static HrNeedsAttention compute({
    required Set<String> emails,
    required HrDayBook book,
    required List<TimeTrackerRequest> requests,
  }) {
    final DateTime now = book.now;
    final List<(TimeTrackerRequest, DateTime)> overdue = <(TimeTrackerRequest, DateTime)>[];
    final List<TimeTrackerRequest> transactions = <TimeTrackerRequest>[];
    for (final TimeTrackerRequest r in requests) {
      if (!emails.contains(_norm(r.requesterEmail))) continue;
      final DateTime? since = TimeTrackerHomeStatsRules.waitingSince(r);
      if (since != null && now.difference(since) > TimeTrackerReminderRules.approvalOverdueAfter) {
        overdue.add((r, since));
      }
      if (r.isTransaction && (r.status == RequestStatus.pending || r.status == RequestStatus.underReview)) {
        transactions.add(r);
      }
    }
    overdue.sort(((TimeTrackerRequest, DateTime) a, (TimeTrackerRequest, DateTime) b) {
      final int bySince = a.$2.compareTo(b.$2);
      return bySince != 0 ? bySince : a.$1.id.compareTo(b.$1.id);
    });
    transactions.sort(_oldestFirst);

    final DateSpan month = DateSpan.of(DashboardRange.month, now);
    final List<HrAbsenceAlert> absences = <HrAbsenceAlert>[];
    final List<AttendanceDay> missing = <AttendanceDay>[];
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    for (final String email in emails) {
      final int absent = book.countIn(email, month)[HrDayKind.absent] ?? 0;
      if (absent >= absenceThreshold) absences.add(HrAbsenceAlert(email: email, count: absent));
      final AttendanceDay? day = book.record(email, yesterday);
      if (day != null && day.openSession != null && !book.runningNow(day)) missing.add(day);
    }
    absences.sort((HrAbsenceAlert a, HrAbsenceAlert b) {
      final int byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.email.compareTo(b.email);
    });
    missing.sort((AttendanceDay a, AttendanceDay b) => a.employeeEmail.compareTo(b.employeeEmail));
    return HrNeedsAttention(
      overdueApprovals: List<TimeTrackerRequest>.unmodifiable(
        overdue.map(((TimeTrackerRequest, DateTime) e) => e.$1),
      ),
      frequentAbsences: List<HrAbsenceAlert>.unmodifiable(absences),
      missingCheckOuts: List<AttendanceDay>.unmodifiable(missing),
      waitingTransactions: List<TimeTrackerRequest>.unmodifiable(transactions),
    );
  }

  static int _oldestFirst(TimeTrackerRequest a, TimeTrackerRequest b) {
    final DateTime x = a.audit.createdAt ?? a.startAt;
    final DateTime y = b.audit.createdAt ?? b.startAt;
    final int byDate = x.compareTo(y);
    return byDate != 0 ? byDate : a.id.compareTo(b.id);
  }
}
