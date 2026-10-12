part of 'control_weight_issue_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_weight_issue_state.dart
/// Purpose: Contains all sealed state classes emitted by
///          [ControlWeightIssueCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 20/7/2026

sealed class ControlWeightIssueState {}

/// State emitted before the page has requested anything.
final class ControlWeightIssueInitial extends ControlWeightIssueState {}

/// State emitted while Controls are being fetched.
final class ControlWeightIssueLoading extends ControlWeightIssueState {}

/// State emitted once the row data is ready. [isEditing] drives whether
/// the Controls Weight tab renders view mode or edit mode.
final class ControlWeightIssueLoaded extends ControlWeightIssueState {
  final bool isEditing;

  ControlWeightIssueLoaded({required this.isEditing});
}

/// State emitted the moment Apply Changes is confirmed, before any of its
/// backend calls start. The page listens for this to show the blocking
/// loading indicator, which stays up until [ControlWeightIssueApplySuccess]
/// or [ControlWeightIssueFailure] is emitted.
final class ControlWeightIssueApplying extends ControlWeightIssueState {}

/// State emitted once after Apply Changes completes successfully, before
/// the cubit reloads and emits a fresh [ControlWeightIssueLoaded]. The page
/// listens for this to show a one-time success snackbar.
final class ControlWeightIssueApplySuccess extends ControlWeightIssueState {}

/// State emitted when any operation fails.
final class ControlWeightIssueFailure extends ControlWeightIssueState {
  final String message;

  ControlWeightIssueFailure(this.message);
}
