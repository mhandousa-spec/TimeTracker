/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_data_cubit.dart
/// Purpose: Declares `TableDataCubit`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// The Form Builder's state — the section every earlier file in this module
/// deferred to. It backs three screens, which is why it is one cubit and not
/// three:
///
///   Table Name Details   the filled card    (Figma 7398:3042 / 3246)
///   Editing Table Name   the editable grid  (Figma 7398:15076)
///   Preview              the rendered table (Figma 7398:15210)
///
/// All three read the same rows, and the editing screen hands its result to the
/// details screen the moment it saves. Splitting them would mean the same
/// documents had three owners and the details screen would show yesterday's
/// values until it was reopened.
///
/// WHY ROWS ARE SEEDED WHEN THE SUBCOLLECTION IS EMPTY
/// ---------------------------------------------------
/// A table is created with "Enter Row Number" — `row_count` — and no row
/// documents at all; nothing has been filled in yet. The Figma still draws that
/// table as four labelled, empty rows rather than as blank space, because those
/// rows are what the user asked for and what they are about to type into.
/// [_seed] materialises them locally. They are NOT written until Save, so a
/// table that is opened and closed again costs no writes.
///
/// UNDO IS A STACK OF WHOLE SNAPSHOTS
/// ----------------------------------
/// Undo/Redo (7398:15076) covers typing, adding and removing rows, and adding
/// and removing columns. A command log would need an inverse for each of those
/// and would have to keep the inverses correct as the screen grows; a snapshot
/// of the columns and rows is correct by construction. A table is bounded at
/// `maxRows` * `maxColumns` short strings, and the stack is capped at
/// [_historyLimit], so the memory is bounded too.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/repository/create_table_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';

part './table_data_state.dart';

class TableDataCubit extends Cubit<TableDataState> {
  TableDataCubit({
    required DatabaseTableEntity table,
    CreateTableBaseRepository? repository,
  })  : _repository = repository ?? CreateTableRepository(),
        super(TableDataState(table: table));

  final CreateTableBaseRepository _repository;

  /// Snapshots older than the current one, newest last. Undo pops from here.
  final List<TableDataSnapshot> _past = <TableDataSnapshot>[];

  /// Snapshots undone away, newest last. Redo pops from here, and any fresh
  /// edit clears it — the branch the user did not take is gone the moment they
  /// take a different one, which is what every editor does.
  final List<TableDataSnapshot> _future = <TableDataSnapshot>[];

  /// How far back Undo reaches. Deep enough that no realistic editing session
  /// hits it, bounded so a long one cannot grow without limit.
  static const int _historyLimit = 50;

  /// Counter behind the locally-minted ids of rows added on this screen.
  ///
  /// Prefixed and counted rather than random: the id has to be unique within
  /// this session and recognisable as "not written yet" — the data source mints
  /// the real document id on save, keyed off whether the id is already in the
  /// subcollection.
  int _localRowSeq = 0;

  @override
  void emit(TableDataState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  /// Function Name: [load]
  ///
  /// Purpose: Read the table's rows, seeding empty ones when it has none.
  ///
  /// A failure is reported and the screen still seeds, so a network that is down
  /// leaves the user with the grid they expected and a message, rather than an
  /// empty screen that looks like the table lost its data.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Either<Failure, List<TableDataRow>> result =
        await _repository.fetchRows(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
    );

    result.fold(
      (Failure failure) => emit(state.copyWith(
        isLoading: false,
        rows: _seed(),
        errorMessage: failure.errMessage,
      )),
      (List<TableDataRow> rows) => emit(state.copyWith(
        isLoading: false,
        rows: rows.isEmpty ? _seed() : rows,
        clearErrorMessage: true,
      )),
    );
  }

  /// The empty rows a table starts life with — `row_count` of them, in order.
  ///
  /// Local ids, because none of these exist in Firestore yet.
  List<TableDataRow> _seed() => <TableDataRow>[
        for (int i = 0; i < state.table.rowCount; i++) _blankRow(i),
      ];

  TableDataRow _blankRow(int order) =>
      TableDataRow(id: 'local-${_localRowSeq++}', order: order);

