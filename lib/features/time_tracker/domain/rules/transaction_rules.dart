/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: transaction_rules.dart
/// Purpose: Declares `TransactionRules` — builds a new attendance
///          transaction (manual check-in / check-out correction) and cancels
///          a pending one — and `TransactionError`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// FINAL SPEC §2: a transaction is a `Requests` document with
/// `Is_Transaction = true`, Start/End = the corrected check-in / check-out,
/// no request type. Owner decisions 8 + 19 (8/10/2026): HR never edits
/// attendance directly; a correction is approved through the same cycle as a
/// request — the requester's direct manager, then HR (manager skipped when
/// none is known). Validation (Figma form `661:80120`): both times set,
/// check-out after check-in, nothing in the future, description ≤ 500.
/// Cancel (`Cancel_Transaction`): only the requester, only while pending.
///
/// Pure Dart — unit-tested.
/// Updated: 9/10/2026 - code review finding 6 (owner rule): the check-out
/// must be on the SAME calendar day as the check-in — or the NEXT day only
/// when the employee's shift crosses midnight — and the span is at most
/// 24 hours (a 1 → 9 Oct "session" used to pass and corrupt one day).
/// Updated: 13/10/2026 - owner rule: the description AND the transaction
/// document are REQUIRED (the manager decides from them).

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_status_machine.dart';

/// Why a transaction draft cannot be submitted.
enum TransactionError {
  checkInRequired,
  checkOutRequired,
  checkOutBeforeCheckIn,
  inFuture,
  descriptionTooLong,

  /// 9/10/2026 (finding 6): check-out not on the check-in day (or the next
  /// day for an overnight shift).
  checkOutWrongDay,

  /// 9/10/2026 (finding 6): longer than [TransactionRules.maxSpan].
  tooLong,

  /// 13/10/2026 (owner rule): a correction must say WHY — the manager reads
  /// it to decide.
  descriptionRequired,

  /// 13/10/2026 (owner rule): a correction must carry its supporting
  /// document.
  documentRequired,
}

class TransactionRules {
  const TransactionRules._();

  /// Figma "0/500".
  static const int maxDescriptionLength = 500;

  /// Longest correction (finding 6, owner 9/10/2026).
  static const Duration maxSpan = Duration(hours: 24);

  /// Function Name: [validate]
  ///
  /// Purpose: Every problem of a draft (empty = valid).
  ///
  /// Parameters:
  ///   [bool] hasDocument: a transaction document is attached (13/10/2026:
  ///     required).
  ///   [bool] overnightShift: the employee's shift crosses midnight — only
  ///     then may the check-out fall on the next day (9/10/2026).
  ///
  /// Return type: [Set<TransactionError>]
  static Set<TransactionError> validate({
    required DateTime? checkIn,
    required DateTime? checkOut,
    required String description,
    required DateTime now,
    required bool hasDocument,
    bool overnightShift = false,
  }) {
    final Set<TransactionError> errors = <TransactionError>{};
    if (checkIn == null) errors.add(TransactionError.checkInRequired);
    if (checkOut == null) errors.add(TransactionError.checkOutRequired);
    if (checkIn != null && checkOut != null && !checkOut.isAfter(checkIn)) {
      errors.add(TransactionError.checkOutBeforeCheckIn);
    }
    if (checkIn != null && checkOut != null && checkOut.isAfter(checkIn)) {
      final DateTime inDay = DateTime(checkIn.year, checkIn.month, checkIn.day);
      final DateTime outDay = DateTime(checkOut.year, checkOut.month, checkOut.day);
      final DateTime nextDay = DateTime(checkIn.year, checkIn.month, checkIn.day + 1);
      if (outDay != inDay && !(overnightShift && outDay == nextDay)) {
        errors.add(TransactionError.checkOutWrongDay);
      }
      if (checkOut.difference(checkIn) > maxSpan) errors.add(TransactionError.tooLong);
    }
    if ((checkIn != null && checkIn.isAfter(now)) ||
        (checkOut != null && checkOut.isAfter(now))) {
      errors.add(TransactionError.inFuture);
    }
    if (description.trim().isEmpty) errors.add(TransactionError.descriptionRequired);
    if (!hasDocument) errors.add(TransactionError.documentRequired);
    if (description.trim().length > maxDescriptionLength) {
      errors.add(TransactionError.descriptionTooLong);
    }
    return errors;
  }

