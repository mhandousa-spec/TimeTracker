/// Module: database / db3_create_table / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_repository.dart
/// Purpose: Declares `CreateTableRepository`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// Turns the data source's throws into `Either<Failure, T>`. This is the only
/// layer that catches — the cubits fold, the UI renders, neither catches.

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/data_source/remote_data_source/create_table_remote_data_source.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/database_table_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/table_comment_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';

class CreateTableRepository implements CreateTableBaseRepository {
  CreateTableRepository({CreateTableRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CreateTableRemoteDataSource();

  final CreateTableRemoteDataSource _remoteDataSource;

  /// Every method funnels through this, so the two failure shapes — a Firebase
  /// error with a code and everything else — are mapped once instead of in five
  /// near-identical try/catch blocks that can drift apart.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right<Failure, T>(await run());
    } on FirebaseException catch (error) {
      return Left<Failure, T>(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left<Failure, T>(FeatureFailure(error.toString()));
    }
  }

  /// An empty parent id means the caller is holding a database that was never
  /// written. Passing it through calls `doc('')`, which throws a bare assertion
  /// from the Firestore SDK rather than anything the UI can show.
  Either<Failure, T>? _rejectEmptyDatabaseId<T>(String databaseId) {
    if (databaseId.isNotEmpty) return null;
    return Left<Failure, T>(
      FeatureFailure(
        'This database has no id, so its tables cannot be read or saved.',
      ),
    );
  }

  @override
  Future<Either<Failure, List<DatabaseTableEntity>>> fetchTables(
    String databaseId,
  ) async {
    // A record with no id has no subcollection either. Reporting an empty list
    // rather than a failure is right here: the details screen's honest state
    // for an unsaved database is "no tables yet", not an error banner.
    if (databaseId.isEmpty) {
      return const Right<Failure, List<DatabaseTableEntity>>(
        <DatabaseTableEntity>[],
      );
    }

    return _guard<List<DatabaseTableEntity>>(
      () => _remoteDataSource.fetchTables(databaseId),
    );
  }

  @override
  Future<Either<Failure, DatabaseTableEntity>> createTable(
    DatabaseTableEntity table,
  ) async {
    final Either<Failure, DatabaseTableEntity>? rejected =
        _rejectEmptyDatabaseId<DatabaseTableEntity>(table.databaseId);
    if (rejected != null) return rejected;

    return _guard<DatabaseTableEntity>(
      () => _remoteDataSource.createTable(
        DatabaseTableModel.fromEntity(table),
      ),
    );
  }

  @override
  Future<Either<Failure, DatabaseTableEntity>> updateTable(
    DatabaseTableEntity table,
  ) async {
    final Either<Failure, DatabaseTableEntity>? rejected =
        _rejectEmptyDatabaseId<DatabaseTableEntity>(table.databaseId);
    if (rejected != null) return rejected;

    if (table.id.isEmpty) {
      return Left<Failure, DatabaseTableEntity>(
        FeatureFailure('This table has no id, so it cannot be saved.'),
      );
    }

    return _guard<DatabaseTableEntity>(
      () => _remoteDataSource.updateTable(
        DatabaseTableModel.fromEntity(table),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteTable({
    required String databaseId,
    required String tableId,
  }) async {
    final Either<Failure, void>? rejected =
        _rejectEmptyDatabaseId<void>(databaseId);
    if (rejected != null) return rejected;

    if (tableId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure('This table has no id, so it cannot be deleted.'),
      );
    }

    return _guard<void>(
      () => _remoteDataSource.deleteTable(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> tableNameExists({
    required String databaseId,
    required String nameEn,
    required String nameAr,
    required String excludeId,
  }) async {
    // No parent, no siblings — so no name can be taken. Reporting "free" rather
    // than a failure keeps the create card usable against a database that has
    // not been written yet, which is the same tolerance `fetchTables` shows.
    if (databaseId.isEmpty) return const Right<Failure, bool>(false);

    return _guard<bool>(
      () => _remoteDataSource.tableNameExists(
        databaseId: databaseId,
        nameEn: nameEn,
        nameAr: nameAr,
        excludeId: excludeId,
      ),
    );
  }

  @override
  Future<Either<Failure, List<DatabaseAccessGrantRecord>>> fetchTableGrants({
    required String databaseId,
    required String tableId,
  }) async {
    // A table that was never written has no subcollection either. An empty list
    // is the honest answer — "nobody has access yet" — not an error banner.
    if (databaseId.isEmpty || tableId.isEmpty) {
      return const Right<Failure, List<DatabaseAccessGrantRecord>>(
        <DatabaseAccessGrantRecord>[],
      );
    }

    return _guard<List<DatabaseAccessGrantRecord>>(
      () => _remoteDataSource.fetchTableGrants(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> replaceTableGrants({
    required String databaseId,
    required String tableId,
    required List<DatabaseAccessGrantRecord> records,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    final Either<Failure, void>? rejected =
        _rejectEmptyDatabaseId<void>(databaseId);
    if (rejected != null) return rejected;

    if (tableId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure(
          'This table has no id, so access to it cannot be saved.',
        ),
      );
    }

    return _guard<void>(
      () => _remoteDataSource.replaceTableGrants(
        databaseId: databaseId,
        tableId: tableId,
        records: records,
        grantedBy: grantedBy,
        grantedByNameEn: grantedByNameEn,
        grantedByNameAr: grantedByNameAr,
      ),
    );
  }

  // ── Rows (Figma 7398:3042 / 15076 / 15210) ───────────────────────────────

  @override
  Future<Either<Failure, List<TableDataRow>>> fetchRows({
    required String databaseId,
    required String tableId,
  }) async {
    // A table with no id has no subcollection. "Nothing has been filled in yet"
    // is the honest state for one, not an error banner — same reading
    // `fetchComments` takes one method down.
    if (databaseId.isEmpty || tableId.isEmpty) {
      return const Right<Failure, List<TableDataRow>>(<TableDataRow>[]);
    }

    return _guard<List<TableDataRow>>(
      () => _remoteDataSource.fetchRows(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> replaceRows({
    required String databaseId,
    required String tableId,
    required List<TableDataRow> rows,
  }) async {
    final Either<Failure, void>? rejected =
        _rejectEmptyDatabaseId<void>(databaseId);
    if (rejected != null) return rejected;

    if (tableId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure(
          'This table has not been saved yet, so its rows cannot be written.',
        ),
      );
    }

    // Renumbered HERE and not in the data source: `order` is a presentation
    // fact — where the row sits on screen — and the list arriving in that order
    // is the contract the interface states. Doing it once at the boundary means
    // neither the cubit nor the data source has to remember to.
    final List<TableDataRow> ordered = <TableDataRow>[
      for (int i = 0; i < rows.length; i++) rows[i].copyWith(order: i),
    ];

    return _guard<void>(
      () => _remoteDataSource.replaceRows(
        databaseId: databaseId,
        tableId: tableId,
        rows: ordered,
      ),
    );
  }

  // ── Comments ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<TableComment>>> fetchComments({
    required String databaseId,
    required String tableId,
  }) async {
    // A table that was never written has no subcollection either. An empty
    // thread is the honest answer, not an error banner — same tolerance
    // `fetchTableGrants` shows.
    if (databaseId.isEmpty || tableId.isEmpty) {
      return const Right<Failure, List<TableComment>>(<TableComment>[]);
    }

    return _guard<List<TableComment>>(
      () => _remoteDataSource.fetchComments(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
  Future<Either<Failure, TableComment>> addComment({
    required String databaseId,
    required TableComment comment,
  }) async {
    final Either<Failure, TableComment>? rejected =
        _rejectEmptyDatabaseId<TableComment>(databaseId);
    if (rejected != null) return rejected;

    if (comment.tableId.isEmpty) {
      return Left<Failure, TableComment>(
        FeatureFailure('This table has no id, so it cannot take comments.'),
      );
    }

    return _guard<TableComment>(
      () => _remoteDataSource.addComment(
        databaseId: databaseId,
        comment: TableCommentModel.fromEntity(comment),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String databaseId,
    required String tableId,
    required String commentId,
  }) async {
    final Either<Failure, void>? rejected =
        _rejectEmptyDatabaseId<void>(databaseId);
    if (rejected != null) return rejected;

    if (tableId.isEmpty || commentId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure('This comment has no id, so it cannot be deleted.'),
      );
    }

    return _guard<void>(
      () => _remoteDataSource.deleteComment(
        databaseId: databaseId,
        tableId: tableId,
        commentId: commentId,
      ),
    );
  }

  @override
  Future<Either<Failure, TableComment>> setCommentReaction({
    required String databaseId,
    required String tableId,
    required String commentId,
    required String employeeId,
    required TableCommentReaction? reaction,
  }) async {
    final Either<Failure, TableComment>? rejected =
        _rejectEmptyDatabaseId<TableComment>(databaseId);
    if (rejected != null) return rejected;

    if (tableId.isEmpty || commentId.isEmpty) {
      return Left<Failure, TableComment>(
        FeatureFailure('This comment has no id, so it cannot be reacted to.'),
      );
    }

    // An anonymous reaction cannot be undone — there would be no id to remove
    // from the array — so it is refused rather than written. The screen keeps
    // the buttons out of reach when nobody is signed in; this is the backstop.
    if (employeeId.isEmpty) {
      return Left<Failure, TableComment>(
        FeatureFailure('Sign in to react to a comment.'),
      );
    }

    return _guard<TableComment>(
      () => _remoteDataSource.setCommentReaction(
        databaseId: databaseId,
        tableId: tableId,
        commentId: commentId,
        employeeId: employeeId,
        reaction: reaction,
      ),
    );
  }
}
