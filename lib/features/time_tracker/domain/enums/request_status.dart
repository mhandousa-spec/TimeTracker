/// Module: time_tracker / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: request_status.dart
/// Purpose: Declares `RequestStatus` (the lifecycle state of a leave request
///          or attendance transaction) and `RequestAction` (what can be done
///          to it).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// FINAL SPEC §2 `Requests.Request_Status`: pending / approved / rejected /
/// under_review / canceled / canceled_by_hr. The allowed moves between them
/// live in `RequestStatusMachine` (domain/rules).
///
/// ⚠️ [storageKey] is what Firestore stores. Never rename a storage key.

enum RequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  underReview('under_review'),
  canceled('canceled'),
  canceledByHr('canceled_by_hr');

  const RequestStatus(this.storageKey);

  /// Value written to `Request_Status`.
  final String storageKey;

  /// No further action is possible from this status.
  bool get isFinal =>
      this == RequestStatus.rejected ||
      this == RequestStatus.canceled ||
      this == RequestStatus.canceledByHr;

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown or missing reads as [pending] so
  /// an odd document still shows up for an approver instead of vanishing.
  ///
  /// Parameters:
  ///   [String?] key: the raw Firestore value.
  ///
  /// Return type: [RequestStatus]
  static RequestStatus fromStorageKey(String? key) {
    for (final RequestStatus value in RequestStatus.values) {
      if (value.storageKey == key) return value;
    }
    return RequestStatus.pending;
  }
}

/// Everything that can move a request from one [RequestStatus] to another.
enum RequestAction {
  /// The last required approval step approves the request.
  approve,

  /// An approver rejects the request (with a reason).
  reject,

  /// The requester cancels their own request while it is still pending.
  cancel,

  /// The requester asks to cancel a request that was already approved.
  requestCancellation,

  /// The approver accepts the cancellation asked for after approval.
  approveCancellation,

  /// The approver refuses that cancellation; the request stays approved.
  rejectCancellation,

  /// HR cancels an approved request directly ("Canceled By HR").
  cancelByHr,
}
