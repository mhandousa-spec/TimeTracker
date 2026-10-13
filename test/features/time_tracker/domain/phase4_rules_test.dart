/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: phase4_rules_test.dart
/// Purpose: Pins the phase-4 pure rules: the request form (available
///          types, total time, validation incl. the vacation balance,
///          building the cycle), the request cycle (approve / reject /
///          cancel / ask to cancel / HR cancel / reminder), comments, the
///          list + Approvals inbox logic, the transaction correction
///          (apply / revert), the history row reader and the HR scope rule.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_comment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_correction_rules.dart';

const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick Leave', nameAr: 'إجازة مرضية');
const RequestType _annual = RequestType(
  id: 'annual',
  nameEn: 'Annual Vacation',
  isDeductedFromVacationBalance: true,
);
const RequestType _strict = RequestType(
  id: 'strict',
  nameEn: 'Business Mission',
  isDescriptionRequired: true,
  isAttachmentRequired: true,
);
const RequestType _free = RequestType(
  id: 'free',
  nameEn: 'Excused',
  isHrApprovalRequired: false,
  isManagerApprovalRequired: false,
);

RequestDraft _allDay(RequestType type, {int days = 3}) => RequestDraft(
      type: type,
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 12 + days - 1),
    );

TimeTrackerRequest _submitted({RequestType type = _sick, String manager = 'boss@co.com'}) {
  final TimeTrackerRequest r = RequestFormRules.build(
    _allDay(type),
    requesterEmail: 'me@co.com',
    requesterDepartmentId: 'dep-1',
    managerEmail: manager,
  );
  return TimeTrackerRequest(
    id: 'r1',
    requesterEmail: r.requesterEmail,
    requesterDepartmentId: r.requesterDepartmentId,
    requestTypeId: r.requestTypeId,
    startAt: r.startAt,
    endAt: r.endAt,
    isAllDay: r.isAllDay,
    totalMinutes: r.totalMinutes,
    status: r.status,
    approvalSteps: r.approvalSteps,
    currentStep: r.currentStep,
  );
}

TimeTrackerRequest _approved({RequestType type = _sick}) {
  final DateTime at = DateTime(2026, 10, 5);
  final CycleOutcome m = RequestCycleRules.approve(_submitted(type: type), approverEmail: 'boss@co.com', at: at);
  return RequestCycleRules.approve(m.after, approverEmail: 'hr@co.com', at: at).after;
}

