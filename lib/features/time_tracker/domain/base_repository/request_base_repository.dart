/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: request_base_repository.dart
/// Purpose: Declares `RequestBaseRepository` — the contract for requests.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.
/// Updated: 9/10/2026 - phase 4: [fetchRequest].
/// Updated: 9/10/2026 - code review: [watchRequestsOf] (an employee reads
/// only their own requests — finding 9), [commitRequest] (the request and
/// its balance / attendance effect in ONE transaction — findings 2–4) and
/// compare-and-set on every update (`TimeTrackerRequest.revision`; a
/// newer stored row → `TimeTrackerRecordChanged`, nothing written).

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_side_effects.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';

abstract class RequestBaseRepository {
  /// Function Name: [watchRequests]
  ///
  /// Purpose: Live list of every request and transaction of the company —
  /// ONLY for approvers / HR dashboard holders (code review finding 9;
  /// employees use [watchRequestsOf]). Filtering (my department / pending
  /// for me) is done in the app — history fields cannot be queried on their
  /// current value (FINAL SPEC §2 "Known risk").
  ///
  /// Return type: [Stream<List<TimeTrackerRequest>>]
  Stream<List<TimeTrackerRequest>> watchRequests();

  /// Function Name: [watchRequestsOf]
  ///
  /// Purpose: ADDED 9/10/2026 (code review finding 9) — live list of the
  /// requests and transactions [email] submitted (`Requester_Email`
  /// array-contains: the field never changes, so its history only holds
  /// that e-mail). An employee's device never downloads anyone else's.
  ///
  /// Return type: [Stream<List<TimeTrackerRequest>>]
  Stream<List<TimeTrackerRequest>> watchRequestsOf({required String email});

  /// Function Name: [commitRequest]
  ///
  /// Purpose: ADDED 9/10/2026 (code review findings 2–4) — save [request]
  /// (new when its id is '', else a compare-and-set on its revision) AND
  /// its [effects] in one transaction: all or nothing.
  ///
  /// Parameters:
  ///   [TimeTrackerRequest] request
  ///   [RequestSideEffects] effects
  ///   [DateTime] now: the day recalculation clock (9/10/2026: the balance
  ///     touched is the one of the year the request STARTS in — no
  ///     roll-over).
  ///
  /// Return type: [Future<RequestCommit>] — throws
  /// `TimeTrackerRecordChanged` (someone saved first) or
  /// `TimeTrackerNoVacationBalance` (a deduction with no balance stored).
  Future<RequestCommit> commitRequest({
    required TimeTrackerRequest request,
    RequestSideEffects effects = RequestSideEffects.none,
    required DateTime now,
  });

  /// Function Name: [createRequest]
  ///
  /// Purpose: Persist a new request or transaction.
  ///
  /// Parameters:
  ///   [TimeTrackerRequest] request: the draft; its id is ignored.
  ///
  /// Return type: [Future<TimeTrackerRequest>] — with its new id.
  Future<TimeTrackerRequest> createRequest({
    required TimeTrackerRequest request,
  });

  /// Function Name: [updateRequest]
  ///
  /// Purpose: Append the full updated request as the next history row
  /// (status change, decision, comment, reminder…). Since 9/10/2026 a
  /// compare-and-set: refused with `TimeTrackerRecordChanged` when the
  /// stored document has moved past [TimeTrackerRequest.revision].
  ///
  /// Parameters:
  ///   [TimeTrackerRequest] request
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> updateRequest({
    required TimeTrackerRequest request,
  });

  /// Function Name: [fetchRequest]
  ///
  /// Purpose: The stored request (phase 4, 9/10/2026 — read again right
  /// before a decision).
  ///
  /// Return type: [Future<TimeTrackerRequest?>] — null when missing.
  Future<TimeTrackerRequest?> fetchRequest({required String id});
}
