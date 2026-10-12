/// Module: database / db3_create_table / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_table_entity.dart
/// Purpose: Declares `DatabaseTableEntity`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The bilingual table record the Creating Table card produces — Figma
/// 7398:6533 (iPad H 1024) / 7398:6732 (iPad V 768), reached from the
/// "+ Table" button on the database details screen.
///
/// A table BELONGS TO a database: [databaseId] is the parent document's id and
/// the record lives in that document's `Tables` subcollection. It is carried on
/// the entity rather than only in the path so a table handed around the UI —
/// to the list, to the edit screen — always knows which database it came from.
///
/// Domain layer: plain Dart, no Firestore types and no Flutter imports. The
/// data layer's `DatabaseTableModel` is what knows about `Timestamp` and maps.

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';

class DatabaseTableEntity {
  const DatabaseTableEntity({
    required this.id,
    required this.databaseId,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn = '',
    this.descriptionAr = '',
    this.rowCount = 0,
    this.columns = const <TableColumn>[],
    this.commentsAccess = TableCommentsAccess.private,
    this.memberCount = 0,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Firestore document id inside the parent's `Tables` subcollection. Empty
  /// before the record is written.
  final String id;

  /// Id of the database document this table hangs off.
  final String databaseId;

  /// Both names are captured on one card ("Table Name" / "اسم الجدول"), so both
  /// are required — this is a bilingual record, not a localized view of one
  /// value. Same rule as `DatabaseEntity.titleEn` / `titleAr`.
  final String nameEn;
  final String nameAr;

  final String descriptionEn;
  final String descriptionAr;

  /// "Enter Row Number" (Figma 7398:6573). How many empty rows the table starts
  /// with. The rows themselves are the Form Builder's concern — the next Figma
  /// section — so only the count is stored here.
  final int rowCount;

  /// "Enter Column Number" drives the LENGTH of this list; the blocks below it
  /// carry the values. Stored as an array inside the table document rather than
  /// a subcollection: a table is opened whole, never one column at a time, so a
  /// subcollection would cost an extra read per table for nothing.
  final List<TableColumn> columns;

  /// Who may see and reply to comments left on this table's rows
  /// (Figma 7398:6702). Read by the Comments screen, which is a later section.
  final TableCommentsAccess commentsAccess;

  /// Distinct people with access to this table, denormalised from its
  /// `Access_Grants` subcollection so the table list never has to read it.
  /// ADDED 16/8/2026 with the Editing Table Access screen; 0 on every table
  /// written before then, and on any table nobody has been granted yet.
  final int memberCount;

  /// Employee id of the creator.
  final String? createdBy;

  final DateTime? createdAt;

  /// When the table was last edited. Null until the first save from the
  /// Editing Table Name card, which is why the list renders the creation date
  /// when it is absent rather than an empty cell.
  final DateTime? updatedAt;

  /// Derived, never stored: the document already holds the columns, and a
  /// second field saying how many there are is one more thing that can be wrong.
  int get columnCount => columns.length;

  /// Name for the current UI locale, with a fallback so a record missing one
  /// side still renders something rather than an empty row.
  String localizedName({required bool isArabic}) {
    if (isArabic) return nameAr.isNotEmpty ? nameAr : nameEn;
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  String localizedDescription({required bool isArabic}) {
    if (isArabic) {
      return descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;
    }
    return descriptionEn.isNotEmpty ? descriptionEn : descriptionAr;
  }

  DatabaseTableEntity copyWith({
    String? id,
    String? databaseId,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    int? rowCount,
    List<TableColumn>? columns,
    TableCommentsAccess? commentsAccess,
    int? memberCount,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DatabaseTableEntity(
      id: id ?? this.id,
      databaseId: databaseId ?? this.databaseId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      rowCount: rowCount ?? this.rowCount,
      columns: columns ?? this.columns,
      commentsAccess: commentsAccess ?? this.commentsAccess,
      memberCount: memberCount ?? this.memberCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
