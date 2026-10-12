/// Module: database / db1_create_database / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: database_model.dart
/// Purpose: Declares `DatabaseModel`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// Firestore <-> entity mapping. Everything that knows about `Timestamp`,
/// field-name strings and null-shaped documents lives here, so
/// `DatabaseEntity` stays plain Dart.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';

class DatabaseModel extends DatabaseEntity {
  const DatabaseModel({
    required super.id,
    required super.titleEn,
    required super.titleAr,
    required super.accessType,
    super.descriptionEn,
    super.descriptionAr,
    super.coverImageUrl,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
    super.tablesCount,
    super.memberCount,
    super.status,
    super.previousStatus,
    super.deletedAt,
  });

  /// Field names, in one place — a typo here is a silently empty screen.
  static const String fTitleEn = 'title_en';
  static const String fTitleAr = 'title_ar';
  static const String fDescriptionEn = 'description_en';
  static const String fDescriptionAr = 'description_ar';
  static const String fAccessType = 'access_type';
  static const String fCoverImageUrl = 'cover_image_url';
  static const String fCreatedBy = 'created_by';
  static const String fCreatedAt = 'created_at';

  /// Last edit. ADDED 16/8/2026 — written by db2's details module, read by the
  /// details card's "Last Edit" line. Absent on every document written before
  /// then, which reads back as null.
  static const String fUpdatedAt = 'updated_at';
  static const String fTablesCount = 'tables_count';
  static const String fMemberCount = 'member_count';

  /// Lifecycle: 'draft', 'active' or 'deleted'. Absent on every document
  /// written before 15/8/2026, which `DatabaseStatus.fromStorageKey` reads as
  /// active.
  static const String fStatus = 'status';

  /// What [fStatus] was immediately before a soft delete, so Restore can put
  /// the record back where it came from instead of promoting every deleted
  /// draft to active. ADDED 16/8/2026; absent on anything never deleted.
  static const String fPreviousStatus = 'previous_status';

  /// When the soft delete happened. ADDED 16/8/2026. Nothing draws it yet — it
  /// is written so a future auto-purge has a real date to work from.
  static const String fDeletedAt = 'deleted_at';

  /// Lower-cased title copies used by [titleExists]. Firestore cannot do a
  /// case-insensitive equality query, so the normalized form is stored
  /// alongside the display form.
  static const String fTitleEnLower = 'title_en_lower';
  static const String fTitleArLower = 'title_ar_lower';

  factory DatabaseModel.fromEntity(DatabaseEntity entity) => DatabaseModel(
        id: entity.id,
        titleEn: entity.titleEn,
        titleAr: entity.titleAr,
        descriptionEn: entity.descriptionEn,
        descriptionAr: entity.descriptionAr,
        accessType: entity.accessType,
        coverImageUrl: entity.coverImageUrl,
        createdBy: entity.createdBy,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        tablesCount: entity.tablesCount,
        memberCount: entity.memberCount,
        status: entity.status,
        previousStatus: entity.previousStatus,
        deletedAt: entity.deletedAt,
      );

  /// Reads one document. Every field is treated as possibly absent — a
  /// document written by an older build of the app is a normal case, not an
  /// error case.
  factory DatabaseModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
    final Object? rawCreatedAt = data[fCreatedAt];
    final Object? rawUpdatedAt = data[fUpdatedAt];
    final Object? rawDeletedAt = data[fDeletedAt];
    final Object? rawPreviousStatus = data[fPreviousStatus];

