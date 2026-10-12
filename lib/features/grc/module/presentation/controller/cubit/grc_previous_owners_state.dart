part of 'grc_previous_owners_cubit.dart';

sealed class GrcPreviousOwnersState {}

final class GrcPreviousOwnersInitial extends GrcPreviousOwnersState {}

final class GrcPreviousOwnersLoading extends GrcPreviousOwnersState {}

final class GrcPreviousOwnersLoaded extends GrcPreviousOwnersState {
  final List<GRCModuleOwnerHistoryEntry> entries;

  GrcPreviousOwnersLoaded(this.entries);
}

final class GrcPreviousOwnersFailure extends GrcPreviousOwnersState {
  final String message;

  GrcPreviousOwnersFailure(this.message);
}
