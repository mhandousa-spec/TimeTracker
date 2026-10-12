/// Module: database / db2_database_details / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_status.dart
/// Purpose: Declares `DatabaseAccessStatus`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The four chips and the last column of the Access table (Figma 7398:10662
/// iPad V / 7398:10875 iPad H, and the full-width table `Group 1597882843`
/// whose "Access Status" column reads Active / Deactivated / Removed /
/// Scheduled).
///
/// WHY THIS IS DERIVED AND NOT STORED
/// ----------------------------------
/// Three of the four states are a statement about TODAY, not about the
/// record: a grant that runs 28 Nov 2025 -> 28 Nov 2026 is "Scheduled" in
/// October, "Active" in December and "Deactivated" a year later, without
/// anybody editing it. Storing the word would mean a nightly job to rewrite
/// documents whose dates never changed, and any device whose clock disagreed
/// with that job would show a stale badge.
///
/// So [resolve] computes it from the window every time it is rendered. The one
/// state that IS persisted is [removed], because "this person used to have
/// access and no longer does" cannot be derived from a row that is gone — see
/// `RemovedAccessMember`.

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';

enum DatabaseAccessStatus {
  /// Today falls inside the window (or the grant has no window at all).
  active,

  /// The start date has not arrived yet.
  scheduled,

  /// The end date has passed.
  deactivated,

  /// The person was taken off the grant. Persisted, never derived.
  removed;

  /// Function Name: [resolve]
  ///
  /// Purpose: Which status a live grant is in on [now].
  ///
  /// Dates are compared DATE-ONLY. A grant that ends "28 Nov 2026" is stored
  /// as midnight on that day, so an instant comparison would call it expired
  /// for the whole of its last day — the user would open the screen on the end
  /// date and find access already gone.
  ///
  /// A missing date means "no bound in that direction" rather than a reason to
  /// refuse: grants written before the dates were mandatory still have to
  /// render as something, and the honest reading of an open-ended window is
  /// that it is in force.
  static DatabaseAccessStatus resolve(
    DatabaseAccessGrant grant, {
    DateTime? now,
  }) {
    final DateTime today = _dateOnly(now ?? DateTime.now());

    final DateTime? start =
        grant.startDate == null ? null : _dateOnly(grant.startDate!);
    final DateTime? end = grant.endDate == null ? null : _dateOnly(grant.endDate!);

    if (start != null && start.isAfter(today)) {
      return DatabaseAccessStatus.scheduled;
    }
    if (end != null && end.isBefore(today)) {
      return DatabaseAccessStatus.deactivated;
    }
    return DatabaseAccessStatus.active;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool get isRemoved => this == DatabaseAccessStatus.removed;

  String get storageKey {
    switch (this) {
      case DatabaseAccessStatus.active:
        return 'active';
      case DatabaseAccessStatus.scheduled:
        return 'scheduled';
      case DatabaseAccessStatus.deactivated:
        return 'deactivated';
      case DatabaseAccessStatus.removed:
        return 'removed';
    }
  }

  String get labelEn {
    switch (this) {
      case DatabaseAccessStatus.active:
        return 'Active';
      case DatabaseAccessStatus.scheduled:
        return 'Scheduled';
      case DatabaseAccessStatus.deactivated:
        return 'Deactivated';
      case DatabaseAccessStatus.removed:
        return 'Removed';
    }
  }

  String get labelAr {
    switch (this) {
      case DatabaseAccessStatus.active:
        return 'نشط';
      case DatabaseAccessStatus.scheduled:
        return 'مجدول';
      case DatabaseAccessStatus.deactivated:
        return 'موقوف';
      case DatabaseAccessStatus.removed:
        return 'مُزال';
    }
  }

  String localizedLabel({required bool isArabic}) =>
      isArabic ? labelAr : labelEn;
}

/// The chip row above the table (Figma 7398:10662): "All" plus one chip per
/// status, in the order the design draws them.
///
/// A separate enum from [DatabaseAccessStatus] because "All" is not a status a
/// row can be in — folding it into the same enum would force every `switch`
/// over a row's status to handle a case that cannot happen.
enum DatabaseAccessFilter {
  all,
  active,
  deactivated,
  removed,
  scheduled;

  /// The status this chip narrows to, or null for [all].
  DatabaseAccessStatus? get status {
    switch (this) {
      case DatabaseAccessFilter.all:
        return null;
      case DatabaseAccessFilter.active:
        return DatabaseAccessStatus.active;
      case DatabaseAccessFilter.deactivated:
        return DatabaseAccessStatus.deactivated;
      case DatabaseAccessFilter.removed:
        return DatabaseAccessStatus.removed;
      case DatabaseAccessFilter.scheduled:
        return DatabaseAccessStatus.scheduled;
    }
  }
}
