// lib/features/grc/control_owner/presentation/controller/owner_state.dart
part of 'owner_cubit.dart';

sealed class OwnerState {}

final class OwnerInitial extends OwnerState {}

final class OwnerLoading extends OwnerState {}

final class OwnerListLoaded extends OwnerState {
  final List<OwnerEntity> owners;

  OwnerListLoaded(this.owners);
}

final class OwnerActionSuccess extends OwnerState {
  final OwnerEntity owner;

  OwnerActionSuccess(this.owner);
}

final class OwnerFailure extends OwnerState {
  final String message;

  OwnerFailure(this.message);
}
