/// Module: services_management_module
/// Description: State for SlaCubit — a thin busy/error signal for the SLA
///              mobile screen's SharedPreferences-backed persistence calls
///              (seed-from-doc, submit-percentages/checkboxes/switches,
///              save-draft). The screen keeps its own local UI state
///              (checkbox/switch maps, text controllers) since that drives
///              a large widget tree that isn't safe to migrate blind
///              without a compiler; this cubit only reports whether the
///              last local-storage call succeeded/failed.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: equatable
/// Revision History: Initial version — extracted from
///                    s12_create_notification_mobile/ui/services_management_module/sla_screen_mobile.dart
///                    (audit fix 1e). First controller/ folder for s12.
library;

import 'package:equatable/equatable.dart';

abstract class SlaState extends Equatable {
  const SlaState();

  @override
  List<Object?> get props => [];
}

class SlaIdle extends SlaState {
  const SlaIdle();
}

class SlaBusy extends SlaState {
  const SlaBusy();
}

class SlaSuccess extends SlaState {
  const SlaSuccess();
}

class SlaError extends SlaState {
  final String message;

  const SlaError(this.message);

  @override
  List<Object?> get props => [message];
}
