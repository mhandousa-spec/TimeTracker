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

enum VacationHistoryStatus { loading, loaded, failure }

class VacationHistoryState {
  const VacationHistoryState({
    this.status = VacationHistoryStatus.loading,
    this.requests = const <TimeTrackerRequest>[],
  });

  final VacationHistoryStatus status;
  final List<TimeTrackerRequest> requests;
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
        if (!isClosed) emit(VacationHistoryState(status: VacationHistoryStatus.loaded, requests: list));
      },
      onError: (Object _) {
        if (!isClosed) emit(const VacationHistoryState(status: VacationHistoryStatus.failure));
      },
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
