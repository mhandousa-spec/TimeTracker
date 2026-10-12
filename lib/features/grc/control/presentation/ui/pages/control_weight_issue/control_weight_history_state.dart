part of 'control_weight_history_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_weight_history_state.dart
/// Purpose: Contains all sealed state classes emitted by
///          [ControlWeightHistoryCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 20/7/2026

sealed class ControlWeightHistoryState {}

final class ControlWeightHistoryInitial extends ControlWeightHistoryState {}

final class ControlWeightHistoryLoading extends ControlWeightHistoryState {}

/// [departmentCounts] maps controlId -> current department count.
final class ControlWeightHistoryLoaded extends ControlWeightHistoryState {
  final List<ControlWeightHistoryEntry> entries;
  final Map<String, int> departmentCounts;

  ControlWeightHistoryLoaded(this.entries, this.departmentCounts);
}

final class ControlWeightHistoryFailure extends ControlWeightHistoryState {
  final String message;

  ControlWeightHistoryFailure(this.message);
}
