/// Module: database / db3_create_table / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: table_comment.dart
/// Purpose: Declares `TableComment`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// One message on the Comments screen — Figma 7398:8232 (iPad H 1024),
/// 7398:8360 / 8437 (iPad V 768), 7398:8587 / 8311 (the reply and reacted
/// states), reached from the "Comments" button on the Table Name Details card.
///
/// A comment belongs to a TABLE, not to a row. The Figma's breadcrumb is
/// "Database > Database Details > Table Name Details > Comments" — there is no
/// row crumb in it — and the Creating Table card's "Comments Access" dropdown
/// is a property of the table. So the documents live in that table's own
/// `Comments` subcollection.
///
/// WHY THE AUTHOR IS COPIED ONTO THE DOCUMENT
/// ------------------------------------------
/// The bubble draws a name, a job title and a face. Resolving those from the
/// directory at render time would mean a lookup per comment on a screen that
/// is a live list — and worse, it would rewrite history: a person who changes
/// department would have every comment they ever left re-labelled with the new
/// one. So the author is a SNAPSHOT taken when the comment is posted, the same
/// rule `DatabaseMember` follows and for the same reason. [authorId] is the key
/// to re-resolve current values when something genuinely needs them.
///
/// Domain layer: plain Dart, no Firestore types and no Flutter imports.

class TableComment {
  const TableComment({
    required this.id,
    required this.tableId,
    required this.authorId,
    this.authorNameEn = '',
    this.authorNameAr = '',
    this.authorJobTitleEn = '',
    this.authorJobTitleAr = '',
    this.authorPhotoUrl,
    this.text = '',
    this.createdAt,
    this.likedBy = const <String>[],
    this.dislikedBy = const <String>[],
  });

  /// Firestore document id inside the table's `Comments` subcollection. Empty
  /// on a comment that has been typed but not yet written.
  final String id;

  /// The table this thread hangs off. Carried on the entity rather than only in
  /// the path so a comment handed around the UI always knows where it came
  /// from — same rule as `DatabaseTableEntity.databaseId`.
  final String tableId;

  /// Employee id of whoever wrote it. Empty only on a document written before
  /// this field existed, which the UI treats as "somebody else" — never as the
  /// current user, or a stranger's comment would render on the outgoing side.
  final String authorId;

  final String authorNameEn;
  final String authorNameAr;

  /// The line under the name in the Figma ("Marketing", "Marketing lead"). It
  /// is the person's JOB TITLE, not their department: 7398:8232 draws "Ben
  /// Parker / Marketing" above one bubble and "Ahmed Ali / Marketing lead"
  /// beside the other, and only a title distinguishes those two.
  final String authorJobTitleEn;
  final String authorJobTitleAr;

  /// Remote avatar URL. Null renders the initial, the same fallback the
  /// employee cards elsewhere in the app use.
  final String? authorPhotoUrl;

  final String text;

  /// Server timestamp of the write. Null for the brief moment between an
  /// optimistic local insert and the reload that replaces it, which is why the
  /// bubble's date line tolerates null rather than asserting.
  final DateTime? createdAt;

  /// Employee ids who reacted. TWO LISTS rather than one map of id -> reaction:
  /// a list is what Firestore can do `arrayUnion` / `arrayRemove` on, so a
  /// reaction is one atomic field update and two people reacting at the same
  /// moment cannot overwrite each other.
  ///
  /// An id appears in at most ONE of them — see [reactionOf] and the cubit's
  /// `react`, which removes from the other side in the same write.
  final List<String> likedBy;
  final List<String> dislikedBy;

  int get likeCount => likedBy.length;
  int get dislikeCount => dislikedBy.length;

  /// What [employeeId] currently has on this comment, or null for nothing.
  TableCommentReaction? reactionOf(String? employeeId) {
    if (employeeId == null || employeeId.isEmpty) return null;
    if (likedBy.contains(employeeId)) return TableCommentReaction.like;
    if (dislikedBy.contains(employeeId)) return TableCommentReaction.dislike;
    return null;
  }

  /// True when this comment was written by the person reading it — which is
  /// what puts the bubble on the trailing edge (Figma 7398:8232, the second
  /// message).
  ///
  /// An empty [employeeId] is NOT a match even against an empty [authorId]:
  /// "we do not know who you are" and "we do not know who wrote this" are both
  /// unknowns, and treating two unknowns as the same person would draw every
  /// legacy comment as the reader's own.
  bool isMine(String? employeeId) =>
      employeeId != null && employeeId.isNotEmpty && employeeId == authorId;

  String localizedAuthorName({required bool isArabic}) {
    if (isArabic) {
      return authorNameAr.isNotEmpty ? authorNameAr : authorNameEn;
    }
    return authorNameEn.isNotEmpty ? authorNameEn : authorNameAr;
  }

  String localizedAuthorJobTitle({required bool isArabic}) {
    if (isArabic) {
      return authorJobTitleAr.isNotEmpty ? authorJobTitleAr : authorJobTitleEn;
    }
    return authorJobTitleEn.isNotEmpty ? authorJobTitleEn : authorJobTitleAr;
  }

  TableComment copyWith({
    String? id,
    String? tableId,
    String? authorId,
    String? authorNameEn,
    String? authorNameAr,
    String? authorJobTitleEn,
    String? authorJobTitleAr,
    String? authorPhotoUrl,
    String? text,
    DateTime? createdAt,
    List<String>? likedBy,
    List<String>? dislikedBy,
  }) {
    return TableComment(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      authorId: authorId ?? this.authorId,
      authorNameEn: authorNameEn ?? this.authorNameEn,
      authorNameAr: authorNameAr ?? this.authorNameAr,
      authorJobTitleEn: authorJobTitleEn ?? this.authorJobTitleEn,
      authorJobTitleAr: authorJobTitleAr ?? this.authorJobTitleAr,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likedBy: likedBy ?? this.likedBy,
      dislikedBy: dislikedBy ?? this.dislikedBy,
    );
  }

  /// Identity is the document, so a comment whose reactions changed is still
  /// the same comment — which is what lets the cubit replace one entry in the
  /// list without rebuilding the thread above it.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TableComment && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// The two reactions the Figma draws under a bubble (7398:8232 — a filled
/// thumb above the incoming message, an outlined pair under the outgoing one).
///
/// An enum rather than a bool because "no reaction" is a third state and a
/// nullable bool reads as a bug at every call site.
enum TableCommentReaction {
  like,
  dislike;

  /// Which of the document's two arrays this value is stored in.
  String get storageField {
    switch (this) {
      case TableCommentReaction.like:
        return 'liked_by';
      case TableCommentReaction.dislike:
        return 'disliked_by';
    }
  }

  /// The one the reaction is removed from when this one is applied.
  TableCommentReaction get opposite {
    switch (this) {
      case TableCommentReaction.like:
        return TableCommentReaction.dislike;
      case TableCommentReaction.dislike:
        return TableCommentReaction.like;
    }
  }
}