  // ── Reading ──────────────────────────────────────────────────────────────

  /// Narrows the grid. In memory — the rows are already here, and re-reading a
  /// subcollection on every keystroke is a read per character typed.
  void searchChanged(String value) => emit(state.copyWith(query: value));

  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  // ── Editing cells ────────────────────────────────────────────────────────

  /// Function Name: [cellChanged]
  ///
  /// Purpose: Put [value] in one cell.
  ///
  /// NOT VALIDATED HERE. `TableColumnType.accepts` is the whole-value check and
  /// it only makes sense on a finished value — running it per keystroke would
  /// reject `2` on the way to `25/12/2026`. The field installs the type's
  /// keystroke filter as the user types and [invalidCells] is what the save
  /// guard reads.
  ///
  /// One snapshot per cell, not per keystroke: undoing a cell should restore the
  /// value that was there before the user started typing in it, not walk back
  /// through the word letter by letter.
  void cellChanged({
    required String rowId,
    required String columnId,
    required String value,
  }) {
    final int index = state.rows.indexWhere((TableDataRow r) => r.id == rowId);
    if (index < 0) return;

    final TableDataRow row = state.rows[index];
    if ((row.values[columnId] ?? '') == value) return;

    _pushHistoryIfNewCell(rowId: rowId, columnId: columnId);

    final List<TableDataRow> next = List<TableDataRow>.of(state.rows);
    next[index] = row.withValue(columnId, value);

    emit(state.copyWith(rows: next, isDirty: true, canUndo: true));
  }

  /// The cell the last snapshot was taken for, so a run of keystrokes in one box
  /// produces one undo step.
  String? _lastEditedCell;

  void _pushHistoryIfNewCell({
    required String rowId,
    required String columnId,
  }) {
    final String key = '$rowId/$columnId';
    if (_lastEditedCell == key) return;
    _lastEditedCell = key;
    _pushHistory();
  }

  // ── Editing rows ─────────────────────────────────────────────────────────

  /// "+ Row" (Figma 7398:15076). Appends one empty row at the end.
  void addRow() {
    _pushHistory();
    emit(state.copyWith(
      rows: <TableDataRow>[...state.rows, _blankRow(state.rows.length)],
      isDirty: true,
      canUndo: true,
    ));
  }

  /// The tick in the leading column.
  void toggleRowSelected(String rowId) {
    final Set<String> next = Set<String>.of(state.selectedRowIds);
    if (!next.remove(rowId)) next.add(rowId);
    emit(state.copyWith(selectedRowIds: next));
  }

  /// "Remove Selection" (Figma 7398:15076). Drops every ticked row.
  ///
  /// Silent when nothing is ticked rather than clearing the whole table — a
  /// button that deletes everything when you have selected nothing is the worst
  /// possible reading of "remove selection".
  void removeSelection() {
    if (!state.hasSelection) return;
    _pushHistory();

    final List<TableDataRow> next = state.rows
        .where((TableDataRow row) => !state.selectedRowIds.contains(row.id))
        .toList(growable: false);

    emit(state.copyWith(
      rows: next,
      selectedRowIds: const <String>{},
      isDirty: true,
      canUndo: true,
    ));
  }

  // ── Editing columns ──────────────────────────────────────────────────────

  /// "+ Column" (Figma 7398:15076). Appends one unnamed General column.
  ///
  /// Unnamed on purpose: the heading is a text field on this screen and the
  /// user is about to type in it. A placeholder name like "Column 5" would have
  /// to be told apart from a real one at save time.
  void addColumn() {
    _pushHistory();

    final List<TableColumn> next = <TableColumn>[
      ...state.table.columns,
      TableColumn(
        id: 'local-col-${_localRowSeq++}',
        order: state.table.columns.length,
      ),
    ];

    emit(state.copyWith(
      table: state.table.copyWith(columns: next),
      isDirty: true,
      canUndo: true,
    ));
  }

  void columnNameChanged({required String columnId, required String name}) =>
      _mutateColumn(columnId, (TableColumn c) => c.copyWith(name: name));

