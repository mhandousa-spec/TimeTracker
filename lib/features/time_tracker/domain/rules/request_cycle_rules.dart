/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: request_cycle_rules.dart
/// Purpose: Declares `RequestCycleRules` — every move of a request after it
///          was submitted (approve, reject, cancel while pending, ask to
///          cancel an approved request, HR cancels after approving, send a
///          reminder) — and `CycleOutcome`, the before / after of a decision.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase-4 brief §A / §B on top of `RequestStatusMachine` + `ApprovalRouter`:
///   * Approve on a pending request decides the current step; the last
///     step makes it approved, otherwise it waits for the next (HR) step.
///   * Reject needs a reason and ends the cycle (rejected).
///   * Pending → canceled by the requester (no approver involved).
///   * Approved → the requester asks to cancel with a reason → under review.
///     The request goes back through the SAME cycle (a "cancellation round":
///     copies of the original steps flagged `isCancellation`; the manager
///     step keeps the direct manager, the HR step is open to HR). Approve on
///     the last one = cancellation accepted → canceled; Reject = the request
///     stays approved. A request whose type needed no approval at all is
///     canceled at once.
///   * HR cancels an approved request directly → canceled by HR (reason).
///   * Send Reminder: requester only, pending only, once every 2 days.
/// Pure Dart — unit-tested; balance / attendance effects live in the
/// services.
/// Updated: 9/10/2026 - code review: only the LATEST round counts and a
/// rejection closes the rest of its round (finding 5); [approve] / [reject]
/// take `overrideBlockedManager` (an HR approver acting on a blocked
/// manager step — finding 7) and [approve] `managerIsFinal` (the manager
/// was the only other HR approver → their approval ends the cycle); the
/// approval cycle never shows a `skipped` step.

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_reminder_rule.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_status_machine.dart';

/// A request before and after one move.
class CycleOutcome {
  const CycleOutcome({required this.before, required this.after});

  final TimeTrackerRequest before;
  final TimeTrackerRequest after;

  RequestStatus get from => before.status;
  RequestStatus get to => after.status;

  /// The last approval step approved the request (pending → approved).
  bool get isFinalApproval => from == RequestStatus.pending && to == RequestStatus.approved;

  /// An approved request ended canceled (balance refund / correction revert).
  bool get endsApprovedRequest =>
      (from == RequestStatus.approved || from == RequestStatus.underReview) &&
      (to == RequestStatus.canceled || to == RequestStatus.canceledByHr);

  /// The cycle moved on to its next step (still waiting for someone).
  bool get movedToNextStep =>
      from == to &&
      (to == RequestStatus.pending || to == RequestStatus.underReview) &&
      after.currentStep != null;
}

class RequestCycleRules {
  const RequestCycleRules._();

  static String _norm(String email) => email.trim().toLowerCase();

  /// Function Name: [isRequester]
  ///
  /// Return type: [bool] — [viewerEmail] submitted [request].
  static bool isRequester(TimeTrackerRequest request, String viewerEmail) =>
      _norm(viewerEmail).isNotEmpty && _norm(request.requesterEmail) == _norm(viewerEmail);

  /// Function Name: [actionableStep]
  ///
  /// Purpose: The step waiting for a decision — only while the request is
  /// pending or under review (a closed request may keep undecided steps).
  ///
  /// Return type: [RequestApprovalStep?]
  static RequestApprovalStep? actionableStep(TimeTrackerRequest request) =>
      request.status == RequestStatus.pending || request.status == RequestStatus.underReview
          ? ApprovalRouter.currentStepOf(request.approvalSteps)
          : null;

  /// Function Name: [approve]
  ///
  /// Purpose: The current step approves (or accepts the cancellation).
  ///
  /// Return type: [CycleOutcome] — throws `StateError` when nothing waits.
  static CycleOutcome approve(
    TimeTrackerRequest request, {
    required String approverEmail,
    required DateTime at,
    bool overrideBlockedManager = false,
    bool managerIsFinal = false,
  }) {
    if (actionableStep(request) == null) {
      throw StateError('Nothing is waiting for a decision.');
    }
    final ApprovalOutcome o = ApprovalRouter.decide(
      steps: request.approvalSteps,
      decision: ApprovalDecision.approved,
      approverEmail: approverEmail,
      at: at,
      skipCurrentFirst: overrideBlockedManager,
      closeFollowingHr: managerIsFinal,
    );
    final bool done = o.currentStep == null;
    final RequestStatus next = !done
        ? request.status
        : RequestStatusMachine.next(
            request.status,
            request.status == RequestStatus.pending
                ? RequestAction.approve
                : RequestAction.approveCancellation,
          );
    return CycleOutcome(
      before: request,
      after: request.copyWith(
        status: next,
        approvalSteps: o.steps,
        currentStep: o.currentStep,
        clearCurrentStep: done,
      ),
    );
  }

  /// Function Name: [reject]
  ///
  /// Purpose: The current step rejects: a pending request becomes
  /// rejected; a cancellation under review is refused (stays approved).
  ///
  /// Return type: [CycleOutcome] — throws `StateError` when nothing waits or
  /// [reason] is empty.
  static CycleOutcome reject(
    TimeTrackerRequest request, {
    required String approverEmail,
    required String reason,
    required DateTime at,
    bool overrideBlockedManager = false,
  }) {
    if (actionableStep(request) == null) {
      throw StateError('Nothing is waiting for a decision.');
    }
    if (reason.trim().isEmpty) throw StateError('A reason is required.');
    final ApprovalOutcome o = ApprovalRouter.decide(
      steps: request.approvalSteps,
      decision: ApprovalDecision.rejected,
      approverEmail: approverEmail,
      at: at,
      reason: reason,
      skipCurrentFirst: overrideBlockedManager,
    );
    return CycleOutcome(
      before: request,
      after: request.copyWith(
        status: RequestStatusMachine.next(
          request.status,
          request.status == RequestStatus.pending
              ? RequestAction.reject
              : RequestAction.rejectCancellation,
        ),
        approvalSteps: o.steps,
        clearCurrentStep: true,
      ),
    );
  }

