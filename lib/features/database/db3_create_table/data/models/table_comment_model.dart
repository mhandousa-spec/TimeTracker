/// Module: database / db3_create_table / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: table_comment_model.dart
/// Purpose: Declares `TableCommentModel`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// Firestore <-> entity mapping for one comment document. Everything that knows
/// about `Timestamp`, field-name strings and half-empty documents lives here so
/// `TableComment` stays plain Dart — the same split `DatabaseTableModel` makes.
///
/// The reaction field names are NOT declared twice. They come from
/// `TableCommentReaction.storageField`, because the write path
/// (`arrayUnion` / `arrayRemove` in the data source) and the read path below
/// are in different files and a typo between them is a reaction that appears
/// to save and never comes back.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';

class TableCommentModel extends TableComment {
  const TableCommentModel({
    required super.id,
    required super.tableId,
    required super.authorId,
    super.authorNameEn,
    super.authorNameAr,
    super.authorJobTitleEn,
    super.authorJobTitleAr,
    super.authorPhotoUrl,
    super.text,
    super.createdAt,
    super.likedBy,
    super.dislikedBy,
  });

  /// Field names, in one place — a typo here is a silently empty bubble.
  static const String fAuthorId = 'author_id';
  static const String fAuthorNameEn = 'author_name_en';
  static const String fAuthorNameAr = 'author_name_ar';
  static const String fAuthorJobTitleEn = 'author_job_title_en';
  static const String fAuthorJobTitleAr = 'author_job_title_ar';
  static const String fAuthorPhotoUrl = 'author_photo_url';
  static const String fText = 'text';
  static const String fCreatedAt = 'created_at';

  /// Mirrors of `TableCommentReaction.like.storageField` /
  /// `.dislike.storageField`. Exposed as constants so a reader of this file
  /// can see the document's full shape without following the enum, and asserted
  /// against the enum by [_ids] below rather than typed a second time.
  static String get fLikedBy => TableCommentReaction.like.storageField;
  static String get fDislikedBy => TableCommentReaction.dislike.storageField;

  factory TableCommentModel.fromEntity(TableComment entity) =>
      TableCommentModel(
        id: entity.id,
        tableId: entity.tableId,
        authorId: entity.authorId,
        authorNameEn: entity.authorNameEn,
        authorNameAr: entity.authorNameAr,
        authorJobTitleEn: entity.authorJobTitleEn,
        authorJobTitleAr: entity.authorJobTitleAr,
        authorPhotoUrl: entity.authorPhotoUrl,
        text: entity.text,
        createdAt: entity.createdAt,
        likedBy: entity.likedBy,
        dislikedBy: entity.dislikedBy,
      );

  /// Reads one document. Every field is treated as possibly absent — a document
  /// written by an older build is a normal case, not an error case.
  ///
  /// [tableId] is passed in rather than read from the data, because it is the
  /// PARENT's id and lives in the path. Storing it inside as well would be a
  /// second copy that can disagree with where the document actually is.
  factory TableCommentModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    required String tableId,
  }) {
    final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
    final Object? rawCreatedAt = data[fCreatedAt];

    return TableCommentModel(
      id: snapshot.id,
      tableId: tableId,
      authorId: (data[fAuthorId] as String?) ?? '',
      authorNameEn: (data[fAuthorNameEn] as String?) ?? '',
      authorNameAr: (data[fAuthorNameAr] as String?) ?? '',
      authorJobTitleEn: (data[fAuthorJobTitleEn] as String?) ?? '',
      authorJobTitleAr: (data[fAuthorJobTitleAr] as String?) ?? '',
      authorPhotoUrl: data[fAuthorPhotoUrl] as String?,
      text: (data[fText] as String?) ?? '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
      likedBy: _ids(data[fLikedBy]),
      dislikedBy: _ids(data[fDislikedBy]),
    );
  }

  /// A stored array of employee ids, defended against every shape Firestore can
  /// hand back for a field that was written by a different build: absent, a
  /// scalar, or a list with nulls and numbers in it.
  static List<String> _ids(Object? raw) {
    if (raw is! List<dynamic>) return const <String>[];
    return List<String>.unmodifiable(
      raw.whereType<String>().where((String id) => id.isNotEmpty),
    );
  }

  /// Payload for a new comment.
  ///
  /// [id] is deliberately absent — the document id is the id, duplicating it
  /// inside invites the two drifting apart. So is [tableId], which is the path.
  ///
  /// The two reaction arrays ARE written, empty. Firestore's `arrayUnion` will
  /// happily create a missing field, so this is not required for correctness —
  /// it is so a document read back before anyone reacts has the same shape as
  /// one read back after, and `_ids` never has to explain an absent key.
  Map<String, dynamic> toCreateMap() => <String, dynamic>{
        fAuthorId: authorId,
        fAuthorNameEn: authorNameEn,
        fAuthorNameAr: authorNameAr,
        fAuthorJobTitleEn: authorJobTitleEn,
        fAuthorJobTitleAr: authorJobTitleAr,
        fAuthorPhotoUrl: authorPhotoUrl,
        fText: text,
        fCreatedAt: FieldValue.serverTimestamp(),
        fLikedBy: const <String>[],
        fDislikedBy: const <String>[],
      };
}
