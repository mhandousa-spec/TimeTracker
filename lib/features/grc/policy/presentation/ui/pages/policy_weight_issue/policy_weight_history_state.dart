part of 'policy_weight_history_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_weight_history_state.dart
/// Purpose: Contains all sealed state classes emitted by
///          [PolicyWeightHistoryCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 19/7/2026

sealed class PolicyWeightHistoryState {}

final class PolicyWeightHistoryInitial extends PolicyWeightHistoryState {}

final class PolicyWeightHistoryLoading extends PolicyWeightHistoryState {}

/// [controlCounts] maps policyId -> current Controls count, resolved
/// separately per distinct policyId in [entries] (Controls aren't part of
/// the Policy revision history [entries] is built from).
final class PolicyWeightHistoryLoaded extends PolicyWeightHistoryState {
  final List<PolicyWeightHistoryEntry> entries;
  final Map<String, int> controlCounts;

  PolicyWeightHistoryLoaded(this.entries, this.controlCounts);
}

final class PolicyWeightHistoryFailure extends PolicyWeightHistoryState {
  final String message;

  PolicyWeightHistoryFailure(this.message);
}
