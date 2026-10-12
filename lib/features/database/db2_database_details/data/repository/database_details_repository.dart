/// Module: database / db2_database_details / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_repository.dart
/// Purpose: Declares `DatabaseDetailsRepository`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// Turns the data source's throws into `Either<Failure, T>`. This is the only
/// layer that catches — the cubits fold, the UI renders, neither catches.

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/data_source/remote_data_source/database_details_remote_data_source.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';

class DatabaseDetailsRepository implements DatabaseDetailsBaseRepository {
  DatabaseDetailsRepository({DatabaseDetailsRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? DatabaseDetailsRemoteDataSource();

  final DatabaseDetailsRemoteDataSource _remoteDataSource;

  /// Every method funnels through this, so the two failure shapes — a
  /// Firebase error with a code and everything else — are mapped once instead
  /// of in six near-identical try/catch blocks that can drift apart.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right<Failure, T>(await run());
    } on FirebaseException catch (error) {
      return Left<Failure, T>(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left<Failure, T>(FeatureFailure(error.toString()));
    }
  }

  /// An empty id means the caller is holding a record that was never written.
  /// Passing it through calls `doc('')`, which throws a bare assertion from
  /// the Firestore SDK rather than anything the UI can show.
  Either<Failure, void>? _rejectEmptyId(String id) {
    if (id.isNotEmpty) return null;
    return Left<Failure, void>(
      FeatureFailure('This database has no id, so it cannot be read or saved.'),
    );
  }

  @override
  Future<Either<Failure, DatabaseEntity>> fetchDatabase(String id) async {
    if (id.isEmpty) {
      return Left<Failure, DatabaseEntity>(
        FeatureFailure('This database has no id, so it cannot be read.'),
      );
    }
    return _guard<DatabaseEntity>(() => _remoteDataSource.fetchDatabase(id));
  }

  @override
  Future<Either<Failure, List<DatabaseAccessGrantRecord>>> fetchGrants(
    String databaseId,
  ) async {
    // A record with no id has no subcollection either. Reporting an empty list
    // rather than a failure is right here: the Access screen's honest state
    // for an unsaved database is "nobody has access yet", not an error banner.
    if (databaseId.isEmpty) {
      return const Right<Failure, List<DatabaseAccessGrantRecord>>(
        <DatabaseAccessGrantRecord>[],
      );
    }
    return _guard<List<DatabaseAccessGrantRecord>>(
      () => _remoteDataSource.fetchGrants(databaseId),
    );
  }

  @override
  Future<Either<Failure, DatabaseEntity>> updateDatabase(
    DatabaseEntity database, {
    File? coverImage,
  }) async {
    if (database.id.isEmpty) {
      return Left<Failure, DatabaseEntity>(
        FeatureFailure('This database has no id, so it cannot be saved.'),
      );
    }

    return _guard<DatabaseEntity>(() async {
      // Upload FIRST. If this throws, the document is untouched — better than
      // a saved record pointing at an image that never landed.
      String? uploadedUrl;
      if (coverImage != null) {
        uploadedUrl = await _remoteDataSource.uploadCoverImage(coverImage);
      }

      return _remoteDataSource.updateDatabase(
        DatabaseModel.fromEntity(database),
        coverImageUrl: uploadedUrl,
      );
    });
  }

  @override
  Future<Either<Failure, bool>> titleExists({
    required String titleEn,
    required String titleAr,
    required String excludeId,
  }) =>
      _guard<bool>(() => _remoteDataSource.titleExists(
            titleEn: titleEn,
            titleAr: titleAr,
            excludeId: excludeId,
          ));

  @override
  Future<Either<Failure, void>> replaceGrants({
    required String databaseId,
    required DatabaseAccessType accessType,
    required List<DatabaseAccessGrantRecord> records,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    final Either<Failure, void>? rejected = _rejectEmptyId(databaseId);
    if (rejected != null) return rejected;

    return _guard<void>(() => _remoteDataSource.replaceGrants(
          databaseId: databaseId,
          accessType: accessType,
          records: records,
          grantedBy: grantedBy,
          grantedByNameEn: grantedByNameEn,
          grantedByNameAr: grantedByNameAr,
        ));
  }
}
