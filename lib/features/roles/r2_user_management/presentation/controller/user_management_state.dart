/// Module: roles / r2_user_management / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_state.dart
/// Purpose: Declares `UserManagementAccessState`, `UserManagementInitial`, `UserPermissionsDataLoaded` (+4 more).
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of './user_management_cubit.dart';

@immutable
sealed class UserManagementAccessState {}

final class UserManagementInitial extends UserManagementAccessState {}

final class UserPermissionsDataLoaded extends UserManagementAccessState {}

class UserManagementAccessError extends UserManagementAccessState {
  final String message;
  UserManagementAccessError(this.message);
}

final class UserPermissionsDataLoading extends UserManagementAccessState {}
final class EmployeeToGiveAccessDataLoaded extends UserManagementAccessState {}

/// ADDED 9/10/2026 — the user-limit snapshot (Knowticed Admin limits + current
/// usage) started loading, finished, or failed. The Add Access page rebuilds
/// its usage lines and the Grant button on it.
final class UserLimitUsageUpdated extends UserManagementAccessState {}




class UserPermissionsDataError extends UserManagementAccessState {
  final String message;
  UserPermissionsDataError(this.message);
}