void main() {
  final DateTime t = DateTime(2026, 10, 5, 10);

  group('RequestFormRules', () {
    test('available types: active, location + department limits, sorted by name', () {
      final List<RequestType> types = <RequestType>[
        _sick,
        _annual,
        const RequestType(id: 'x', nameEn: 'Inactive', status: RequestTypeStatus.inactive),
        const RequestType(id: 'y', nameEn: 'Removed', status: RequestTypeStatus.removed),
        const RequestType(id: 'loc', nameEn: 'Branch Only', locationIds: <String>['branch']),
        const RequestType(id: 'dep', nameEn: 'Sales Only', departmentIds: <String>['dep-2']),
      ];
      final List<RequestType> mine =
          RequestFormRules.availableTypes(types, locationId: 'hq', departmentId: 'dep-1');
      expect(mine.map((RequestType e) => e.id), <String>['annual', 'sick']);
      expect(
        RequestFormRules.availableTypes(types, locationId: 'branch', departmentId: 'dep-2').map((RequestType e) => e.id),
        <String>['annual', 'loc', 'dep', 'sick'],
      );
    });

    test('total time: all day = days × 24 h; partial = end − start', () {
      expect(RequestFormRules.totalMinutes(_allDay(_sick)), 3 * 24 * 60);
      final RequestDraft partial = RequestDraft(
        type: _sick,
        isAllDay: false,
        startDate: DateTime(2026, 10, 12),
        endDate: DateTime(2026, 10, 12),
        startMinutes: 9 * 60,
        endMinutes: 17 * 60 + 30,
      );
      expect(RequestFormRules.totalMinutes(partial), 8 * 60 + 30);
      expect(RequestFormRules.totalMinutes(partial.copyWith(endMinutes: 8 * 60)), 0);
    });

    test('an empty draft reports type and both dates; All Day off adds the times', () {
      expect(RequestFormRules.validate(const RequestDraft()), <RequestFormError>{
        RequestFormError.typeRequired,
        RequestFormError.startDateRequired,
        RequestFormError.endDateRequired,
      });
      expect(
        RequestFormRules.validate(const RequestDraft(isAllDay: false)),
        containsAll(<RequestFormError>[RequestFormError.startTimeRequired, RequestFormError.endTimeRequired]),
      );
    });

    test('description and attachments become required with the type', () {
      final Set<RequestFormError> errors = RequestFormRules.validate(_allDay(_strict));
      expect(errors, <RequestFormError>{RequestFormError.descriptionRequired, RequestFormError.attachmentsRequired});
      final RequestDraft ok = _allDay(_strict).copyWith(
        description: 'Client visit',
        attachments: const <RequestAttachment>[RequestAttachment(name: 'a.pdf', url: 'u')],
      );
      expect(RequestFormRules.validate(ok), isEmpty);
    });

    test('end before start is refused', () {
      final RequestDraft d = RequestDraft(type: _sick, startDate: DateTime(2026, 10, 12), endDate: DateTime(2026, 10, 11));
      expect(RequestFormRules.validate(d), contains(RequestFormError.endBeforeStart));
    });

    test('a deducting type cannot ask for more days than remain; no balance stored → 0 remaining', () {
      const VacationBalance two = VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10, usedDays: 8);
      expect(RequestFormRules.validate(_allDay(_annual), balance: two), contains(RequestFormError.exceedsBalance));
      expect(RequestFormRules.validate(_allDay(_annual, days: 2), balance: two), isEmpty);
      // Code review finding 10 (owner, 9/10/2026): no balance = 0 remaining
      // for a deducting type ("contact HR"); other types are not affected.
      expect(RequestFormRules.validate(_allDay(_annual)), contains(RequestFormError.noBalance));
      expect(RequestFormRules.validate(_allDay(_sick)), isEmpty);
      expect(RequestFormRules.validate(_allDay(_sick), balance: two), isEmpty);
      // Working days only: Sat/Sun off → a Fri–Mon request costs 2 days.
      const WorkSchedule weekdays = WorkSchedule(startMinutes: 540, endMinutes: 1020, workingDays: <int>[1, 2, 3, 4, 5]);
      final RequestDraft friToMon =
          RequestDraft(type: _annual, startDate: DateTime(2026, 10, 9), endDate: DateTime(2026, 10, 12));
      expect(RequestFormRules.requestedDays(friToMon, schedule: weekdays), 2);
      expect(RequestFormRules.validate(friToMon, balance: two, schedule: weekdays), isEmpty);
    });

    test('build: manager → HR, pending; no manager → HR only; no step → approved', () {
      final TimeTrackerRequest r = _submitted();
      expect(r.status, RequestStatus.pending);
      expect(r.approvalSteps.map((RequestApprovalStep s) => s.step), <ApprovalStepKind>[ApprovalStepKind.manager, ApprovalStepKind.hr]);
      expect(r.currentStep, ApprovalStepKind.manager);
      expect(r.totalMinutes, 3 * 24 * 60);
      expect(_submitted(manager: '').approvalSteps.single.step, ApprovalStepKind.hr);
      expect(_submitted(type: _free).status, RequestStatus.approved);
      expect(() => RequestFormRules.build(const RequestDraft(), requesterEmail: 'a', requesterDepartmentId: '', managerEmail: ''),
          throwsStateError);
    });
  });

  group('RequestCycleRules', () {
    test('manager approves → waits for HR; HR approves → approved', () {
      final CycleOutcome m = RequestCycleRules.approve(_submitted(), approverEmail: 'boss@co.com', at: t);
      expect(m.after.status, RequestStatus.pending);
      expect(m.after.currentStep, ApprovalStepKind.hr);
      expect(m.movedToNextStep, isTrue);
      expect(m.isFinalApproval, isFalse);
      final CycleOutcome h = RequestCycleRules.approve(m.after, approverEmail: 'hr@co.com', at: t);
      expect(h.after.status, RequestStatus.approved);
      expect(h.after.currentStep, isNull);
      expect(h.isFinalApproval, isTrue);
      expect(h.after.approvalSteps.last.approverEmail, 'hr@co.com');
    });

    test('reject needs a reason and ends the cycle', () {
      expect(() => RequestCycleRules.reject(_submitted(), approverEmail: 'boss@co.com', reason: ' ', at: t),
          throwsStateError);
      final CycleOutcome r =
          RequestCycleRules.reject(_submitted(), approverEmail: 'boss@co.com', reason: 'Busy week', at: t);
      expect(r.after.status, RequestStatus.rejected);
      expect(r.after.approvalSteps.first.reason, 'Busy week');
      expect(RequestCycleRules.actionableStep(r.after), isNull);
    });

    test('the requester cancels a pending request; not an approved one', () {
      expect(RequestCycleRules.canCancelPending(_submitted(), 'ME@co.com'), isTrue);
      expect(RequestCycleRules.canCancelPending(_submitted(), 'boss@co.com'), isFalse);
      expect(RequestCycleRules.cancelPending(_submitted()).status, RequestStatus.canceled);
      expect(RequestCycleRules.canCancelPending(_approved(), 'me@co.com'), isFalse);
    });

    test('asking to cancel an approved request: under review + a cancellation round', () {
      final TimeTrackerRequest approved = _approved();
      expect(RequestCycleRules.canRequestCancellation(approved, 'me@co.com'), isTrue);
      expect(() => RequestCycleRules.requestCancellation(approved, reason: ''), throwsStateError);
      final TimeTrackerRequest review = RequestCycleRules.requestCancellation(approved, reason: 'Plans changed');
      expect(review.status, RequestStatus.underReview);
      expect(review.cancellationReason, 'Plans changed');
      expect(review.approvalSteps, hasLength(4));
      expect(review.approvalSteps.skip(2).every((RequestApprovalStep s) => s.isCancellation && s.isPending), isTrue);
      expect(review.approvalSteps[2].approverEmail, 'boss@co.com');
      expect(review.currentStep, ApprovalStepKind.manager);
      expect(RequestCycleRules.visibleSteps(review), hasLength(2));
    });

    test('cancellation round: both approve → canceled; a rejection keeps it approved', () {
      final TimeTrackerRequest review = RequestCycleRules.requestCancellation(_approved(), reason: 'x');
      final CycleOutcome m = RequestCycleRules.approve(review, approverEmail: 'boss@co.com', at: t);
      expect(m.after.status, RequestStatus.underReview);
      final CycleOutcome h = RequestCycleRules.approve(m.after, approverEmail: 'hr@co.com', at: t);
      expect(h.after.status, RequestStatus.canceled);
      expect(h.endsApprovedRequest, isTrue);
      final CycleOutcome no = RequestCycleRules.reject(review, approverEmail: 'boss@co.com', reason: 'No', at: t);
      expect(no.after.status, RequestStatus.approved);
      expect(no.endsApprovedRequest, isFalse);
    });

    test('a type that needed no approval is canceled at once; transactions cannot ask', () {
      final TimeTrackerRequest free = _submitted(type: _free);
      expect(RequestCycleRules.requestCancellation(free, reason: 'x').status, RequestStatus.canceled);
      final TimeTrackerRequest tx = TimeTrackerRequest(
        id: 't',
        requesterEmail: 'me@co.com',
        startAt: t,
        endAt: t.add(const Duration(hours: 8)),
        isTransaction: true,
        status: RequestStatus.approved,
      );
      expect(RequestCycleRules.canRequestCancellation(tx, 'me@co.com'), isFalse);
    });

    test('HR cancels an approved request (reason required); not a pending one', () {
      expect(RequestCycleRules.canCancelByHr(_approved()), isTrue);
      expect(RequestCycleRules.canCancelByHr(_submitted()), isFalse);
      expect(() => RequestCycleRules.cancelByHr(_approved(), reason: ''), throwsStateError);
      expect(RequestCycleRules.cancelByHr(_approved(), reason: 'Audit').status, RequestStatus.canceledByHr);
    });

    test('reminder: requester, pending, once every 24 hours (owner H3)', () {
      final TimeTrackerRequest r = _submitted();
      expect(RequestCycleRules.canRemind(r, 'me@co.com', t), isTrue);
      expect(RequestCycleRules.canRemind(r, 'boss@co.com', t), isFalse);
      final TimeTrackerRequest sent = RequestCycleRules.remind(r, now: t);
      expect(sent.lastReminderAt, t);
      expect(RequestCycleRules.canRemind(sent, 'me@co.com', t.add(const Duration(hours: 23))), isFalse);
      expect(() => RequestCycleRules.remind(sent, now: t.add(const Duration(hours: 12))), throwsStateError);
      expect(RequestCycleRules.canRemind(sent, 'me@co.com', t.add(const Duration(hours: 24))), isTrue);
      expect(RequestCycleRules.canRemind(_approved(), 'me@co.com', t), isFalse);
    });

    test('approving with nothing waiting throws', () {
      expect(() => RequestCycleRules.approve(_approved(), approverEmail: 'hr@co.com', at: t), throwsStateError);
    });
  });

  group('RequestCommentRules', () {
    // 9/10/2026 (data model): one comment = one document; the rules work on
    // ONE comment and [thread] builds what is shown.
    test('create, edit / delete only your own, deleted ones hidden', () {
      final RequestComment mine = RequestCommentRules.create(authorEmail: 'Me@co.com', text: ' Hi ', now: t);
      expect(mine.authorEmail, 'me@co.com');
      expect(mine.text, 'Hi');
      final RequestComment a = RequestComment(id: 'a', authorEmail: mine.authorEmail, text: mine.text, createdAt: t);
      final RequestComment b = RequestComment(
          id: 'b', authorEmail: 'boss@co.com', text: 'Why?', createdAt: t.add(const Duration(minutes: 1)));
      expect(RequestCommentRules.thread(<RequestComment>[b, a]).map((RequestComment c) => c.text),
          <String>['Hi', 'Why?']);
      expect(() => RequestCommentRules.edited(b, editorEmail: 'me@co.com', text: 'x', now: t), throwsStateError);
      final RequestComment edited = RequestCommentRules.edited(a, editorEmail: 'me@co.com', text: 'Hello', now: t);
      expect(edited.text, 'Hello');
      expect(edited.editedAt, t);
      final RequestComment gone = RequestCommentRules.deleted(edited, editorEmail: 'me@co.com');
      expect(RequestCommentRules.thread(<RequestComment>[gone, b]).single.text, 'Why?');
      expect(() => RequestCommentRules.create(authorEmail: 'me@co.com', text: '  ', now: t), throwsStateError);
      expect(() => RequestCommentRules.create(authorEmail: 'me@co.com', text: 'x' * 501, now: t), throwsStateError);
    });

    test('legacy (embedded) comments show until migrated, are read-only, the stored copy wins', () {
      final RequestComment legacy = RequestComment(
          id: 'old_1', authorEmail: 'me@co.com', text: 'Old text', createdAt: t, isLegacy: true);
      final RequestComment migrated = RequestComment(id: 'old_1', authorEmail: 'me@co.com', text: 'Old text', createdAt: t);
      expect(RequestCommentRules.thread(const <RequestComment>[], legacy: <RequestComment>[legacy]).single.isLegacy,
          isTrue);
      expect(RequestCommentRules.canModify(legacy, 'me@co.com'), isFalse);
      final List<RequestComment> both =
          RequestCommentRules.thread(<RequestComment>[migrated], legacy: <RequestComment>[legacy]);
      expect(both, hasLength(1));
      expect(both.single.isLegacy, isFalse);
      expect(RequestCommentRules.canModify(both.single, 'ME@co.com'), isTrue);
    });
  });

  group('RequestList + ApprovalInbox', () {
    TimeTrackerRequest req(String id, RequestStatus s, {String who = 'me@co.com', String dep = 'dep-1'}) =>
        TimeTrackerRequest(id: id, requesterEmail: who, requesterDepartmentId: dep, startAt: t, endAt: t, status: s);

    test('counters: Canceled By HR is Canceled; Approvals counts Under Review as Pending', () {
      final List<TimeTrackerRequest> list = <TimeTrackerRequest>[
        req('a', RequestStatus.pending),
        req('b', RequestStatus.underReview),
        req('c', RequestStatus.canceled),
        req('d', RequestStatus.canceledByHr),
        req('e', RequestStatus.approved),
      ];
      final Map<RequestBucket, int> mine = RequestList.counts(list);
      expect(mine[RequestBucket.all], 5);
      expect(mine[RequestBucket.pending], 1);
      expect(mine[RequestBucket.underReview], 1);
      expect(mine[RequestBucket.canceled], 2);
      final Map<RequestBucket, int> approvals = RequestList.counts(list, underReviewAsPending: true);
      expect(approvals[RequestBucket.pending], 2);
      expect(approvals[RequestBucket.underReview], 0);
    });

    test('filter: kind, type, status, date range, department, employee, search, requester', () {
      final TimeTrackerRequest leave = _submitted();
      final TimeTrackerRequest tx = TimeTrackerRequest(
        id: 'tx',
        requesterEmail: 'amr@co.com',
        startAt: DateTime(2026, 10, 1, 9),
        endAt: DateTime(2026, 10, 1, 13),
        isTransaction: true,
        totalMinutes: 240,
      );
      final List<TimeTrackerRequest> list = <TimeTrackerRequest>[leave, tx];
      List<String> ids(RequestFilter f, {String q = '', String who = ''}) => RequestList.filter(list,
              filter: f, query: q, requesterEmail: who, textOf: (TimeTrackerRequest r) => r.isTransaction ? 'transaction' : 'sick leave')
          .map((TimeTrackerRequest r) => r.id)
          .toList();
      expect(ids(const RequestFilter(kind: RequestKind.transaction)), <String>['tx']);
      expect(ids(const RequestFilter(requestTypeId: 'sick')), <String>['r1']);
      // UI quality pass (9/10/2026, owner): Request Type · Status · From–To
      // (+ Department / Employee on Approvals).
      expect(ids(RequestFilter(from: DateTime(2026, 10, 13), to: DateTime(2026, 10, 13))), <String>['r1']);
      expect(ids(RequestFilter(to: DateTime(2026, 10, 1))), <String>['tx']);
      expect(ids(RequestFilter(from: DateTime(2026, 10, 2))), <String>['r1']);
      expect(ids(const RequestFilter(status: RequestStatus.approved)), isEmpty);
      expect(ids(const RequestFilter(status: RequestStatus.pending)), <String>['r1', 'tx']);
      expect(ids(const RequestFilter(departmentId: 'dep-1')), <String>['r1']);
      expect(ids(const RequestFilter(employeeEmail: 'AMR@co.com')), <String>['tx']);
      expect(ids(RequestFilter.none, q: 'SICK'), <String>['r1']);
      expect(ids(RequestFilter.none, who: 'amr@co.com'), <String>['tx']);
    });

    test('involvement: manager always, All-Departments HR after the manager, never own', () {
      const ApproverView boss = ApproverView(
          email: 'boss@co.com', departmentId: 'dep-9', canApproveAndReject: true, allDepartments: false, canCancelAfterApproving: false);
      const ApproverView hrAll = ApproverView(
          email: 'hr@co.com', departmentId: 'dep-9', canApproveAndReject: true, allDepartments: true, canCancelAfterApproving: false);
      const ApproverView hrOwn = ApproverView(
          email: 'lead@co.com', departmentId: 'dep-1', canApproveAndReject: true, allDepartments: false, canCancelAfterApproving: false);
      const ApproverView hrOther = ApproverView(
          email: 'x@co.com', departmentId: 'dep-2', canApproveAndReject: true, allDepartments: false, canCancelAfterApproving: false);
      final TimeTrackerRequest pending = _submitted();
      expect(ApprovalInbox.involves(pending, boss), isTrue);
      expect(ApprovalInbox.involves(pending, hrAll), isFalse, reason: 'HR waits for the manager');
      final TimeTrackerRequest atHr = RequestCycleRules.approve(pending, approverEmail: 'boss@co.com', at: t).after;
      expect(ApprovalInbox.involves(atHr, hrAll), isTrue);
      // Owner rule (9/10/2026): the HR step = All Departments holders only.
      expect(ApprovalInbox.involves(atHr, hrOwn), isFalse);
      expect(ApprovalInbox.involves(atHr, hrOther), isFalse);
      expect(ApprovalInbox.waitsFor(atHr, email: 'lead@co.com', isHrApprover: true, hrDepartmentId: 'dep-1'), isFalse);
      expect(ApprovalInbox.waitsFor(atHr, email: 'hr@co.com', isHrApprover: true, hrAllDepartments: true), isTrue);
      expect(ApprovalInbox.waitsFor(atHr, email: 'boss@co.com'), isFalse);
      const ApproverView self = ApproverView(
          email: 'me@co.com', departmentId: 'dep-1', canApproveAndReject: true, allDepartments: true, canCancelAfterApproving: true);
      expect(ApprovalInbox.involves(atHr, self), isFalse);
      final TimeTrackerRequest rejected =
          RequestCycleRules.reject(pending, approverEmail: 'boss@co.com', reason: 'r', at: t).after;
      expect(ApprovalInbox.involves(rejected, hrAll), isFalse);
    });

    test('Cancel_Request_After_Approving in scope sees approved requests; counts wait per approver', () {
      const ApproverView canceler = ApproverView(
          email: 'c@co.com', departmentId: 'dep-1', canApproveAndReject: false, allDepartments: false, canCancelAfterApproving: true);
      final TimeTrackerRequest free = _submitted(type: _free);
      expect(ApprovalInbox.involves(free, canceler), isTrue);
      final List<TimeTrackerRequest> all = <TimeTrackerRequest>[
        _submitted(),
        TimeTrackerRequest(id: 'r2', requesterEmail: 'amr@co.com', startAt: t, endAt: t,
            approvalSteps: const <RequestApprovalStep>[RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'boss@co.com')],
            currentStep: ApprovalStepKind.manager),
      ];
      expect(ApprovalInbox.waitingCount(all, email: 'boss@co.com'), 2);
      expect(ApprovalInbox.waitingCount(all, email: 'hr@co.com', isHrApprover: true, hrAllDepartments: true), 0);
    });
  });

  // 9/10/2026 (code review, FINAL SPEC wins): the phase-4 own-department
  // widening of the HR step is reverted — only "All Departments" holders.
  group('ApprovalRouter — HR scope (code review: All Departments only)', () {
    const RequestApprovalStep hr = RequestApprovalStep(step: ApprovalStepKind.hr);
    test('without All Departments the HR step is never open', () {
      bool act({bool all = false}) => ApprovalRouter.mayAct(
            step: hr,
            viewerEmail: 'v@co.com',
            requesterEmail: 'req@co.com',
            canApproveAndReject: true,
            approvalsAllDepartments: all,
          );
      expect(act(), isFalse);
      expect(act(all: true), isTrue);
    });
  });

  group('TransactionCorrectionRules', () {
    const WorkSchedule nineToFive = WorkSchedule(startMinutes: 9 * 60, endMinutes: 17 * 60);
    final DateTime day = DateTime(2026, 10, 1);
    TimeTrackerRequest tx(int inH, int outH) => TimeTrackerRequest(
          id: 'tx-1',
          requesterEmail: 'me@co.com',
          isTransaction: true,
          startAt: DateTime(2026, 10, 1, inH),
          endAt: DateTime(2026, 10, 1, outH),
          status: RequestStatus.approved,
        );

    test('no record → one corrected session, flagged, recalculated', () {
      final AttendanceDay d = TransactionCorrectionRules.apply(
          existing: null, transaction: tx(9, 17), schedule: nineToFive, now: DateTime(2026, 10, 5));
      expect(d.sessions.single.checkInAt, DateTime(2026, 10, 1, 9));
      expect(d.isCorrectedByTransaction, isTrue);
      expect(d.sourceRequestId, 'tx-1');
      expect(d.status, AttendanceStatus.present);
      expect(d.totalWorkMinutes, 480);
      final AttendanceDay late = TransactionCorrectionRules.apply(
          existing: null, transaction: tx(10, 17), schedule: nineToFive, now: DateTime(2026, 10, 5));
      expect(late.status, AttendanceStatus.late);
      expect(late.lateMinutes, 60);
    });

    test('an overlapping (open) session is replaced, the others kept', () {
      final AttendanceDay existing = AttendanceDay(
        id: 'me@co.com_2026-10-01',
        employeeEmail: 'me@co.com',
        date: day,
        sessions: <AttendanceSession>[
          AttendanceSession(checkInAt: DateTime(2026, 10, 1, 7), checkOutAt: DateTime(2026, 10, 1, 8), workLocationId: 'hq'),
          AttendanceSession(checkInAt: DateTime(2026, 10, 1, 9, 5), workLocationId: 'hq'),
        ],
      );
      final AttendanceDay d = TransactionCorrectionRules.apply(
          existing: existing, transaction: tx(9, 17), schedule: nineToFive, now: DateTime(2026, 10, 5));
      expect(d.sessions, hasLength(2));
      expect(d.sessions.last.checkOutAt, DateTime(2026, 10, 1, 17));
      expect(d.sessions.last.workLocationId, 'hq');
      expect(d.isCheckedIn, isFalse);
    });

    test('revert: back to the row before, or an empty (absent) day', () {
      final AttendanceDay corrected = TransactionCorrectionRules.apply(
          existing: null, transaction: tx(9, 17), schedule: nineToFive, now: DateTime(2026, 10, 5));
      final AttendanceDay emptied = TransactionCorrectionRules.revert(
          current: corrected, before: null, schedule: nineToFive, now: DateTime(2026, 10, 5));
      expect(emptied.sessions, isEmpty);
      expect(emptied.isCorrectedByTransaction, isFalse);
      expect(emptied.status, AttendanceStatus.absent);
      final AttendanceDay vacation = AttendanceDay(
          id: '', employeeEmail: 'me@co.com', date: day, status: AttendanceStatus.vacation);
      expect(
        TransactionCorrectionRules.revert(current: corrected, before: vacation, schedule: nineToFive, now: DateTime(2026, 10, 5))
            .status,
        AttendanceStatus.vacation,
      );
      expect(() => TransactionCorrectionRules.apply(existing: null, transaction: _submitted(), schedule: null, now: t),
          throwsStateError);
    });
  });

  group('history row reader', () {
    test('rowAt + correctionHistory find the day just before the correction', () {
      final TimeTrackerAudit audit = TimeTrackerAudit.next(null, actor: 'a@co.com', now: DateTime(2026));
      final AttendanceDay absent = AttendanceDay(
          id: 'd', employeeEmail: 'me@co.com', date: DateTime(2026, 10, 1), status: AttendanceStatus.absent);
      Map<String, dynamic> doc = TimeTrackerHistoryCodec.append(
          old: null, values: AttendanceDayModel.row(absent, id: 'd', audit: audit), now: DateTime(2026, 10, 2));
      final AttendanceDay fixed = absent.copyWith(
        sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 1, 9), checkOutAt: DateTime(2026, 10, 1, 17))],
        status: AttendanceStatus.present,
        isCorrectedByTransaction: true,
        sourceRequestId: 'tx-1',
      );
      doc = TimeTrackerHistoryCodec.append(old: doc, values: AttendanceDayModel.row(fixed, id: 'd', audit: audit), now: DateTime(2026, 10, 3));
      expect(TimeTrackerHistoryCodec.rowCount(doc), 2);
      final AttendanceCorrectionHistory? h = AttendanceDayModel.correctionHistory('d', doc, 'tx-1');
      expect(h, isNotNull);
      expect(h!.current.status, AttendanceStatus.present);
      expect(h.before!.status, AttendanceStatus.absent);
      expect(h.before!.sessions, isEmpty);
      expect(AttendanceDayModel.correctionHistory('d', doc, 'other'), isNull);
      expect(const AuditInfo().createdBy, '');
    });
  });
}
