// ******************* FILE INFO *******************
// File Name: sla_notification_state.dart
// Description: State classes for SLA notification cubit
// Created by: Amr Mesbah
// Last Update: 30/8/2025

import 'package:equatable/equatable.dart';

abstract class SlaNotificationState extends Equatable {
  const SlaNotificationState();

  @override
  List<Object?> get props => [];
}

class SlaNotificationInitial extends SlaNotificationState {}

class SlaNotificationLoading extends SlaNotificationState {}

class SlaNotificationDraftSaved extends SlaNotificationState {
  const SlaNotificationDraftSaved();
}

class SlaNotificationLoaded extends SlaNotificationState {
  final String? currentDocId;
  final bool notifyRequesterChecked;
  final bool notifyProviderChecked;
  final bool notifyManagerChecked;
  final bool notifyRequesterSwitch0;
  final bool notifyManagerSwitch1;
  final List<String> extraSlaList;
  final List<String> extraSlaTwoList;
  final Map<String, Map<int, bool>> notificationSwitches;

  const SlaNotificationLoaded({
    this.currentDocId,
    required this.notifyRequesterChecked,
    required this.notifyProviderChecked,
    required this.notifyManagerChecked,
    required this.notifyRequesterSwitch0,
    required this.notifyManagerSwitch1,
    required this.extraSlaList,
    required this.extraSlaTwoList,
    required this.notificationSwitches,
  });

  @override
  List<Object?> get props => [
    currentDocId,
    notifyRequesterChecked,
    notifyProviderChecked,
    notifyManagerChecked,
    notifyRequesterSwitch0,
    notifyManagerSwitch1,
    extraSlaList,
    extraSlaTwoList,
    notificationSwitches,
  ];
}

class SlaNotificationSaving extends SlaNotificationState {}

class SlaNotificationSaved extends SlaNotificationState {}

class SlaNotificationError extends SlaNotificationState {
  final String message;

  const SlaNotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class SlaNotificationValidationError extends SlaNotificationState {
  final String message;

  const SlaNotificationValidationError(this.message);

  @override
  List<Object?> get props => [message];
}