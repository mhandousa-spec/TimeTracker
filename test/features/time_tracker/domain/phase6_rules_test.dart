/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: phase6_rules_test.dart
/// Purpose: Pins the phase-6 pure rules: the home-card figures
///          (`TimeTrackerHomeStatsRules`: month counts, vacation days, my /
///          approval buckets, waiting-for-me order, waiting since) and the
///          reminder sweep (`TimeTrackerReminderRules`: missed check-in,
///          forgot to check out, pending approvals > 2 days).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absent_day_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/reminder_sweep_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

const String _me = 'me@co.com';

/// 9:00 → 17:00, Sunday – Thursday, 10 minutes grace.
const WorkSchedule _schedule = WorkSchedule(
  startMinutes: 9 * 60,
  endMinutes: 17 * 60,
  workingDays: <int>[7, 1, 2, 3, 4],
  lateAfterMinutes: 10,
);

AttendanceDay _day(DateTime date, AttendanceStatus? status, {List<AttendanceSession> sessions = const <AttendanceSession>[]}) =>
    AttendanceDay(id: 'd${date.day}', employeeEmail: _me, date: date, status: status, sessions: sessions);

TimeTrackerRequest _req(
  String id, {
  String who = _me,
  RequestStatus status = RequestStatus.pending,
  DateTime? start,
  DateTime? end,
  bool tx = false,
  List<RequestApprovalStep> steps = const <RequestApprovalStep>[],
  DateTime? created,
  String dep = 'dep-1',
  bool allDay = false,
}) =>
    TimeTrackerRequest(
      id: id,
      isAllDay: allDay,
      requesterEmail: who,
      requesterDepartmentId: dep,
      requestTypeId: tx ? '' : 'sick',
      isTransaction: tx,
      startAt: start ?? DateTime(2026, 10, 12),
      endAt: end ?? DateTime(2026, 10, 12),
      status: status,
      approvalSteps: steps,
      audit: AuditInfo(createdAt: created ?? DateTime(2026, 10, 1), updatedAt: created ?? DateTime(2026, 10, 1)),
    );

const RequestApprovalStep _mgrPending = RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'boss@co.com');

