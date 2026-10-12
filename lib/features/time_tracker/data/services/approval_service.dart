/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: approval_service.dart
/// Purpose: Declares `ApprovalService` — what an APPROVER does: approve,
///          reject (with a reason), cancel after approving — with the
///          permission / scope checks, the side effects (vacation balance,
///          transaction correction), notifications and System Log.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase-4 brief §B. Gates (FINAL SPEC §1 section 5):
///   * approve / reject `Approve_And_Reject` and the CURRENT step must be the
///     viewer's (`TimeTrackerAccess.mayActOnStep`: the manager step only by
///     the direct manager stored on it; the HR step by HR with "All
///     Departments", or without it for their own department);
///   * cancel after approving `Cancel_Request_After_Approving`, in the
///     viewer's approvals scope, never one's own request.
/// Approve on the manager step moves the request to HR (HR approvers
/// notified); the last approval approves it (balance deducted or the
/// attendance day corrected; requester notified). Under review: approve =
/// accept the cancellation (canceled + refund / revert), reject = keep it
/// approved. Every decision re-reads the stored request first, writes one
/// history row (who / decision / time / reason) and a System Log entry. The
/// request type and schedule are read BEFORE the request is saved, so a read
/// failure changes nothing. No try here (playbook §3).

/// Updated: 9/10/2026 - code review:
///   * HR step: "All Departments" approvers only, never the person who
///     decided the manager step of the same round (FINAL SPEC / owner);
///     when the deciding manager is the only other HR approver, their
///     approval is final (`isSoleOtherHrApprover`);
///   * findings 2 + 3 + 4: the decision and its effects are ONE
///     compare-and-set transaction (`RequestBaseRepository.commitRequest`
///     over the request as re-read) — a double tap / a second approver /
///     a cancel in between ends in `TimeTrackerRecordChanged`, never in a
///     second deduction; a refund gives back exactly the stored deduction;
///   * finding 7: an HR approver may act on a BLOCKED manager step (the
///     manager is no longer an active approver) — [refreshApprovers] keeps
///     the list the buttons read;
///   * finding 10: approving a deducting request of an employee without a
///     balance is refused (`TimeTrackerNoVacationBalance`).

import 'package:knowticed_plus/features/time_tracker/data/services/request_effects.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_side_effects.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

class ApprovalService {
  ApprovalService({
    required RequestBaseRepository requests,
    required RequestTypeBaseRepository types,
    required ApproverDirectory approvers,
    required RequestEffects effects,
    required TimeTrackerNotificationService notifier,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
    DateTime Function() clock = DateTime.now,
  })  : _requests = requests,
        _types = types,
        _approvers = approvers,
        _effects = effects,
        _notifier = notifier,
        _access = access,
        _log = log,
        _clock = clock;

  final RequestBaseRepository _requests;
  final RequestTypeBaseRepository _types;
  final ApproverDirectory _approvers;
  final RequestEffects _effects;
  final TimeTrackerNotificationService _notifier;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;
  final DateTime Function() _clock;

  /// Function Name: [mayDecide]
  ///
  /// Purpose: Approve / Reject are shown: the request's current step waits
  /// for the signed-in user (an HR approver also on a BLOCKED manager step —
  /// finding 7; never the HR step after deciding the manager step).
  ///
  /// Return type: [bool]
  bool mayDecide(TimeTrackerRequest request) {
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(request);
    return step != null &&
        _access.mayActOnStep(
          step,
          requesterEmail: request.requesterEmail,
          requesterDepartmentId: request.requesterDepartmentId,
          steps: request.approvalSteps,
          managerStepBlocked: ApprovalInbox.isManagerStepBlocked(request, _approvers.knownApproverEmails),
        );
  }

  /// Function Name: [refreshApprovers]
  ///
  /// Purpose: ADDED 9/10/2026 (finding 7) — load who may approve, so a
  /// manager step whose manager cannot act shows Approve / Reject to HR.
  ///
  /// Return type: [Future<Set<String>>] — the approvers' e-mails.
  Future<Set<String>> refreshApprovers() async => <String>{
        for (final TimeTrackerApprover a in await _approvers.fetchApprovers()) a.email,
      };

  /// Function Name: [mayCancelAfterApproving]
  ///
  /// Purpose: "Cancel" is shown on an approved request (HR).
  ///
  /// Return type: [bool]
  bool mayCancelAfterApproving(TimeTrackerRequest request) =>
      _access.canCancelAfterApproving &&
      !RequestCycleRules.isRequester(request, _access.currentUserEmail) &&
      _access.approvalsCover(request.requesterDepartmentId) &&
      RequestCycleRules.canCancelByHr(request);

