/// Module: database / db3_create_table / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: table_data_row.dart
/// Purpose: Declares `TableDataRow`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// One filled row of a table — the thing every earlier file in this module
/// deferred to "the Form Builder". Figma 7398:3042 / 3246 draws four of them
/// under the "Table Name" card, and 7398:15076 draws the same four editable.
///
/// NOT `TableRow`. Flutter's material library already exports a widget by that
/// name and this file's importers all import material; the collision would be
/// resolved by whichever import came last, which is not a thing to leave to
/// import order.
///
/// WHY VALUES ARE KEYED BY COLUMN ID AND NOT BY INDEX
/// --------------------------------------------------
/// The Editing screen can remove a column from the middle of the table
/// (7398:15076, the red circle on each heading). Keyed by position, deleting
/// the second of four columns would shift every value in every row one place to
/// the left — the Date column's dates would land under Duration. `TableColumn`
/// already carries a stable [TableColumn.id] for exactly this reason on the
/// create card; this reuses it.
///
/// A column the row has no entry for reads as empty, and an entry whose column
/// no longer exists is ignored on the way out rather than deleted on the way in:
/// undoing a column removal has to bring its values back with it.
///
/// WHY EVERY VALUE IS A STRING
/// ---------------------------
/// A cell's meaning is its COLUMN's `TableColumnType`, not the cell's own — the
/// type is what says `23 Feb 2024` is a date and `75%` is a percentage, and it
/// already owns the keystroke filter, the whole-value check and the example
/// (see `TableColumnType.accepts`). Storing a typed union here would mean the
/// same rule expressed twice, and a column re-typed from Number to General on
/// the editing screen would have to rewrite every row underneath it. Text is
/// what the user typed; the column says how to read it.
///
/// Domain layer: plain Dart, no Firestore types and no Flutter imports.

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';

class TableDataRow {
  const TableDataRow({
    required this.id,
    required this.order,
    this.values = const <String, String>{},
    this.createdAt,
    this.updatedAt,
  });

  /// Stable identity. A Firestore document id once the row has been written,
  /// and a locally-minted one before that — the editing screen adds rows with
  /// "+ Row" and has to key them long before anything is saved.
  final String id;

  /// Zero-based position in the table. Stored rather than derived from the
  /// document order: Firestore returns documents by id unless told otherwise,
  /// and "the order they happen to sort in" is not the order the user typed.
  final int order;

  /// Column id -> the text in that cell. Absent key means an empty cell.
  final Map<String, String> values;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// The row's number as the grid draws it — 1-based, because "row 0" is not
  /// what the "No" column in Figma 7398:15210 shows.
  int get displayNumber => order + 1;

  /// Function Name: [valueFor]
  ///
  /// Purpose: The text in one cell, or empty when the row has nothing there.
  ///
  /// Returns: [String] never null, so callers do not each pick their own
  /// fallback for a cell that was never filled.
  String valueFor(TableColumn column) => values[column.id] ?? '';

  /// True when every cell is blank. The save guard drops these rather than
  /// writing documents that hold nothing: "+ Row" adds an empty row eagerly, so
  /// a user who taps it twice and saves should not get two empty documents.
  bool get isEmpty =>
      values.values.every((String value) => value.trim().isEmpty);

  /// Function Name: [withValue]
  ///
  /// Purpose: This row with one cell replaced.
  ///
  /// Copies the map rather than mutating it: the undo stack on the editing
  /// screen holds previous rows, and a shared map would let a later keystroke
  /// rewrite history.
  ///
  /// Returns: [TableDataRow] a new row.
  TableDataRow withValue(String columnId, String value) {
    final Map<String, String> next = Map<String, String>.of(values);
    next[columnId] = value;
    return copyWith(values: next);
  }

  TableDataRow copyWith({
    String? id,
    int? order,
    Map<String, String>? values,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableDataRow(
      id: id ?? this.id,
      order: order ?? this.order,
      values: values ?? this.values,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Identity is [id] alone — a row whose cells were edited is still the same
  /// row, which is what lets the cubit replace one entry without the grid
  /// rebuilding every field below it and losing focus mid-word.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TableDataRow && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
