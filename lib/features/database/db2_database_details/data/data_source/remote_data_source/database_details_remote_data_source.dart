/// Module: database / db2_database_details / data / data_source
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_remote_data_source.dart
/// Purpose: Declares `DatabaseDetailsRemoteDataSource`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// Raw Firestore / Storage calls for the details section. Throws on failure;
/// turning those throws into `Failure` values is the repository's job, so
/// there is no try/catch and no dartz import here — same split as db1.
///
/// The collection path, the covers folder and the grants subcollection name
/// all come from `CreateDatabaseCollections`. Re-declaring them here is how a
/// module ends up writing to a collection nothing else reads.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/data_source/remote_data_source/create_database_remote_data_source.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';

class DatabaseDetailsRemoteDataSource {
  DatabaseDetailsRemoteDataSource({
    FirebaseFirestore? firestore,
    CreateDatabaseRemoteDataSource? covers,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        // Cover uploads go through db1's data source rather than being
        // reimplemented: it already derives a clock-based file name (so two
        // people picking IMG_0001.jpg do not overwrite each other) and it
        // already guards the empty-tenant case. A second copy of that would
        // drift the first time either changed.
        _covers = covers ?? CreateDatabaseRemoteDataSource();

  final FirebaseFirestore _firestore;
  final CreateDatabaseRemoteDataSource _covers;

  /// `Demo/{companyId}/Modules/Database/Databases`.
  ///
  /// The empty-baseUri check is not defensive noise — see db1's data source
  /// for the full reasoning. Short version: with no tenant prefix the path is
  /// three segments, which Firestore accepts as a DIFFERENT, top-level
  /// collection; reads come back empty and writes land where nobody looks.
  CollectionReference<Map<String, dynamic>> get _collection {
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

  CollectionReference<Map<String, dynamic>> _grantsOf(String databaseId) =>
      _collection.doc(databaseId).collection(
            CreateDatabaseCollections.accessGrants,
          );

  /// Function Name: [uploadCoverImage]
  ///
  /// Purpose: Push a newly picked cover to Storage and return its URL.
  Future<String> uploadCoverImage(File image) => _covers.uploadCoverImage(image);

  /// Function Name: [fetchDatabase]
  ///
  /// Purpose: Read one record back from the server.
  ///
  /// A missing document throws rather than returning null: every caller
  /// reaches this holding a record it just wrote or just opened, so "not
  /// there" means it was deleted underneath them — which the user has to be
  /// told about, not shown as an empty form.
  Future<DatabaseModel> fetchDatabase(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _collection.doc(id).get();

    if (!snapshot.exists) {
      throw StateError('This database no longer exists.');
    }
    return DatabaseModel.fromSnapshot(snapshot);
  }

  /// Function Name: [fetchGrants]
  ///
  /// Purpose: Read the `Access_Grants` subcollection, keeping each document's
  /// id so an edit can rewrite the right rows.
  ///
  /// `DatabaseAccessGrant.fromMap` reads the grant itself; the keys it does
  /// not know about — the removed members and the grantor — are picked out
  /// here, because they are this module's addition to a shape db1 owns.
  Future<List<DatabaseAccessGrantRecord>> fetchGrants(String databaseId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _grantsOf(databaseId).get();

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

  /// Function Name: [updateDatabase]
  ///
  /// Purpose: Write the Editing screen's fields back and return the record as
  /// the SERVER now holds it.
  ///
  /// The map is built field by field rather than reusing `toCreateMap()`.
  /// That map carries `created_at: FieldValue.serverTimestamp()`, `created_by`
  /// and `status` — using it for an update would stamp today's date onto the
  /// creation of a record made months ago and re-activate a draft, from a
  /// screen that only ever showed a title, a description and a picture.
  Future<DatabaseModel> updateDatabase(
    DatabaseModel model, {
    String? coverImageUrl,
  }) async {
    final DocumentReference<Map<String, dynamic>> doc =
        _collection.doc(model.id);

    final Map<String, dynamic> payload = <String, dynamic>{
      DatabaseModel.fTitleEn: model.titleEn,
      DatabaseModel.fTitleAr: model.titleAr,
      DatabaseModel.fTitleEnLower: model.titleEn.toLowerCase(),
      DatabaseModel.fTitleArLower: model.titleAr.toLowerCase(),
      DatabaseModel.fDescriptionEn: model.descriptionEn,
      DatabaseModel.fDescriptionAr: model.descriptionAr,
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
      // Only overwrite the cover when a new file was actually uploaded.
      // Passing the existing (possibly null) URL back would clear the picture
      // of a record whose owner only renamed it.
      if (coverImageUrl != null) DatabaseModel.fCoverImageUrl: coverImageUrl,
    };

    await doc.update(payload);

    final DocumentSnapshot<Map<String, dynamic>> saved = await doc.get();
    return DatabaseModel.fromSnapshot(saved);
  }

  /// Function Name: [titleExists]
  ///
  /// Purpose: True when a database OTHER than [excludeId] already uses either
  /// title.
  ///
  /// Two queries rather than one for the same reason as db1: Firestore has no
  /// OR across different fields in one `where` chain. Each is capped at two
  /// documents, not one — the record being edited is expected to match itself,
  /// so a limit of one could return only that and report "free" when a real
  /// duplicate sat behind it.
  Future<bool> titleExists({
    required String titleEn,
    required String titleAr,
    required String excludeId,
  }) async {
    Future<bool> otherThanSelf(String field, String value) async {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection
          .where(field, isEqualTo: value.toLowerCase())
          .limit(2)
          .get();

      return snapshot.docs
          .any((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.id != excludeId);
    }

    if (await otherThanSelf(DatabaseModel.fTitleEnLower, titleEn)) return true;
    return otherThanSelf(DatabaseModel.fTitleArLower, titleAr);
  }

  /// Function Name: [replaceGrants]
  ///
  /// Purpose: Swap the whole `Access_Grants` subcollection for [records] and
  /// bring the parent document back in step, atomically.
  ///
  /// ONE BATCH, deliberately. The alternative — clear, then write — leaves a
  /// window in which the database exists with nobody on it; a crash or a lost
  /// connection inside that window revokes everyone's access and the screen
  /// that caused it has already navigated away. A batch either lands whole or
  /// not at all.
  ///
  /// The parent carries `access_type` and `member_count`, both denormalised so
  /// the list screen never reads the subcollection. They are written here
  /// rather than by a separate call for the same reason: a parent claiming
  /// "Open Access, 20 members" over an empty subcollection is a state no
  /// screen can explain, and two calls can always produce it.
  ///
  /// [DatabaseAccessType] is written even when it did not change, because it
  /// is one field in a map that is being set anyway; branching on "did it
  /// change" would cost a read to find out.
  Future<void> replaceGrants({
    required String databaseId,
    required DatabaseAccessType accessType,
    required List<DatabaseAccessGrantRecord> records,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    final CollectionReference<Map<String, dynamic>> grants =
        _grantsOf(databaseId);

    // Read the existing ids BEFORE the batch so the delete set is a snapshot
    // rather than a live query — a document added between the read and the
    // commit survives, which is the safe direction to be wrong in.
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
        // The grant's own shape stays db1's — this module only adds keys.
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

    // Distinct people across every grant — the same dedupe rule the review
    // screen's "Total Employees" tile uses, so the number on the card and the
    // number in the document cannot disagree.
    final int memberCount = records
        .expand((DatabaseAccessGrantRecord r) => r.grant.members)
        .toSet()
        .length;

    batch.update(_collection.doc(databaseId), <String, dynamic>{
      DatabaseModel.fAccessType: accessType.storageKey,
      DatabaseModel.fMemberCount: memberCount,
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
