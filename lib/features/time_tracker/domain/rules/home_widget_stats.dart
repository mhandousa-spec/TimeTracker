/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_stats.dart
/// Purpose: Declares `TimeTrackerHomeStats` — every figure the seven Time
///          Tracker home cards draw — and `TimeTrackerHomeStatsRules`, which
///          computes them from the signed-in employee's attendance days and
///          the company's requests.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 6 (brief §A). Figma "Widgets" column (inventory §5):
///   * Presence `2583:26557` — Present · Absence · Late (THIS MONTH);
///   * Totals `2583:27002` — Total Present · Total Requests · Total Late ·
///     Vacations (THIS MONTH);
///   * Tracker Status `2583:26899` / My Request `2583:26771` — my requests
///     by status, all time (the Requests tab counters; Under Review still
///     waits for a decision, so it counts as Pending — the cards have no
///     Under Review tile);
///   * Tracker Approver `2583:26697` — the Approvals tab counters
///     (`ApprovalInbox`, Under Review as Pending) and the requests whose
///     CURRENT step waits for me (Approve / Reject from the card).
///
/// Month figures reuse `PersonalDashboardStats.compute` over the month span
/// (so Present / Absence / Late / Total Requests equal the personal
/// dashboard's Month range): Present counts attended days incl. late ones;
/// requests are counted by their start date, transactions excluded.
/// Vacations = distinct days of the month covered by an approved leave
/// (approved or under a cancellation review), or stored with a leave status.
/// Pure Dart — unit-tested.
/// Updated: 9/10/2026 - code review: Vacations counts only WHOLE days off
/// (finding 8); Absence ignores untrusted absent rows when the schedule is
/// given (finding 1); [waitingSince] reads the current round only (5).
/// Updated: 9/10/2026 - QA KP-TT-013: Present / Absence / Late use the HR
/// view's day rule (`HrDayBook`) at `now`, with the assignment start.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absence_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/personal_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

/// Every figure of the Time Tracker home cards.
class TimeTrackerHomeStats {
  const TimeTrackerHomeStats({
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.vacationDays = 0,
    this.monthRequests = 0,
    this.myCounts = const <RequestBucket, int>{},
    this.approvalCounts = const <RequestBucket, int>{},
    this.waitingForMe = const <TimeTrackerRequest>[],
  });

  /// This month.
  final int present;
  final int absent;
  final int late;
  final int vacationDays;
  final int monthRequests;

  /// My requests (and transactions) per bucket, Under Review as Pending.
  final Map<RequestBucket, int> myCounts;

  /// The Approvals tab per bucket, Under Review as Pending.
  final Map<RequestBucket, int> approvalCounts;

  /// Requests whose current step waits for me, oldest wait first.
  final List<TimeTrackerRequest> waitingForMe;

  int myCount(RequestBucket bucket) => myCounts[bucket] ?? 0;
  int approvalCount(RequestBucket bucket) => approvalCounts[bucket] ?? 0;

  static const TimeTrackerHomeStats empty = TimeTrackerHomeStats();
}

