part of 'control_previous_owners_cubit.dart';

sealed class ControlPreviousOwnersState {}

final class ControlPreviousOwnersInitial extends ControlPreviousOwnersState {}

final class ControlPreviousOwnersLoading extends ControlPreviousOwnersState {}

final class ControlPreviousOwnersLoaded extends ControlPreviousOwnersState {
  final List<ControlOwnerHistoryEntry> entries;

  ControlPreviousOwnersLoaded(this.entries);
}

final class ControlPreviousOwnersFailure extends ControlPreviousOwnersState {
  final String message;

  ControlPreviousOwnersFailure(this.message);
}
