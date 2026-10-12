/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_data_state.dart
/// Purpose: Declares `TableDataState` and `TableDataSnapshot`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026

part of './table_data_cubit.dart';

/// One point on the undo stack.
///
/// Columns AND rows together, never one without the other: removing a column
/// (Figma 7398:15076, the red circle on a heading) changes the headings and
/// orphans a value in every row, so undoing it has to put both sides back. Two
/// stacks would let a user undo the heading and keep the hole.
@immutable
class TableDataSnapshot {
  const TableDataSnapshot({required this.columns, required this.rows});

  final List<TableColumn> columns;
  final List<TableDataRow> rows;
}

@immutable
class TableDataState {
  const TableDataState({
    required this.table,
    this.rows = const <TableDataRow>[],
    this.selectedRowIds = const <String>{},
    this.query = '',
    this.isLoading = false,
    this.isSaving = false,
    this.isDirty = false,
    this.canUndo = false,
    this.canRedo = false,
    this.errorMessage,
  });

  /// The table these rows belong to. Held whole rather than as a bare id
  /// because the COLUMNS are on it, and the editing screen changes them in the
  /// same gesture it changes rows.
  final DatabaseTableEntity table;

  final List<TableDataRow> rows;

  /// Which rows carry a tick in the leading column (Figma 7398:15076).
  ///
  /// Ids and not indices: "Remove Selection" deletes rows, and an index-based
  /// selection would still be pointing at position 2 after the row that WAS at
  /// position 2 is gone.
  final Set<String> selectedRowIds;

  /// The details screen's search box, narrowing which rows are drawn.
  final String query;

  final bool isLoading;
  final bool isSaving;

  /// True once anything has been typed, added or removed since the last save.
  /// Drives whether Save does anything and whether Discard has to ask first.
  final bool isDirty;

  final bool canUndo;
  final bool canRedo;

  final String? errorMessage;

  /// The columns the grid draws headings for.
  ///
  /// UNNAMED COLUMNS ARE DROPPED, the same rule `TableDetailsState.namedColumns`
  /// applies: a table's `columns` array is sized by "Enter Column Number" on the
  /// create card, so a table can hold four entries with two headings typed, and
  /// an unlabelled column is one nothing can ever be filled into.
  ///
  /// The EDITING screen deliberately does not use this — a column being renamed
  /// passes through empty on the way to its new name, and dropping it mid-word
  /// would take the user's cursor with it. That screen reads [table.columns].
  List<TableColumn> get namedColumns => table.columns
      .where((TableColumn column) => column.isNamed)
      .toList(growable: false);

  /// The rows the details grid draws, narrowed by the search box.
  ///
  /// Matches against the CELL TEXT rather than the row number. Once rows carry
  /// values, the values are what somebody is looking for — searching "23 Feb"
  /// should find the four rows dated that, not row 23. The number stays
  /// searchable because a row whose number matches is still a hit.
  List<TableDataRow> get visibleRows {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return rows;

    return rows.where((TableDataRow row) {
      if ('${row.displayNumber}' == needle) return true;
      return row.values.values.any(
        (String value) => value.toLowerCase().contains(needle),
      );
    }).toList(growable: false);
  }

  /// True when the table has no rows at all — what puts `CustomEmptyState` on
  /// screen rather than a grid of headings over nothing.
  bool get isEmpty => rows.isEmpty;

  /// True when a search is on and matched nothing. Told apart from [isEmpty]
  /// because the two are different situations: one table has no data, the other
  /// has data the user has just hidden from themselves.
  bool get isFilteredEmpty => rows.isNotEmpty && visibleRows.isEmpty;

  bool get hasSelection => selectedRowIds.isNotEmpty;

  TableDataState copyWith({
    DatabaseTableEntity? table,
    List<TableDataRow>? rows,
    Set<String>? selectedRowIds,
    String? query,
    bool? isLoading,
    bool? isSaving,
    bool? isDirty,
    bool? canUndo,
    bool? canRedo,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TableDataState(
      table: table ?? this.table,
      rows: rows ?? this.rows,
      selectedRowIds: selectedRowIds ?? this.selectedRowIds,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDirty: isDirty ?? this.isDirty,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