  /// Function Name: [build]
  ///
  /// Purpose: The new transaction (id '' — the repository assigns one),
  /// routed manager → HR.
  ///
  /// Parameters:
  ///   [String] requesterEmail / [String] requesterDepartmentId
  ///   [String] managerEmail: '' = no manager known (step 1 skipped).
  ///   [DateTime] checkIn / [DateTime] checkOut
  ///   [String] description
  ///   [List<RequestAttachment>] attachments
  ///
  /// Return type: [TimeTrackerRequest] — throws `StateError` when the draft
  /// is invalid.
  static TimeTrackerRequest build({
    required String requesterEmail,
    required String requesterDepartmentId,
    required String managerEmail,
    required DateTime checkIn,
    required DateTime checkOut,
    required String description,
    required DateTime now,
    List<RequestAttachment> attachments = const <RequestAttachment>[],
    bool requesterIsHrApprover = false,
    bool managerIsSoleOtherHr = false,
    bool overnightShift = false,
  }) {
    final Set<TransactionError> errors = validate(
      checkIn: checkIn,
      checkOut: checkOut,
      description: description,
      now: now,
      hasDocument: attachments.isNotEmpty,
      overnightShift: overnightShift,
    );
    if (errors.isNotEmpty) {
      throw StateError('Invalid transaction: ${errors.map((e) => e.name).join(', ')}');
    }
    final List<RequestApprovalStep> steps = ApprovalRouter.transactionSteps(
      managerEmail: managerEmail,
      requesterEmail: requesterEmail,
      requesterIsHrApprover: requesterIsHrApprover,
      managerIsSoleOtherHr: managerIsSoleOtherHr,
    );
    return TimeTrackerRequest(
      id: '',
      requesterEmail: requesterEmail.trim().toLowerCase(),
      requesterDepartmentId: requesterDepartmentId,
      isTransaction: true,
      description: description.trim(),
      startAt: checkIn,
      endAt: checkOut,
      totalMinutes: checkOut.difference(checkIn).inMinutes,
      attachments: List<RequestAttachment>.unmodifiable(attachments),
      status: ApprovalRouter.initialStatus(steps),
      approvalSteps: steps,
      currentStep: ApprovalRouter.currentStepOf(steps)?.step,
    );
  }

  /// Function Name: [canCancel]
  ///
  /// Purpose: Whether [viewerEmail] may cancel [request] now.
  ///
  /// Return type: [bool]
  static bool canCancel(TimeTrackerRequest request, String viewerEmail) =>
      request.isTransaction &&
      request.requesterEmail.trim().toLowerCase() ==
          viewerEmail.trim().toLowerCase() &&
      RequestStatusMachine.can(request.status, RequestAction.cancel);

  /// Function Name: [cancel]
  ///
  /// Purpose: [request] canceled by its requester (pending → canceled); the
  /// cycle stops.
  ///
  /// Parameters:
  ///   [TimeTrackerRequest] request
  ///   [String] reason: optional justification.
  ///
  /// Return type: [TimeTrackerRequest] — throws `StateError` when not
  /// cancelable.
  static TimeTrackerRequest cancel(TimeTrackerRequest request, {String reason = ''}) {
    if (!request.isTransaction) {
      throw StateError('Only an attendance transaction can be canceled here.');
    }
    return request.copyWith(
      status: RequestStatusMachine.next(request.status, RequestAction.cancel),
      clearCurrentStep: true,
      cancellationReason: reason.trim(),
    );
  }
}
