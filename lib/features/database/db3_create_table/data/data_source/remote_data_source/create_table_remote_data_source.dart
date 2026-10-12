/// Module: database / db3_create_table / data / data_source
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_remote_data_source.dart
/// Purpose: Declares `CreateTableRemoteDataSource`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// Raw Firestore calls for the Creating Table section. Throws on failure;
/// turning those throws into `Failure` values is the repository's job, so there
/// is no try/catch and no dartz import here — same split as db1 and db2.
///
/// The databases collection path comes from `CreateDatabaseCollections`; only
/// the `Tables` subcollection name is this module's. Re-declaring the parent
/// path here is how a module ends up writing to a collection nothing reads.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/database_table_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/table_comment_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/table_data_row_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';

class CreateTableRemoteDataSource {
  CreateTableRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// `Demo/{companyId}/Modules/Database/Databases`.
  ///
  /// The empty-baseUri check is not defensive noise — see db1's data source for
  /// the full reasoning. Short version: with no tenant prefix the path is three
  /// segments, which Firestore accepts as a DIFFERENT, top-level collection;
  /// reads come back empty and writes land where nobody looks.
  CollectionReference<Map<String, dynamic>> get _databases {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the '
        'database collection path cannot be resolved.',
      );
    }
    return _firestore.collection(
      getBaseUrl(CreateDatabaseCollections.databases),
    );
  }

  DocumentReference<Map<String, dynamic>> _databaseDoc(String databaseId) =>
      _databases.doc(databaseId);

  /// `…/Databases/{databaseId}/Tables`. Nested under a document, so no tenant
  /// prefix — the parent path already carries it.
  CollectionReference<Map<String, dynamic>> _tablesOf(String databaseId) =>
      _databaseDoc(databaseId).collection(CreateTableCollections.tables);

  /// `…/Tables/{tableId}/Access_Grants`.
  ///
  /// Reuses `CreateDatabaseCollections.accessGrants` rather than naming a
  /// second constant: a table's grants and a database's grants are the same
  /// documents one level apart, and two names for one subcollection is how a
  /// reader ends up looking in the wrong place.
  CollectionReference<Map<String, dynamic>> _grantsOfTable(
    String databaseId,
    String tableId,
  ) =>
      _tablesOf(databaseId)
          .doc(tableId)
          .collection(CreateDatabaseCollections.accessGrants);

  /// `…/Tables/{tableId}/Comments` — the thread the Comments screen draws
  /// (Figma 7398:8232).
  ///
  /// A SUBCOLLECTION rather than an array on the table document, unlike
  /// `columns`. The two are opposite cases: a table is opened whole and has a
  /// handful of columns, while a thread grows without a ceiling and is appended
  /// to by several people at once. As an array it would be rewritten in full on
  /// every reply, and two replies posted in the same second would lose one.
  CollectionReference<Map<String, dynamic>> _commentsOfTable(
    String databaseId,
    String tableId,
  ) =>
      _tablesOf(databaseId)
          .doc(tableId)
          .collection(CreateTableCollections.comments);

  /// Function Name: [fetchTables]
  ///
  /// Purpose: Read every table under one database, newest first.
  ///
  /// Ordered by `created_at` DESCENDING so a table the user just made is the
  /// first row they see rather than the last. Documents written before
  /// `created_at` existed sort last under Firestore's null ordering, which is
  /// the right place for them: they are the oldest.
  Future<List<DatabaseTableModel>> fetchTables(String databaseId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _tablesOf(
      databaseId,
    ).orderBy(DatabaseTableModel.fCreatedAt, descending: true).get();

    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              DatabaseTableModel.fromSnapshot(doc, databaseId: databaseId),
        )
        .toList(growable: false);
  }

  /// Function Name: [createTable]
  ///
  /// Purpose: Write a new table and bring the parent's count up with it,
  /// atomically.
  ///
  /// ONE BATCH, deliberately. The alternative — write the table, then increment
  /// — leaves a window in which the table exists and the card above it still
  /// says "No. Of Tables: 0"; a crash inside that window makes the discrepancy
  /// permanent, and nothing recounts. A batch either lands whole or not at all.
  ///
  /// `FieldValue.increment(1)` rather than "the count I read plus one": two
  /// people adding a table at the same time would otherwise both write the same
  /// number and one table would go uncounted forever.
  ///
  /// The document is re-read after the commit rather than assembled locally,
  /// because `created_at` is a SERVER timestamp — the value the caller needs is
  /// the one Firestore resolved, not the sentinel that was sent.
  Future<DatabaseTableModel> createTable(DatabaseTableModel model) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _tablesOf(model.databaseId).doc();

    final WriteBatch batch = _firestore.batch();

    batch.set(ref, model.toCreateMap());
    batch.update(_databaseDoc(model.databaseId), <String, dynamic>{
      DatabaseModel.fTablesCount: FieldValue.increment(1),
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();

    final DocumentSnapshot<Map<String, dynamic>> saved = await ref.get();
    return DatabaseTableModel.fromSnapshot(
      saved,
      databaseId: model.databaseId,
    );
  }

  /// Function Name: [updateTable]
  ///
  /// Purpose: Write the Editing Table Name card's fields back and return the
  /// record as the SERVER now holds it.
  ///
  /// No batch and no count here: editing a table does not change how many there
  /// are. The parent's `updated_at` is still stamped, so the database's "Last
  /// Edit" line reflects that something inside it changed.
  Future<DatabaseTableModel> updateTable(DatabaseTableModel model) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _tablesOf(model.databaseId).doc(model.id);

    final WriteBatch batch = _firestore.batch();
    batch.update(ref, model.toUpdateMap());
    batch.update(_databaseDoc(model.databaseId), <String, dynamic>{
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });
    await batch.commit();

    final DocumentSnapshot<Map<String, dynamic>> saved = await ref.get();

    // A missing document means it was deleted underneath the editor — which the
    // user has to be told about, not shown as an empty form.
    if (!saved.exists) {
      throw StateError('This table no longer exists.');
    }
    return DatabaseTableModel.fromSnapshot(
      saved,
      databaseId: model.databaseId,
    );
  }

  /// Function Name: [deleteTable]
  ///
  /// Purpose: Remove one table and take the parent's count down with it, in one
  /// batch — same reasoning as [createTable], in the other direction.
  Future<void> deleteTable({
    required String databaseId,
    required String tableId,
  }) async {
    final WriteBatch batch = _firestore.batch();

    batch.delete(_tablesOf(databaseId).doc(tableId));
    batch.update(_databaseDoc(databaseId), <String, dynamic>{
      DatabaseModel.fTablesCount: FieldValue.increment(-1),
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Function Name: [tableNameExists]
  ///
  /// Purpose: True when a table OTHER than [excludeId] in the SAME database
  /// already uses either name.
  ///
  /// Two queries rather than one, for the same reason as db1's title check:
  /// Firestore has no OR across different fields in one `where` chain. Each is
  /// capped at two documents, not one — the record being edited is expected to
  /// match itself, so a limit of one could return only that and report the name
  /// free while a real duplicate sat behind it.
  Future<bool> tableNameExists({
    required String databaseId,
    required String nameEn,
    required String nameAr,
    required String excludeId,
  }) async {
    final CollectionReference<Map<String, dynamic>> tables =
        _tablesOf(databaseId);

    Future<bool> otherThanSelf(String field, String value) async {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await tables.where(field, isEqualTo: value.toLowerCase()).limit(2).get();

      return snapshot.docs.any(
        (QueryDocumentSnapshot<Map<String, dynamic>> d) => d.id != excludeId,
      );
    }

    if (await otherThanSelf(DatabaseTableModel.fNameEnLower, nameEn)) {
      return true;
    }
    return otherThanSelf(DatabaseTableModel.fNameArLower, nameAr);
  }

  // ── Editing Table Access ─────────────────────────────────────────────────

  /// Function Name: [fetchTableGrants]
  ///
  /// Purpose: Read one table's `Access_Grants` subcollection, keeping each
  /// document's id so an edit can rewrite the right rows.
  ///
  /// `DatabaseAccessGrant.fromMap` reads the grant itself — including the
  /// `viewable_fields` key it gained on 16/8/2026. The keys it does not know
  /// about, the removed members and the grantor, are picked out here using
  /// db2's `DatabaseGrantFields`, because those are that module's addition to a
  /// shape db1 owns and this module is only reusing both.
  Future<List<DatabaseAccessGrantRecord>> fetchTableGrants({
    required String databaseId,
    required String tableId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _grantsOfTable(databaseId, tableId).get();

    return snapshot.docs.map((
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
    ) {
      final Map<String, dynamic> data = doc.data();

      final List<dynamic> rawRemoved =
          (data[DatabaseGrantFields.removedMembers] as List<dynamic>?) ??
              const <dynamic>[];

      return DatabaseAccessGrantRecord(
        id: doc.id,
        grant: DatabaseAccessGrant.fromMap(data),
        removedMembers: rawRemoved
            .whereType<Map<String, dynamic>>()
            .map(RemovedAccessMember.fromMap)
            .toList(growable: false),
        grantedBy: data[DatabaseGrantFields.grantedBy] as String?,
        grantedByNameEn: data[DatabaseGrantFields.grantedByNameEn] as String?,
        grantedByNameAr: data[DatabaseGrantFields.grantedByNameAr] as String?,
      );
    }).toList(growable: false);
  }

  /// Function Name: [replaceTableGrants]
  ///
  /// Purpose: Swap the whole subcollection for [records] and bring the table
  /// document back in step, atomically.
  ///
  /// ONE BATCH, for the same reason db2's `replaceGrants` uses one: clear-then-
  /// write leaves a window in which the table exists with nobody on it, and a
  /// crash inside that window revokes everyone's access from a screen that has
  /// already navigated away.
  ///
  /// The existing ids are read BEFORE the batch so the delete set is a snapshot
  /// rather than a live query — a document added between the read and the
  /// commit survives, which is the safe direction to be wrong in.
  Future<void> replaceTableGrants({
    required String databaseId,
    required String tableId,
    required List<DatabaseAccessGrantRecord> records,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    final CollectionReference<Map<String, dynamic>> grants =
        _grantsOfTable(databaseId, tableId);

    final QuerySnapshot<Map<String, dynamic>> existing = await grants.get();

    final WriteBatch batch = _firestore.batch();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final DatabaseAccessGrantRecord record in records) {
      // Reusing the document id where there is one keeps the subcollection
      // stable across edits, so an audit trail or a security rule keyed on a
      // grant id does not see every save as a fresh set of grants.
      final DocumentReference<Map<String, dynamic>> ref =
          record.id.isEmpty ? grants.doc() : grants.doc(record.id);

      batch.set(ref, <String, dynamic>{
        ...record.grant.toMap(),
        DatabaseGrantFields.removedMembers: record.removedMembers
            .map((RemovedAccessMember m) => m.toMap())
            .toList(growable: false),
        DatabaseGrantFields.grantedBy: record.grantedBy ?? grantedBy,
        DatabaseGrantFields.grantedByNameEn:
            record.grantedByNameEn ?? grantedByNameEn,
        DatabaseGrantFields.grantedByNameAr:
            record.grantedByNameAr ?? grantedByNameAr,
        DatabaseGrantFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Distinct people across every grant — the same dedupe db2 uses, so the
    // number on the table row and the number in the subcollection cannot
    // disagree.
    final int memberCount = records
        .expand((DatabaseAccessGrantRecord r) => r.grant.members)
        .toSet()
        .length;

    batch.update(_tablesOf(databaseId).doc(tableId), <String, dynamic>{
      DatabaseTableModel.fMemberCount: memberCount,
      DatabaseTableModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });

    // The DATABASE's own timestamp moves too: something inside it changed, and
    // the details card's "Last Edit" line is the only place that shows it.
    // `tables_count` is untouched — granting access adds no tables.
    batch.update(_databaseDoc(databaseId), <String, dynamic>{
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── Rows (Figma 7398:3042 / 15076 / 15210) ───────────────────────────────

  /// `…/Tables/{tableId}/Rows` — the table's own data.
  ///
  /// A subcollection for the reasons `TableDataRowModel` states: 5000 rows do
  /// not fit in one document, the Preview screen pages through them, and one
  /// edited cell should not rewrite the whole table.
  CollectionReference<Map<String, dynamic>> _rowsOfTable(
    String databaseId,
    String tableId,
  ) =>
      _tablesOf(databaseId)
          .doc(tableId)
          .collection(CreateTableCollections.rows);

  /// Function Name: [fetchRows]
  ///
  /// Purpose: Read one table's rows in the order the user arranged them.
  ///
  /// Ordered by `order` ASCENDING — the opposite of `fetchTables`, and
  /// deliberately: a table is a list of records where newest-first is useful,
  /// while a row's position IS its meaning. Row 3 sits under row 2 or the grid
  /// is not the grid the user typed.
  ///
  /// Returns: [List] rows, first to last.
  Future<List<TableDataRowModel>> fetchRows({
    required String databaseId,
    required String tableId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _rowsOfTable(databaseId, tableId)
            .orderBy(TableDataRowModel.fOrder)
            .get();

    return <TableDataRowModel>[
      for (int i = 0; i < snapshot.docs.length; i++)
        TableDataRowModel.fromSnapshot(snapshot.docs[i], fallbackOrder: i),
    ];
  }

  /// Function Name: [replaceRows]
  ///
  /// Purpose: Write the table's rows as the editing screen left them.
  ///
  /// REPLACE, not merge — the same contract [replaceTableGrants] has and for
  /// the same reason: the Editing Table Name screen (7398:15076) hands back the
  /// complete intended state, including which rows it REMOVED, and a
  /// diff-and-patch would have to reconstruct that intent from two snapshots.
  ///
  /// The table's `row_count` moves in the SAME batch. It is the number the
  /// details screen's "No. Of Rows" tile renders, and a count written in a
  /// second call is a count that can be wrong for as long as the network takes
  /// to fail.
  ///
  /// A Firestore batch is capped at 500 operations, so this commits in chunks
  /// of [_batchLimit]. The chunks are NOT atomic with one another — a failure
  /// halfway leaves the earlier chunks written — which is why the deletes and
  /// the writes are interleaved in document order rather than "delete
  /// everything, then write everything": a partial commit then leaves a table
  /// with some old rows and some new ones, not a table with no rows at all.
  Future<void> replaceRows({
    required String databaseId,
    required String tableId,
    required List<TableDataRow> rows,
  }) async {
    final CollectionReference<Map<String, dynamic>> collection =
        _rowsOfTable(databaseId, tableId);

    // Read BEFORE the writes so the delete set is a snapshot rather than a live
    // query — a row added by somebody else between the read and the commit
    // survives, which is the safe direction to be wrong in.
    final QuerySnapshot<Map<String, dynamic>> existing = await collection.get();

    final Set<String> keptIds = rows
        .map((TableDataRow row) => row.id)
        .where((String id) => id.isNotEmpty)
        .toSet();

    final List<DocumentReference<Map<String, dynamic>>> doomed =
        <DocumentReference<Map<String, dynamic>>>[
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in existing.docs)
        if (!keptIds.contains(doc.id)) doc.reference,
    ];

    final Set<String> existingIds = existing.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.id)
        .toSet();

    // One flat list of operations, then sliced into batches. Building it first
    // is what keeps the chunking rule in one place instead of at three call
    // sites inside a loop.
    final List<void Function(WriteBatch)> operations =
        <void Function(WriteBatch)>[
      for (final DocumentReference<Map<String, dynamic>> ref in doomed)
        (WriteBatch batch) => batch.delete(ref),
      for (final TableDataRow row in rows)
        (WriteBatch batch) {
          final TableDataRowModel model = TableDataRowModel.fromEntity(row);
          // A row the user added on the editing screen has a locally-minted id
          // that is not a document id yet. `doc()` mints a real one; reusing an
          // existing id keeps the subcollection stable across saves.
          final bool isExisting =
              row.id.isNotEmpty && existingIds.contains(row.id);
          final DocumentReference<Map<String, dynamic>> ref =
              isExisting ? collection.doc(row.id) : collection.doc();

          batch.set(
            ref,
            isExisting ? model.toUpdateMap() : model.toCreateMap(),
            SetOptions(merge: true),
          );
        },
    ];

    for (int start = 0; start < operations.length; start += _batchLimit) {
      final int end = (start + _batchLimit).clamp(0, operations.length);
      final WriteBatch batch = _firestore.batch();
      for (final void Function(WriteBatch) operation
          in operations.sublist(start, end)) {
        operation(batch);
      }
      await batch.commit();
    }

    // The count and both timestamps last, in their own batch: if the rows above
    // failed there is nothing to count, and running this first would leave the
    // tile claiming rows the table does not have.
    final WriteBatch tail = _firestore.batch();
    tail.update(_tablesOf(databaseId).doc(tableId), <String, dynamic>{
      DatabaseTableModel.fRowCount: rows.length,
      DatabaseTableModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });
    tail.update(_databaseDoc(databaseId), <String, dynamic>{
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });
    await tail.commit();
  }

  /// Firestore's own ceiling on one `WriteBatch`. Named rather than inlined so
  /// the reason the loop above exists is readable at the loop.
  static const int _batchLimit = 500;

  // ── Comments (Figma 7398:8232 / 8311 / 8587) ─────────────────────────────

  /// Function Name: [fetchComments]
  ///
  /// Purpose: Read one table's thread, OLDEST first.
  ///
  /// The opposite order to `fetchTables`, and deliberately: a list of records is
  /// read newest-first because the newest is the one you were looking for, but a
  /// conversation is read top-to-bottom or it stops being a conversation. The
  /// screen scrolls to the bottom on open, which is where the newest message
  /// then is.
  ///
  /// A document written before `created_at` existed sorts FIRST under
  /// Firestore's null ordering — the right place for it, since it is the oldest.
  Future<List<TableCommentModel>> fetchComments({
    required String databaseId,
    required String tableId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _commentsOfTable(databaseId, tableId)
            .orderBy(TableCommentModel.fCreatedAt)
            .get();

    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              TableCommentModel.fromSnapshot(doc, tableId: tableId),
        )
        .toList(growable: false);
  }

  /// Function Name: [addComment]
  ///
  /// Purpose: Post one message and return it as the SERVER now holds it.
  ///
  /// Re-read after the write rather than assembled locally, for the same reason
  /// `createTable` re-reads: `created_at` is a server timestamp, and the value
  /// the bubble has to print is the one Firestore resolved, not the sentinel
  /// that was sent. Without it every message would render with no date until the
  /// screen was reopened.
  ///
  /// No batch and no counter on the table document. A comment count is not drawn
  /// anywhere — the Figma's tile beside it reads "Comments Access", which is a
  /// setting, not a total — so there is nothing to keep in step, and adding a
  /// counter now would be a second number that can only ever go wrong.
  Future<TableCommentModel> addComment({
    required String databaseId,
    required TableCommentModel comment,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _commentsOfTable(databaseId, comment.tableId).doc();

    await ref.set(comment.toCreateMap());

    final DocumentSnapshot<Map<String, dynamic>> saved = await ref.get();
    return TableCommentModel.fromSnapshot(saved, tableId: comment.tableId);
  }

  /// Function Name: [deleteComment]
  ///
  /// Purpose: Remove one message.
  ///
  /// Hard delete, not a flag. A database record is soft-deleted because it has
  /// a Deleted chip to sit in and things hanging off it; a retracted sentence
  /// has neither, and keeping the text of something the author took back is the
  /// opposite of what taking it back means.
  Future<void> deleteComment({
    required String databaseId,
    required String tableId,
    required String commentId,
  }) {
    return _commentsOfTable(databaseId, tableId).doc(commentId).delete();
  }

  /// Function Name: [setCommentReaction]
  ///
  /// Purpose: Apply, switch or clear one person's thumb on one comment, and
  /// return the comment as it stands afterwards.
  ///
  /// ONE update with BOTH arrays in it. [reaction] null clears; otherwise the id
  /// is unioned into that reaction's array and removed from the other in the
  /// same write, which is what enforces "at most one of the two" — as two writes
  /// there is a window in which a thumb is counted on both sides, and a crash
  /// inside it makes that permanent.
  ///
  /// `arrayUnion` / `arrayRemove` rather than writing the list this client read:
  /// several people react to the same message at once, and a whole-array write
  /// would drop whichever reactions arrived between the read and the write.
  Future<TableCommentModel> setCommentReaction({
    required String databaseId,
    required String tableId,
    required String commentId,
    required String employeeId,
    required TableCommentReaction? reaction,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _commentsOfTable(databaseId, tableId).doc(commentId);

    await ref.update(<String, dynamic>{
      for (final TableCommentReaction value in TableCommentReaction.values)
        value.storageField: value == reaction
            ? FieldValue.arrayUnion(<String>[employeeId])
            : FieldValue.arrayRemove(<String>[employeeId]),
    });

    final DocumentSnapshot<Map<String, dynamic>> saved = await ref.get();

    // Gone means somebody deleted it while this thumb was in flight. Saying so
    // is the only honest answer — the alternative is an empty bubble that the
    // user cannot tell apart from a reaction that silently failed.
    if (!saved.exists) {
      throw StateError('This comment no longer exists.');
    }
    return TableCommentModel.fromSnapshot(saved, tableId: tableId);
  }
}
