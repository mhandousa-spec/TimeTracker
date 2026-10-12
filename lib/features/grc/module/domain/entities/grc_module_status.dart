/// The fixed set of GRC Module lifecycle states. Extracted because
/// 'Active'/'Inactive'/'Scheduled'/'Removed' were hardcoded string
/// literals across 5 files, unlike every sibling GRC feature (Champion,
/// Owner, Control, Policy), which already has an equivalent enum.
library;

enum GrcModuleStatus {
  active,
  inactive,
  scheduled,
  removed;

  String get value {
    switch (this) {
      case GrcModuleStatus.active:
        return 'Active';
      case GrcModuleStatus.inactive:
        return 'Inactive';
      case GrcModuleStatus.scheduled:
        return 'Scheduled';
      case GrcModuleStatus.removed:
        return 'Removed';
    }
  }

  static GrcModuleStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'inactive':
        return GrcModuleStatus.inactive;
      case 'scheduled':
        return GrcModuleStatus.scheduled;
      case 'removed':
        return GrcModuleStatus.removed;
      case 'active':
      default:
        return GrcModuleStatus.active;
    }
  }
}
