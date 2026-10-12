/// Module: database / db1_create_database / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: database_permission_level.dart
/// Purpose: Declares `DatabasePermissionLevel`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
/// Updated: 16/8/2026 - Levels replaced with the Figma's four.
///
/// The "Permissions" dropdown on the Access Management screens
/// (Figma 7398:18600 "Choose Permissions") and the value the Review summary
/// tile reports.
///
/// THE FOUR LEVELS ARE THE FIGMA'S, IN THE FIGMA'S ORDER
/// -----------------------------------------------------
/// The open menu reads Full Access / Edit / Export / View, top to bottom, and
/// [selectable] returns them in exactly that order — a dropdown that reorders
/// its own design is a bug report waiting to happen.
///
/// This replaced Viewer / Editor / Admin on 16/8/2026. Those were three ROLE
/// names; these are four things a person may DO, and Export is the one that
/// has no equivalent in the old set — which is why this is a replacement
/// rather than a rename.
///
/// [custom] is not in that menu. It is what the summary shows when different
/// departments ended up with different levels (Figma 7398:18213,
/// "Permissions / Custom"). Keeping it in the same enum means the summary tile
/// has one type to render instead of a nullable level plus a boolean.

enum DatabasePermissionLevel {
  fullAccess,
  edit,
  export,
  view,
  custom;

  /// Levels a user can actually choose, in the Figma's own order.
  /// [custom] is derived, never selected.
  static List<DatabasePermissionLevel> get selectable =>
      const <DatabasePermissionLevel>[
        DatabasePermissionLevel.fullAccess,
        DatabasePermissionLevel.edit,
        DatabasePermissionLevel.export,
        DatabasePermissionLevel.view,
      ];

  /// Value written to / read from Firestore. Independent of the Dart name so
  /// renaming the enum cannot orphan existing grants.
  String get storageKey {
    switch (this) {
      case DatabasePermissionLevel.fullAccess:
        return 'full_access';
      case DatabasePermissionLevel.edit:
        return 'edit';
      case DatabasePermissionLevel.export:
        return 'export';
      case DatabasePermissionLevel.view:
        return 'view';
      case DatabasePermissionLevel.custom:
        return 'custom';
    }
  }

  String get labelEn {
    switch (this) {
      case DatabasePermissionLevel.fullAccess:
        return 'Full Access';
      case DatabasePermissionLevel.edit:
        return 'Edit';
      case DatabasePermissionLevel.export:
        return 'Export';
      case DatabasePermissionLevel.view:
        return 'View';
      case DatabasePermissionLevel.custom:
        return 'Custom';
    }
  }

  String get labelAr {
    switch (this) {
      case DatabasePermissionLevel.fullAccess:
        return 'وصول كامل';
      case DatabasePermissionLevel.edit:
        return 'تعديل';
      case DatabasePermissionLevel.export:
        return 'تصدير';
      case DatabasePermissionLevel.view:
        return 'عرض';
      case DatabasePermissionLevel.custom:
        return 'مخصص';
    }
  }

  /// Storage keys written before 16/8/2026, mapped onto the level that means
  /// the same thing.
  ///
  /// Grants ALREADY EXIST with these values. Without this map every one of them
  /// would read back as null — an incomplete grant — and the Review screen
  /// would refuse to save a database whose permissions were set weeks ago, with
  /// an empty dropdown as the only clue why.
  ///
  ///   admin  -> Full Access   the level that could do everything
  ///   editor -> Edit
  ///   viewer -> View
  ///
  /// Nothing maps to Export: it is new, and inventing a grant that lets people
  /// pull data out of the company is not a migration this is allowed to make.
  ///
  /// These are read-only. Nothing writes them again — a record touched by any
  /// screen is saved with the new key — so this map shrinks to dead weight
  /// naturally and can be dropped once the collection has turned over.
  static const Map<String, DatabasePermissionLevel> _legacyKeys =
      <String, DatabasePermissionLevel>{
    'admin': DatabasePermissionLevel.fullAccess,
    'editor': DatabasePermissionLevel.edit,
    'viewer': DatabasePermissionLevel.view,
  };

  static DatabasePermissionLevel? fromStorageKey(String? key) {
    if (key == null) return null;
    for (final DatabasePermissionLevel level in DatabasePermissionLevel.values) {
      if (level.storageKey == key) return level;
    }
    return _legacyKeys[key];
  }
}
