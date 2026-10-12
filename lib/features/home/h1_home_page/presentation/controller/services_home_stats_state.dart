/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: services_home_stats_state.dart
/// Purpose: States for `ServicesHomeStatsCubit`.
/// Author: Knowticed Plus team
/// Created at: 30/8/2026
library;

abstract class ServicesHomeStatsState {}

/// Nothing has been asked for yet.
class ServicesHomeStatsInitial extends ServicesHomeStatsState {}

/// A load is in flight. The cards render their skeleton dashes.
class ServicesHomeStatsLoading extends ServicesHomeStatsState {}

/// Counts are on the cubit and ready to read.
///
/// Carries no payload, matching `RolesHomeStatsLoaded`: the figures live in
/// fields on the cubit, so a card reads `cubit.statusCounts[...]` rather than
/// casting the state.
class ServicesHomeStatsLoaded extends ServicesHomeStatsState {}

/// Every source failed. A partial failure still emits
/// [ServicesHomeStatsLoaded] — see `ServicesHomeStatsCubit.load`.
class ServicesHomeStatsError extends ServicesHomeStatsState {
  final String message;

  ServicesHomeStatsError(this.message);
}
