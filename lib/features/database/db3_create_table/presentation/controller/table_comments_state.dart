/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_comments_state.dart
/// Purpose: Declares `TableCommentsState`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026

part of './table_comments_cubit.dart';

@immutable
class TableCommentsState {
  const TableCommentsState({
    required this.databaseId,
    required this.tableId,
    required this.currentEmployeeId,
    this.commentsAccess = TableCommentsAccess.private,
    this.tableCreatedBy,
    this.comments = const <TableComment>[],
    this.isLoading = true,
    this.isPosting = false,
    this.authorNameEn = '',
    this.authorNameAr = '',
    this.authorJobTitleEn = '',
    this.authorJobTitleAr = '',
    this.authorPhotoUrl,
    this.errorMessage,
  });

  final String databaseId;
  final String tableId;

  /// Who is reading. Empty when the module was opened without an employee id —
  /// the thread is still readable, the composer and the thumbs are not.
  final String currentEmployeeId;

  /// The table's "Comments Access" setting (Figma 7398:6702). Copied onto the
  /// state rather than read off the table each time so [canPost] is one
  /// expression the screen can trust.
  final TableCommentsAccess commentsAccess;

  /// Employee id of whoever created the table — this module's notion of the
  /// table's admin. See [canPost].
  final String? tableCreatedBy;

  /// The thread, OLDEST first. That is the server's order and the screen keeps
  /// it: a conversation reordered by anything else stops being one.
  final List<TableComment> comments;

  /// Starts true so the screen shows a spinner rather than an empty thread for
  /// the half second before the first read lands. An empty state that turns out
  /// to be wrong is worse than a spinner.
  final bool isLoading;

  final bool isPosting;

  /// The reader's own name and face, resolved once from the directory and
  /// copied onto every comment they post. Empty when the directory could not be
  /// reached, which the bubble renders as an unnamed author rather than an
  /// error — see the cubit's `_resolveAuthor`.
  final String authorNameEn;
  final String authorNameAr;
  final String authorJobTitleEn;
  final String authorJobTitleAr;
  final String? authorPhotoUrl;

  final String? errorMessage;

  bool get hasError => errorMessage != null;

  /// Whether the composer and the thumbs are offered.
  ///
  /// Nobody signed in means no, always: a comment with no author cannot be
  /// deleted by its writer and a reaction with no id cannot be taken back.
  ///
  /// On a SHARED table (the enum's own words: "All employees can view, reply
  /// to, and engage with the comments") anyone signed in may post. On a PRIVATE
  /// one only the person who created the table may — this module's nearest
  /// honest reading of "only admins", since a table carries a creator and
  /// nothing else on it says who administers it.
  ///
  /// This governs POSTING, not reading. Hiding the thread itself from everyone
  /// but one person is a rule that belongs in Firestore's security rules, where
  /// it cannot be walked around; a screen that merely declined to draw what it
  /// had already downloaded would be theatre.
  bool get canPost {
    if (currentEmployeeId.isEmpty) return false;
    if (commentsAccess == TableCommentsAccess.shared) return true;
    return tableCreatedBy != null && tableCreatedBy == currentEmployeeId;
  }

  TableCommentsState copyWith({
    String? databaseId,
    String? tableId,
    String? currentEmployeeId,
    TableCommentsAccess? commentsAccess,
    String? tableCreatedBy,
    List<TableComment>? comments,
    bool? isLoading,
    bool? isPosting,
    String? authorNameEn,
    String? authorNameAr,
    String? authorJobTitleEn,
    String? authorJobTitleAr,
    String? authorPhotoUrl,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TableCommentsState(
      databaseId: databaseId ?? this.databaseId,
      tableId: tableId ?? this.tableId,
      currentEmployeeId: currentEmployeeId ?? this.currentEmployeeId,
      commentsAccess: commentsAccess ?? this.commentsAccess,
      tableCreatedBy: tableCreatedBy ?? this.tableCreatedBy,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isPosting: isPosting ?? this.isPosting,
      authorNameEn: authorNameEn ?? this.authorNameEn,
      authorNameAr: authorNameAr ?? this.authorNameAr,
      authorJobTitleEn: authorJobTitleEn ?? this.authorJobTitleEn,
      authorJobTitleAr: authorJobTitleAr ?? this.authorJobTitleAr,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
