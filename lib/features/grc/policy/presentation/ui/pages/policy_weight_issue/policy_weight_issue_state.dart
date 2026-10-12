part of 'policy_weight_issue_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_weight_issue_state.dart
/// Purpose: Contains all sealed state classes emitted by
///          [PolicyWeightIssueCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 19/7/2026

sealed class PolicyWeightIssueState {}

/// State emitted before the page has requested anything.
final class PolicyWeightIssueInitial extends PolicyWeightIssueState {}

/// State emitted while policies/controls are being fetched.
final class PolicyWeightIssueLoading extends PolicyWeightIssueState {}

/// State emitted once the row data is ready. [isEditing] drives whether the
/// Policies Weight tab renders view mode or edit mode.
final class PolicyWeightIssueLoaded extends PolicyWeightIssueState {
  final bool isEditing;

  PolicyWeightIssueLoaded({required this.isEditing});
}

/// State emitted the moment Apply Changes is confirmed, before any of its
/// backend calls start. The page listens for this to show the blocking
/// loading indicator, which stays up until [PolicyWeightIssueApplySuccess]
/// or [PolicyWeightIssueFailure] is emitted.
final class PolicyWeightIssueApplying extends PolicyWeightIssueState {}

/// State emitted once after Apply Changes completes successfully, before
/// the cubit reloads and emits a fresh [PolicyWeightIssueLoaded]. The page
/// listens for this to show a one-time success snackbar.
final class PolicyWeightIssueApplySuccess extends PolicyWeightIssueState {}

/// State emitted when any operation fails.
final class PolicyWeightIssueFailure extends PolicyWeightIssueState {
  final String message;

  PolicyWeightIssueFailure(this.message);
}
