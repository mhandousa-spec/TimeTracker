/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_request.dart
/// Purpose: Declares `TimeTrackerRequest` — one leave request OR attendance
///          transaction (a manual check-in / check-out correction).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// FINAL SPEC §2 `Requests/{id}`: transactions live in the same collection
/// (`Is_Transaction`), with Start/End = the corrected check-in / check-out.
/// The approval steps are stored inside the request. Status moves are checked
/// by `RequestStatusMachine`; the steps by `ApprovalRouter`.
///
/// Plain immutable Dart: no Firestore, no Flutter.
/// Updated: 9/10/2026 - code review: [revision] (the history row the request
/// was read at — every save is a compare-and-set on it, finding 2) and
/// [deductedVacationDays] (what the final approval actually took from the
/// balance; a cancel refunds exactly that — finding 4).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): comments are no longer
/// part of the request — they live in `Requests/{id}/Comments/{commentId}`
/// (`RequestCommentBaseRepository`). [legacyComments] only carries an OLD
/// document's embedded `Comments` list (read-only, until the migration
/// moves it); nothing writes it.
/// Updated: 9/10/2026 - owner decision (round 9, option b): the deduction is
/// recorded PER YEAR ([deductedDaysByYear], `Deducted_Vacation_Days` stored
/// as a map {"2026": 3, "2027": 3}); [deductedVacationDays] is its total.

import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

class TimeTrackerRequest {
  const TimeTrackerRequest({
    required this.id,
    required this.requesterEmail,
    required this.startAt,
    required this.endAt,
    this.requesterDepartmentId = '',
    this.requestTypeId = '',
    this.isTransaction = false,
    this.description = '',
    this.isAllDay = false,
    this.totalMinutes = 0,
    this.attachments = const <RequestAttachment>[],
    this.status = RequestStatus.pending,
    this.approvalSteps = const <RequestApprovalStep>[],
    this.currentStep,
    this.cancellationReason = '',
    this.lastReminderAt,
    this.legacyComments = const <RequestComment>[],
    this.audit = AuditInfo.none,
    this.revision = 0,
    this.deductedDaysByYear,
  });

  final String id;
  final String requesterEmail;
  final String requesterDepartmentId;

  /// '' for a transaction (it has no request type).
  final String requestTypeId;
  final bool isTransaction;
  final String description;

  /// Leave: the requested time frame. Transaction: check-in / check-out.
  final DateTime startAt;
  final DateTime endAt;
  final bool isAllDay;
  final int totalMinutes;
  final List<RequestAttachment> attachments;
  final RequestStatus status;
  final List<RequestApprovalStep> approvalSteps;

  /// The step waiting for a decision; null when none is pending.
  final ApprovalStepKind? currentStep;
  final String cancellationReason;

  /// Last "Send Reminder" (once every 24 hours — `RequestReminderRule`).
  final DateTime? lastReminderAt;

  /// 9/10/2026: the embedded `Comments` list of an OLD request document
  /// (before the migration) — read-only, never written. The thread itself is
  /// the `Comments` sub-collection.
  final List<RequestComment> legacyComments;
  final AuditInfo audit;

  /// ADDED 9/10/2026 (code review finding 2): how many history rows the
  /// stored document had when this copy was read (0 = never read — a new
  /// request, or a copy built in memory: no compare-and-set). Not stored.
  final int revision;

  /// ADDED 9/10/2026 (code review finding 4; per year since the owner's
  /// round-9 option b): vacation days the final approval deducted from each
  /// year's balance (`Deducted_Vacation_Days` = {"2026": 3, "2027": 3}); an
  /// empty map = nothing was taken. Null = never recorded (approved before
  /// the field existed) → a refund falls back to recomputing the cost. An
  /// old numeric value reads as {start year: n}.
  final Map<int, double>? deductedDaysByYear;

  /// Total of [deductedDaysByYear] (null = never recorded).
  double? get deductedVacationDays {
    final Map<int, double>? byYear = deductedDaysByYear;
    if (byYear == null) return null;
    double total = 0;
    for (final double d in byYear.values) {
      total += d;
    }
    return total;
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update. [clearCurrentStep] sets [currentStep] to
  /// null (the cycle finished).
  ///
  /// Return type: [TimeTrackerRequest]
  TimeTrackerRequest copyWith({
    String? requestTypeId,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    int? totalMinutes,
    List<RequestAttachment>? attachments,
    RequestStatus? status,
    List<RequestApprovalStep>? approvalSteps,
    ApprovalStepKind? currentStep,
    bool clearCurrentStep = false,
    String? cancellationReason,
    DateTime? lastReminderAt,
    Map<int, double>? deductedDaysByYear,
  }) =>
      TimeTrackerRequest(
        id: id,
        requesterEmail: requesterEmail,
        requesterDepartmentId: requesterDepartmentId,
        requestTypeId: requestTypeId ?? this.requestTypeId,
        isTransaction: isTransaction,
        description: description ?? this.description,
        startAt: startAt ?? this.startAt,
        endAt: endAt ?? this.endAt,
        isAllDay: isAllDay ?? this.isAllDay,
        totalMinutes: totalMinutes ?? this.totalMinutes,
        attachments: attachments ?? this.attachments,
        status: status ?? this.status,
        approvalSteps: approvalSteps ?? this.approvalSteps,
        currentStep:
            clearCurrentStep ? null : (currentStep ?? this.currentStep),
        cancellationReason: cancellationReason ?? this.cancellationReason,
        lastReminderAt: lastReminderAt ?? this.lastReminderAt,
        legacyComments: legacyComments,
        audit: audit,
        revision: revision,
        deductedDaysByYear: deductedDaysByYear ?? this.deductedDaysByYear,
      );
}
