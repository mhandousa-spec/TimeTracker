/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: approval_router.dart
/// Purpose: Declares `ApprovalRouter` — builds a request's approval cycle,
///          applies a decision to it, and says who may act on a step — and
///          `ApprovalOutcome`, the result of a decision.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Rules (owner decisions 3, 18, 19 — 8/10/2026):
///   * Step 1 = the requester's DIRECT MANAGER from the Org Chart (the
///     `Supervisor` email on `Employees_Info`, resolved by `ManagerResolver`),
///     only when the request type has `Is_Manager_Approval_Required`.
///     Fallback (decision 18): no manager known — or the requester is their
///     own manager — → step 1 is skipped and the request goes straight to HR.
///   * Step 2 = HR, only when `Is_HR_Approval_Required`.
///   * Transactions (attendance corrections, decision 19) always route
///     manager → HR, both required — see [ApprovalRouter.transactionSteps].
///   * Steps that are not required are not created; no step at all → the
///     request is approved on submit.
///   * Step 1 can be acted on only by that direct manager (the step's
///     `approverEmail`); step 2 only by holders of `Approve_And_Reject` +
///     `Approvals_All_Departments`. Both need `Approve_And_Reject`.
///   * A rejection ends the cycle (status rejected); the last approval
///     approves the request.
///
/// Updated: 8/10/2026 - round-3 decisions 18 + 19 (direct manager, skip when
/// unknown, transactions manager → HR).
/// Updated: 9/10/2026 - owner rule "every HR has a manager": when the
/// REQUESTER is an HR approver (`Approve_And_Reject` + "All Departments"),
/// the request goes to their direct manager ONLY and the manager's decision
/// is final — HR never approves their own request ([initialSteps]
/// `requesterIsHrApprover`). No known manager → the HR step stays, and
/// another HR approver decides (nobody decides their own request).
/// Updated: 9/10/2026 - phase 4 (brief §B): the HR step was also opened to
/// an `Approve_And_Reject` holder WITHOUT "All Departments" for their own
/// department — REVERTED by the code review below.
/// Updated: 9/10/2026 - code review (owner rules, FINAL SPEC wins):
///   * the phase-4 widening is REVERTED — the HR step is decided ONLY by
///     `Approve_And_Reject` + `Approvals_All_Departments` holders;
///   * one person never decides both steps of one round: whoever decided the
///     manager step cannot decide the HR step ([mayAct] `steps`). When the
///     manager is themself the only other HR approver, their approval is
///     final ([initialSteps] `managerIsSoleOtherHr`);
///   * finding 5: only the LATEST round counts ([currentStepOf] /
///     [decide]); a rejection closes the rest of its round (`skipped`), so a
///     stale pending step of a refused cancellation round never waits again;
///   * finding 7: a manager who cannot act (no approve switch / not an
///     active employee) is skipped at submit — the request goes to HR — and
///     an HR approver may act on a manager step that is BLOCKED
///     ([mayAct] `managerStepBlocked`; the HR decision lands on the HR step
///     and the manager step is `skipped`);
///   * decision 18 applied fully: a manager-only type with no actionable
///     manager goes to HR instead of being approved on submit.

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

/// The cycle after a decision.
class ApprovalOutcome {
  const ApprovalOutcome({
    required this.steps,
    required this.status,
    required this.currentStep,
  });

  final List<RequestApprovalStep> steps;
  final RequestStatus status;

  /// The next step waiting for a decision; null when the cycle is over.
  final ApprovalStepKind? currentStep;
}

class ApprovalRouter {
  const ApprovalRouter._();

