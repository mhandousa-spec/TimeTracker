/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: request_status_machine.dart
/// Purpose: Declares `RequestStatusMachine` — the only allowed moves of a
///          request's status.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Lifecycle (Screen Inventory §C, confirmed by the owner 8/10/2026):
///   pending      --approve-->             approved
///   pending      --reject-->              rejected
///   pending      --cancel-->              canceled      (requester)
///   approved     --requestCancellation--> under_review  (requester + reason)
///   under_review --approveCancellation--> canceled
///   under_review --rejectCancellation-->  approved
///   approved     --cancelByHr-->          canceled_by_hr
/// rejected / canceled / canceled_by_hr are final.
///
/// "approve" here is the FINAL approval; intermediate steps are tracked by
/// `ApprovalRouter` and leave the status pending.

import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

class RequestStatusMachine {
  const RequestStatusMachine._();

  static const Map<RequestStatus, Map<RequestAction, RequestStatus>> _moves =
      <RequestStatus, Map<RequestAction, RequestStatus>>{
    RequestStatus.pending: <RequestAction, RequestStatus>{
      RequestAction.approve: RequestStatus.approved,
      RequestAction.reject: RequestStatus.rejected,
      RequestAction.cancel: RequestStatus.canceled,
    },
    RequestStatus.approved: <RequestAction, RequestStatus>{
      RequestAction.requestCancellation: RequestStatus.underReview,
      RequestAction.cancelByHr: RequestStatus.canceledByHr,
    },
    RequestStatus.underReview: <RequestAction, RequestStatus>{
      RequestAction.approveCancellation: RequestStatus.canceled,
      RequestAction.rejectCancellation: RequestStatus.approved,
    },
  };

  /// Function Name: [tryNext]
  ///
  /// Purpose: The status [action] leads to from [from], or null when the move
  /// is not allowed.
  ///
  /// Parameters:
  ///   [RequestStatus] from
  ///   [RequestAction] action
  ///
  /// Return type: [RequestStatus?]
  static RequestStatus? tryNext(RequestStatus from, RequestAction action) =>
      _moves[from]?[action];

  /// Function Name: [can]
  ///
  /// Purpose: Whether [action] is allowed from [from].
  ///
  /// Return type: [bool]
  static bool can(RequestStatus from, RequestAction action) =>
      tryNext(from, action) != null;

  /// Function Name: [next]
  ///
  /// Purpose: Like [tryNext] but throws on a forbidden move.
  ///
  /// Parameters:
  ///   [RequestStatus] from
  ///   [RequestAction] action
  ///
  /// Return type: [RequestStatus] — throws `StateError` when not allowed.
  static RequestStatus next(RequestStatus from, RequestAction action) {
    final RequestStatus? to = tryNext(from, action);
    if (to == null) {
      throw StateError(
        'A ${from.storageKey} request cannot be moved with "${action.name}".',
      );
    }
    return to;
  }

  /// Function Name: [actionsFrom]
  ///
  /// Purpose: Every action allowed from [from] (drives which buttons show).
  ///
  /// Return type: [Set<RequestAction>]
  static Set<RequestAction> actionsFrom(RequestStatus from) =>
      (_moves[from] ?? const <RequestAction, RequestStatus>{}).keys.toSet();
}
