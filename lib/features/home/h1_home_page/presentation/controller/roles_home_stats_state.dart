/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: roles_home_stats_state.dart
/// Purpose: States for `RolesHomeStatsCubit`.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
library;

abstract class RolesHomeStatsState {}

/// Nothing has been asked for yet.
class RolesHomeStatsInitial extends RolesHomeStatsState {}

/// A load is in flight. The cards render their skeleton dashes.
class RolesHomeStatsLoading extends RolesHomeStatsState {}

/// Counts are on the cubit and ready to read.
///
/// Carries no payload: the counts live in fields on the cubit, the way
/// `RoleCubit` and `UserManagementAccessCubit` already hold theirs, so a card
/// reads `cubit.roleCounts[...]` rather than casting the state.
class RolesHomeStatsLoaded extends RolesHomeStatsState {}

/// Every source failed. A partial failure still emits [RolesHomeStatsLoaded] —
/// see `RolesHomeStatsCubit.load`.
class RolesHomeStatsError extends RolesHomeStatsState {
  final String message;

  RolesHomeStatsError(this.message);
}
