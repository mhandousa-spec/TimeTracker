/// Module: database / db1_create_database / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: database_status.dart
/// Purpose: Declares `DatabaseStatus`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The record's lifecycle, which is what the "Drafts" and "Deleted" chips on
/// the Database Builder list count (Figma 7398:2492).
///
/// Separate from [DatabaseAccessType]: access says WHO can see a database,
/// status says whether it is finished. A draft has an access type like any
/// other record — it simply has not been granted yet.
///
/// Domain layer: no Flutter imports.

enum DatabaseStatus {
  /// Written by "Save For Later". The wizard's work is kept, but nobody has
  /// been granted access yet — so it is deliberately NOT counted under the
  /// access-type chips, only under Drafts.
  draft,

  /// Finished — created through "Grant Access" / "Create".
  active,

  /// Soft-deleted from the card's "..." menu. ADDED 16/8/2026.
  ///
  /// The document AND its `Access_Grants` subcollection are still there —
  /// only this field changed. That is what makes Restore a one-field write
  /// rather than a re-creation, and it is why deleting no longer sweeps the
  /// grants: they are part of what Restore has to bring back.
  ///
  /// A record in this state is excluded from every other chip, INCLUDING All.
  /// It is reachable only under Deleted. Anything else would put a deleted
  /// database back in the middle of the working list.
  deleted;

  /// Value written to / read from Firestore. Independent of the Dart name so
  /// renaming the enum cannot orphan existing records.
  String get storageKey {
    switch (this) {
      case DatabaseStatus.draft:
        return 'draft';
      case DatabaseStatus.active:
        return 'active';
      case DatabaseStatus.deleted:
        return 'deleted';
    }
  }

  bool get isDraft => this == DatabaseStatus.draft;

  bool get isDeleted => this == DatabaseStatus.deleted;

  /// The statuses a record can be restored INTO — everything except [deleted]
  /// itself. Used to sanity-check a stored `previous_status`: a document whose
  /// previous status somehow reads back as `deleted` would restore into the
  /// Deleted chip and look like Restore silently did nothing.
  bool get isRestorable => !isDeleted;

  /// Parses a stored value, defaulting to [active].
  ///
  /// The default matters: every record written before this field existed has
  /// no `status` at all, and those are finished databases. Defaulting to
  /// `draft` would move the whole existing collection into the Drafts chip.
  static DatabaseStatus fromStorageKey(String? key) {
    return DatabaseStatus.values.firstWhere(
      (DatabaseStatus status) => status.storageKey == key,
      orElse: () => DatabaseStatus.active,
    );
  }
}
