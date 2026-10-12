/// Module: database / db3_create_table / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: table_data_row_model.dart
/// Purpose: Declares `TableDataRowModel`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// Firestore <-> entity mapping for one ROW document (Figma 7398:3042 /
/// 15076). Everything that knows about `Timestamp`, field-name strings and
/// half-written documents lives here so `TableDataRow` stays plain Dart — the
/// same split `DatabaseTableModel` and `TableCommentModel` make.
///
/// WHY ROWS ARE A SUBCOLLECTION AND COLUMNS ARE AN ARRAY
/// ----------------------------------------------------
/// `DatabaseTableEntity.columns` is an array inside the table document because
/// a table is opened whole and never one column at a time. Rows are the other
/// case: `CreateTableLimits.maxRows` is 5000, a document is capped at 1MB, and
/// the Preview screen (7398:15210) pages through them. One document per row is
/// also what lets a single edited cell be written without resending the whole
/// table.
///
///     …/Databases/{databaseId}/Tables/{tableId}/Rows/{rowId}
///
/// EVERY CELL IS WRITTEN AS A STRING
/// ---------------------------------
/// See `TableDataRow`'s header for why. The consequence here is that
/// [_valuesFrom] coerces whatever it finds — a row written by an importer that
/// put a real number in the map still reads back as text rather than throwing.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';

class TableDataRowModel extends TableDataRow {
  const TableDataRowModel({
    required super.id,
    required super.order,
    super.values,
    super.createdAt,
    super.updatedAt,
  });

  /// Field names, in one place — a typo here is a silently empty cell.
  static const String fOrder = 'order';
  static const String fValues = 'values';
  static const String fCreatedAt = 'created_at';
  static const String fUpdatedAt = 'updated_at';

  factory TableDataRowModel.fromEntity(TableDataRow entity) =>
      TableDataRowModel(
        id: entity.id,
        order: entity.order,
        values: entity.values,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  /// Reads one row document.
  ///
  /// [fallbackOrder] is the document's position in the query result and is used
  /// only when `order` is missing — a row written before this field existed, or
  /// by an import that did not set it, still lands somewhere sensible instead of
  /// collapsing every such row onto 0.
  factory TableDataRowModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    int fallbackOrder = 0,
  }) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    return TableDataRowModel(
      id: doc.id,
      order: _intFrom(data[fOrder]) ?? fallbackOrder,
      values: _valuesFrom(data[fValues]),
      createdAt: _dateFrom(data[fCreatedAt]),
      updatedAt: _dateFrom(data[fUpdatedAt]),
    );
  }

  /// Function Name: [_valuesFrom]
  ///
  /// Purpose: Coerce the stored cell map into `Map<String, String>`.
  ///
  /// Anything that is not a map reads as no cells rather than throwing: one
  /// malformed row must not take the whole table's screen down with it.
  ///
  /// Returns: [Map] column id -> text.
  static Map<String, String> _valuesFrom(Object? raw) {
    if (raw is! Map) return const <String, String>{};

    final Map<String, String> out = <String, String>{};
    raw.forEach((Object? key, Object? value) {
      if (key is! String || value == null) return;
      out[key] = value is String ? value : '$value';
    });
    return out;
  }

  static int? _intFrom(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static DateTime? _dateFrom(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }

  /// The payload for a brand-new row. `created_at` is the server's clock, not
  /// the device's, for the same reason every other create in this module uses
  /// it: two tablets with different times must not disagree about which row
  /// came first.
  Map<String, dynamic> toCreateMap() => <String, dynamic>{
        fOrder: order,
        fValues: values,
        fCreatedAt: FieldValue.serverTimestamp(),
        fUpdatedAt: FieldValue.serverTimestamp(),
      };

  /// The payload for an edited row. `created_at` is deliberately absent — an
  /// edit must not restamp a row that has been there for months.
  Map<String, dynamic> toUpdateMap() => <String, dynamic>{
        fOrder: order,
        fValues: values,
        fUpdatedAt: FieldValue.serverTimestamp(),
      };
}
