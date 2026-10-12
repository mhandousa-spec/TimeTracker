/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_controller_state_main_core.dart
/// Purpose: States for the shell notification cubit.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

part of './notification_controller_cubit_main_core.dart';

@immutable
sealed class NotificationControllerState {}

final class NotificationControllerInitial extends NotificationControllerState {}
