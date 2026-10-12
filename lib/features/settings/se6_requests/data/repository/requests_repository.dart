/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: requests_repository.dart
/// Purpose: Implements [RequestsBaseRepository] over the remote data source.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N01 / N02. This is the legal home for the 17 `try`
/// blocks that were spread across the four pages.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/data_source/remote_data_source/requests_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/base_repository/requests_base_repository.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
// ADDED 9/10/2026 — self-approval block.
import 'package:knowticed_plus/features/settings/se6_requests/domain/rules/self_approval_rule.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestsRepository implements RequestsBaseRepository {
  RequestsRepository({RequestsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? RequestsRemoteDataSource();

  final RequestsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ChangeRequest>>> getRequestsForEmployee(
      String employeeId) async {
    if (employeeId.isEmpty) {
      return Left<Failure, List<ChangeRequest>>(
        FeatureFailure('No employee id available to load requests for.'),
      );
    }

    try {
      return Right<Failure, List<ChangeRequest>>(
        await _remoteDataSource.readForEmployee(employeeId),
      );
    } catch (e) {
      return Left<Failure, List<ChangeRequest>>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChangeRequest?>> getRequest(String requestId) async {
    if (requestId.isEmpty) {
      return Left<Failure, ChangeRequest?>(
        FeatureFailure('No request id was supplied.'),
      );
    }

    try {
      return Right<Failure, ChangeRequest?>(
          await _remoteDataSource.read(requestId));
    } catch (e) {
      return Left<Failure, ChangeRequest?>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitRequest(ChangeRequest request) async {
    if (request.employeeId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure('Employee ID is not available.'),
      );
    }
    if (request.changes.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure('There are no changes to submit.'),
      );
    }

    try {
      // Confirm the employee exists before logging a request against it — the
      // same guard the submit page performed, kept here so both the personal
      // and health-insurance submit paths share it.
      if (!await _remoteDataSource.employeeExists(request.employeeId)) {
        return Left<Failure, void>(
          FeatureFailure('Employee document not found.'),
        );
      }

      await _remoteDataSource.create(request);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name: [_guardDecision]
  ///
  /// Purpose: The self-approval check, run against the STORED request
  ///          (ADDED 9/10/2026, owner decision).
  ///
  /// The screens already hide Approve / Reject on an own request; this is the
  /// second check, so a stale screen, a role switch mid-session or a future
  /// caller cannot get round it. The request is re-read rather than trusted
  /// from the caller, and anything that cannot be verified is refused.
  ///
  /// Returns: `null` when the decision may go ahead, otherwise the
  ///          localized [SelfApprovalFailure] to return. Never throws.
  Future<Failure?> _guardDecision({
    required String requestId,
    required String deciderEmail,
    required String deciderEmployeeId,
  }) async {
    try {
      final ChangeRequest? stored = await _remoteDataSource.read(requestId);

      final SelfApprovalVerdict verdict = stored == null
          ? SelfApprovalVerdict.unverifiable
          : SelfApprovalRule.check(
              requesterEmail: stored.employeeEmail,
              requesterId: stored.employeeId,
              deciderEmail: deciderEmail,
              deciderId: deciderEmployeeId,
            );

      if (verdict.isAllowed) return null;
      return _selfApprovalFailure(verdict);
    } catch (e) {
      // Could not read the request — fail closed.
      return _selfApprovalFailure(SelfApprovalVerdict.unverifiable);
    }
  }

  /// The user-facing EN/AR failure for a blocked decision.
  static SelfApprovalFailure _selfApprovalFailure(SelfApprovalVerdict verdict) {
    String message;
    try {
      message = verdict == SelfApprovalVerdict.ownRequest
          ? S.current.selfApprovalBlocked
          : S.current.requestDecisionUnverifiable;
    } catch (_) {
      // S not loaded (should not happen in the app) — still refuse.
      message = verdict == SelfApprovalVerdict.ownRequest
          ? 'You cannot approve or reject your own request.'
          : 'This decision could not be verified, so nothing was saved.';
    }
    return SelfApprovalFailure(message, verdict: verdict);
  }

  @override
  Future<Either<Failure, void>> approveRequest({
    required ChangeRequest request,
    required String employeeId,
    required String approverEmail,
    String approverEmployeeId = '',
    String reason = '',
  }) async {
    if (employeeId.isEmpty) {
      return Left<Failure, void>(FeatureFailure('Employee ID not found.'));
    }
    if (request.id.isEmpty) {
      return Left<Failure, void>(FeatureFailure('No request id was supplied.'));
    }

    // ADDED 9/10/2026 — never the requester; checked before ANY write.
    final Failure? blocked = await _guardDecision(
      requestId: request.id,
      deciderEmail: approverEmail,
      deciderEmployeeId: approverEmployeeId,
    );
    if (blocked != null) return Left<Failure, void>(blocked);

    try {
      // Profile first, status second. If the profile write throws, the request
      // keeps its pending status and stays actionable — the previous ordering
      // in details_request.dart was the same, and it is the ordering that
      // matters: a request must never read as approved with nothing written.
      final List<String> skipped =
          await _remoteDataSource.applyChangesToEmployee(
        employeeId: employeeId,
        changes: request.changes,
      );

      // ADDED 13/8/2026: the data source now skips a field the employee model
      // cannot store instead of throwing and losing the rest of the batch. If
      // it could not store *any* of them the approval wrote nothing, so it must
      // not be recorded as approved — that is the state that produced "the info
      // doesn't change after approval" with no error anywhere.
      if (skipped.length == request.changes.length &&
          request.changes.isNotEmpty) {
        return Left<Failure, void>(FeatureFailure(
          'None of the requested fields could be applied: ${skipped.join(', ')}',
        ));
      }

      await _remoteDataSource.updateStatus(request.id, RequestStatus.approved,
          reason: reason);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setRequestStatus({
    required String requestId,
    required RequestStatus status,
    String reason = '',
    String deciderEmail = '',
    String deciderEmployeeId = '',
  }) async {
    if (requestId.isEmpty) {
      return Left<Failure, void>(FeatureFailure('No request id was supplied.'));
    }

    // ADDED 9/10/2026 — a reject (or approve) is a reviewer's decision and
    // goes through the same self-approval check; cancel does not.
    if (SelfApprovalRule.isDecision(status)) {
      final Failure? blocked = await _guardDecision(
        requestId: requestId,
        deciderEmail: deciderEmail,
        deciderEmployeeId: deciderEmployeeId,
      );
      if (blocked != null) return Left<Failure, void>(blocked);
    }

    try {
      await _remoteDataSource.updateStatus(requestId, status, reason: reason);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }
}
