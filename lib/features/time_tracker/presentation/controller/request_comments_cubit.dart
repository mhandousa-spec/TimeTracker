/// Module: time_tracker / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_comments_cubit.dart
/// Purpose: Declares `RequestCommentsCubit` + `RequestCommentsState` — the
///          live "Inquiries And Comments" thread of ONE request.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (data model — owner, 9 Oct)
///
/// Comments are documents of `Requests/{requestId}/Comments` (no longer a
/// list inside the request), so the details page streams them separately:
/// the comments section creates this cubit over
/// `RequestActionsCubit.watchComments` (the same service the add / edit /
/// delete buttons use) for its request. The state keeps the STORED comments;
/// the section merges an old request's embedded list (read-only, before the
/// migration) with `RequestCommentRules.thread`. Stream cancelled in
/// [close]; emit-after-close guarded (playbook §3).

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';

enum RequestCommentsStatus { loading, loaded, failure }

class RequestCommentsState {
  const RequestCommentsState({
    this.status = RequestCommentsStatus.loading,
    this.comments = const <RequestComment>[],
    this.errorMessage = '',
  });

  final RequestCommentsStatus status;

  /// The stored comments (deleted ones included — the thread hides them).
  final List<RequestComment> comments;
  final String errorMessage;

  bool get isLoading => status == RequestCommentsStatus.loading;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [RequestCommentsState]
  RequestCommentsState copyWith({
    RequestCommentsStatus? status,
    List<RequestComment>? comments,
    String? errorMessage,
  }) =>
      RequestCommentsState(
        status: status ?? this.status,
        comments: comments ?? this.comments,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class RequestCommentsCubit extends Cubit<RequestCommentsState> {
  RequestCommentsCubit({required Stream<List<RequestComment>> Function(String requestId) source})
      : _source = source,
        super(const RequestCommentsState());

  final Stream<List<RequestComment>> Function(String requestId) _source;
  StreamSubscription<List<RequestComment>>? _sub;

  @override
  void emit(RequestCommentsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [watch]
  ///
  /// Purpose: Stream the comments of [requestId] (replaces any earlier one).
  ///
  /// Return type: [Future<void>]
  Future<void> watch(String requestId) async {
    await _sub?.cancel();
    if (isClosed) return;
    emit(const RequestCommentsState());
    _sub = _source(requestId).listen(
      (List<RequestComment> list) =>
          emit(RequestCommentsState(status: RequestCommentsStatus.loaded, comments: list)),
      onError: (Object error) => emit(state.copyWith(
        status: RequestCommentsStatus.failure,
        errorMessage: error.toString(),
      )),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
