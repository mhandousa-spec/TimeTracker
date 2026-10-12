/// Module: database / db2_database_details / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_base_repository.dart
/// Purpose: Declares `DatabaseDetailsBaseRepository`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The contract the details cubits depend on, so the presentation layer never
/// names the Firestore-backed implementation and a test can pass a fake.
///
/// Deleting is deliberately absent: `CreateDatabaseBaseRepository.deleteDatabase`
/// already does it, sweeping the `Access_Grants` subcollection in the same
/// batch, and the red Delete button on the details page calls that. A second
/// delete here would be a second chance to forget the sweep.

import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';

abstract class DatabaseDetailsBaseRepository {
  /// Re-reads one record. The list hands the details screen the row it already
  /// has, so this is only used after a write — the screen shows what the
  /// SERVER now holds rather than what the form believed it sent.
  Future<Either<Failure, DatabaseEntity>> fetchDatabase(String id);

  /// Every grant document under [databaseId], with its id and its removed
  /// members.
  Future<Either<Failure, List<DatabaseAccessGrantRecord>>> fetchGrants(
    String databaseId,
  );

  /// Writes the edited title / description / cover back.
  ///
  /// Only the fields the Editing screen owns are touched — `created_at`,
  /// `created_by`, `tables_count` and the lifecycle status are left alone, so
  /// an edit cannot silently un-draft a record or reset its table count.
  ///
  /// When [coverImage] is supplied it is uploaded FIRST; a failed upload
  /// leaves the document untouched rather than pointing it at an image that
  /// never landed.
  Future<Either<Failure, DatabaseEntity>> updateDatabase(
    DatabaseEntity database, {
    File? coverImage,
  });

  /// True when a DIFFERENT database already uses either title.
  ///
  /// [excludeId] is what makes this usable on an edit screen: saving an edit
  /// that did not touch the title would otherwise match the record against
  /// itself and be rejected as a duplicate.
  ///
  /// REQUIRED here, optional on `CreateDatabaseBaseRepository` — which gained
  /// the parameter on 16/8/2026 for the draft-resume path. Every screen in
  /// this module edits a record that already exists, so an omitted id would
  /// always be a mistake; over there the common case is a brand new database
  /// with no id to exclude yet.
  Future<Either<Failure, bool>> titleExists({
    required String titleEn,
    required String titleAr,
    required String excludeId,
  });

  /// Replaces the whole `Access_Grants` subcollection with [records].
  ///
  /// REPLACE, not merge. The edit screens hand back the complete intended
  /// state — including the removed people, which travel inside the records —
  /// so a diff-and-patch would have to reconstruct that intent from two
  /// snapshots and would drift the moment a grant was split or merged.
  ///
  /// [accessType] and the derived member count are written onto the PARENT in
  /// the same batch: switching a database from Open to Personal drops every
  /// grant, and a parent still labelled "Open Access" over an empty
  /// subcollection is the one state the list screen cannot explain.
  /// [grantedBy] and the two name fields stamp the "Access Grantor" column on
  /// any record that does not carry one of its own — grants written by the
  /// create wizard never do, so without this the column would stay blank for
  /// every database made before this screen existed.
  Future<Either<Failure, void>> replaceGrants({
    required String databaseId,
    required DatabaseAccessType accessType,
    required List<DatabaseAccessGrantRecord> records,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  });
}
