/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_comments_cubit.dart
/// Purpose: Declares `TableCommentsCubit`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// The thread behind Figma 7398:8232 (iPad H 1024), 7398:8360 / 8437 (iPad V
/// 768) and 7398:8587 / 8311 — read, post, react, delete.
///
/// WHO THE AUTHOR IS
/// -----------------
/// The screen is handed an employee id (the same `editedBy` the rest of the
/// module passes down from the drawer) and this cubit resolves the NAME, the
/// job title and the face from `MainCoreEmployeeController` — the app's single
/// source for the org chart, and the same one `TableAccessCubit._loadDirectory`
/// uses. It degrades to the bare id rather than throwing: a thread that cannot
/// reach the directory should still be readable and postable, just with a
/// nameless bubble, and that is strictly better than an error over comments
/// that loaded fine.
///
/// The snapshot is taken ONCE per screen, not per message. It does not change
/// while the screen is open, and a directory read per keystroke-to-send would
/// be a lookup for something already known.
///
/// OPTIMISM, AND WHERE IT STOPS
/// ----------------------------
/// Posting appends the server's copy when it lands rather than a local one
/// first: the bubble prints a timestamp, and a message that appears with no
/// date and then quietly grows one is worse than a half-second of a spinning
/// send button. Reactions ARE optimistic — the thumb has to answer the tap
/// immediately — and roll back to the server's copy either way, because that is
/// the copy that includes everyone else's thumbs.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/repository/create_table_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

part './table_comments_state.dart';

class TableCommentsCubit extends Cubit<TableCommentsState> {
  /// [table] is the record the details screen is already holding — the thread's
  /// path, its "Comments Access" setting and its creator all come off it, so the
  /// screen never has to re-read a document it was handed.
  TableCommentsCubit({
    required DatabaseTableEntity table,
    String? currentEmployeeId,
    CreateTableBaseRepository? repository,
  })  : _repository = repository ?? CreateTableRepository(),
        super(TableCommentsState(
          databaseId: table.databaseId,
          tableId: table.id,
          currentEmployeeId: currentEmployeeId ?? '',
          commentsAccess: table.commentsAccess,
          tableCreatedBy: table.createdBy,
        ));

  final CreateTableBaseRepository _repository;

