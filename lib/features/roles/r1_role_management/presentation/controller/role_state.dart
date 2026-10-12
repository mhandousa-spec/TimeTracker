/// Module: roles / r1_role_management / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: role_state.dart
/// Purpose: Declares `RoleState`, `RoleInitial`, `RoleLoading` (+18 more).
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of './role_cubit.dart';

@immutable
sealed class RoleState {}

final class RoleInitial extends RoleState {}

class RoleLoading extends RoleState {} // ADD THIS

final class RoleModuleSelected extends RoleState {}

final class RoleStatusSelected extends RoleState {}

final class RoleFetched extends RoleState {}

final class RoleFiltered extends RoleState {}

final class RoleSwitchToggled extends RoleState {}

// Add these missing states:
final class RoleAdded extends RoleState {}

final class RoleError extends RoleState {
  final String message;
  RoleError(this.message);  // Remove 'const' here
}

final class RolePermissionUpdated extends RoleState {}

final class RoleImagePicked extends RoleState {}

final class RoleSelected extends RoleState {}

final class RoleUpdated extends RoleState {}

final class RoleDeleted extends RoleState {}

final class RoleDraftSaved extends RoleState {}

final class RoleActivated extends RoleState {}

final class RolePermissionLoaded extends RoleState {}

final class RolePermissionSaved extends RoleState {}

final class RolePermissionsCleared extends RoleState {}

final class RoleConfigurationImported extends RoleState {}