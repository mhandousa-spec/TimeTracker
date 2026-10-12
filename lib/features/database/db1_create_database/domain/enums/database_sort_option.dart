/// Module: database / db1_create_database / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: database_sort_option.dart
/// Purpose: Declares `DatabaseSortOption`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// What the Sort button on the Database Builder list offers (Figma 7398:2492 —
/// the popover next to Filter).
///
/// Three options, not two axes. Ascending and Descending order the cards by
/// TITLE, which is the thing the user is reading on the card and the only
/// field where "A → Z" means anything; Last Updated orders by DATE. Modelling
/// this as one enum rather than a (field, direction) pair keeps it inside what
/// `CustomSortButton` can express — a single-select dropdown whose selected
/// item is the whole state — and matches the one popover the Figma draws.
///
/// Domain layer: no Flutter imports. The labels live here because they are the
/// enum's own vocabulary; the toolbar picks one by locale.

enum DatabaseSortOption {
  /// Title A → Z, using the locale's own title so an Arabic UI sorts the
  /// Arabic names rather than the English ones sitting behind them.
  ascending,

  /// Title Z → A.
  descending,

  /// Most recently touched first.
  ///
  /// "Touched" is `updatedAt` falling back to `createdAt`, so a record nobody
  /// has edited sorts by the date the card already prints under "Creation:" —
  /// which is what makes this option's order explainable from the card itself.
  /// Sorting purely by `updatedAt` would drop every never-edited record (that
  /// field is null on them) to one undifferentiated block at the bottom.
  lastUpdated;

  /// Value that could be persisted with a user preference later. Kept
  /// independent of the Dart name for the same reason every other enum in this
  /// module does it.
  String get storageKey {
    switch (this) {
      case DatabaseSortOption.ascending:
        return 'ascending';
      case DatabaseSortOption.descending:
        return 'descending';
      case DatabaseSortOption.lastUpdated:
        return 'last_updated';
    }
  }

  String get labelEn {
    switch (this) {
      case DatabaseSortOption.ascending:
        return 'Ascending';
      case DatabaseSortOption.descending:
        return 'Descending';
      case DatabaseSortOption.lastUpdated:
        return 'Last Updated';
    }
  }

  String get labelAr {
    switch (this) {
      case DatabaseSortOption.ascending:
        return 'تصاعدي';
      case DatabaseSortOption.descending:
        return 'تنازلي';
      case DatabaseSortOption.lastUpdated:
        return 'آخر تحديث';
    }
  }

  String label({required bool isArabic}) => isArabic ? labelAr : labelEn;

  static DatabaseSortOption? fromStorageKey(String? key) {
    if (key == null) return null;
    for (final DatabaseSortOption option in DatabaseSortOption.values) {
      if (option.storageKey == key) return option;
    }
    return null;
  }
}