  @override
  void emit(TableCommentsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [_logPostGate]
  ///
  /// Purpose: Print every value `TableCommentsState.canPost` reads, so a
  /// composer that refuses to appear can be diagnosed from the console instead
  /// of by guessing which of the three inputs is wrong.
  ///
  /// `debugPrint` and not `print`: it is stripped from release builds by the
  /// same rule the rest of the app follows, and it rate-limits so a rebuild
  /// storm cannot flood the log and drop the line that mattered.
  ///
  /// ADDED 17/8/2026 while chasing "I am in the access team and it still will
  /// not let me post". The answer that came out of it: the access team has
  /// nothing to do with it — `canPost` on a Private table compares against
  /// `table.created_by`, and every table written before the module started
  /// stamping the signed-in employee has that field null.
  void _logPostGate(String where) {
    final String creator = state.tableCreatedBy ?? '<null>';
    final bool isCreator =
        state.tableCreatedBy != null && state.tableCreatedBy == state.currentEmployeeId;

    debugPrint(
      '[TableComments] $where\n'
      '  tableId          = "${state.tableId}"\n'
      '  currentEmployeeId= "${state.currentEmployeeId}"'
      '${state.currentEmployeeId.isEmpty ? '   <-- EMPTY: nobody is signed in as far as this screen knows' : ''}\n'
      '  tableCreatedBy   = "$creator"'
      '${state.tableCreatedBy == null ? '   <-- NULL: this table was written before created_by was stamped' : ''}\n'
      '  commentsAccess   = ${state.commentsAccess.storageKey}\n'
      '  isCreator        = $isCreator\n'
      '  canPost          = ${state.canPost}',
    );
  }

  /// Function Name: [load]
  ///
  /// Purpose: Read the thread, and the author's own details alongside it.
  ///
  /// The two run TOGETHER rather than one after the other: neither needs the
  /// other's answer, and serialising them would make the screen wait for the
  /// directory before it could draw comments that had already arrived.
  Future<void> load() async {
    _logPostGate('load:start');
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final List<Object?> results = await Future.wait<Object?>(<Future<Object?>>[
      _repository.fetchComments(
        databaseId: state.databaseId,
        tableId: state.tableId,
      ),
      _resolveAuthor(),
    ]);

    final Either<Failure, List<TableComment>> thread =
        results.first as Either<Failure, List<TableComment>>;
    final _Author? author = results.last as _Author?;

    emit(thread.fold(
      (Failure failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.errMessage,
        authorNameEn: author?.nameEn,
        authorNameAr: author?.nameAr,
        authorJobTitleEn: author?.jobTitleEn,
        authorJobTitleAr: author?.jobTitleAr,
        authorPhotoUrl: author?.photoUrl,
      ),
      (List<TableComment> comments) => state.copyWith(
        isLoading: false,
        comments: List<TableComment>.unmodifiable(comments),
        clearErrorMessage: true,
        authorNameEn: author?.nameEn,
        authorNameAr: author?.nameAr,
        authorJobTitleEn: author?.jobTitleEn,
        authorJobTitleAr: author?.jobTitleAr,
        authorPhotoUrl: author?.photoUrl,
      ),
    ));

    // Again AFTER the emit: the directory lookup can only fail loudly here, and
    // seeing the same three values twice tells the reader whether `load`
    // changed any of them (it does not) or whether they arrived wrong.
    debugPrint(
      '[TableComments] author resolved: nameEn="${author?.nameEn ?? '<null>'}" '
      'photo=${author?.photoUrl == null ? 'none' : 'yes'}',
    );
    _logPostGate('load:done');
  }

  /// Function Name: [post]
  ///
  /// Purpose: Write one message and append the server's copy.
  ///
  /// Whitespace-only text is dropped before the write rather than rejected with
  /// a message: the user pressed send on an empty box, which is a slip, not a
  /// mistake worth a dialog.
  Future<bool> post(String text) async {
    final String body = text.trim();
    if (body.isEmpty || state.isPosting || !state.canPost) return false;

    emit(state.copyWith(isPosting: true, clearErrorMessage: true));

    final Either<Failure, TableComment> result = await _repository.addComment(
      databaseId: state.databaseId,
      comment: TableComment(
        id: '',
        tableId: state.tableId,
        authorId: state.currentEmployeeId,
        authorNameEn: state.authorNameEn,
        authorNameAr: state.authorNameAr,
        authorJobTitleEn: state.authorJobTitleEn,
        authorJobTitleAr: state.authorJobTitleAr,
        authorPhotoUrl: state.authorPhotoUrl,
        text: body,
      ),
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isPosting: false,
          errorMessage: failure.errMessage,
        ));
        return false;
      },
      (TableComment saved) {
        // Appended, not re-fetched. The thread is ordered oldest-first and this
        // is the newest, so the end is exactly where the next read would put
        // it — and a refetch would throw away everyone else's scroll position
        // to learn something already known.
        emit(state.copyWith(
          isPosting: false,
          comments: List<TableComment>.unmodifiable(
            <TableComment>[...state.comments, saved],
          ),
          clearErrorMessage: true,
        ));
        return true;
      },
    );
  }

  /// Function Name: [react]
  ///
  /// Purpose: Toggle one thumb on one comment.
  ///
  /// TAPPING THE REACTION YOU ALREADY HAVE CLEARS IT. That is why this takes the
  /// button that was pressed rather than the reaction to apply: the caller
  /// should not have to read the current state to work out that pressing Like
  /// twice means "no reaction", and two call sites doing that arithmetic
  /// differently is exactly how a thumb ends up stuck on.
  Future<void> react(
    TableComment comment,
    TableCommentReaction pressed,
  ) async {
    // Same gate as the composer, and for the same reason: engaging with a
    // thread is what "Shared" grants and "Private" withholds, and a thumb is
    // engagement. The screen also hides the buttons — this is the backstop.
    if (!state.canPost) return;

    final TableCommentReaction? next =
        comment.reactionOf(state.currentEmployeeId) == pressed ? null : pressed;

    // Optimistic: the thumb answers the tap now, and the server's copy replaces
    // this a moment later. `_replace` keys on the comment id, so the local guess
    // is overwritten rather than duplicated.
    _replace(_withLocalReaction(comment, next));

    final Either<Failure, TableComment> result =
        await _repository.setCommentReaction(
      databaseId: state.databaseId,
      tableId: state.tableId,
      commentId: comment.id,
      employeeId: state.currentEmployeeId,
      reaction: next,
    );

    result.fold(
      (Failure failure) {
        // Put the ORIGINAL back, not the guess. Leaving the optimistic thumb up
        // over a write that failed is the one outcome the user cannot detect.
        _replace(comment);
        emit(state.copyWith(errorMessage: failure.errMessage));
      },
      _replace,
    );
  }

  /// Function Name: [delete]
  ///
  /// Purpose: Remove one of the reader's own messages; true when it is gone.
  ///
  /// The screen only offers this on a bubble the reader wrote — see
  /// `TableComment.isMine` — and this re-checks it rather than trusting the
  /// caller, because a repository call that deletes somebody else's comment is
  /// worth one comparison.
  Future<bool> delete(TableComment comment) async {
    if (!comment.isMine(state.currentEmployeeId)) return false;

    final Either<Failure, void> result = await _repository.deleteComment(
      databaseId: state.databaseId,
      tableId: state.tableId,
      commentId: comment.id,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(
          comments: List<TableComment>.unmodifiable(
            state.comments.where((TableComment c) => c.id != comment.id),
          ),
          clearErrorMessage: true,
        ));
        return true;
      },
    );
  }

  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  // ── Internals ────────────────────────────────────────────────────────────

  /// Swaps one comment for a newer copy of itself, in place.
  ///
  /// In place rather than re-sorting: the thread's order is the server's
  /// `created_at` and a reaction does not change it, so moving the bubble would
  /// be a visible jump for no reason.
  void _replace(TableComment updated) {
    emit(state.copyWith(
      comments: List<TableComment>.unmodifiable(<TableComment>[
        for (final TableComment c in state.comments)
          c.id == updated.id ? updated : c,
      ]),
    ));
  }

  /// The comment as it would look with [reaction] applied by the current user —
  /// the local guess the optimistic path draws.
  TableComment _withLocalReaction(
    TableComment comment,
    TableCommentReaction? reaction,
  ) {
    final String me = state.currentEmployeeId;

    List<String> without(List<String> ids) =>
        ids.where((String id) => id != me).toList(growable: false);

    List<String> with_(List<String> ids) =>
        List<String>.unmodifiable(<String>[...without(ids), me]);

    return comment.copyWith(
      likedBy: reaction == TableCommentReaction.like
          ? with_(comment.likedBy)
          : without(comment.likedBy),
      dislikedBy: reaction == TableCommentReaction.dislike
          ? with_(comment.dislikedBy)
          : without(comment.dislikedBy),
    );
  }

  /// The signed-in person's name, title and photo, or null when they cannot be
  /// resolved.
  ///
  /// Swallows everything: `Get.find` throws when the controller was never
  /// registered (a screen opened from a test harness, or before the drawer has
  /// built), and a thread is perfectly usable without it. The caller treats null
  /// as "leave the fields as they are".
  Future<_Author?> _resolveAuthor() async {
    if (state.currentEmployeeId.isEmpty) return null;

    try {
      final MainCoreEmployeeController employees =
          Get.find<MainCoreEmployeeController>();

      final List<EmployeeEntityPro> all =
          (await employees.getAllNewEmployees()) ?? <EmployeeEntityPro>[];

      EmployeeEntityPro? me;
      for (final EmployeeEntityPro employee in all) {
        if (employee.id == state.currentEmployeeId) {
          me = employee;
          break;
        }
      }
      if (me == null) return null;

      String join(String? first, String? last) => <String?>[first, last]
          .whereType<String>()
          .where((String part) => part.isNotEmpty)
          .join(' ');

      return _Author(
        nameEn: join(me.firstName, me.lastName),
        nameAr: join(me.firstNameInArabic, me.lastNameInArabic),
        jobTitleEn: me.title ?? '',
        jobTitleAr: me.titleInArabic ?? '',
        photoUrl: me.photo,
      );
    } catch (_) {
      return null;
    }
  }
}

/// The four author fields copied onto every comment this screen posts. A
/// private carrier rather than a `DatabaseMember`: that entity exists to be
/// WRITTEN into a grant and carries an email and a department id a comment has
/// no business holding.
@immutable
class _Author {
  const _Author({
    required this.nameEn,
    required this.nameAr,
    required this.jobTitleEn,
    required this.jobTitleAr,
    required this.photoUrl,
  });

  final String nameEn;
  final String nameAr;
  final String jobTitleEn;
  final String jobTitleAr;
  final String? photoUrl;
}
