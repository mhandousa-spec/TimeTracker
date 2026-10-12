/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_cubit.dart
/// Purpose: Declares `CreateTableCubit`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The draft behind the Creating Table card — Figma 7398:6533 (iPad H) /
/// 7398:6732 (iPad V) — and behind its Editing Table Name variant
/// (7398:6934 / 7398:7121).
///
/// ONE CUBIT FOR BOTH, because they are one card with one field removed. The
/// difference is `state.original`: null while creating, the loaded record while
/// editing. Everything that differs between the two frames reads off that —
/// which breadcrumb, which button label, whether the row/column count fields
/// are drawn, whether [isDirty] means "anything typed" or "different from what
/// was loaded", and whether submit writes or updates.
///
/// A second cubit would be this file with `create` swapped for `update` and the
/// two would drift the first time a validation rule changed.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/repository/create_table_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';

part './create_table_state.dart';

class CreateTableCubit extends Cubit<CreateTableState> {
  /// A blank card for a new table under [databaseId].
  CreateTableCubit.creating({
    required String databaseId,
    this.databaseNameEn = '',
    this.databaseNameAr = '',
    CreateTableBaseRepository? repository,
  })  : _repository = repository ?? CreateTableRepository(),
        super(
          CreateTableState.creating(
            databaseId: databaseId,
            firstColumnId: _mintColumnId(),
          ),
        );

  /// The same card seeded from an existing table.
  CreateTableCubit.editing({
    required DatabaseTableEntity table,
    this.databaseNameEn = '',
    this.databaseNameAr = '',
    CreateTableBaseRepository? repository,
  })  : _repository = repository ?? CreateTableRepository(),
        super(CreateTableState.from(table));

  final CreateTableBaseRepository _repository;

  /// The parent database's bilingual title, carried only so the notifications
  /// this cubit raises can name it (spec §1.7 says "the table {{tableName}}
  /// within {{databaseName}}"). ADDED 17/8/2026.
  ///
  /// Names and not a `DatabaseEntity`: the entity would be a second copy of a
  /// record the page above already owns and renders, and it would go stale the
  /// moment that page edited the title. Two strings cannot.
  ///
  /// Defaulted to empty rather than required so a caller that does not care
  /// about notifications — a test, or the next screen to reuse this cubit —
  /// keeps compiling. An empty pair means the body falls back to the other
  /// language and, if both are empty, prints nothing for the database; the
  /// notification still goes out, because the table name is the part the
  /// recipient needs.
  final String databaseNameEn;
  final String databaseNameAr;