    return DatabaseModel(
      id: snapshot.id,
      titleEn: (data[fTitleEn] as String?) ?? '',
      titleAr: (data[fTitleAr] as String?) ?? '',
      descriptionEn: (data[fDescriptionEn] as String?) ?? '',
      descriptionAr: (data[fDescriptionAr] as String?) ?? '',
      accessType:
          DatabaseAccessType.fromStorageKey(data[fAccessType] as String?),
      coverImageUrl: data[fCoverImageUrl] as String?,
      createdBy: data[fCreatedBy] as String?,
      createdAt:
          rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
      updatedAt:
          rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
      tablesCount: (data[fTablesCount] as num?)?.toInt() ?? 0,
      memberCount: (data[fMemberCount] as num?)?.toInt() ?? 0,
      status: DatabaseStatus.fromStorageKey(data[fStatus] as String?),
      // NOT `fromStorageKey` on a null: that helper defaults to `active`,
      // which is the right answer for a missing `status` but the wrong one
      // here. A record that has never been deleted has no previous status at
      // all, and `DatabaseEntity.restoreTarget` is what turns the absence into
      // a fallback — one place, not two.
      previousStatus: rawPreviousStatus is String
          ? DatabaseStatus.fromStorageKey(rawPreviousStatus)
          : null,
      deletedAt: rawDeletedAt is Timestamp ? rawDeletedAt.toDate() : null,
    );
  }

  /// Payload for a create. [id] is deliberately absent — the document id is
  /// the id, duplicating it inside invites the two drifting apart.
  ///
  /// `updated_at` IS STAMPED HERE (16/8/2026), with the same server timestamp
  /// as `created_at`. A record's last write IS its creation until something
  /// edits it, and the details card's "Last Edit" line reads this field — so
  /// leaving it absent meant every database showed no Last Edit at all until
  /// its first edit, which read as a missing feature rather than as "not
  /// edited yet". Sorting is unaffected: `DatabaseListCubit` already ranks by
  /// `updatedAt ?? createdAt`, and these two are now equal on a new record.
  Map<String, dynamic> toCreateMap() => <String, dynamic>{
        fTitleEn: titleEn,
        fTitleAr: titleAr,
        fTitleEnLower: titleEn.toLowerCase(),
        fTitleArLower: titleAr.toLowerCase(),
        fDescriptionEn: descriptionEn,
        fDescriptionAr: descriptionAr,
        fAccessType: accessType.storageKey,
        fCoverImageUrl: coverImageUrl,
        fCreatedBy: createdBy,
        fCreatedAt: FieldValue.serverTimestamp(),
        fUpdatedAt: FieldValue.serverTimestamp(),
        fTablesCount: tablesCount,
        fMemberCount: memberCount,
        fStatus: status.storageKey,
      };

  /// Payload for RESUMING A DRAFT — the wizard reopened on an existing record
  /// and finished (or re-parked) it. ADDED 16/8/2026.
  ///
  /// Deliberately NOT `toCreateMap`. Four of its keys would be wrong here:
  ///
  ///   `created_at`  a fresh `serverTimestamp()` would move the record to the
  ///                 top of a list ordered by creation date and rewrite the
  ///                 date already printed on its card.
  ///   `created_by`  the person finishing a draft is not necessarily the
  ///                 person who started it.
  ///   `tables_count` the wizard does not know it; a draft that somehow gained
  ///                 tables would have the count reset to the wizard's 0.
  ///   `deleted_at` / `previous_status` are not touched at all — resuming is
  ///                 not a restore, and a draft in the Deleted chip is not
  ///                 reachable from the list anyway.
  ///
  /// `updated_at` is stamped because this IS an edit, and the details card
  /// draws a "Last Edit" line from it.
  Map<String, dynamic> toUpdateMap() => <String, dynamic>{
        fTitleEn: titleEn,
        fTitleAr: titleAr,
        fTitleEnLower: titleEn.toLowerCase(),
        fTitleArLower: titleAr.toLowerCase(),
        fDescriptionEn: descriptionEn,
        fDescriptionAr: descriptionAr,
        fAccessType: accessType.storageKey,
        fCoverImageUrl: coverImageUrl,
        fMemberCount: memberCount,
        fStatus: status.storageKey,
        fUpdatedAt: FieldValue.serverTimestamp(),
      };
}
