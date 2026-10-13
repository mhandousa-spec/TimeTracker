/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: request_rules_test.dart
/// Purpose: Unit tests for the request rules — `RequestStatusMachine`
///          (lifecycle), `ApprovalRouter` (manager → HR cycle, who may act)
///          and `RequestReminderRule` (once every 24 hours).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_reminder_rule.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_status_machine.dart';

void main() {
  group('RequestStatusMachine', () {
    test('pending → approved / rejected / canceled', () {
      expect(RequestStatusMachine.next(RequestStatus.pending, RequestAction.approve),
          RequestStatus.approved);
      expect(RequestStatusMachine.next(RequestStatus.pending, RequestAction.reject),
          RequestStatus.rejected);
      expect(RequestStatusMachine.next(RequestStatus.pending, RequestAction.cancel),
          RequestStatus.canceled);
    });

    test('approved → under review on a cancellation request → canceled or back',
        () {
      final RequestStatus review = RequestStatusMachine.next(
          RequestStatus.approved, RequestAction.requestCancellation);
      expect(review, RequestStatus.underReview);
      expect(RequestStatusMachine.next(review, RequestAction.approveCancellation),
          RequestStatus.canceled);
      expect(RequestStatusMachine.next(review, RequestAction.rejectCancellation),
          RequestStatus.approved);
    });

    test('HR cancels an approved request → canceled_by_hr', () {
      expect(RequestStatusMachine.next(RequestStatus.approved, RequestAction.cancelByHr),
          RequestStatus.canceledByHr);
      expect(RequestStatus.canceledByHr.storageKey, 'canceled_by_hr');
    });

    test('forbidden moves are refused; final statuses allow nothing', () {
      expect(RequestStatusMachine.can(RequestStatus.pending, RequestAction.cancelByHr),
          isFalse);
      expect(RequestStatusMachine.can(RequestStatus.approved, RequestAction.cancel),
          isFalse);
      expect(() => RequestStatusMachine.next(RequestStatus.rejected, RequestAction.approve),
          throwsStateError);
      for (final RequestStatus s in <RequestStatus>[
        RequestStatus.rejected,
        RequestStatus.canceled,
        RequestStatus.canceledByHr,
      ]) {
        expect(s.isFinal, isTrue);
        expect(RequestStatusMachine.actionsFrom(s), isEmpty);
      }
      expect(RequestStatusMachine.actionsFrom(RequestStatus.approved), <RequestAction>{
        RequestAction.requestCancellation,
        RequestAction.cancelByHr,
      });
    });
  });

  group('ApprovalRouter', () {
    test('HR requester → their direct manager decides alone (owner 9/10/2026)', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: true,
        managerEmail: 'Boss@Co.com',
        requesterEmail: 'hr@co.com',
        requesterIsHrApprover: true,
      );
      expect(steps.length, 1);
      expect(steps.single.step, ApprovalStepKind.manager);
      expect(steps.single.approverEmail, 'boss@co.com');
      // HR-only type: still the manager, never HR themselves.
      final List<RequestApprovalStep> hrOnly = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: false,
        isHrApprovalRequired: true,
        managerEmail: 'boss@co.com',
        requesterEmail: 'hr@co.com',
        requesterIsHrApprover: true,
      );
      expect(hrOnly.single.step, ApprovalStepKind.manager);
      // The manager's approval completes the cycle.
      final ApprovalOutcome o = ApprovalRouter.decide(
        steps: steps,
        decision: ApprovalDecision.approved,
        approverEmail: 'boss@co.com',
        at: DateTime(2026, 10, 9),
      );
      expect(o.status, RequestStatus.approved);
      expect(o.currentStep, isNull);
    });

    test('HR requester without a manager → another HR decides, never themselves', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: true,
        requesterEmail: 'hr@co.com',
        requesterIsHrApprover: true,
      );
      expect(steps.single.step, ApprovalStepKind.hr);
      expect(
        ApprovalRouter.mayAct(
          step: steps.single,
          viewerEmail: 'hr@co.com',
          requesterEmail: 'hr@co.com',
          canApproveAndReject: true,
          approvalsAllDepartments: true,
        ),
        isFalse,
      );
    });

    test('HR transaction → manager only', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.transactionSteps(
        managerEmail: 'boss@co.com',
        requesterEmail: 'hr@co.com',
        requesterIsHrApprover: true,
      );
      expect(steps.single.step, ApprovalStepKind.manager);
    });

    final DateTime t = DateTime(2026, 10, 8, 10);

    test('manager then HR when both are required', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: true,
        managerEmail: 'Boss@Co.com',
      );
      expect(steps.map((RequestApprovalStep s) => s.step),
          <ApprovalStepKind>[ApprovalStepKind.manager, ApprovalStepKind.hr]);
      expect(steps.first.approverEmail, 'boss@co.com');
      expect(ApprovalRouter.initialStatus(steps), RequestStatus.pending);
      expect(ApprovalRouter.currentStepOf(steps)!.step, ApprovalStepKind.manager);
    });

    test('steps that are not required are skipped', () {
      expect(
        ApprovalRouter.initialSteps(
          isManagerApprovalRequired: false,
          isHrApprovalRequired: true,
        ).single.step,
        ApprovalStepKind.hr,
      );
      expect(
        ApprovalRouter.initialSteps(
          isManagerApprovalRequired: true,
          isHrApprovalRequired: false,
          managerEmail: 'boss@co.com',
        ).single.step,
        ApprovalStepKind.manager,
      );
    });

    test('no direct manager known → step 1 skipped, straight to HR (decision 18)',
        () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: true,
      );
      expect(steps.single.step, ApprovalStepKind.hr);
      expect(
        ApprovalRouter.initialSteps(
          isManagerApprovalRequired: true,
          isHrApprovalRequired: true,
          managerEmail: 'Me@co.com',
          requesterEmail: 'me@co.com',
        ).single.step,
        ApprovalStepKind.hr,
      );
    });

    test('transactions route manager → HR, both required (decision 19)', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.transactionSteps(
        managerEmail: 'Boss@co.com',
        requesterEmail: 'me@co.com',
      );
      expect(steps.map((RequestApprovalStep s) => s.step),
          <ApprovalStepKind>[ApprovalStepKind.manager, ApprovalStepKind.hr]);
      expect(steps.first.approverEmail, 'boss@co.com');
      expect(
        ApprovalRouter.transactionSteps(managerEmail: '', requesterEmail: 'me@co.com')
            .single
            .step,
        ApprovalStepKind.hr,
      );
    });

    test('a requester who is the department manager skips step 1', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: true,
        managerEmail: 'boss@co.com',
        requesterIsDepartmentManager: true,
      );
      expect(steps.single.step, ApprovalStepKind.hr);
    });

    test('no approval required → approved on submit', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: false,
        isHrApprovalRequired: false,
      );
      expect(steps, isEmpty);
      expect(ApprovalRouter.initialStatus(steps), RequestStatus.approved);
    });

    test('manager approves → still pending at HR; HR approves → approved', () {
      final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: true,
        managerEmail: 'boss@co.com',
      );
      final ApprovalOutcome first = ApprovalRouter.decide(
        steps: steps,
        decision: ApprovalDecision.approved,
        approverEmail: 'Boss@co.com',
        at: t,
      );
      expect(first.status, RequestStatus.pending);
      expect(first.currentStep, ApprovalStepKind.hr);
      expect(first.steps.first.approverEmail, 'boss@co.com');
      expect(first.steps.first.decidedAt, t);
      final ApprovalOutcome second = ApprovalRouter.decide(
        steps: first.steps,
        decision: ApprovalDecision.approved,
        approverEmail: 'hr@co.com',
        at: t,
      );
      expect(second.status, RequestStatus.approved);
      expect(second.currentStep, isNull);
    });

    test('a rejection ends the cycle with its reason', () {
      final ApprovalOutcome out = ApprovalRouter.decide(
        steps: ApprovalRouter.initialSteps(
          isManagerApprovalRequired: true,
          isHrApprovalRequired: true,
          managerEmail: 'boss@co.com',
        ),
        decision: ApprovalDecision.rejected,
        approverEmail: 'boss@co.com',
        at: t,
        reason: '  Busy season ',
      );
      expect(out.status, RequestStatus.rejected);
      expect(out.currentStep, isNull);
      expect(out.steps.first.reason, 'Busy season');
    });

    test('deciding with nothing pending, or "pending", throws', () {
      expect(
        () => ApprovalRouter.decide(
          steps: const <RequestApprovalStep>[],
          decision: ApprovalDecision.approved,
          approverEmail: 'x@co.com',
          at: t,
        ),
        throwsStateError,
      );
      expect(
        () => ApprovalRouter.decide(
          steps: ApprovalRouter.initialSteps(
              isManagerApprovalRequired: true,
              isHrApprovalRequired: false,
              managerEmail: 'boss@co.com'),
          decision: ApprovalDecision.pending,
          approverEmail: 'x@co.com',
          at: t,
        ),
        throwsStateError,
      );
    });

    group('mayAct', () {
      const RequestApprovalStep manager = RequestApprovalStep(
        step: ApprovalStepKind.manager,
        approverEmail: 'boss@co.com',
      );
      const RequestApprovalStep hr = RequestApprovalStep(step: ApprovalStepKind.hr);

      bool act(
        RequestApprovalStep step, {
        String viewer = 'v@co.com',
        bool approve = true,
        bool all = false,
      }) =>
          ApprovalRouter.mayAct(
            step: step,
            viewerEmail: viewer,
            requesterEmail: 'req@co.com',
            canApproveAndReject: approve,
            approvalsAllDepartments: all,
          );

      test('step 1 only for the requester direct manager', () {
        expect(act(manager, viewer: 'Boss@co.com'), isTrue);
        expect(act(manager, all: true), isFalse);
        expect(act(manager, viewer: 'boss@co.com', approve: false), isFalse);
      });

      test('step 2 only with Approve_And_Reject + All Departments', () {
        expect(act(hr, all: true), isTrue);
        expect(act(hr, viewer: 'boss@co.com'), isFalse);
        expect(act(hr, all: true, approve: false), isFalse);
      });

      test('never on your own request or a decided step', () {
        expect(act(hr, all: true, viewer: 'REQ@co.com'), isFalse);
        expect(act(hr.copyWith(decision: ApprovalDecision.approved), all: true),
            isFalse);
      });
    });
  });

  group('RequestReminderRule', () {
    final DateTime last = DateTime(2026, 10, 1, 9);

    test('first reminder is always allowed on a pending request', () {
      expect(
        RequestReminderRule.canSend(
            status: RequestStatus.pending, lastReminderAt: null, now: last),
        isTrue,
      );
    });

    test('once every 24 hours (owner H3) + the countdown', () {
      bool at(DateTime now) => RequestReminderRule.canSend(
          status: RequestStatus.pending, lastReminderAt: last, now: now);
      expect(at(last.add(const Duration(hours: 23, minutes: 59))), isFalse);
      expect(at(last.add(const Duration(hours: 24))), isTrue);
      expect(RequestReminderRule.nextAllowedAt(last), DateTime(2026, 10, 2, 9));
      expect(RequestReminderRule.waitLeft(last, last.add(const Duration(minutes: 1))),
          const Duration(hours: 23, minutes: 59));
      expect(RequestReminderRule.waitLeft(last, last.add(const Duration(hours: 24))), isNull);
      expect(RequestReminderRule.waitLeft(null, last), isNull);
    });

    test('only pending requests can be reminded about', () {
      expect(
        RequestReminderRule.canSend(
            status: RequestStatus.approved, lastReminderAt: null, now: last),
        isFalse,
      );
    });
  });
}
