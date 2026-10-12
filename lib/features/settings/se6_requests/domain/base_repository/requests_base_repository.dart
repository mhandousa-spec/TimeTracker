/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: requests_base_repository.dart
/// Purpose: Domain contract for submitting, listing and deciding on change
///          requests.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N01 / N03. The feature was feature-first in name only:
/// `presentation/` and `data/models/` were the only folders, so the approval
/// flow — a two-document write plus an employee-profile history append — lived
/// in pages.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';

abstract class RequestsBaseRepository {
  /// Every request raised by one employee, newest first.
  Future<Either<Failure, List<ChangeRequest>>> getRequestsForEmployee(
      String employeeId);

  /// One request. `Right(null)` when the document is gone.
  Future<Either<Failure, ChangeRequest?>> getRequest(String requestId);

  /// Write a new request.
  ///
  /// The employee document is **not** touched here: the change is applied by
  /// the approver via [approveRequest]. The employee's existence is verified
  /// first so a request cannot be logged against a missing record.
  Future<Either<Failure, void>> submitRequest(ChangeRequest request);

  /// Apply a request's changes to the employee profile, then mark it approved.
  ///
  /// Both steps or neither: if the profile write fails the status is left
  /// alone, so the request stays actionable rather than reading as approved
  /// with nothing written.
  ///
  /// [approverEmail] / [approverEmployeeId] (ADDED 9/10/2026): who is
  /// approving. The STORED request is re-read and checked with
  /// `SelfApprovalRule` first — the requester can never approve their own
  /// request, and an unknown approver fails closed with a
  /// `SelfApprovalFailure`. Nothing is written in either case.
  Future<Either<Failure, void>> approveRequest({
    required ChangeRequest request,
    required String employeeId,
    required String approverEmail,
    String approverEmployeeId = '',
    String reason = '',
  });

  /// Move a request to [status] without touching the employee profile.
  ///
  /// [deciderEmail] / [deciderEmployeeId] (ADDED 9/10/2026): required in
  /// practice for a decision (approved / rejected) — the same
  /// `SelfApprovalRule` check as [approveRequest] runs against the stored
  /// request. Cancelling is the requester's own action and is not checked.
  Future<Either<Failure, void>> setRequestStatus({
    required String requestId,
    required RequestStatus status,
    String reason = '',
    String deciderEmail = '',
    String deciderEmployeeId = '',
  });
}