  /// Function Name: [approve]
  ///
  /// Purpose: Approve the current step (or accept a cancellation).
  ///
  /// Parameters:
  ///   [TimeTrackerRequest] request · [TimeTrackerTypeName] typeName (for
  ///   the requester's notification) · [bool] isArabic
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> approve(
    TimeTrackerRequest request, {
    required TimeTrackerTypeName typeName,
    required bool isArabic,
  }) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    final bool override = await _overridesManager(fresh);
    if (!mayDecide(fresh)) throw const TimeTrackerPermissionDenied();
    final String me = _access.currentUserEmail;
    final RequestApprovalStep step = RequestCycleRules.actionableStep(fresh)!;
    // Owner rule (9/10/2026): the manager who is the only other HR approver
    // decides alone — the HR step is closed with this approval.
    final bool managerIsFinal = !override &&
        step.step == ApprovalStepKind.manager &&
        await _approvers.isSoleOtherHrApprover(email: me, requesterEmail: fresh.requesterEmail);
    final CycleOutcome outcome = RequestCycleRules.approve(
      fresh,
      approverEmail: me,
      at: _clock(),
      overrideBlockedManager: override,
      managerIsFinal: managerIsFinal,
    );
    final RequestCommit commit = await _commit(outcome);
    final TimeTrackerRequest saved = commit.request;
    _log.log(fresh.status == RequestStatus.underReview
        ? TimeTrackerLogService.actionApproveCancellation
        : TimeTrackerLogService.actionApprove);
    if (outcome.movedToNextStep) await _notifyWaiting(saved, isArabic: isArabic);
    if (outcome.isFinalApproval) {
      await _notifier.notifyApproved(
        senderEmail: me,
        requesterEmail: saved.requesterEmail,
        isTransaction: saved.isTransaction,
        typeName: typeName,
        requestId: saved.id,
        isArabic: isArabic,
      );
      if (commit.usedUpBalance) {
        await _notifier.notifyVacationExhausted(
          senderEmail: me,
          requesterEmail: saved.requesterEmail,
          requestId: saved.id,
          isArabic: isArabic,
        );
      }
    }
    if (outcome.endsApprovedRequest) {
      await _notifier.notifyCanceled(
        senderEmail: me,
        requesterEmail: saved.requesterEmail,
        typeName: typeName,
        requestId: saved.id,
        isArabic: isArabic,
      );
    }
    return saved;
  }

  /// Function Name: [reject]
  ///
  /// Purpose: Reject the current step with [reason] ("Reason Of Rejection").
  /// A cancellation under review is refused: the request stays approved.
  /// The rest of the round is closed (finding 5).
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> reject(
    TimeTrackerRequest request, {
    required String reason,
    required TimeTrackerTypeName typeName,
    required bool isArabic,
  }) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    final bool override = await _overridesManager(fresh);
    if (!mayDecide(fresh)) throw const TimeTrackerPermissionDenied();
    final CycleOutcome outcome = RequestCycleRules.reject(
      fresh,
      approverEmail: _access.currentUserEmail,
      reason: reason,
      at: _clock(),
      overrideBlockedManager: override,
    );
    // Compare-and-set on the revision read above (finding 2).
    final TimeTrackerRequest saved = await _requests.updateRequest(request: outcome.after);
    if (fresh.status == RequestStatus.underReview) {
      _log.log(TimeTrackerLogService.actionRejectCancellation);
      return saved;
    }
    _log.log(TimeTrackerLogService.actionReject);
    await _notifier.notifyRejected(
      senderEmail: _access.currentUserEmail,
      requesterEmail: saved.requesterEmail,
      isTransaction: saved.isTransaction,
      typeName: typeName,
      requestId: saved.id,
      isArabic: isArabic,
    );
    return saved;
  }

  /// Function Name: [cancelAfterApproving]
  ///
  /// Purpose: HR cancels an APPROVED request ("Canceled By HR"): the stored
  /// deduction refunded or the correction reverted — in the same
  /// transaction; requester notified.
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> cancelAfterApproving(
    TimeTrackerRequest request, {
    required String reason,
    required TimeTrackerTypeName typeName,
    required bool isArabic,
  }) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    if (!mayCancelAfterApproving(fresh)) throw const TimeTrackerPermissionDenied();
    final RequestCommit commit = await _commit(
      CycleOutcome(before: fresh, after: RequestCycleRules.cancelByHr(fresh, reason: reason)),
    );
    final TimeTrackerRequest saved = commit.request;
    _log.log(TimeTrackerLogService.actionCancelAfterApproving);
    await _notifier.notifyCanceled(
      senderEmail: _access.currentUserEmail,
      requesterEmail: saved.requesterEmail,
      typeName: typeName,
      requestId: saved.id,
      isArabic: isArabic,
    );
    return saved;
  }

  /// The signed-in user acts on a manager step that is not theirs (an HR
  /// approver on a BLOCKED step — finding 7); loads the approvers first so
  /// [mayDecide] can tell.
  Future<bool> _overridesManager(TimeTrackerRequest request) async {
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(request);
    if (step == null || step.step != ApprovalStepKind.manager) return false;
    if (step.approverEmail.trim().toLowerCase() == _access.currentUserEmail) return false;
    if (!_access.approvalsAllDepartments) return false;
    await _approvers.fetchApprovers();
    return ApprovalInbox.isManagerStepBlocked(request, _approvers.knownApproverEmails);
  }

  /// Plans the effects of [outcome] (the type is read first, so a failed
  /// read changes nothing) and saves the request with them in ONE
  /// compare-and-set transaction (findings 2–4).
  Future<RequestCommit> _commit(CycleOutcome outcome) async {
    final TimeTrackerRequest after = outcome.after;
    final RequestType? type = RequestEffects.needsType(outcome.from, after)
        ? await _types.fetchRequestType(id: after.requestTypeId)
        : null;
    final PlannedRequestChange planned =
        await _effects.plan(from: outcome.from, after: after, type: type);
    return _requests.commitRequest(
      request: planned.request,
      effects: planned.effects,
      now: _clock(),
    );
  }

  Future<TimeTrackerRequest> _fresh(TimeTrackerRequest request) async {
    final TimeTrackerRequest? stored = await _requests.fetchRequest(id: request.id);
    if (stored == null) throw Exception('This request no longer exists.');
    return stored;
  }

  Future<void> _notifyWaiting(TimeTrackerRequest request, {required bool isArabic}) async {
    final Map<String, int> waiting = await _approvers.waitingApprovers(request);
    if (waiting.isEmpty) return;
    await _notifier.notifyPendingApprovals(
      senderEmail: _access.currentUserEmail,
      countByApprover: waiting,
      requestId: request.id,
      isArabic: isArabic,
    );
  }
}
