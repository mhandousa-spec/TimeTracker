part of 'champion_cubit.dart';

sealed class ChampionState {}

final class ChampionInitial extends ChampionState {}

final class ChampionLoading extends ChampionState {}

final class ChampionListLoaded extends ChampionState {
  final List<ChampionEntity> champions;

  ChampionListLoaded(this.champions);
}

final class ChampionActionSuccess extends ChampionState {
  final ChampionEntity champion;

  ChampionActionSuccess(this.champion);
}

final class ChampionFailure extends ChampionState {
  final String message;

  ChampionFailure(this.message);
}
