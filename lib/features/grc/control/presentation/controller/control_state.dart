part of 'control_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_state.dart
/// Purpose: Contains all sealed state classes emitted by [ControlCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

sealed class ControlState {}

/// State emitted before any action has been requested.
final class ControlInitial extends ControlState {}

/// State emitted while any async operation is in progress.
final class ControlLoading extends ControlState {}

/// State emitted when a single Control create/update completes successfully.
final class ControlActionSuccess extends ControlState {
  final ControlEntity control;

  ControlActionSuccess(this.control);
}

/// State emitted when a Policy's Controls have been fetched successfully.
final class ControlsListLoaded extends ControlState {
  final List<ControlEntity> controls;

  ControlsListLoaded(this.controls);
}

/// State emitted when a Control has been deleted successfully.
final class ControlDeleted extends ControlState {
  final String controlId;

  ControlDeleted(this.controlId);
}

/// State emitted when any operation fails.
final class ControlFailure extends ControlState {
  final String message;

  ControlFailure(this.message);
}