  /// Function Name: [canCancelPending] / [cancelPending]
  ///
  /// Purpose: The requester withdraws a PENDING request (canceled).
  ///
  /// Return type: [bool] / [TimeTrackerRequest] — `cancelPending` throws
  /// `StateError` when not allowed.
  static bool canCancelPending(TimeTrackerRequest request, String viewerEmail) =>
      isRequester(request, viewerEmail) &&
      RequestStatusMachine.can(request.status, RequestAction.cancel);

  static TimeTrackerRequest cancelPending(TimeTrackerRequest request, {String reason = ''}) =>
      request.copyWith(
        status: RequestStatusMachine.next(request.status, RequestAction.cancel),
        clearCurrentStep: true,
        cancellationReason: reason.trim(),
      );

  /// Function Name: [canRequestCancellation] / [requestCancellation]
  ///
  /// Purpose: The requester asks to cancel an APPROVED leave request: under
  /// review + a cancellation round (see the file header).
  ///
  /// Return type: [bool] / [TimeTrackerRequest] — throws `StateError` when
  /// not allowed or [reason] is empty.
  static bool canRequestCancellation(TimeTrackerRequest request, String viewerEmail) =>
      !request.isTransaction &&
      isRequester(request, viewerEmail) &&
      RequestStatusMachine.can(request.status, RequestAction.requestCancellation);

  static TimeTrackerRequest requestCancellation(
    TimeTrackerRequest request, {
    required String reason,
  }) {
    if (reason.trim().isEmpty) throw StateError('A reason is required.');
    final RequestStatus review =
        RequestStatusMachine.next(request.status, RequestAction.requestCancellation);
    final List<RequestApprovalStep> round = <RequestApprovalStep>[
      for (final RequestApprovalStep s in request.approvalSteps)
        if (!s.isCancellation)
          RequestApprovalStep(
            step: s.step,
            approverEmail: s.step == ApprovalStepKind.manager ? s.approverEmail : '',
            isCancellation: true,
          ),
    ];
    if (round.isEmpty) {
      // Nobody approved it in the first place → nobody to ask.
      return request.copyWith(
        status: RequestStatusMachine.next(review, RequestAction.approveCancellation),
        clearCurrentStep: true,
        cancellationReason: reason.trim(),
      );
    }
    return request.copyWith(
      status: review,
      approvalSteps: List<RequestApprovalStep>.unmodifiable(
        <RequestApprovalStep>[...request.approvalSteps, ...round],
      ),
      currentStep: round.first.step,
      cancellationReason: reason.trim(),
    );
  }

  /// Function Name: [canCancelByHr] / [cancelByHr]
  ///
  /// Purpose: HR cancels an APPROVED request ("Canceled By HR").
  ///
  /// Return type: [bool] / [TimeTrackerRequest] — throws `StateError` when
  /// not approved or [reason] is empty.
  static bool canCancelByHr(TimeTrackerRequest request) =>
      RequestStatusMachine.can(request.status, RequestAction.cancelByHr);

  static TimeTrackerRequest cancelByHr(TimeTrackerRequest request, {required String reason}) {
    if (reason.trim().isEmpty) throw StateError('A reason is required.');
    return request.copyWith(
      status: RequestStatusMachine.next(request.status, RequestAction.cancelByHr),
      clearCurrentStep: true,
      cancellationReason: reason.trim(),
    );
  }

  /// Function Name: [canRemind] / [remind]
  ///
  /// Purpose: "Send Reminder" — requester only, pending only, once every
  /// 24 hours (`RequestReminderRule`).
  ///
  /// Return type: [bool] / [TimeTrackerRequest] — `remind` throws
  /// `StateError` when not allowed now.
  static bool canRemind(TimeTrackerRequest request, String viewerEmail, DateTime now) =>
      isRequester(request, viewerEmail) &&
      RequestReminderRule.canSend(
        status: request.status,
        lastReminderAt: request.lastReminderAt,
        now: now,
      );

  static TimeTrackerRequest remind(TimeTrackerRequest request, {required DateTime now}) {
    if (!RequestReminderRule.canSend(
      status: request.status,
      lastReminderAt: request.lastReminderAt,
      now: now,
    )) {
      throw StateError('A reminder was sent less than two days ago.');
    }
    return request.copyWith(lastReminderAt: now);
  }

  /// Function Name: [visibleSteps]
  ///
  /// Purpose: The steps the "Approval Cycle" shows: the latest round
  /// (cancellation round while one exists, else the original steps); on a
  /// closed request only the decided ones.
  ///
  /// Return type: [List<RequestApprovalStep>]
  static List<RequestApprovalStep> visibleSteps(TimeTrackerRequest request) {
    final List<RequestApprovalStep> all = request.approvalSteps;
    // Every round copies the original steps, so round k starts at k × size.
    final List<RequestApprovalStep> round = all.sublist(ApprovalRouter.roundStart(all));
    final bool open = actionableStep(request) != null;
    return List<RequestApprovalStep>.unmodifiable(<RequestApprovalStep>[
      for (final RequestApprovalStep s in round)
        // A skipped step had no decision of its own (9/10/2026).
        if (!s.isSkipped && (open || !s.isPending)) s,
    ]);
  }
}
