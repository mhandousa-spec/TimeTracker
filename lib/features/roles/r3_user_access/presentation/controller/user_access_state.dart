/// Module: roles / r3_user_access / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_state.dart
/// Purpose: Declares `UserAccessState`, `UserAccessInitial`, `UserAccessLoaded` (+2 more).
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

sealed class UserAccessState {}

final class UserAccessInitial extends UserAccessState {}

final class UserAccessLoaded extends UserAccessState {}

final class UserAccessLoading extends UserAccessState {}

final class UserAccessError extends UserAccessState {
  final String message;
  UserAccessError(this.message);
}