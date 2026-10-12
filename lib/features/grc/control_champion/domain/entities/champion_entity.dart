// lib/features/grc/control_champion/domain/entities/champion_entity.dart
/// Module: Control Champion Management
/// Description: Flat (non-list) representation of a Control Champion record,
///              derived from the latest revision of [ChampionModel].
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: AssigningControlEntity, ChampionStatus

import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'champion_status.dart';

/// class name: [ChampionEntity]
///
/// purpose: holds the current (latest) values of a Control Champion record.
class ChampionEntity {
  final String championEmail;
  final List<AssigningControlEntity> assigningControls;
  final ChampionStatus status;

  // Tracking fields (latest values only)
  final DateTime createdAt;
  final DateTime modificationDate;
  final String lastModifier;

  const ChampionEntity({
    required this.championEmail,
    required this.assigningControls,
    required this.status,
    required this.createdAt,
    required this.modificationDate,
    required this.lastModifier,
  });
}
