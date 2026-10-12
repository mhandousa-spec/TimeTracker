/// Module: database / db1_create_database / data / data_source
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_remote_data_source.dart
/// Purpose: Declares `CreateDatabaseRemoteDataSource`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// Raw Firestore / Storage calls. Throws on failure; converting those throws
/// into `Failure` values is the repository's job, so this file has no
/// try/catch and no dartz import.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';

class CreateDatabaseRemoteDataSource {
  CreateDatabaseRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// `Demo/{companyId}/Modules/Database/Databases`.
  ///
  /// MOVED 15/8/2026 off the top-level `Databases` collection. The tenant
  /// prefix comes from `ApiConstants.baseUri`, which `demo_login_repository`
  /// sets to `Demo/{companyId}` at login — the same source every other
  /// module's paths resolve through, so this collection follows whoever is
  /// signed in instead of naming one company.
  ///
  /// The empty-baseUri check is not defensive noise. With no prefix the path
  /// would be `Modules/Database/Databases` — three segments, which Firestore
  /// happily accepts as a DIFFERENT, top-level collection. Reads would come
  /// back empty and writes would land somewhere nobody looks; failing loudly
  /// is the only outcome that is debuggable. The repository turns this into a
  /// `Failure`, so it reaches the user as the error dialog.
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