  /// The "Data Type" dropdown on a heading.
  ///
  /// The values already in that column are NOT rewritten or cleared. Retyping a
  /// column is how a user fixes a column they typed wrong, and throwing away
  /// what is in it would punish them for the correction — the cells that no
  /// longer fit are reported by [invalidCells] and shown in place instead.
  void columnTypeChanged({
    required String columnId,
    required TableColumnType type,
  }) =>
      _mutateColumn(columnId, (TableColumn c) => c.copyWith(type: type));

  /// The red circle on a heading. Removes the column and every value under it.
  ///
  /// The VALUES are left in each row's map rather than stripped out, so Undo
  /// brings the column back with its data. `TableDataRow.valueFor` only ever
  /// reads by a live column's id, so the orphans are invisible until then; the
  /// save path is where they are finally dropped.
  void removeColumn(String columnId) {
    _pushHistory();

    final List<TableColumn> next = <TableColumn>[
      for (final TableColumn column in state.table.columns)
        if (column.id != columnId) column,
    ];

    emit(state.copyWith(
      table: state.table.copyWith(columns: _reordered(next)),
      isDirty: true,
      canUndo: true,
    ));
  }

  void _mutateColumn(String columnId, TableColumn Function(TableColumn) apply) {
    final int index = state.table.columns
        .indexWhere((TableColumn c) => c.id == columnId);
    if (index < 0) return;

    _pushHistoryIfNewCell(rowId: 'heading', columnId: columnId);

    final List<TableColumn> next = List<TableColumn>.of(state.table.columns);
    next[index] = apply(next[index]);

    emit(state.copyWith(
      table: state.table.copyWith(columns: next),
      isDirty: true,
      canUndo: true,
    ));
  }

  /// `order` rewritten from list position, so removing the second of four
  /// columns does not leave the remaining three numbered 0, 2, 3.
  List<TableColumn> _reordered(List<TableColumn> columns) => <TableColumn>[
        for (int i = 0; i < columns.length; i++) columns[i].copyWith(order: i),
      ];

  // ── Importing ────────────────────────────────────────────────────────────

  /// Function Name: [applyImportedRows]
  ///
  /// Purpose: Fold rows read from a file into the table (Figma 7398:4041).
  ///
  /// [overwrite] true replaces every row; false appends after the ones already
  /// there — the two values of "Type Of Import".
  ///
  /// NOT WRITTEN HERE. The rows land in state exactly as if they had been
  /// typed, which means the user sees what they imported before it is stored,
  /// Undo takes it back, and Save is still the one place rows reach Firestore.
  /// An import that wrote straight through would be the only action on this
  /// screen the user could not reconsider.
  ///
  /// The imported ids are re-minted so a file imported twice cannot produce two
  /// rows claiming the same id — the parser numbers them from zero every time.
  void applyImportedRows(
    List<TableDataRow> imported, {
    required bool overwrite,
  }) {
    if (imported.isEmpty) return;
    _pushHistory();

    final List<TableDataRow> incoming = <TableDataRow>[
      for (final TableDataRow row in imported)
        row.copyWith(id: 'local-${_localRowSeq++}'),
    ];

    // Overwrite drops the EXISTING rows, not the empty ones among them: a
    // table seeded with four blank rows and then overwritten should hold the
    // file's rows and nothing else.
    final List<TableDataRow> next = overwrite
        ? incoming
        : <TableDataRow>[
            // Appending after blank seeded rows would leave gaps in the middle
            // of the table, so the blanks go: they were placeholders for data
            // that has now arrived.
            ...state.rows.where((TableDataRow row) => !row.isEmpty),
            ...incoming,
          ];

    emit(state.copyWith(
      rows: <TableDataRow>[
        for (int i = 0; i < next.length; i++) next[i].copyWith(order: i),
      ],
      selectedRowIds: const <String>{},
      isDirty: true,
      canUndo: true,
    ));
  }

  // ── Undo / Redo ──────────────────────────────────────────────────────────

  void _pushHistory() {
    _past.add(TableDataSnapshot(columns: state.table.columns, rows: state.rows));
    if (_past.length > _historyLimit) _past.removeAt(0);
    // Any new edit abandons the redo branch.
    _future.clear();
  }

