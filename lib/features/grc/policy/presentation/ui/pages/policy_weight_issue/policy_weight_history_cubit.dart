/// Module: Policy Management
/// Description: BLoC Cubit that manages the Policy Weight Issue page's
///              History tab: loads every recorded weight change for a
///              module and each affected policy's current Controls count.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, GetPolicyWeightHistoryUseCase, GetAllControlsUseCase
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'policy_weight_history_state.dart';

/// class name: [PolicyWeightHistoryCubit]
///
/// purpose: load and expose the Policy weight-change history for one GRC
///          Module, plus each affected policy's current Controls count.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightHistoryCubit extends Cubit<PolicyWeightHistoryState> {
  PolicyWeightHistoryCubit({
    required GetPolicyWeightHistoryUseCase getPolicyWeightHistoryUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _getPolicyWeightHistoryUseCase = getPolicyWeightHistoryUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(PolicyWeightHistoryInitial());

  final GetPolicyWeightHistoryUseCase _getPolicyWeightHistoryUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;

  /// function name: [loadHistory]
  ///
  /// purpose: fetch [moduleId]'s full weight-change history, then resolve
  ///          the current Controls count for every distinct policyId that
  ///          appears in it.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<void>]
  Future<void> loadHistory(String moduleId) async {
    emit(PolicyWeightHistoryLoading());

    final result = await _getPolicyWeightHistoryUseCase.execute(moduleId);
    final entries = result.fold((failure) {
      emit(PolicyWeightHistoryFailure(failure.message));
      return null;
    }, (entries) => entries);
    if (entries == null) return;

    final controlCounts = <String, int>{};
    for (final policyId in entries.map((e) => e.policyId).toSet()) {
      final controlsResult = await _getAllControlsUseCase.call(
        moduleId: moduleId,
        policyId: policyId,
      );
      controlCounts[policyId] = controlsResult.fold((_) => 0, (controls) => controls.length);
    }

    emit(PolicyWeightHistoryLoaded(entries, controlCounts));
  }
}