  /// Function Name: [initialSteps]
  ///
  /// Purpose: The pending steps of a new request.
  ///
  /// Parameters:
  ///   [bool] isManagerApprovalRequired: from the request type.
  ///   [bool] isHrApprovalRequired: from the request type.
  ///   [String] managerEmail: the requester's direct manager ('' = none
  ///     known, or one who cannot act → the manager step goes to HR).
  ///   [String] requesterEmail: a manager equal to the requester is ignored.
  ///   [bool] requesterIsDepartmentManager: skip the manager step.
  ///   [bool] requesterIsHrApprover: the requester is themselves HR → their
  ///     direct manager decides alone (owner, 9/10/2026).
  ///   [bool] managerIsSoleOtherHr: ADDED 9/10/2026 — the manager is an HR
  ///     approver and no OTHER HR approver could decide the HR step → the
  ///     manager's approval is final.
  ///
  /// Return type: [List<RequestApprovalStep>] — in decision order.
  static List<RequestApprovalStep> initialSteps({
    required bool isManagerApprovalRequired,
    required bool isHrApprovalRequired,
    String managerEmail = '',
    String requesterEmail = '',
    bool requesterIsDepartmentManager = false,
    bool requesterIsHrApprover = false,
    bool managerIsSoleOtherHr = false,
  }) {
    final String manager = managerEmail.trim().toLowerCase();
    final bool hasManager = manager.isNotEmpty &&
        manager != requesterEmail.trim().toLowerCase() &&
        !requesterIsDepartmentManager;
    final bool needsAny = isManagerApprovalRequired || isHrApprovalRequired;
    if ((requesterIsHrApprover || managerIsSoleOtherHr) && hasManager && needsAny) {
      // HR's own request, or a manager who is the only other HR approver:
      // the manager's approval is the whole cycle.
      return List<RequestApprovalStep>.unmodifiable(<RequestApprovalStep>[
        RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: manager),
      ]);
    }
    final bool managerStep = isManagerApprovalRequired && hasManager;
    // Decision 18: no actionable manager → the request goes straight to HR.
    final bool hrStep = isHrApprovalRequired || (isManagerApprovalRequired && !hasManager);
    return List<RequestApprovalStep>.unmodifiable(<RequestApprovalStep>[
      if (managerStep)
        RequestApprovalStep(
          step: ApprovalStepKind.manager,
          approverEmail: manager,
        ),
      if (hrStep) const RequestApprovalStep(step: ApprovalStepKind.hr),
    ]);
  }

  /// Function Name: [transactionSteps]
  ///
  /// Purpose: The steps of a new attendance transaction (owner decision 19:
  /// manager → HR, both required; the manager step is skipped when the
  /// requester has no known manager).
  ///
  /// Parameters:
  ///   [String] managerEmail: the requester's direct manager ('' = none).
  ///   [String] requesterEmail
  ///
  /// Return type: [List<RequestApprovalStep>]
  static List<RequestApprovalStep> transactionSteps({
    required String managerEmail,
    required String requesterEmail,
    bool requesterIsHrApprover = false,
    bool managerIsSoleOtherHr = false,
  }) =>
      initialSteps(
        isManagerApprovalRequired: true,
        isHrApprovalRequired: true,
        managerEmail: managerEmail,
        requesterEmail: requesterEmail,
        requesterIsHrApprover: requesterIsHrApprover,
        managerIsSoleOtherHr: managerIsSoleOtherHr,
      );

  /// Function Name: [roundStart]
  ///
  /// Purpose: ADDED 9/10/2026 (code review finding 5) — the index where the
  /// LATEST round starts. Every cancellation round copies the original
  /// steps, so all rounds have the size of the original one.
  ///
  /// Return type: [int]
  static int roundStart(List<RequestApprovalStep> steps) {
    final int size = steps.where((RequestApprovalStep s) => !s.isCancellation).length;
    if (size <= 0 || steps.length <= size) return 0;
    return size * ((steps.length - size) ~/ size);
  }

  /// Function Name: [roundStartOf]
  ///
  /// Purpose: The index where the round holding [index] starts.
  ///
  /// Return type: [int]
  static int roundStartOf(List<RequestApprovalStep> steps, int index) {
    final int size = steps.where((RequestApprovalStep s) => !s.isCancellation).length;
    if (size <= 0 || index < size) return 0;
    return size * (index ~/ size);
  }

  /// Function Name: [currentStepOf]
  ///
  /// Purpose: The first step of the LATEST round still waiting for a
  /// decision, or null (9/10/2026, finding 5: an earlier round's leftover
  /// pending step never waits again).
  ///
  /// Return type: [RequestApprovalStep?]
  static RequestApprovalStep? currentStepOf(List<RequestApprovalStep> steps) {
    for (int i = roundStart(steps); i < steps.length; i++) {
      if (steps[i].isPending) return steps[i];
    }
    return null;
  }

  /// Function Name: [initialStatus]
  ///
  /// Purpose: pending while there is a step to decide; approved when the
  /// type needs no approval at all.
  ///
  /// Return type: [RequestStatus]
  static RequestStatus initialStatus(List<RequestApprovalStep> steps) =>
      currentStepOf(steps) == null ? RequestStatus.approved : RequestStatus.pending;

  /// Function Name: [decide]
  ///
  /// Purpose: Apply [decision] to the current step. A rejection closes the
  /// rest of its round (`skipped`, finding 5). [skipCurrentFirst] (an HR
  /// approver acting on a BLOCKED manager step, finding 7) first passes the
  /// manager step when an HR step follows in the round — the decision then
  /// lands on that HR step. [closeFollowingHr] (the manager is the only
  /// other HR approver) closes the HR step that would come next, so this
  /// approval is final.
  ///
  /// Parameters:
  ///   [List<RequestApprovalStep>] steps
  ///   [ApprovalDecision] decision: approved or rejected.
  ///   [String] approverEmail: who decided.
  ///   [DateTime] at: when.
  ///   [String] reason: reason of rejection (or a note).
  ///
  /// Return type: [ApprovalOutcome] — throws `StateError` when no step is
  /// pending or [decision] is not approved / rejected.
  static ApprovalOutcome decide({
    required List<RequestApprovalStep> steps,
    required ApprovalDecision decision,
    required String approverEmail,
    required DateTime at,
    String reason = '',
    bool skipCurrentFirst = false,
    bool closeFollowingHr = false,
  }) {
    if (decision == ApprovalDecision.pending || decision == ApprovalDecision.skipped) {
      throw StateError('A decision must approve or reject.');
    }
    final List<RequestApprovalStep> next = List<RequestApprovalStep>.of(steps);
    final int start = roundStart(steps);
    int index = _pendingFrom(next, start);
    if (index < 0) throw StateError('No approval step is waiting.');
    if (skipCurrentFirst && next[index].step == ApprovalStepKind.manager) {
      final int hr = _pendingFrom(next, index + 1);
      if (hr >= 0 && next[hr].step == ApprovalStepKind.hr) {
        next[index] = next[index].copyWith(decision: ApprovalDecision.skipped, decidedAt: at);
        index = hr;
      }
    }
    next[index] = next[index].copyWith(
      approverEmail: approverEmail.trim().toLowerCase(),
      decision: decision,
      decidedAt: at,
      reason: reason.trim(),
    );
    if (decision == ApprovalDecision.rejected) {
      // Finding 5: nothing else of this round may wait any more.
      for (int i = index + 1; i < next.length; i++) {
        if (next[i].isPending) next[i] = next[i].copyWith(decision: ApprovalDecision.skipped, decidedAt: at);
      }
      return ApprovalOutcome(
        steps: List<RequestApprovalStep>.unmodifiable(next),
        status: RequestStatus.rejected,
        currentStep: null,
      );
    }
    if (closeFollowingHr) {
      final int hr = _pendingFrom(next, index + 1);
      if (hr >= 0 && next[hr].step == ApprovalStepKind.hr) {
        next[hr] = next[hr].copyWith(decision: ApprovalDecision.skipped, decidedAt: at);
      }
    }
    final List<RequestApprovalStep> frozen = List<RequestApprovalStep>.unmodifiable(next);
    final RequestApprovalStep? following = currentStepOf(frozen);
    return ApprovalOutcome(
      steps: frozen,
      status: following == null ? RequestStatus.approved : RequestStatus.pending,
      currentStep: following?.step,
    );
  }

  static int _pendingFrom(List<RequestApprovalStep> steps, int from) {
    for (int i = from; i < steps.length; i++) {
      if (steps[i].isPending) return i;
    }
    return -1;
  }

  /// Function Name: [decidedInRound]
  ///
  /// Purpose: [email] already decided a step of the round that holds
  /// [step] (nobody decides two steps of one round — owner, 9/10/2026).
  ///
  /// Return type: [bool]
  static bool decidedInRound(
    List<RequestApprovalStep> steps,
    RequestApprovalStep step,
    String email,
  ) {
    final String who = email.trim().toLowerCase();
    final int index = steps.indexOf(step);
    if (who.isEmpty || index < 0) return false;
    for (int i = roundStartOf(steps, index); i < index; i++) {
      final RequestApprovalStep s = steps[i];
      if (!s.isPending && !s.isSkipped && s.approverEmail.trim().toLowerCase() == who) return true;
    }
    return false;
  }

  /// Function Name: [mayAct]
  ///
  /// Purpose: Whether the viewer may approve / reject [step].
  ///
  /// Parameters:
  ///   [RequestApprovalStep] step
  ///   [String] viewerEmail / [String] requesterEmail: nobody decides their
  ///     own request.
  ///   [bool] canApproveAndReject: the `Approve_And_Reject` switch.
  ///   [bool] approvalsAllDepartments: the `Approvals_All_Departments` switch
  ///     — REQUIRED for the HR step (FINAL SPEC; the phase-4 own-department
  ///     widening is reverted 9/10/2026).
  ///   [List<RequestApprovalStep>] steps: the request's steps (who decided
  ///     the manager step of this round may not decide its HR step).
  ///   [bool] managerStepBlocked: the manager on [step] cannot act (no
  ///     approve switch / not an active employee) — an HR approver may act.
  ///
  /// Return type: [bool]
  static bool mayAct({
    required RequestApprovalStep step,
    required String viewerEmail,
    required String requesterEmail,
    required bool canApproveAndReject,
    required bool approvalsAllDepartments,
    List<RequestApprovalStep> steps = const <RequestApprovalStep>[],
    bool managerStepBlocked = false,
  }) {
    if (!step.isPending || !canApproveAndReject) return false;
    final String viewer = viewerEmail.trim().toLowerCase();
    if (viewer.isEmpty || viewer == requesterEmail.trim().toLowerCase()) {
      return false;
    }
    switch (step.step) {
      case ApprovalStepKind.manager:
        // Only the direct manager stored on the step (decision 18) — or, when
        // that manager cannot act, an HR approver (finding 7).
        if (viewer == step.approverEmail.trim().toLowerCase()) return true;
        return managerStepBlocked && approvalsAllDepartments;
      case ApprovalStepKind.hr:
        return approvalsAllDepartments && !decidedInRound(steps, step, viewer);
    }
  }
}
