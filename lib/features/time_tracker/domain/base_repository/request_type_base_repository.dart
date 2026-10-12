/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_base_repository.dart
/// Purpose: Declares `RequestTypeBaseRepository` — the contract for request types.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.
/// Updated: 9/10/2026 - phase 4: [fetchRequestType].

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';

abstract class RequestTypeBaseRepository {
  /// Function Name: [watchRequestTypes]
  ///
  /// Purpose: Live list of every request type (removed ones included).
  ///
  /// Return type: [Stream<List<RequestType>>]
  Stream<List<RequestType>> watchRequestTypes();

  /// Function Name: [createRequestType]
  ///
  /// Purpose: Persist a new request type.
  ///
  /// Parameters:
  ///   [RequestType] type: the draft; its id is ignored.
  ///
  /// Return type: [Future<RequestType>] — with its new id.
  Future<RequestType> createRequestType({required RequestType type});

  /// Function Name: [updateRequestType]
  ///
  /// Purpose: Append the edited request type (edit / status / remove).
  ///
  /// Parameters:
  ///   [RequestType] type
  ///
  /// Return type: [Future<RequestType>] — as stored.
  Future<RequestType> updateRequestType({required RequestType type});

  /// Function Name: [fetchRequestType]
  ///
  /// Purpose: One request type by id (phase 4, 9/10/2026 — the approval
  /// side effects read whether it deducts from the vacation balance).
  ///
  /// Return type: [Future<RequestType?>] — null when missing or [id] is ''.
  Future<RequestType?> fetchRequestType({required String id});
}
