/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_entity.dart
/// Purpose: Declares `DatabaseEntity`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The bilingual database record the Create New Database card produces
/// (Figma 7398:6137 iPad landscape / 7398:6214 iPad portrait).
///
/// Domain layer: plain Dart, no Firestore types and no Flutter imports. The
/// data layer's `DatabaseModel` is what knows about `Timestamp` and maps.

import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';

class DatabaseEntity {
  const DatabaseEntity({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.accessType,
    this.descriptionEn = '',
    this.descriptionAr = '',
    this.coverImageUrl,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.tablesCount = 0,
    this.memberCount = 0,
    this.status = DatabaseStatus.active,
    this.previousStatus,
    this.deletedAt,
  });

  /// Firestore document id. Empty before the record is written.
  final String id;

  /// Both titles are captured on one screen, so both are required — this is a
  /// bilingual record, not a localized view of one value.
  final String titleEn;
  final String titleAr;

  final String descriptionEn;
  final String descriptionAr;

  final DatabaseAccessType accessType;

  /// Remote URL of the uploaded cover image. Null while the user has only
  /// picked a local file and the upload has not finished.
  final String? coverImageUrl;

  /// Employee id of the creator.
  final String? createdBy;

  final DateTime? createdAt;

  /// When the record was last edited. ADDED 16/8/2026 for the details card's
  /// "Last Edit: 17 Jul 2024" line (Figma 7398:735).
  ///
  /// Null on every document written before that date and on records that have
  /// never been edited — the card then omits the line rather than showing the
  /// creation date twice under two different labels.
  final DateTime? updatedAt;

  /// Number of tables inside. Always 0 at creation; the list card
  /// ("No. Of Tables: 15") reads it later.
  final int tablesCount;

  /// Distinct people with access, denormalised from the grants subcollection
  /// so the list screen never has to read it.
  final int memberCount;

  /// Lifecycle. `active` for anything created through Grant Access / Create,
  /// `draft` for a record parked by "Save For Later" — which is what the
  /// Drafts chip on the list counts — and `deleted` for a record the user
  /// removed from the card menu. Deleting is a status change, not a document
  /// delete; see [previousStatus].
  final DatabaseStatus status;

  /// What [status] was immediately before the record was deleted. ADDED
  /// 16/8/2026 for Restore.
  ///
  /// Restore has to put the record back where it CAME FROM, and that is not
  /// always `active`: a draft that was parked by "Save For Later" and then
  /// deleted belongs under Drafts again, not in the finished list where it
  /// would claim access it never granted. Restoring to a hardcoded `active`
  /// would quietly promote every deleted draft.
  ///
  /// Null on a record that has never been deleted, and on documents written
  /// before this field existed — [restoreTarget] falls back to `active` for
  /// those, which is what an old record with no draft marker actually was.
  final DatabaseStatus? previousStatus;

  /// When the record was deleted. Null unless [status] is deleted. Not drawn
  /// anywhere yet; it is written so a future "auto-purge after N days" has the
  /// date it needs rather than having to guess from `updated_at`.
  final DateTime? deletedAt;

  bool get isDraft => status.isDraft;

  bool get isDeleted => status.isDeleted;

  /// The status Restore should write. Guards against a stored
  /// `previous_status` of `deleted`, which would restore the record straight
  /// back into the Deleted chip and read as Restore doing nothing.
  DatabaseStatus get restoreTarget {
    final DatabaseStatus? previous = previousStatus;
    if (previous == null || !previous.isRestorable) return DatabaseStatus.active;
    return previous;
  }

  /// Title for the current UI locale, with a fallback so a record that is
  /// missing one side still renders something rather than an empty row.
  String localizedTitle({required bool isArabic}) {
    if (isArabic) return titleAr.isNotEmpty ? titleAr : titleEn;
    return titleEn.isNotEmpty ? titleEn : titleAr;
  }

  String localizedDescription({required bool isArabic}) {
    if (isArabic) return descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;
    return descriptionEn.isNotEmpty ? descriptionEn : descriptionAr;
  }

  DatabaseEntity copyWith({
    String? id,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    DatabaseAccessType? accessType,
    String? coverImageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? tablesCount,
    int? memberCount,
    DatabaseStatus? status,
    DatabaseStatus? previousStatus,
    DateTime? deletedAt,

    /// Restore has to WIPE both fields, and `previousStatus: null` cannot say
    /// that — null is "leave it alone" for every other nullable here. Same
    /// shape `DatabaseAccessGrant.copyWith` uses for its cleared dates.
    bool clearDeletionMarkers = false,
  }) {
    return DatabaseEntity(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      accessType: accessType ?? this.accessType,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tablesCount: tablesCount ?? this.tablesCount,
      memberCount: memberCount ?? this.memberCount,
      status: status ?? this.status,
      previousStatus: clearDeletionMarkers
          ? null
          : (previousStatus ?? this.previousStatus),
      deletedAt: clearDeletionMarkers ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
