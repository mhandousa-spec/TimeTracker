/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: approver_directory.dart
/// Purpose: Declares `ApproverDirectory` — "who are the HR approvers?" — and
///          `TimeTrackerApprover`, one of them with their scope.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 4 notifications (brief §C): a request moving to its HR step, a
/// reminder on it, or a cancellation round reaching HR notifies the HR
/// approvers. `TimeTrackerAccess` only answers for the SIGNED-IN user, so
/// this asks the opposite question for every role: which roles carry the
/// Time Tracker module with `Approval_Permissions` + `Approve_And_Reject`
/// on, and who holds them (`Approvals_All_Departments` = every
/// department, else only their own — FINAL SPEC scope rule).
///
/// Error policy: [fetchHrApprovers] completes or throws a clean `Exception`;
/// [waitingApprovers] never throws (a notification must not fail the
/// action that triggered it).
/// Updated: 9/10/2026 - code review (FINAL SPEC wins): HR approvers are
/// ONLY `Approve_And_Reject` + `Approvals_All_Departments` holders;
/// [fetchApprovers] (every `Approve_And_Reject` holder — a manager who is not
/// one cannot act, finding 7) and [knownApproverEmails] (the last answer,
/// read synchronously by the Approve / Reject buttons).

import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';

class TimeTrackerApprover {
  const TimeTrackerApprover({
    required this.email,
    this.departmentId = '',
    this.allDepartments = false,
  });

  /// Lower-cased.
  final String email;
  final String departmentId;
  final bool allDepartments;

  /// Function Name: [covers]
  ///
  /// Return type: [bool] — a requester of [requesterDepartmentId] is in scope.
  bool covers(String requesterDepartmentId) =>
      allDepartments ||
      (departmentId.trim().isNotEmpty && departmentId.trim() == requesterDepartmentId.trim());
}

abstract class ApproverDirectory {
  /// Function Name: [fetchApprovers]
  ///
  /// Purpose: ADDED 9/10/2026 — every ACTIVE employee holding
  /// `Approve_And_Reject` (with their "All Departments" flag).
  ///
  /// Return type: [Future<List<TimeTrackerApprover>>]
  Future<List<TimeTrackerApprover>> fetchApprovers();

  /// Function Name: [fetchHrApprovers]
  ///
  /// Purpose: Every employee who may decide an HR step — `Approve_And_Reject`
  /// + `Approvals_All_Departments` ONLY (FINAL SPEC, 9/10/2026).
  ///
  /// Return type: [Future<List<TimeTrackerApprover>>]
  Future<List<TimeTrackerApprover>> fetchHrApprovers();

  /// The e-mails of the last [fetchApprovers] answer (null = never loaded).
  Set<String>? get knownApproverEmails;

  /// Function Name: [mayApprove]
  ///
  /// Purpose: ADDED 9/10/2026 (code review finding 7) — [email] is an
  /// active `Approve_And_Reject` holder (a direct manager who is not is
  /// skipped at submit). Never throws: a failed lookup answers true (the
  /// manager is kept — an HR approver can still act if they cannot).
  ///
  /// Return type: [Future<bool>]
  Future<bool> mayApprove(String email);

  /// Function Name: [isSoleOtherHrApprover]
  ///
  /// Purpose: ADDED 9/10/2026 (owner rule) — [email] is an HR approver and
  /// no OTHER HR approver (neither [email] nor [requesterEmail]) exists, so
  /// [email]'s manager approval is final. Never throws: false on failure.
  ///
  /// Return type: [Future<bool>]
  Future<bool> isSoleOtherHrApprover({required String email, required String requesterEmail});

  /// Function Name: [waitingApprovers]
  ///
  /// Purpose: Who [request]'s current step waits for — its direct manager,
  /// or every HR approver covering the requester (never the requester) —
  /// each with how many company requests now wait for them.
  ///
  /// Return type: [Future<Map<String, int>>] — email → count; {} when
  /// nobody waits or the lookup failed.
  Future<Map<String, int>> waitingApprovers(TimeTrackerRequest request);
}
