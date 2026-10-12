/// Module: Policy Management
/// Description: BLoC Cubit that manages the Control Weight Issue page's
///              History tab: loads every recorded weight change for one
///              Policy's Controls and each affected control's current
///              department count.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, GetControlWeightHistoryUseCase, GetAllControlsUseCase
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:knowticed_plus/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_weight_history_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'control_weight_history_state.dart';

/// class name: [ControlWeightHistoryCubit]
///
/// purpose: load and expose the Control weight-change history for one
///          Policy, plus each affected control's current department count.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightHistoryCubit extends Cubit<ControlWeightHistoryState> {
  ControlWeightHistoryCubit({
    required GetControlWeightHistoryUseCase getControlWeightHistoryUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _getControlWeightHistoryUseCase = getControlWeightHistoryUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(ControlWeightHistoryInitial());

  final GetControlWeightHistoryUseCase _getControlWeightHistoryUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;

  /// function name: [loadHistory]
  ///
  /// purpose: fetch [moduleId]/[policyId]'s full weight-change history,
  ///          then resolve the current department count for every Control
  ///          under that same policy in one call (all history entries
  ///          share this moduleId/policyId).
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<void>]
  Future<void> loadHistory(String moduleId, String policyId) async {
    emit(ControlWeightHistoryLoading());

    final result = await _getControlWeightHistoryUseCase.execute(moduleId, policyId);
    final entries = result.fold((failure) {
      emit(ControlWeightHistoryFailure(failure.message));
      return null;
    }, (entries) => entries);
    if (entries == null) return;

    final controlsResult = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    final departmentCounts = controlsResult.fold(
      (_) => <String, int>{},
      (controls) => {for (final c in controls) c.id: c.departments.length},
    );

    emit(ControlWeightHistoryLoaded(entries, departmentCounts));
  }
}
