// lib/features/grc/control_champion/domain/entities/champion_status.dart
/// Module: Control Champion Management
/// Description: Lifecycle status of a Control Champion record.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: None

/// class name: [ChampionStatus]
///
/// purpose: represent whether a Control Champion assignment is currently
///          in effect ([active]) or has been soft-deleted ([removed]).
enum ChampionStatus {
  active,
  removed;

  String get value {
    switch (this) {
      case ChampionStatus.active:
        return 'Active';
      case ChampionStatus.removed:
        return 'Removed';
    }
  }

  static ChampionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'removed':
        return ChampionStatus.removed;
      case 'active':
      default:
        return ChampionStatus.active;
    }
  }
}
