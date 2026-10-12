/// Module: database / db3_create_table / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: database_table_model.dart
/// Purpose: Declares `DatabaseTableModel`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// Firestore <-> entity mapping for a table document. Everything that knows
/// about `Timestamp`, field-name strings and null-shaped documents lives here,
/// so `DatabaseTableEntity` stays plain Dart. Same split as db1's
/// `DatabaseModel`.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';

class DatabaseTableModel extends DatabaseTableEntity {
  const DatabaseTableModel({
    required super.id,
    required super.databaseId,
    required super.nameEn,
    required super.nameAr,
    super.descriptionEn,
    super.descriptionAr,
    super.rowCount,
    super.columns,
    super.commentsAccess,
    super.memberCount,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  /// Field names, in one place — a typo here is a silently empty screen.
  static const String fNameEn = 'name_en';
  static const String fNameAr = 'name_ar';
  static const String fDescriptionEn = 'description_en';
  static const String fDescriptionAr = 'description_ar';
  static const String fRowCount = 'row_count';
  static const String fColumns = 'columns';
  static const String fCommentsAccess = 'comments_access';

  /// Distinct people with access, denormalised from the table's
  /// `Access_Grants` subcollection. ADDED 16/8/2026; absent on tables written
  /// before then, which reads back as 0.
  static const String fMemberCount = 'member_count';
  static const String fCreatedBy = 'created_by';
  static const String fCreatedAt = 'created_at';
  static const String fUpdatedAt = 'updated_at';

  /// Lower-cased name copies used by `tableNameExists`. Firestore cannot do a
  /// case-insensitive equality query, so the normalized form is stored
  /// alongside the display form — the same trick db1 uses for titles.
  static const String fNameEnLower = 'name_en_lower';
  static const String fNameArLower = 'name_ar_lower';

  /// Keys inside one entry of the [fColumns] array.
  static const String fColumnId = 'id';
  static const String fColumnOrder = 'order';
  static const String fColumnName = 'name';
  static const String fColumnType = 'type';

  factory DatabaseTableModel.fromEntity(DatabaseTableEntity entity) =>
      DatabaseTableModel(
        id: entity.id,
        databaseId: entity.databaseId,
        nameEn: entity.nameEn,
        nameAr: entity.nameAr,
        descriptionEn: entity.descriptionEn,
        descriptionAr: entity.descriptionAr,
        rowCount: entity.rowCount,
        columns: entity.columns,
        commentsAccess: entity.commentsAccess,
        memberCount: entity.memberCount,
        createdBy: entity.createdBy,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  /// Reads one document. Every field is treated as possibly absent — a document
  /// written by an older build of the app is a normal case, not an error case.
  ///
  /// [databaseId] is passed in rather than read from the data, because it is
  /// the PARENT's id and lives in the path, not in the document. Storing it
  /// inside as well would be a second copy that can disagree with where the
  /// document actually is.
  factory DatabaseTableModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    required String databaseId,
  }) {
    final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
    final Object? rawCreatedAt = data[fCreatedAt];
    final Object? rawUpdatedAt = data[fUpdatedAt];

    return DatabaseTableModel(
      id: snapshot.id,
      databaseId: databaseId,
      nameEn: (data[fNameEn] as String?) ?? '',
      nameAr: (data[fNameAr] as String?) ?? '',
      descriptionEn: (data[fDescriptionEn] as String?) ?? '',
      descriptionAr: (data[fDescriptionAr] as String?) ?? '',
      rowCount: (data[fRowCount] as num?)?.toInt() ?? 0,
      columns: _columnsFrom(data[fColumns]),
      commentsAccess: TableCommentsAccess.fromStorageKey(
        data[fCommentsAccess] as String?,
      ),
      memberCount: (data[fMemberCount] as num?)?.toInt() ?? 0,
      createdBy: data[fCreatedBy] as String?,
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
    );
  }

  /// Rebuilds the column list from the stored array.
  ///
  /// Sorted by the stored `order` rather than trusting the array's own
  /// sequence: the array is rewritten on every save and a reorder that landed
  /// half-way would otherwise render the columns in whatever order Firestore
  /// happened to return. An entry with no id gets one derived from its index,
  /// so a document written before ids existed still opens.
  static List<TableColumn> _columnsFrom(Object? raw) {
    if (raw is! List<dynamic>) return const <TableColumn>[];

    final List<TableColumn> columns = <TableColumn>[];
    for (int i = 0; i < raw.length; i++) {
      final Object? entry = raw[i];
      if (entry is! Map<String, dynamic>) continue;

      final String id = (entry[fColumnId] as String?) ?? '';
      columns.add(
        TableColumn(
          id: id.isNotEmpty ? id : 'column_$i',
          order: (entry[fColumnOrder] as num?)?.toInt() ?? i,
          name: (entry[fColumnName] as String?) ?? '',
          type: TableColumnType.fromStorageKey(entry[fColumnType] as String?),
        ),
      );
    }

    columns.sort((TableColumn a, TableColumn b) => a.order.compareTo(b.order));
    return List<TableColumn>.unmodifiable(columns);
  }

  /// The columns array as Firestore stores it. Written by both the create and
  /// the update payload, so the two cannot describe a column differently.
  ///
  /// `order` is re-derived from the list position rather than copied off the
  /// entity: after a remove, the surviving columns still carry the orders they
  /// had, and persisting those would leave gaps (0, 1, 3) that the sort in
  /// [_columnsFrom] tolerates but nothing else should have to.
  List<Map<String, dynamic>> columnsToMap() => <Map<String, dynamic>>[
        for (int i = 0; i < columns.length; i++)
          <String, dynamic>{
            fColumnId: columns[i].id,
            fColumnOrder: i,
            fColumnName: columns[i].name,
            fColumnType: columns[i].type.storageKey,
          },
      ];

  /// Payload for a create. [id] is deliberately absent — the document id is the
  /// id, duplicating it inside invites the two drifting apart. So is
  /// [databaseId], which is the path.
  Map<String, dynamic> toCreateMap() => <String, dynamic>{
        fNameEn: nameEn,
        fNameAr: nameAr,
        fNameEnLower: nameEn.toLowerCase(),
        fNameArLower: nameAr.toLowerCase(),
        fDescriptionEn: descriptionEn,
        fDescriptionAr: descriptionAr,
        fRowCount: rowCount,
        fColumns: columnsToMap(),
        fCommentsAccess: commentsAccess.storageKey,
        fMemberCount: memberCount,
        fCreatedBy: createdBy,
        fCreatedAt: FieldValue.serverTimestamp(),
      };

  /// Payload for an edit.
  ///
  /// Built field by field rather than reusing [toCreateMap]. That map carries
  /// `created_at: serverTimestamp()`, `created_by` and `row_count` — using it
  /// for an update would stamp today's date onto the creation of a table made
  /// months ago and resize it, from a card that only ever showed a name, a
  /// description and the columns.
  Map<String, dynamic> toUpdateMap() => <String, dynamic>{
        fNameEn: nameEn,
        fNameAr: nameAr,
        fNameEnLower: nameEn.toLowerCase(),
        fNameArLower: nameAr.toLowerCase(),
        fDescriptionEn: descriptionEn,
        fDescriptionAr: descriptionAr,
        fColumns: columnsToMap(),
        fCommentsAccess: commentsAccess.storageKey,
        fUpdatedAt: FieldValue.serverTimestamp(),
      };
}
