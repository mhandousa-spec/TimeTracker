/// Module: time_tracker / tt13_vacation_balances / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_history_cubit.dart
/// Purpose: Declares `VacationHistoryCubit` — the live requests of ONE
///          employee for the Vacation History page (owner V1).
/// Author: Knowticed Plus team
/// Created at: 13/10/2026 (owner review V1)
///
/// Watches `RequestBaseRepository.watchRequestsOf`; the page keeps the
/// vacation-deducting types of the chosen year.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

enum VacationHistoryStatus { loading, loaded, failure }

class VacationHistoryState {
  const VacationHistoryState({
    this.status = VacationHistoryStatus.loading,
    this.requests = const <TimeTrackerRequest>[],
    this.bucket = RequestBucket.all,
  });

  final VacationHistoryStatus status;
  final List<TimeTrackerRequest> requests;

  /// 13/10/2026 (owner): the status counter picked (All · Pending · Under
  /// Review · Approved · Rejected · Canceled, as on Requests).
  final RequestBucket bucket;

  VacationHistoryState copyWith({
    VacationHistoryStatus? status,
    List<TimeTrackerRequest>? requests,
    RequestBucket? bucket,
  }) =>
      VacationHistoryState(
        status: status ?? this.status,
        requests: requests ?? this.requests,
        bucket: bucket ?? this.bucket,
      );
}

class VacationHistoryCubit extends Cubit<VacationHistoryState> {
  VacationHistoryCubit({required RequestBaseRepository requests})
      : _requests = requests,
        super(const VacationHistoryState());

  final RequestBaseRepository _requests;
  StreamSubscription<List<TimeTrackerRequest>>? _sub;

  /// Function Name: [watch]
  ///
  /// Purpose: Follow [email]'s requests.
  ///
  /// Return type: [void]
  void watch(String email) {
    unawaited(_sub?.cancel());
    _sub = _requests.watchRequestsOf(email: email).listen(
      (List<TimeTrackerRequest> list) {
        if (!isClosed) emit(state.copyWith(status: VacationHistoryStatus.loaded, requests: list));
      },
      onError: (Object _) {
        if (!isClosed) emit(state.copyWith(status: VacationHistoryStatus.failure));
      },
    );
  }

  /// 13/10/2026 (owner): pick a status counter.
  void setBucket(RequestBucket bucket) => emit(state.copyWith(bucket: bucket));

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