void main() {
  group('TimeTrackerHomeStatsRules.compute', () {
    final DateTime now = DateTime(2026, 10, 20, 10);

    test('month figures: present incl. late, absent, late, requests by start (no transactions)', () {
      final TimeTrackerHomeStats s = TimeTrackerHomeStatsRules.compute(
        days: <AttendanceDay>[
          _day(DateTime(2026, 10, 1), AttendanceStatus.present),
          _day(DateTime(2026, 10, 2), AttendanceStatus.late),
          _day(DateTime(2026, 10, 5), AttendanceStatus.absent),
          _day(DateTime(2026, 9, 30), AttendanceStatus.present), // last month
        ],
        requests: <TimeTrackerRequest>[
          _req('a', status: RequestStatus.approved, start: DateTime(2026, 10, 7)),
          _req('b', start: DateTime(2026, 10, 25)),
          _req('t', tx: true, start: DateTime(2026, 10, 3)),
          _req('old', start: DateTime(2026, 9, 3)),
          _req('other', who: 'x@co.com', start: DateTime(2026, 10, 3)),
        ],
        email: _me,
        now: now,
      );
      expect(s.present, 2);
      expect(s.late, 1);
      expect(s.absent, 1);
      expect(s.monthRequests, 2);
    });

    test('vacation days: distinct days of the month on approved leave or stored leave', () {
      final TimeTrackerHomeStats s = TimeTrackerHomeStatsRules.compute(
        days: <AttendanceDay>[
          _day(DateTime(2026, 10, 8), AttendanceStatus.sickLeave),
          _day(DateTime(2026, 10, 13), AttendanceStatus.vacation), // inside the request too
        ],
        requests: <TimeTrackerRequest>[
          // 12 → 14 Oct approved = 3 days (13 shared with the stored day).
          _req('a', status: RequestStatus.approved, start: DateTime(2026, 10, 12), end: DateTime(2026, 10, 14), allDay: true),
          // Under review = still approved; spills into November (only 31 Oct counts).
          _req('b', status: RequestStatus.underReview, start: DateTime(2026, 10, 31), end: DateTime(2026, 11, 2), allDay: true),
          _req('p', start: DateTime(2026, 10, 20), allDay: true), // pending → not a leave day
          _req('t', tx: true, status: RequestStatus.approved, start: DateTime(2026, 10, 21)),
          // Code review finding 8 (9/10/2026): an approved PARTIAL-day
          // request (2 hours) is not a leave day.
          _req('h', status: RequestStatus.approved, start: DateTime(2026, 10, 22, 10), end: DateTime(2026, 10, 22, 12)),
        ],
        email: _me,
        now: now,
      );
      expect(s.vacationDays, 5, reason: '8, 12, 13, 14, 31 Oct');
    });

    test('my buckets: Under Review counted as Pending, Canceled By HR as Canceled; transactions included', () {
      final TimeTrackerHomeStats s = TimeTrackerHomeStatsRules.compute(
        days: const <AttendanceDay>[],
        requests: <TimeTrackerRequest>[
          _req('1', status: RequestStatus.approved),
          _req('2'),
          _req('3', status: RequestStatus.underReview),
          _req('4', status: RequestStatus.rejected),
          _req('5', status: RequestStatus.canceledByHr),
          _req('6', status: RequestStatus.canceled, tx: true),
          _req('7', who: 'x@co.com'),
        ],
        email: 'ME@co.com',
        now: now,
      );
      expect(s.myCount(RequestBucket.all), 6);
      expect(s.myCount(RequestBucket.approved), 1);
      expect(s.myCount(RequestBucket.pending), 2);
      expect(s.myCount(RequestBucket.underReview), 0);
      expect(s.myCount(RequestBucket.rejected), 1);
      expect(s.myCount(RequestBucket.canceled), 2);
    });

    test('approval buckets follow ApprovalInbox; none without an approver view', () {
      final List<TimeTrackerRequest> all = <TimeTrackerRequest>[
        _req('w', who: 'emp@co.com', steps: const <RequestApprovalStep>[_mgrPending]),
        _req('d', who: 'emp@co.com', status: RequestStatus.approved, steps: <RequestApprovalStep>[
          _mgrPending.copyWith(decision: ApprovalDecision.approved, decidedAt: DateTime(2026, 10, 2)),
        ]),
        // The boss's own request is never in his Approvals.
        _req('mine', who: 'boss@co.com', steps: const <RequestApprovalStep>[_mgrPending]),
      ];
      const ApproverView boss = ApproverView(
        email: 'boss@co.com',
        departmentId: 'dep-9',
        canApproveAndReject: true,
        allDepartments: false,
        canCancelAfterApproving: false,
      );
      final TimeTrackerHomeStats s = TimeTrackerHomeStatsRules.compute(
        days: const <AttendanceDay>[],
        requests: all,
        email: 'boss@co.com',
        now: now,
        approver: boss,
        waitsForMe: (TimeTrackerRequest r) => r.id == 'w',
      );
      expect(s.approvalCount(RequestBucket.all), 2);
      expect(s.approvalCount(RequestBucket.pending), 1);
      expect(s.approvalCount(RequestBucket.approved), 1);
      expect(s.waitingForMe.map((TimeTrackerRequest r) => r.id), <String>['w']);
      final TimeTrackerHomeStats none =
          TimeTrackerHomeStatsRules.compute(days: const <AttendanceDay>[], requests: all, email: 'boss@co.com', now: now);
      expect(none.approvalCounts, isEmpty);
      expect(none.waitingForMe, isEmpty);
    });

    test('waiting for me: oldest wait first', () {
      final TimeTrackerHomeStats s = TimeTrackerHomeStatsRules.compute(
        days: const <AttendanceDay>[],
        requests: <TimeTrackerRequest>[
          _req('new', who: 'a@co.com', steps: const <RequestApprovalStep>[_mgrPending], created: DateTime(2026, 10, 9)),
          _req('old', who: 'b@co.com', steps: const <RequestApprovalStep>[_mgrPending], created: DateTime(2026, 10, 2)),
        ],
        email: 'boss@co.com',
        now: now,
        waitsForMe: (_) => true,
      );
      expect(s.waitingForMe.map((TimeTrackerRequest r) => r.id), <String>['old', 'new']);
    });
  });

  group('TimeTrackerHomeStatsRules.waitingSince', () {
    test('first step: creation; HR step: the manager decision; cancellation round: its last write', () {
      expect(
        TimeTrackerHomeStatsRules.waitingSince(
            _req('a', steps: const <RequestApprovalStep>[_mgrPending], created: DateTime(2026, 10, 3))),
        DateTime(2026, 10, 3),
      );
      final TimeTrackerRequest atHr = _req('b', created: DateTime(2026, 10, 1), steps: <RequestApprovalStep>[
        _mgrPending.copyWith(decision: ApprovalDecision.approved, decidedAt: DateTime(2026, 10, 6)),
        const RequestApprovalStep(step: ApprovalStepKind.hr),
      ]);
      expect(TimeTrackerHomeStatsRules.waitingSince(atHr), DateTime(2026, 10, 6));
      final TimeTrackerRequest review = TimeTrackerRequest(
        id: 'c',
        requesterEmail: _me,
        startAt: DateTime(2026, 10, 12),
        endAt: DateTime(2026, 10, 12),
        status: RequestStatus.underReview,
        approvalSteps: <RequestApprovalStep>[
          _mgrPending.copyWith(decision: ApprovalDecision.approved, decidedAt: DateTime(2026, 10, 2)),
          const RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'boss@co.com', isCancellation: true),
        ],
        audit: AuditInfo(createdAt: DateTime(2026, 10, 1), updatedAt: DateTime(2026, 10, 15)),
      );
      expect(TimeTrackerHomeStatsRules.waitingSince(review), DateTime(2026, 10, 15));
      expect(TimeTrackerHomeStatsRules.waitingSince(_req('d', status: RequestStatus.approved)), isNull);
    });
  });

  group('TimeTrackerReminderRules.missedCheckIn', () {
    // 12 Oct 2026 is a Monday (a working day of _schedule).
    TimeTrackerDueReminder? at(DateTime now, {AttendanceDay? today, List<DayRange> leaves = const <DayRange>[], DateTime? start}) =>
        TimeTrackerReminderRules.missedCheckIn(
          email: _me,
          schedule: _schedule,
          today: today,
          approvedLeaves: leaves,
          now: now,
          assignmentStart: start,
        );

    test('due at start + grace on a working day with no check-in, marker = today + threshold', () {
      expect(at(DateTime(2026, 10, 12, 9, 9)), isNull, reason: 'grace not over');
      final TimeTrackerDueReminder? r = at(DateTime(2026, 10, 12, 9, 10));
      expect(r?.kind, TimeTrackerReminderKind.missedCheckIn);
      expect(r?.refId, 'me@co.com_2026-10-12');
      expect(r?.dueAt, DateTime(2026, 10, 12, 9, 10));
      expect(at(DateTime(2026, 10, 12, 20)), isNotNull, reason: 'still that day: sent once, late');
    });

    test('not on a day off, not before the assignment starts, not when checked in or on leave', () {
      expect(at(DateTime(2026, 10, 16, 12)), isNull, reason: 'Friday is not a working day');
      expect(at(DateTime(2026, 10, 12, 12), start: DateTime(2026, 10, 13)), isNull);
      final AttendanceDay checkedIn = _day(DateTime(2026, 10, 12), null,
          sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 12, 9, 30))]);
      expect(at(DateTime(2026, 10, 12, 12), today: checkedIn), isNull);
      expect(at(DateTime(2026, 10, 12, 12), today: _day(DateTime(2026, 10, 12), AttendanceStatus.vacation)), isNull);
      expect(at(DateTime(2026, 10, 12, 12), leaves: <DayRange>[DayRange(DateTime(2026, 10, 11), DateTime(2026, 10, 13))]),
          isNull);
    });
  });

  group('TimeTrackerReminderRules.missedCheckOut', () {
    AttendanceDay open(DateTime checkIn) => _day(DateTime(checkIn.year, checkIn.month, checkIn.day), null,
        sessions: <AttendanceSession>[AttendanceSession(checkInAt: checkIn)]);

    test('30 minutes after the shift end, marker = that day + due time', () {
      final AttendanceDay d = open(DateTime(2026, 10, 12, 9));
      expect(TimeTrackerReminderRules.missedCheckOut(email: _me, schedule: _schedule, openDay: d, now: DateTime(2026, 10, 12, 17, 29)),
          isNull);
      final TimeTrackerDueReminder? r =
          TimeTrackerReminderRules.missedCheckOut(email: _me, schedule: _schedule, openDay: d, now: DateTime(2026, 10, 12, 17, 30));
      expect(r?.kind, TimeTrackerReminderKind.missedCheckOut);
      expect(r?.refId, 'me@co.com_2026-10-12');
      expect(r?.dueAt, DateTime(2026, 10, 12, 17, 30));
    });

    test('none when checked out, or for a session started after the shift ended', () {
      final AttendanceDay closed = _day(DateTime(2026, 10, 12), AttendanceStatus.present, sessions: <AttendanceSession>[
        AttendanceSession(checkInAt: DateTime(2026, 10, 12, 9), checkOutAt: DateTime(2026, 10, 12, 17)),
      ]);
      expect(TimeTrackerReminderRules.missedCheckOut(email: _me, schedule: _schedule, openDay: closed, now: DateTime(2026, 10, 12, 22)),
          isNull);
      expect(TimeTrackerReminderRules.missedCheckOut(email: _me, schedule: _schedule, openDay: null, now: DateTime(2026, 10, 12, 22)),
          isNull);
      expect(
        TimeTrackerReminderRules.missedCheckOut(
            email: _me, schedule: _schedule, openDay: open(DateTime(2026, 10, 12, 18)), now: DateTime(2026, 10, 12, 23)),
        isNull,
      );
    });

    test('an overnight shift ends the next day', () {
      const WorkSchedule night = WorkSchedule(startMinutes: 22 * 60, endMinutes: 6 * 60);
      final AttendanceDay d = open(DateTime(2026, 10, 12, 22));
      expect(TimeTrackerReminderRules.missedCheckOut(email: _me, schedule: night, openDay: d, now: DateTime(2026, 10, 13, 6, 10)),
          isNull);
      expect(
        TimeTrackerReminderRules.missedCheckOut(email: _me, schedule: night, openDay: d, now: DateTime(2026, 10, 13, 6, 30))?.dueAt,
        DateTime(2026, 10, 13, 6, 30),
      );
    });
  });

  group('TimeTrackerReminderRules.overdueApprovals', () {
    final List<TimeTrackerRequest> all = <TimeTrackerRequest>[
      _req('fresh', who: 'a@co.com', steps: const <RequestApprovalStep>[_mgrPending], created: DateTime(2026, 10, 9)),
      _req('old', who: 'b@co.com', steps: const <RequestApprovalStep>[_mgrPending], created: DateTime(2026, 10, 3)),
      _req('older', who: 'c@co.com', steps: const <RequestApprovalStep>[_mgrPending], created: DateTime(2026, 10, 2)),
      _req('notMine', who: 'd@co.com', steps: const <RequestApprovalStep>[_mgrPending], created: DateTime(2026, 9, 1)),
    ];
    bool waits(TimeTrackerRequest r) => r.id != 'notMine';

    test('count of requests waiting > 2 days, oldest as the link, once a day', () {
      final TimeTrackerDueReminder? r = TimeTrackerReminderRules.overdueApprovals(
        approverEmail: 'Boss@co.com',
        requests: all,
        waitsForMe: waits,
        now: DateTime(2026, 10, 10, 11),
      );
      expect(r?.kind, TimeTrackerReminderKind.pendingApprovals);
      expect(r?.count, 2);
      expect(r?.requestId, 'older');
      expect(r?.refId, 'approvals_boss@co.com');
      expect(r?.dueAt, DateTime(2026, 10, 10), reason: 'the day → one marker per day');
    });

    test('nothing when no request waited more than two days', () {
      expect(
        TimeTrackerReminderRules.overdueApprovals(
            approverEmail: 'boss@co.com', requests: all, waitsForMe: waits, now: DateTime(2026, 10, 4)),
        isNull,
        reason: 'older (2 Oct 00:00) waited exactly 2 days — not more',
      );
      expect(
        TimeTrackerReminderRules.overdueApprovals(
                approverEmail: 'boss@co.com', requests: all, waitsForMe: waits, now: DateTime(2026, 10, 4, 0, 1))
            ?.count,
        1,
      );
      expect(
        TimeTrackerReminderRules.overdueApprovals(
            approverEmail: 'boss@co.com', requests: all, waitsForMe: (_) => false, now: DateTime(2026, 10, 10)),
        isNull,
      );
    });
  });
}
