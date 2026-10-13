/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: code_review_rules_test.dart
/// Purpose: The pure-rule half of the 9/10/2026 code review fixes
///          (`Documents/Time Tracker Module/QA/CODE_REVIEW.md`): finding 1
///          (unknown HR working week), 4 (refund the stored days), 5 (only
///          the latest approval round), 6 (transaction day + 24 h cap), 7
///          (stuck manager step), 8 (partial-day leave), the owner's HR-step
///          rules (All Departments only; never both steps; sole other HR →
///          the manager is final), `View_Approvals`, own-request overlap and
///          DST-safe shift times.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Each test names its finding; each failed against the code before the
/// fix (the behaviour it pins did not exist or was the opposite).

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absence_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absent_day_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/reminder_sweep_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_correction_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';

/// An HR shift: hours known, working week NOT stored (finding 1).
const WorkSchedule _hrShift = WorkSchedule(startMinutes: 9 * 60, endMinutes: 17 * 60, isWorkingWeekKnown: false);

/// A Time Tracker location week: Sunday → Thursday.
const WorkSchedule _sunThu = WorkSchedule(startMinutes: 9 * 60, endMinutes: 17 * 60, workingDays: <int>[7, 1, 2, 3, 4]);

const RequestType _annual = RequestType(id: 'annual', nameEn: 'Annual', isDeductedFromVacationBalance: true);
const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick');

TimeTrackerRequest _leave({
  required DateTime start,
  required DateTime end,
  bool allDay = true,
  RequestStatus status = RequestStatus.approved,
  String who = 'me@co.com',
  double? deducted,
}) =>
    TimeTrackerRequest(
      id: 'r-${start.day}-${start.hour}',
      requesterEmail: who,
      requestTypeId: 'annual',
      startAt: start,
      endAt: end,
      isAllDay: allDay,
      status: status,
      // Owner round 9 b: recorded per year (the start year here).
      deductedDaysByYear: deducted == null ? null : <int, double>{start.year: deducted},
    );

/// A manager → HR request as stored after submit.
TimeTrackerRequest _submitted() {
  final TimeTrackerRequest r = RequestFormRules.build(
    RequestDraft(type: _sick, startDate: DateTime(2026, 10, 12), endDate: DateTime(2026, 10, 13)),
    requesterEmail: 'me@co.com',
    requesterDepartmentId: 'dep-1',
    managerEmail: 'boss@co.com',
  );
  return r;
}

final DateTime _t = DateTime(2026, 10, 5, 10);

