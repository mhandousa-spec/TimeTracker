/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: app_notification_state.dart
/// Purpose: States for AppNotificationCubit.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

part of './app_notification_cubit.dart';

sealed class AppNotificationState {
  const AppNotificationState();
}

final class AppNotificationInitial extends AppNotificationState {
  const AppNotificationInitial();
}
