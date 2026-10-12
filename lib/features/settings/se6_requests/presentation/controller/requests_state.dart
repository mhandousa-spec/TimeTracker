/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: requests_state.dart
/// Purpose: States for RequestsCubit.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026

part of './requests_cubit.dart';

enum RequestsStatus { initial, loading, success, failure }

@immutable
class RequestsState {
  const RequestsState({
    this.status = RequestsStatus.initial,
    this.requests = const <ChangeRequest>[],
    this.selected,
    this.errorMessage,
    this.userMessage,
    this.submitted = false,
    this.decided = false,
  });

  final RequestsStatus status;

  /// The signed-in employee's requests, newest first.
  final List<ChangeRequest> requests;

  /// The request open in the details page.
  final ChangeRequest? selected;

  /// One-shot. Cleared with [consumed] once a listener has shown it.
  final String? errorMessage;

  /// One-shot, ADDED 9/10/2026: an already-localized (EN/AR) message that is
  /// safe to show as-is — today only a blocked self-approval
  /// (`SelfApprovalFailure`). [errorMessage] can be a raw Firestore error, so
  /// the screens never show that one directly.
  final String? userMessage;

  /// One-shot: a submission completed.
  final bool submitted;

  /// One-shot: an approve/reject completed.
  final bool decided;

  bool get isBusy => status == RequestsStatus.loading;

  RequestsState copyWith({
    RequestsStatus? status,
    List<ChangeRequest>? requests,
    Object? selected = _unset,
    Object? errorMessage = _unset,
    Object? userMessage = _unset,
    bool? submitted,
    bool? decided,
  }) {
    return RequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      selected: identical(selected, _unset)
          ? this.selected
          : selected as ChangeRequest?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      userMessage: identical(userMessage, _unset)
          ? this.userMessage
          : userMessage as String?,
      submitted: submitted ?? this.submitted,
      decided: decided ?? this.decided,
    );
  }

  /// Drops the one-shot flags after a listener has acted on them.
  /// (9/10/2026: [userMessage] too.)
  RequestsState consumed() => copyWith(
      errorMessage: null, userMessage: null, submitted: false, decided: false);
}

/// Sentinel so `copyWith` can tell "leave unchanged" from "set to null".
const Object _unset = Object();