class TimeTrackerHomeStatsRules {
  const TimeTrackerHomeStatsRules._();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Function Name: [compute]
  ///
  /// Purpose: The home-card figures of [email] at [now].
  ///
  /// Parameters:
  ///   [List<AttendanceDay>] days: the employee's attendance days.
  ///   [List<TimeTrackerRequest>] requests: the company's requests.
  ///   [String] email: the signed-in employee.
  ///   [ApproverView?] approver: null = no Approvals tab (no counters).
  ///   [bool Function(TimeTrackerRequest)?] waitsForMe: the current step
  ///   waits for the viewer (`ApprovalService.mayDecide`); null = none.
  ///   [DateTime] now
  ///
  /// Return type: [TimeTrackerHomeStats]
  static TimeTrackerHomeStats compute({
    required List<AttendanceDay> days,
    required List<TimeTrackerRequest> requests,
    required String email,
    required DateTime now,
    ApproverView? approver,
    bool Function(TimeTrackerRequest request)? waitsForMe,
    WorkSchedule? schedule,
    DateTime? assignmentStart,
  }) {
    final String me = email.trim().toLowerCase();
    final DateSpan month = DateSpan.of(DashboardRange.month, now);
    // QA KP-TT-013 (9/10/2026): the HR view's day rule at [now].
    final PersonalDashboardStats stats = PersonalDashboardStats.compute(
      days: days,
      requests: requests,
      email: me,
      span: month,
      schedule: schedule,
      assignmentStart: assignmentStart,
      now: now,
    );
    final List<TimeTrackerRequest> mine = RequestList.mine(requests, me);
    final ApproverView? viewer = approver;
    final bool Function(TimeTrackerRequest)? waits = waitsForMe;
    final List<TimeTrackerRequest> waiting = waits == null
        ? <TimeTrackerRequest>[]
        : <TimeTrackerRequest>[for (final TimeTrackerRequest r in requests) if (waits(r)) r];
    waiting.sort((TimeTrackerRequest a, TimeTrackerRequest b) {
      final DateTime x = waitingSince(a) ?? a.startAt;
      final DateTime y = waitingSince(b) ?? b.startAt;
      final int byWait = x.compareTo(y);
      return byWait != 0 ? byWait : a.id.compareTo(b.id);
    });
    return TimeTrackerHomeStats(
      present: stats.present,
      absent: stats.absent,
      late: stats.late,
      vacationDays: leaveDaysIn(month, days: days, requests: mine, schedule: schedule),
      monthRequests: stats.totalRequests,
      myCounts: Map<RequestBucket, int>.unmodifiable(
        RequestList.counts(mine, underReviewAsPending: true),
      ),
      approvalCounts: viewer == null
          ? const <RequestBucket, int>{}
          : Map<RequestBucket, int>.unmodifiable(
              RequestList.counts(ApprovalInbox.of(requests, viewer), underReviewAsPending: true),
            ),
      waitingForMe: List<TimeTrackerRequest>.unmodifiable(waiting),
    );
  }

  /// Function Name: [leaveDaysIn]
  ///
  /// Purpose: Distinct days of [span] on leave: covered by an approved leave
  /// request of [requests] (approved, or under a cancellation review), or
  /// stored with a leave status in [days].
  ///
  /// Return type: [int]
  static int leaveDaysIn(
    DateSpan span, {
    required List<AttendanceDay> days,
    required List<TimeTrackerRequest> requests,
    WorkSchedule? schedule,
  }) {
    final Set<DateTime> leave = <DateTime>{
      for (final AttendanceDay d in days)
        if ((d.status?.isLeave ?? false) && span.contains(d.date)) _day(d.date),
    };
    for (final TimeTrackerRequest r in requests) {
      if (!AbsenceRules.isHeldLeave(r)) continue;
      DateTime d = _day(r.startAt);
      final DateTime last = _day(r.endAt);
      for (int guard = 0; !d.isAfter(last) && guard < AbsenceRules.maxDaysPerRequest; guard++) {
        // Code review finding 8 (9/10/2026): a few hours off is not a day off.
        if (span.contains(d) && AbsenceRules.coversWholeDay(r, d, schedule: schedule)) leave.add(d);
        d = DateTime(d.year, d.month, d.day + 1);
      }
    }
    return leave.length;
  }

  /// Function Name: [waitingSince]
  ///
  /// Purpose: When [request]'s current step started waiting: the latest
  /// decision of the earlier steps of the same round, else the request's
  /// creation (a cancellation round: its last write — when it went under
  /// review).
  ///
  /// Return type: [DateTime?] — null when nothing waits or no date is known.
  static DateTime? waitingSince(TimeTrackerRequest request) {
    final RequestApprovalStep? current = RequestCycleRules.actionableStep(request);
    if (current == null) return null;
    final List<RequestApprovalStep> steps = request.approvalSteps;
    final int index = steps.indexOf(current);
    DateTime? latest;
    // Only the current round (9/10/2026, code review finding 5).
    for (int i = ApprovalRouter.roundStartOf(steps, index); i < index; i++) {
      final RequestApprovalStep s = steps[i];
      final DateTime? at = s.decidedAt;
      if (s.isCancellation != current.isCancellation || at == null) continue;
      if (latest == null || at.isAfter(latest)) latest = at;
    }
    if (latest != null) return latest;
    return current.isCancellation
        ? (request.audit.updatedAt ?? request.audit.createdAt)
        : (request.audit.createdAt ?? request.audit.updatedAt);
  }
}
