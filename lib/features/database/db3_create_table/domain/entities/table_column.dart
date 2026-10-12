/// Module: database / db3_create_table / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: table_column.dart
/// Purpose: Declares `TableColumn`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// One "1st Column" block of the Creating Table card — Figma 7398:6667 /
/// 7398:6641 / 7398:6615 / 7398:6589 inside 7398:6533, and their 616-wide
/// portrait twins inside 7398:6732.
///
/// A block carries exactly two editable values: a Data Type and a Column Name.
/// The ordinal ("1st", "2nd") is NOT stored — it is [order] rendered as a word
/// by the page, so inserting or reordering a column cannot leave a block
/// labelled "3rd Column" sitting second in the list.
///
/// Domain layer: plain Dart, no Firestore types and no Flutter imports.

import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';

class TableColumn {
  const TableColumn({
    required this.id,
    required this.order,
    this.name = '',
    this.type = TableColumnType.general,
  });

  /// Stable identity for the list. NOT a Firestore document id — columns are
  /// an array inside the table document, not a subcollection.
  ///
  /// It exists because the blocks are editable and reorderable: keyed only by
  /// index, removing the second of four blocks would make Flutter reuse the
  /// third block's `TextEditingController` for the row that used to be fourth,
  /// and the user would watch the names shuffle.
  final String id;

  /// Zero-based position. The page turns this into "1st Column" / "الحقل الأول".
  final int order;

  /// What the column is called. The Figma places a single field here, not an
  /// EN/AR pair — unlike the table's own name, a column heading is written once.
  final String name;

  final TableColumnType type;

  /// True once the user has given the column a name. The submit guard uses this
  /// rather than checking `name.isEmpty` at three call sites.
  bool get isNamed => name.trim().isNotEmpty;

  TableColumn copyWith({
    String? id,
    int? order,
    String? name,
    TableColumnType? type,
  }) {
    return TableColumn(
      id: id ?? this.id,
      order: order ?? this.order,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  /// Identity is [id] alone, so a column that has been renamed is still the
  /// same column — which is what lets the cubit replace one entry in the list
  /// without rebuilding every block below it.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TableColumn && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