  void undo() {
    if (_past.isEmpty) return;

    _future.add(
      TableDataSnapshot(columns: state.table.columns, rows: state.rows),
    );
    final TableDataSnapshot previous = _past.removeLast();
    _lastEditedCell = null;

    emit(state.copyWith(
      table: state.table.copyWith(columns: previous.columns),
      rows: previous.rows,
      isDirty: true,
      canUndo: _past.isNotEmpty,
      canRedo: true,
    ));
  }

  void redo() {
    if (_future.isEmpty) return;

    _past.add(TableDataSnapshot(columns: state.table.columns, rows: state.rows));
    final TableDataSnapshot next = _future.removeLast();
    _lastEditedCell = null;

    emit(state.copyWith(
      table: state.table.copyWith(columns: next.columns),
      rows: next.rows,
      isDirty: true,
      canUndo: true,
      canRedo: _future.isNotEmpty,
    ));
  }

  // ── Saving ───────────────────────────────────────────────────────────────

  /// Every cell whose text does not fit its column's type, as `rowId/columnId`.
  ///
  /// Computed rather than stored: it is a function of the rows and the columns,
  /// and a stored copy is one that can be stale for exactly as long as it takes
  /// somebody to forget to recompute it.
  Set<String> get invalidCells {
    final Set<String> out = <String>{};
    for (final TableDataRow row in state.rows) {
      for (final TableColumn column in state.table.columns) {
        if (!column.isNamed) continue;
        if (!column.type.accepts(row.valueFor(column))) {
          out.add('${row.id}/${column.id}');
        }
      }
    }
    return out;
  }

  /// Function Name: [save]
  ///
  /// Purpose: Write the rows back; true when they are stored.
  ///
  /// EMPTY ROWS ARE DROPPED and orphaned values with them. "+ Row" adds a row
  /// eagerly, so a user who taps it three times and fills one should get one
  /// document, not three. A table whose rows are ALL empty still saves — that is
  /// how a user clears a table — and the row_count the repository writes then
  /// says zero, which is the truth.
  ///
  /// Unnamed columns are dropped from the write for the same reason the details
  /// grid does not draw them: nothing can be filled into a column with no
  /// heading, so persisting one only makes a heading that has to be explained
  /// on every screen that reads it.
  Future<bool> save() async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true, clearErrorMessage: true));

    final List<TableColumn> namedColumns = _reordered(state.table.columns
        .where((TableColumn c) => c.isNamed)
        .toList(growable: false));

    final Set<String> liveColumnIds =
        namedColumns.map((TableColumn c) => c.id).toSet();

    final List<TableDataRow> payload = <TableDataRow>[
      for (final TableDataRow row in state.rows)
        if (!row.isEmpty)
          row.copyWith(
            values: <String, String>{
              for (final MapEntry<String, String> entry in row.values.entries)
                if (liveColumnIds.contains(entry.key)) entry.key: entry.value,
            },
          ),
    ];

    final Either<Failure, void> rowsWritten = await _repository.replaceRows(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
      rows: payload,
    );

    final Failure? rowsFailure = rowsWritten.fold(
      (Failure failure) => failure,
      (_) => null,
    );
    if (rowsFailure != null) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: rowsFailure.errMessage,
      ));
      return false;
    }

    // The COLUMNS ride along, because the editing screen changes both in one
    // gesture. Written after the rows and not before: a column removed from the
    // table document while its values were still in the subcollection would
    // leave the details grid reading cells it has no heading for.
    final DatabaseTableEntity updated =
        state.table.copyWith(columns: namedColumns, rowCount: payload.length);

    final Either<Failure, DatabaseTableEntity> tableWritten =
        await _repository.updateTable(updated);

    return tableWritten.fold(
      (Failure failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (DatabaseTableEntity saved) {
        _past.clear();
        _future.clear();
        _lastEditedCell = null;
        emit(state.copyWith(
          table: saved,
          rows: payload,
          isSaving: false,
          isDirty: false,
          canUndo: false,
          canRedo: false,
          selectedRowIds: const <String>{},
          clearErrorMessage: true,
        ));
        return true;
      },
    );
  }
}