  /// Function Name: [uploadCoverImage]
  ///
  /// Purpose: Push the picked file to Storage and return its download URL.
  ///
  /// The file name is derived from the clock rather than the original name so
  /// two users picking `IMG_0001.jpg` do not overwrite each other.
  Future<String> uploadCoverImage(File image) async {
    final String extension = image.path.split('.').last;
    final String name =
        '${DateTime.now().millisecondsSinceEpoch}.$extension';

    // Tenant-scoped like the collection — `Demo/{companyId}/Modules/Database/
    // covers/{name}`. The same empty-baseUri guard is repeated inline because
    // this path is built from Storage, not from `_collection`.
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the '
        'cover image storage path cannot be resolved.',
      );
    }

    final Reference ref = _storage
        .ref()
        .child(getBaseUrl(CreateDatabaseCollections.coversFolder))
        .child(name);

    await ref.putFile(image);
    return ref.getDownloadURL();
  }

  /// Function Name: [createDatabase]
  ///
  /// Purpose: Write the document plus its access grants, and return the
  /// record re-read from the server so the caller gets the resolved
  /// `created_at` instead of the sentinel `FieldValue.serverTimestamp()`
  /// it sent.
  ///
  /// The parent document and the grants go in ONE `WriteBatch`. Firestore
  /// applies a batch atomically, so the alternative — add the parent, then
  /// loop the grants — could leave a database that exists but grants nobody
  /// access if the app died between the two, and that record looks perfectly
  /// valid from the list screen.
  ///
  /// Grants are a subcollection rather than an array field because a
  /// department grant embeds every one of its members; a few hundred of
  /// those would approach the 1 MB document ceiling.
  Future<DatabaseModel> createDatabase(
    DatabaseModel model, {
    List<DatabaseAccessGrant> grants = const <DatabaseAccessGrant>[],
  }) async {
    final DocumentReference<Map<String, dynamic>> doc = _collection.doc();
    final WriteBatch batch = _firestore.batch();

    batch.set(doc, model.toCreateMap());

    for (final DatabaseAccessGrant grant in grants) {
      batch.set(
        doc.collection(CreateDatabaseCollections.accessGrants).doc(),
        grant.toMap(),
      );
    }

    await batch.commit();

    final DocumentSnapshot<Map<String, dynamic>> saved = await doc.get();
    return DatabaseModel.fromSnapshot(saved);
  }

  /// Function Name: [updateDatabase]
  ///
  /// Purpose: Finish — or re-park — a record the wizard was REOPENED on: the
  /// draft resume path. ADDED 16/8/2026.
  ///
  /// This is what stops a resumed draft from becoming a second database. Until
  /// now the wizard had exactly one write, [createDatabase], so reopening a
  /// draft and pressing "Grant Access" would have written a NEW document and
  /// left the original sitting under Drafts for ever.
  ///
  /// The grants are REPLACED, not merged: the wizard hands back the complete
  /// intended access, and the user may well have removed people since the
  /// draft was parked, so a merge would silently resurrect them. The deletes
  /// and the re-adds share the parent's batch, so the record is never briefly
  /// visible granting nobody anything.
  ///
  /// A batch caps at 500 writes. One parent plus the old and new grants is
  /// nowhere near it for a wizard-built draft — a grant is one document per
  /// department, not per person.
  Future<DatabaseModel> updateDatabase(
    String id,
    DatabaseModel model, {
    required List<DatabaseAccessGrant> grants,
  }) async {
    final DocumentReference<Map<String, dynamic>> doc = _collection.doc(id);
    final CollectionReference<Map<String, dynamic>> grantsRef =
        doc.collection(CreateDatabaseCollections.accessGrants);

    final QuerySnapshot<Map<String, dynamic>> existing = await grantsRef.get();

    final WriteBatch batch = _firestore.batch();
    batch.update(doc, model.toUpdateMap());

    for (final QueryDocumentSnapshot<Map<String, dynamic>> grant
        in existing.docs) {
      batch.delete(grant.reference);
    }
    for (final DatabaseAccessGrant grant in grants) {
      batch.set(grantsRef.doc(), grant.toMap());
    }

    await batch.commit();

    final DocumentSnapshot<Map<String, dynamic>> saved = await doc.get();
    return DatabaseModel.fromSnapshot(saved);
  }

  /// Function Name: [fetchGrants]
  ///
  /// Purpose: Read the access rules under [databaseId] back into the wizard's
  /// own entity. ADDED 16/8/2026 for the draft resume path.
  ///
  /// A parked draft keeps the people it had picked, so reopening it has to put
  /// them back on screen — otherwise "Save For Later" would quietly mean
  /// "start the member list again later".
  ///
  /// db2 has a `fetchGrants` too, but it returns `DatabaseAccessGrantRecord`:
  /// grants WITH their document ids and their removed-member rows, which is
  /// what the access-EDITING screens need. The wizard has no concept of
  /// either — it rewrites the whole subcollection — so it reads the plain
  /// entity here rather than depending on db2, which would point the module's
  /// dependency arrow backwards.
  Future<List<DatabaseAccessGrant>> fetchGrants(String databaseId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection
        .doc(databaseId)
        .collection(CreateDatabaseCollections.accessGrants)
        .get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            DatabaseAccessGrant.fromMap(doc.data()))
        .toList(growable: false);
  }

  /// Function Name: [listDatabases]
  ///
  /// Purpose: Read the collection for the Database Builder list, newest
  /// first.
  ///
  /// Capped at 200: the list screen has no pagination in the Figma, and an
  /// uncapped read on a large org would pull the whole collection into
  /// memory to render one screenful. Raise it when paging exists.
  Future<List<DatabaseModel>> listDatabases() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection
        .orderBy(DatabaseModel.fCreatedAt, descending: true)
        .limit(200)
        .get();

    return snapshot.docs.map(DatabaseModel.fromSnapshot).toList(growable: false);
  }

  /// Function Name: [titleExists]
  ///
  /// Purpose: True when either title is already taken.
  ///
  /// Two queries rather than one: Firestore has no OR across different
  /// fields in a single `where` chain, and `Filter.or` would need a composite
  /// index per pair.
  ///
  /// [excludeId] is the record allowed to keep its own name — the draft the
  /// wizard was reopened on. ADDED 16/8/2026: without it, resuming a draft and
  /// pressing the primary button matched the draft against ITSELF and was
  /// rejected as a duplicate title, which is unarguable and unfixable from the
  /// screen. The limit rises to two when it is supplied, because the one hit
  /// may be the excluded record and a limit of one would then hide a genuine
  /// clash behind it.
  Future<bool> titleExists({
    required String titleEn,
    required String titleAr,
    String? excludeId,
  }) async {
    final int limit = excludeId == null ? 1 : 2;

    bool matchesAnother(QuerySnapshot<Map<String, dynamic>> snapshot) =>
        snapshot.docs.any(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              doc.id != excludeId,
        );

    final QuerySnapshot<Map<String, dynamic>> byEn = await _collection
        .where(DatabaseModel.fTitleEnLower, isEqualTo: titleEn.toLowerCase())
        .limit(limit)
        .get();
    if (matchesAnother(byEn)) return true;

    final QuerySnapshot<Map<String, dynamic>> byAr = await _collection
        .where(DatabaseModel.fTitleArLower, isEqualTo: titleAr.toLowerCase())
        .limit(limit)
        .get();
    return matchesAnother(byAr);
  }

  /// Function Name: [softDeleteDatabase]
  ///
  /// Purpose: Move the record [id] into the Deleted chip — the "Delete" row of
  /// the card's "..." menu. CHANGED 16/8/2026 from a real document delete.
  ///
  /// Nothing is removed. `status` becomes `deleted`, `previous_status` records
  /// where the record was so Restore can put it back, and `deleted_at` stamps
  /// when. The `Access_Grants` subcollection is left completely alone: those
  /// grants ARE the record, and sweeping them would make Restore hand back a
  /// database that had quietly lost everyone's access.
  ///
  /// [previousStatus] is passed in rather than re-read here. The caller is
  /// holding the record it just showed the user, so a read would only buy a
  /// chance for the two to disagree. A `deleted` value would be a bug — a
  /// double delete — so it is refused rather than stored, otherwise Restore
  /// would put the record back into the Deleted chip.
  Future<void> softDeleteDatabase(
    String id, {
    required DatabaseStatus previousStatus,
  }) async {
    await _collection.doc(id).update(<String, dynamic>{
      DatabaseModel.fStatus: DatabaseStatus.deleted.storageKey,
      DatabaseModel.fPreviousStatus:
          (previousStatus.isRestorable ? previousStatus : DatabaseStatus.active)
              .storageKey,
      DatabaseModel.fDeletedAt: FieldValue.serverTimestamp(),
    });
  }

  /// Function Name: [restoreDatabase]
  ///
  /// Purpose: Put a soft-deleted record back — "Restore" on the "..." menu.
  /// ADDED 16/8/2026.
  ///
  /// [status] is the caller's `DatabaseEntity.restoreTarget`, so a deleted
  /// draft returns to Drafts and a deleted finished database returns to the
  /// access chips.
  ///
  /// The two markers are REMOVED from the document rather than nulled: as far
  /// as every reader is concerned a restored record has never been deleted,
  /// and a leftover `previous_status: null` would make the next delete look
  /// like it had already run.
  Future<void> restoreDatabase(
    String id, {
    required DatabaseStatus status,
  }) async {
    await _collection.doc(id).update(<String, dynamic>{
      DatabaseModel.fStatus: status.storageKey,
      DatabaseModel.fPreviousStatus: FieldValue.delete(),
      DatabaseModel.fDeletedAt: FieldValue.delete(),
    });
  }

  /// Function Name: [purgeDatabase]
  ///
  /// Purpose: Permanently delete the record [id] together with its access
  /// grants. This is the OLD `deleteDatabase`; nothing in the UI calls it now
  /// that the card menu soft-deletes.
  ///
  /// Kept rather than removed because the Deleted chip is exactly where a
  /// "Delete Permanently" action belongs, and because this is the only correct
  /// way to remove one of these documents. The grants are read first and
  /// deleted in the SAME batch as the parent: Firestore does not cascade, so
  /// `doc(id).delete()` on its own would leave the `Access_Grants`
  /// subcollection intact — invisible to every screen (the list reads parents
  /// only) yet still holding employee ids, and silently re-adopted if a future
  /// document ever landed on that same id.
  ///
  /// One batch rather than two passes so a mid-delete failure cannot leave a
  /// database whose grants are already gone — the card would still be on
  /// screen claiming access it can no longer prove.
  Future<void> purgeDatabase(String id) async {
    final DocumentReference<Map<String, dynamic>> doc = _collection.doc(id);

    final QuerySnapshot<Map<String, dynamic>> grants =
        await doc.collection(CreateDatabaseCollections.accessGrants).get();

    final WriteBatch batch = _firestore.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> grant
        in grants.docs) {
      batch.delete(grant.reference);
    }
    batch.delete(doc);

    await batch.commit();
  }
}