  @override
  void emit(CreateTableState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Ids for the column blocks.
  ///
  /// Monotonic within the process rather than random: the blocks are keyed by
  /// this in the widget tree, and two columns created in the same microsecond
  /// sharing an id would make Flutter reuse one block's controller for both.
  static int _columnSeq = 0;
  static String _mintColumnId() =>
      'col_${DateTime.now().microsecondsSinceEpoch}_${_columnSeq++}';

  // ── Fields ───────────────────────────────────────────────────────────────

  void nameEnChanged(String value) =>
      emit(state.copyWith(nameEn: value, clearNameEnError: true));

  void nameArChanged(String value) =>
      emit(state.copyWith(nameAr: value, clearNameArError: true));

  void descriptionEnChanged(String value) =>
      emit(state.copyWith(descriptionEn: value));

  void descriptionArChanged(String value) =>
      emit(state.copyWith(descriptionAr: value));

  void commentsAccessChanged(TableCommentsAccess value) =>
      emit(state.copyWith(commentsAccess: value));

  /// Function Name: [rowCountChanged]
  ///
  /// Purpose: Take "Enter Row Number" as raw text and flag it when it is out of
  /// range.
  ///
  /// The text is stored either way, including when it is rejected: blanking the
  /// box the user is typing into would make the error impossible to read and
  /// the correction impossible to make.
  void rowCountChanged(String raw, {required String rangeMessage}) {
    final String trimmed = raw.trim();

    if (trimmed.isEmpty) {
      // Empty is zero rows, which is a legitimate table — not an error.
      emit(state.copyWith(rowCountText: raw, clearRowCountError: true));
      return;
    }

    final int? parsed = int.tryParse(trimmed);
    final bool valid = parsed != null &&
        parsed >= CreateTableLimits.minRows &&
        parsed <= CreateTableLimits.maxRows;

    emit(state.copyWith(
      rowCountText: raw,
      rowCountError: valid ? null : rangeMessage,
      clearRowCountError: valid,
    ));
  }

  // ── Columns ──────────────────────────────────────────────────────────────

  /// Function Name: [columnCountRejected]
  ///
  /// Purpose: Record that the typed column number cannot be applied, without
  /// touching the blocks.
  ///
  /// Split from [applyColumnCount] because the page has to decide between the
  /// two: a number that would delete named columns needs a confirmation first,
  /// and only a widget with a BuildContext can ask for one.
  void columnCountRejected(String message) =>
      emit(state.copyWith(columnCountError: message));

  void clearColumnCountError() =>
      emit(state.copyWith(clearColumnCountError: true));

  /// How many named columns would be lost by shrinking to [next].
  ///
  /// Only the TRAILING blocks are dropped — "Enter Column Number" resizes the
  /// list from the end — so this counts from [next] onwards rather than
  /// counting named columns in total.
  int namedColumnsLostBy(int next) {
    if (next >= state.columns.length) return 0;
    return state.columns
        .skip(next)
        .where((TableColumn column) => column.isNamed)
        .length;
  }

  /// Function Name: [applyColumnCount]
  ///
  /// Purpose: Grow or shrink the block list to [next].
  ///
  /// Growing APPENDS fresh columns and leaves the existing ones untouched, so
  /// raising the number from 2 to 4 does not disturb what is already typed.
  /// Shrinking drops from the end for the same reason — the user is answering
  /// "how many", and taking them off the front would move every remaining
  /// heading up one row.
  ///
  /// Out-of-range values are ignored rather than clamped: silently turning a
  /// typed 500 into 50 looks like the box refusing keystrokes. The page shows
  /// [CreateTableStrings.columnCountRange] instead.
  void applyColumnCount(int next) {
    if (next < CreateTableLimits.minColumns ||
        next > CreateTableLimits.maxColumns) {
      return;
    }
    if (next == state.columns.length) {
      emit(state.copyWith(clearColumnCountError: true));
      return;
    }

    final List<TableColumn> columns = <TableColumn>[...state.columns];

    if (next < columns.length) {
      columns.removeRange(next, columns.length);
    } else {
      for (int i = columns.length; i < next; i++) {
        columns.add(TableColumn(id: _mintColumnId(), order: i));
      }
    }

    emit(state.copyWith(
      columns: _reordered(columns),
      clearColumnCountError: true,
    ));
  }

  void columnNameChanged(String columnId, String value) => _replaceColumn(
        columnId,
        (TableColumn column) => column.copyWith(name: value),
      );

  void columnTypeChanged(String columnId, TableColumnType type) =>
      _replaceColumn(
        columnId,
        (TableColumn column) => column.copyWith(type: type),
      );

  /// Function Name: [duplicateColumn]
  ///
  /// Purpose: Insert a copy of one column directly beneath it (the copy glyph
  /// on each block, Figma 7398:6608).
  ///
  /// The NAME is deliberately not copied, and still is as of 17/8/2026 — even
  /// though duplicate headings are now allowed. Two blocks arriving with the
  /// same heading is a copy the user has to undo; an empty one is a copy they
  /// have to fill in, which is what they were going to do anyway. What is worth
  /// duplicating is the Data Type, the part that takes a decision.
  void duplicateColumn(String columnId) {
    final int index = state.columns.indexWhere(
      (TableColumn column) => column.id == columnId,
    );
    if (index < 0) return;
    if (state.columns.length >= CreateTableLimits.maxColumns) return;

    final List<TableColumn> columns = <TableColumn>[...state.columns];
    columns.insert(
      index + 1,
      TableColumn(
        id: _mintColumnId(),
        order: index + 1,
        type: columns[index].type,
      ),
    );

    emit(state.copyWith(
      columns: _reordered(columns),
      clearColumnCountError: true,
    ));
  }

  /// Function Name: [removeColumn]
  ///
  /// Purpose: Drop one column (the red minus on each block, Figma 7398:6613).
  ///
  /// Refuses to remove the last one: a table with no columns is not a table,
  /// and an empty card with no way back to a first block is a dead end. The
  /// page hides the minus at that point, so this is the second line of defence
  /// rather than the message the user sees.
  void removeColumn(String columnId) {
    if (state.columns.length <= CreateTableLimits.minColumns) return;

    final List<TableColumn> columns = state.columns
        .where((TableColumn column) => column.id != columnId)
        .toList();
    if (columns.length == state.columns.length) return;

    emit(state.copyWith(
      columns: _reordered(columns),
      clearColumnCountError: true,
    ));
  }

  /// Re-stamps `order` from the list position.
  ///
  /// Every mutation above goes through this, so `order` can never disagree with
  /// where the block actually sits — which is what the "1st / 2nd / 3rd" labels
  /// and the stored array both read.
  static List<TableColumn> _reordered(List<TableColumn> columns) {
    return List<TableColumn>.unmodifiable(<TableColumn>[
      for (int i = 0; i < columns.length; i++) columns[i].copyWith(order: i),
    ]);
  }

  void _replaceColumn(
    String columnId,
    TableColumn Function(TableColumn column) update,
  ) {
    final int index = state.columns.indexWhere(
      (TableColumn column) => column.id == columnId,
    );
    if (index < 0) return;

    final List<TableColumn> columns = <TableColumn>[...state.columns];
    columns[index] = update(columns[index]);
    emit(state.copyWith(columns: List<TableColumn>.unmodifiable(columns)));
  }

  // ── Messages ─────────────────────────────────────────────────────────────

  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  /// Puts every field back — "Discard" on the create card, "Discard Changes" on
  /// the edit one.
  ///
  /// Resets rather than pops, because the page also has to push these values
  /// back into its `TextEditingController`s; a cubit that only popped would
  /// leave the boxes showing the edits it had just thrown away.
  void discard() {
    final DatabaseTableEntity? loaded = state.original;
    emit(
      loaded != null
          ? CreateTableState.from(loaded)
          : CreateTableState.creating(
              databaseId: state.databaseId,
              firstColumnId: _mintColumnId(),
            ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  /// Function Name: [submit]
  ///
  /// Purpose: Validate the names, check the name is free inside this database,
  /// and write.
  ///
  /// The localized copy is passed in because a cubit has no BuildContext and
  /// the domain layer must not acquire one — the same arrangement db1 and db2
  /// use.
  ///
  /// There are no COLUMN guards left to re-run. The page used to check for an
  /// unnamed block, a heading that did not match its Data Type, and two blocks
  /// sharing a heading; all three were dropped on 17/8/2026 — see
  /// `TableColumnBlock._nameField`. Column headings are saved as typed.
  ///
  /// The TABLE name is still validated here, and ORDER MATTERS for it: local
  /// checks first (free, no network), then the duplicate-name query, then the
  /// write. Running the duplicate check on an empty name would spend a
  /// Firestore read to be told that "" is available.
  Future<void> submit({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
    String? createdBy,
  }) async {
    final String nameEn = state.nameEn.trim();
    final String nameAr = state.nameAr.trim();

    final String? enError = _nameError(
      nameEn,
      requiredMessage: requiredEnMessage,
      tooShortMessage: tooShortMessage,
    );
    final String? arError = _nameError(
      nameAr,
      requiredMessage: requiredArMessage,
      tooShortMessage: tooShortMessage,
    );

    if (enError != null || arError != null) {
      emit(state.copyWith(
        submitted: true,
        status: CreateTableStatus.initial,
        nameEnError: enError,
        nameArError: arError,
        clearNameEnError: enError == null,
        clearNameArError: arError == null,
      ));
      return;
    }

    emit(state.copyWith(
      submitted: true,
      status: CreateTableStatus.submitting,
      clearErrorMessage: true,
      clearNameEnError: true,
      clearNameArError: true,
    ));

    final DatabaseTableEntity? loaded = state.original;

    // Only worth asking when a name actually changed — or when there is nothing
    // to compare against because this is a create. An edit that touched only
    // the description would otherwise pay for two queries to confirm that the
    // table still has the name it already had.
    final bool nameChanged = loaded == null ||
        nameEn.toLowerCase() != loaded.nameEn.trim().toLowerCase() ||
        nameAr.toLowerCase() != loaded.nameAr.trim().toLowerCase();

    if (nameChanged) {
      final Either<Failure, bool> taken = await _repository.tableNameExists(
        databaseId: state.databaseId,
        nameEn: nameEn,
        nameAr: nameAr,
        excludeId: loaded?.id ?? '',
      );

      final bool rejected = taken.fold(
        (Failure failure) {
          emit(state.copyWith(
            status: CreateTableStatus.failure,
            errorMessage: failure.errMessage,
          ));
          return true;
        },
        (bool exists) {
          if (!exists) return false;
          emit(state.copyWith(
            status: CreateTableStatus.failure,
            errorMessage: duplicateMessage,
          ));
          return true;
        },
      );

      if (rejected) return;
    }

    final DatabaseTableEntity draft = (loaded ??
            DatabaseTableEntity(
              id: '',
              databaseId: state.databaseId,
              nameEn: nameEn,
              nameAr: nameAr,
            ))
        .copyWith(
      nameEn: nameEn,
      nameAr: nameAr,
      descriptionEn: state.descriptionEn.trim(),
      descriptionAr: state.descriptionAr.trim(),
      columns: state.columns,
      commentsAccess: state.commentsAccess,
      // Only a create sets these two: the row count is not editable from the
      // edit card, and re-stamping `created_by` on an edit would credit the
      // table to whoever last renamed it.
      rowCount: loaded == null ? state.rowCount : loaded.rowCount,
      createdBy: loaded == null ? createdBy : loaded.createdBy,
    );

    final Either<Failure, DatabaseTableEntity> result = loaded == null
        ? await _repository.createTable(draft)
        : await _repository.updateTable(draft);

    final CreateTableState next = result.fold(
      (Failure failure) => state.copyWith(
        status: CreateTableStatus.failure,
        errorMessage: failure.errMessage,
      ),
      // Seeded from what came BACK, not from what was sent: the server resolved
      // `created_at` / `updated_at`, and the next Discard has to return to the
      // saved state rather than to the pre-save one.
      (DatabaseTableEntity saved) => CreateTableState.from(saved).copyWith(
        status: CreateTableStatus.success,
        savedTable: saved,
      ),
    );

    emit(next);

    if (next.status == CreateTableStatus.success) {
      _notify(saved: next.savedTable, before: loaded);
    }
  }

  /// Function Name: [_notify]
  ///
  /// Purpose: Raise the §1.7 events this save earned — after the emit, and
  /// never awaited. See `DatabaseNotificationDispatcher`.
  ///
  /// A CREATE is one event. An EDIT is up to three, because the card edits three
  /// unrelated things behind one button and the spec has a separate event for
  /// each: the details (name / description / comments access), the columns added,
  /// and the structure otherwise changing. Sending only "Table Details Updated"
  /// for a save that dropped two columns would understate it to exactly the
  /// people whose saved views are about to break.
  void _notify({
    required DatabaseTableEntity? saved,
    required DatabaseTableEntity? before,
  }) {
    if (saved == null) return;

    if (before == null) {
      DatabaseNotificationDispatcher.tableCreated(
        databaseId: saved.databaseId,
        databaseNameEn: databaseNameEn,
        databaseNameAr: databaseNameAr,
        tableNameEn: saved.nameEn,
        tableNameAr: saved.nameAr,
      );
      return;
    }

    final bool detailsChanged = saved.nameEn != before.nameEn ||
        saved.nameAr != before.nameAr ||
        saved.descriptionEn != before.descriptionEn ||
        saved.descriptionAr != before.descriptionAr ||
        saved.commentsAccess != before.commentsAccess;

    // Columns are identified by `TableColumn.id`, so a column that was RENAMED
    // is the same column with different details — it belongs to
    // `structureChanged`, not to `addedColumnNames`, and announcing it as new
    // would tell people to look for a field that has been there all along.
    final Set<String> beforeIds = before.columns
        .map((TableColumn c) => c.id)
        .toSet();

    final List<TableColumn> added = saved.columns
        .where((TableColumn c) => !beforeIds.contains(c.id))
        .toList(growable: false);

    final Set<String> savedIds =
        saved.columns.map((TableColumn c) => c.id).toSet();
    final bool removed = beforeIds.any((String id) => !savedIds.contains(id));

    // A retype or a reorder of columns that already existed. Both change how
    // the stored data reads, which is what `tableStructureUpdated` is about.
    bool reshaped = false;
    for (final TableColumn column in saved.columns) {
      for (final TableColumn was in before.columns) {
        if (was.id != column.id) continue;
        if (was.type != column.type ||
            was.order != column.order ||
            was.name != column.name) {
          reshaped = true;
        }
        break;
      }
      if (reshaped) break;
    }

    DatabaseNotificationDispatcher.tableSaved(
      databaseId: saved.databaseId,
      databaseNameEn: databaseNameEn,
      databaseNameAr: databaseNameAr,
      tableNameEn: saved.nameEn,
      tableNameAr: saved.nameAr,
      detailsChanged: detailsChanged,
      structureChanged: removed || reshaped,
      addedColumnNames:
          added.map((TableColumn c) => c.name).toList(growable: false),
    );
  }

  /// Both names use the same two rules, so they share one check — a second copy
  /// is how the English side ends up enforcing a limit the Arabic side does not.
  ///
  /// The limits are db1's `CreateDatabaseLimits`, imported rather than restated:
  /// a table name and a database title are the same kind of value.
  String? _nameError(
    String value, {
    required String requiredMessage,
    required String tooShortMessage,
  }) {
    if (value.isEmpty) return requiredMessage;
    if (value.length < CreateDatabaseLimits.titleMinLength) {
      return tooShortMessage;
    }
    return null;
  }
}
