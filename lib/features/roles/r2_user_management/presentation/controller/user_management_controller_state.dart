/// Module: roles / r2_user_management / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_controller_state.dart
/// Purpose: Declares `UserManagementControllerState`, `UserManagementControllerInitial`, `UserManagementControllerLoading` (+4 more).
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of './user_management_controller.dart';

@immutable
sealed class UserManagementControllerState {}

final class UserManagementControllerInitial
    extends UserManagementControllerState {}

final class UserManagementControllerLoading
    extends UserManagementControllerState {}

final class UserManagementControllerLoaded
    extends UserManagementControllerState {}

/// Emitted whenever the members / permissions lists change.
///
/// Replaces the old GetX `update(['editRoleMembersList'])` notifications. It is
/// deliberately a fresh instance each time so consecutive list mutations are
/// not deduplicated by Cubit's equality check.
final class UserManagementMembersUpdated
    extends UserManagementControllerState {}

/// Emitted after a permission was written successfully.
///
/// Replaces the two `CustomDialogManager.showMessage(context: Get.context!)`
/// calls that used to fire from inside the cubit: the page listens for this and
/// shows the confirmation, so no BuildContext leaks into the controller layer.
final class UserManagementPermissionSaved
    extends UserManagementControllerState {
  /// Human-readable description of what was saved.
  final String message;
  UserManagementPermissionSaved(this.message);
}

class UserManagementControllerError extends UserManagementControllerState {
  final String message;
  UserManagementControllerError(this.message);
}
