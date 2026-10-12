/// Module: database / db1_create_database / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_repository.dart
/// Purpose: Declares `CreateDatabaseRepository`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// Turns the data source's throws into `Either<Failure, T>`. This is the only
/// layer that catches — the cubit folds, the UI renders, neither catches.

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/data_source/remote_data_source/create_database_remote_data_source.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';

class CreateDatabaseRepository implements CreateDatabaseBaseRepository {
  CreateDatabaseRepository({CreateDatabaseRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? CreateDatabaseRemoteDataSource();

  final CreateDatabaseRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, DatabaseEntity>> createDatabase(
    DatabaseEntity database, {
    File? coverImage,
    List<DatabaseAccessGrant> grants = const <DatabaseAccessGrant>[],
  }) async {
    try {
      String? coverUrl = database.coverImageUrl;

      // Upload first. If this throws, nothing has been written yet — better
      // than a saved record pointing at an image that never landed.
      if (coverImage != null) {
        coverUrl = await _remoteDataSource.uploadCoverImage(coverImage);
      }

      final DatabaseModel saved = await _remoteDataSource.createDatabase(
        DatabaseModel.fromEntity(database.copyWith(coverImageUrl: coverUrl)),
        grants: grants,
      );

      return Right(saved);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, DatabaseEntity>> updateDatabase(
    DatabaseEntity database, {
    File? coverImage,
    List<DatabaseAccessGrant> grants = const <DatabaseAccessGrant>[],
  }) async {
    if (database.id.isEmpty) {
      return Left(FeatureFailure('This database has no id and cannot be '
          'updated.'));
    }

    try {
      String? coverUrl = database.coverImageUrl;

      // Upload first, exactly as `createDatabase` does: a failed upload leaves
      // the record untouched rather than pointing it at an image that never
      // landed.
      if (coverImage != null) {
        coverUrl = await _remoteDataSource.uploadCoverImage(coverImage);
      }

      final DatabaseModel saved = await _remoteDataSource.updateDatabase(
        database.id,
        DatabaseModel.fromEntity(database.copyWith(coverImageUrl: coverUrl)),
        grants: grants,
      );

      return Right(saved);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DatabaseAccessGrant>>> fetchGrants(
    String databaseId,
  ) async {
    if (databaseId.isEmpty) {
      return const Right<Failure, List<DatabaseAccessGrant>>(
        <DatabaseAccessGrant>[],
      );
    }

    try {
      final List<DatabaseAccessGrant> grants =
          await _remoteDataSource.fetchGrants(databaseId);
      return Right(grants);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DatabaseEntity>>> listDatabases() async {
    try {
      final List<DatabaseModel> databases =
          await _remoteDataSource.listDatabases();
      return Right(databases);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> titleExists({
    required String titleEn,
    required String titleAr,
    String? excludeId,
  }) async {
    try {
      final bool exists = await _remoteDataSource.titleExists(
        titleEn: titleEn,
        titleAr: titleAr,
        excludeId: excludeId,
      );
      return Right(exists);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDatabase(
    String id, {
    required DatabaseStatus previousStatus,
  }) async {
    // An empty id means the caller is holding a record that was never
    // written. Passing it through would call `_collection.doc('')`, which
    // throws a bare assertion from the Firestore SDK rather than anything the
    // UI can show — so it is rejected here as the Failure it actually is.
    if (id.isEmpty) {
      return Left(FeatureFailure('This database has no id and cannot be '
          'deleted.'));
    }

    try {
      await _remoteDataSource.softDeleteDatabase(
        id,
        previousStatus: previousStatus,
      );
      return const Right<Failure, void>(null);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreDatabase(
    String id, {
    required DatabaseStatus status,
  }) async {
    if (id.isEmpty) {
      return Left(FeatureFailure('This database has no id and cannot be '
          'restored.'));
    }

    try {
      await _remoteDataSource.restoreDatabase(id, status: status);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> purgeDatabase(String id) async {
    if (id.isEmpty) {
      return Left(FeatureFailure('This database has no id and cannot be '
          'deleted.'));
    }

    try {
      await _remoteDataSource.purgeDatabase(id);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }
}
