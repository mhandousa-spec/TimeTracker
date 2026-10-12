// lib/features/grc/control_owner/domain/entities/owner_status.dart
/// Module: Control Owner Management
/// Description: Lifecycle status of a Control Owner record.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: None

enum OwnerStatus {
  active,
  removed;

  String get value {
    switch (this) {
      case OwnerStatus.active:
        return 'Active';
      case OwnerStatus.removed:
        return 'Removed';
    }
  }

  static OwnerStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'removed':
        return OwnerStatus.removed;
      case 'active':
      default:
        return OwnerStatus.active;
    }
  }
}