void main() {
  group('finding 1 — HR shift = unknown working week', () {
    test('the absent sweep marks nothing (no weekend becomes "absent")', () {
      final List<DateTime> days = AbsentDayRules.daysToMarkAbsent(
        now: DateTime(2026, 10, 9, 20),
        schedule: _hrShift,
        assignmentStart: DateTime(2026, 10, 1),
        recordedDays: const <DateTime>[],
        approvedLeaves: const <DayRange>[],
      );
      expect(days, isEmpty);
      // A known week still marks its working days only (Fri 2 / Sat 3 skipped).
      final List<DateTime> known = AbsentDayRules.daysToMarkAbsent(
        now: DateTime(2026, 10, 5, 20),
        schedule: _sunThu,
        assignmentStart: DateTime(2026, 10, 1),
        recordedDays: const <DateTime>[],
        approvedLeaves: const <DayRange>[],
      );
      expect(known, <DateTime>[DateTime(2026, 10, 1), DateTime(2026, 10, 4)]);
    });

    test('no "Check-In Not Recorded" reminder on an unknown week', () {
      expect(
        TimeTrackerReminderRules.missedCheckIn(
          email: 'me@co.com',
          schedule: _hrShift,
          today: null,
          approvedLeaves: const <DayRange>[],
          now: DateTime(2026, 10, 10, 12), // a Saturday
        ),
        isNull,
      );
    });

    test('vacation days count on the company week, else Sun–Thu (deduction only)', () {
      // Thu 8 → Sun 11 Oct 2026, all day.
      final TimeTrackerRequest r = _leave(start: DateTime(2026, 10, 8), end: DateTime(2026, 10, 11));
      expect(VacationBalanceRules.requestedDays(r, schedule: _hrShift), 4, reason: 'before: every day counted');
      final WorkSchedule fallback = VacationBalanceRules.deductionSchedule(_hrShift);
      expect(fallback.workingDays, WorkSchedule.sundayToThursday);
      expect(fallback.isWorkingWeekKnown, isFalse, reason: 'still never used for absences');
      expect(VacationBalanceRules.requestedDays(r, schedule: fallback), 2, reason: 'Thu + Sun');
      final WorkSchedule company = VacationBalanceRules.deductionSchedule(_hrShift, companyWeek: <int>[1, 2, 3, 4, 5]);
      expect(VacationBalanceRules.requestedDays(r, schedule: company), 2, reason: 'Thu + Fri');
      // A known schedule is used as it is.
      expect(identical(VacationBalanceRules.deductionSchedule(_sunThu), _sunThu), isTrue);
    });

    test('absent rows the sweep wrote on an unknown week / a day off are not trusted', () {
      final AttendanceDay sat = AttendanceDay(
        id: 'me@co.com_2026-10-10',
        employeeEmail: 'me@co.com',
        date: DateTime(2026, 10, 10),
        status: AttendanceStatus.absent,
      );
      expect(AbsenceRules.isUntrustedAbsence(sat, _hrShift), isTrue);
      expect(AbsenceRules.isUntrustedAbsence(sat, _sunThu), isTrue, reason: 'Saturday is not a working day');
      final AttendanceDay sun = AttendanceDay(
        id: 'me@co.com_2026-10-11',
        employeeEmail: 'me@co.com',
        date: DateTime(2026, 10, 11),
        status: AttendanceStatus.absent,
      );
      expect(AbsenceRules.isUntrustedAbsence(sun, _sunThu), isFalse);
      expect(AbsenceRules.isUntrustedAbsence(sun, null), isFalse, reason: 'unknown schedule → kept');
      final AttendanceDay corrected = AttendanceDay(
        id: 'x',
        employeeEmail: 'me@co.com',
        date: DateTime(2026, 10, 10),
        status: AttendanceStatus.absent,
        isCorrectedByTransaction: true,
      );
      expect(AbsenceRules.isUntrustedAbsence(corrected, _hrShift), isFalse);
      expect(AbsenceRules.trusted(<AttendanceDay>[sat, sun], _sunThu), <AttendanceDay>[sun]);
    });
  });

  group('finding 4 — refund exactly what was deducted', () {
    test('the stored Deducted_Vacation_Days wins (per year); legacy rows recompute', () {
      final TimeTrackerRequest stored = _leave(start: DateTime(2026, 10, 8), end: DateTime(2026, 10, 11), deducted: 2);
      expect(VacationBalanceRules.refundByYear(stored, recomputed: <int, double>{2026: 4}), <int, double>{2026: 2});
      final TimeTrackerRequest legacy = _leave(start: DateTime(2026, 10, 8), end: DateTime(2026, 10, 11));
      expect(VacationBalanceRules.refundByYear(legacy, recomputed: <int, double>{2026: 4}), <int, double>{2026: 4});
      expect(VacationBalanceRules.refundByYear(_leave(start: _t, end: _t, deducted: -1), recomputed: <int, double>{2026: 3}),
          isEmpty);
    });
  });

  group('finding 5 — only the latest approval round counts', () {
    test('a refused cancellation closes its round; the next cancellation starts clean', () {
      TimeTrackerRequest r = _submitted();
      r = RequestCycleRules.approve(r, approverEmail: 'boss@co.com', at: _t).after;
      r = RequestCycleRules.approve(r, approverEmail: 'hr@co.com', at: _t).after;
      expect(r.status, RequestStatus.approved);
      r = RequestCycleRules.requestCancellation(r, reason: 'Trip canceled');
      r = RequestCycleRules.reject(r, approverEmail: 'boss@co.com', reason: 'No', at: _t).after;
      expect(r.status, RequestStatus.approved);
      expect(r.approvalSteps.where((RequestApprovalStep s) => s.isPending), isEmpty,
          reason: 'the HR step of the refused round is skipped, not left pending');
      expect(RequestCycleRules.actionableStep(r), isNull);
      // Second cancellation: its OWN manager step waits (not the stale HR one).
      r = RequestCycleRules.requestCancellation(r, reason: 'Again');
      final RequestApprovalStep? now = RequestCycleRules.actionableStep(r);
      expect(now!.step, ApprovalStepKind.manager);
      expect(r.approvalSteps.indexOf(now), greaterThanOrEqualTo(ApprovalRouter.roundStart(r.approvalSteps)));
      r = RequestCycleRules.approve(r, approverEmail: 'boss@co.com', at: _t).after;
      expect(r.currentStep, ApprovalStepKind.hr);
      r = RequestCycleRules.approve(r, approverEmail: 'hr@co.com', at: _t).after;
      expect(r.status, RequestStatus.canceled);
      // Skipped steps are hidden from the cycle shown to people.
      expect(RequestCycleRules.visibleSteps(r).any((RequestApprovalStep s) => s.decision == ApprovalDecision.skipped),
          isFalse);
    });
  });

  group('finding 6 — a transaction is one day (or one overnight shift), ≤ 24 h', () {
    final DateTime now = DateTime(2026, 10, 10, 12);
    test('check-out the same day; next day only for an overnight shift', () {
      expect(
        TransactionRules.validate(
            checkIn: DateTime(2026, 10, 1, 9), checkOut: DateTime(2026, 10, 1, 17), description: 'x', now: now, hasDocument: true),
        isEmpty,
      );
      expect(
        TransactionRules.validate(
            checkIn: DateTime(2026, 10, 1, 22), checkOut: DateTime(2026, 10, 2, 6), description: 'x', now: now, hasDocument: true),
        contains(TransactionError.checkOutWrongDay),
      );
      expect(
        TransactionRules.validate(
          checkIn: DateTime(2026, 10, 1, 22),
          checkOut: DateTime(2026, 10, 2, 6),
          description: 'x',
          now: now, hasDocument: true,
          overnightShift: true,
        ),
        isEmpty,
      );
    });

    test('1 Oct 09:00 → 9 Oct 17:00 is refused (wrong day + too long)', () {
      final Set<TransactionError> e = TransactionRules.validate(
        checkIn: DateTime(2026, 10, 1, 9),
        checkOut: DateTime(2026, 10, 9, 17),
        description: 'x',
        now: now, hasDocument: true,
        overnightShift: true,
      );
      expect(e, containsAll(<TransactionError>[TransactionError.checkOutWrongDay, TransactionError.tooLong]));
      expect(
        TransactionRules.validate(
          checkIn: DateTime(2026, 10, 1, 6),
          checkOut: DateTime(2026, 10, 2, 7),
          description: 'x',
          now: now, hasDocument: true,
          overnightShift: true,
        ),
        contains(TransactionError.tooLong),
      );
    });

    test('the correction itself refuses a span over 24 h (defence in depth)', () {
      final TimeTrackerRequest tx = TimeTrackerRequest(
        id: 't1',
        requesterEmail: 'me@co.com',
        isTransaction: true,
        startAt: DateTime(2026, 10, 1, 9),
        endAt: DateTime(2026, 10, 9, 17),
      );
      expect(
        () => TransactionCorrectionRules.apply(existing: null, transaction: tx, schedule: null, now: now),
        throwsStateError,
      );
    });
  });

  group('finding 7 + owner HR rules — who decides which step', () {
    RequestApprovalStep hrStep(List<RequestApprovalStep> steps) =>
        steps.firstWhere((RequestApprovalStep s) => s.step == ApprovalStepKind.hr);

    test('a manager-only type without an actionable manager goes to HR', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: false,
        managerEmail: '',
        requesterEmail: 'me@co.com',
      );
      expect(steps.single.step, ApprovalStepKind.hr);
    });

    test('a blocked manager step: an All-Departments HR approver may act and skips it', () {
      final TimeTrackerRequest r = _submitted();
      final RequestApprovalStep manager = r.approvalSteps.first;
      bool may({required String who, required bool all, required bool blocked}) => ApprovalRouter.mayAct(
            step: manager,
            viewerEmail: who,
            requesterEmail: 'me@co.com',
            canApproveAndReject: true,
            approvalsAllDepartments: all,
            steps: r.approvalSteps,
            managerStepBlocked: blocked,
          );
      expect(may(who: 'hr@co.com', all: true, blocked: false), isFalse);
      expect(may(who: 'hr@co.com', all: true, blocked: true), isTrue);
      expect(may(who: 'lead@co.com', all: false, blocked: true), isFalse);
      final TimeTrackerRequest done =
          RequestCycleRules.approve(r, approverEmail: 'hr@co.com', at: _t, overrideBlockedManager: true).after;
      expect(done.status, RequestStatus.approved);
      expect(done.approvalSteps.first.decision, ApprovalDecision.skipped);
      expect(hrStep(done.approvalSteps).decision, ApprovalDecision.approved);
      expect(hrStep(done.approvalSteps).approverEmail, 'hr@co.com');
    });

    test('the HR step: All Departments only, and never the person who decided the manager step', () {
      final TimeTrackerRequest atHr = RequestCycleRules.approve(_submitted(), approverEmail: 'boss@co.com', at: _t).after;
      bool may(String who, {bool all = true}) => ApprovalRouter.mayAct(
            step: hrStep(atHr.approvalSteps),
            viewerEmail: who,
            requesterEmail: 'me@co.com',
            canApproveAndReject: true,
            approvalsAllDepartments: all,
            steps: atHr.approvalSteps,
          );
      expect(may('hr@co.com'), isTrue);
      expect(may('lead@co.com', all: false), isFalse, reason: 'own department is not enough');
      expect(may('boss@co.com'), isFalse, reason: 'the manager (also HR) decided this round already');
    });

    test('the manager is the only other HR approver → their approval is final', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: true,
        managerEmail: 'boss@co.com',
        requesterEmail: 'me@co.com',
        managerIsSoleOtherHr: true,
      );
      expect(steps.map((RequestApprovalStep s) => s.step), <ApprovalStepKind>[ApprovalStepKind.manager]);
      final TimeTrackerRequest r = _submitted();
      final TimeTrackerRequest done =
          RequestCycleRules.approve(r, approverEmail: 'boss@co.com', at: _t, managerIsFinal: true).after;
      expect(done.status, RequestStatus.approved);
    });

    test('View_Approvals OFF → no request is "involved", even a direct report\'s', () {
      const ApproverView off = ApproverView(
        email: 'boss@co.com',
        departmentId: 'dep-9',
        canApproveAndReject: true,
        allDepartments: false,
        canCancelAfterApproving: false,
        canViewApprovals: false,
      );
      expect(ApprovalInbox.involves(_submitted(), off), isFalse);
      const ApproverView on = ApproverView(
        email: 'boss@co.com',
        departmentId: 'dep-9',
        canApproveAndReject: true,
        allDepartments: false,
        canCancelAfterApproving: false,
      );
      expect(ApprovalInbox.involves(_submitted(), on), isTrue);
    });
  });

  group('finding 8 — only a whole-day leave explains an absence', () {
    test('partial requests count only when they span the whole shift', () {
      final DateTime day = DateTime(2026, 10, 12);
      final TimeTrackerRequest twoHours =
          _leave(start: DateTime(2026, 10, 12, 10), end: DateTime(2026, 10, 12, 12), allDay: false);
      final TimeTrackerRequest wholeShift =
          _leave(start: DateTime(2026, 10, 12, 9), end: DateTime(2026, 10, 12, 17), allDay: false);
      expect(AbsenceRules.coversWholeDay(twoHours, day, schedule: _sunThu), isFalse);
      expect(AbsenceRules.coversWholeDay(wholeShift, day, schedule: _sunThu), isTrue);
      expect(AbsenceRules.coversWholeDay(wholeShift, day), isFalse, reason: 'unknown hours → not a whole day');
      expect(AbsenceRules.coversWholeDay(_leave(start: day, end: day), day), isTrue);
      final List<DayRange> leaves = AbsenceRules.wholeDayLeaves(
        <TimeTrackerRequest>[twoHours, _leave(start: DateTime(2026, 10, 14), end: DateTime(2026, 10, 15))],
        'ME@co.com',
        schedule: _sunThu,
      );
      expect(leaves.any((DayRange r) => r.covers(day)), isFalse);
      expect(leaves.any((DayRange r) => r.covers(DateTime(2026, 10, 15))), isTrue);
      // A pending request never explains a day.
      expect(AbsenceRules.isHeldLeave(_leave(start: day, end: day, status: RequestStatus.pending)), isFalse);
    });
  });

  group('minor findings', () {
    test('no overlap with my own pending / approved leave', () {
      final List<TimeTrackerRequest> mine = <TimeTrackerRequest>[
        _leave(start: DateTime(2026, 10, 13), end: DateTime(2026, 10, 14), status: RequestStatus.pending),
        _leave(start: DateTime(2026, 10, 20), end: DateTime(2026, 10, 20), status: RequestStatus.canceled),
      ];
      final RequestDraft overlapping =
          RequestDraft(type: _sick, startDate: DateTime(2026, 10, 12), endDate: DateTime(2026, 10, 13));
      expect(RequestFormRules.validate(overlapping, ownRequests: mine), contains(RequestFormError.overlapsExisting));
      final RequestDraft free = RequestDraft(type: _sick, startDate: DateTime(2026, 10, 20), endDate: DateTime(2026, 10, 20));
      expect(RequestFormRules.validate(free, ownRequests: mine), isEmpty, reason: 'a canceled request frees its days');
    });

    test('no vacation balance = 0 days remaining for a deducting type (finding 10)', () {
      final RequestDraft d = RequestDraft(type: _annual, startDate: DateTime(2026, 10, 12), endDate: DateTime(2026, 10, 12));
      expect(RequestFormRules.validate(d), contains(RequestFormError.noBalance));
    });

    test('DST: the shift starts at 08:00 / ends at 16:00 on EVERY day of the year', () {
      const WorkSchedule s = WorkSchedule(startMinutes: 8 * 60, endMinutes: 16 * 60);
      for (DateTime d = DateTime(2026, 1, 1); d.year == 2026; d = DateTime(d.year, d.month, d.day + 1)) {
        final DateTime start = s.startOn(d);
        final DateTime end = s.endOn(d);
        expect(<int>[start.day, start.hour, start.minute], <int>[d.day, 8, 0], reason: '$d start');
        expect(<int>[end.hour, end.minute], <int>[16, 0], reason: '$d end');
      }
    });
  });
}
