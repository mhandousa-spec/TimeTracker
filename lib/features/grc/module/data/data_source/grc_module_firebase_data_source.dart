/// Module: GRC Module Management
/// Description: Firebase (Cloud Firestore) implementation of the GRC Module
///              data source.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: cloud_firestore, GRCModuleDataSource, GRCModuleModel
/// Revision History: 2026-06-30 - Initial creation
///                    2026-06-30 - Switched delete() to soft-delete, added restore(), and added
///                                 includeDeleted filtering to getAll() (Mohamed Magdy Abdelkhalek)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/module/data/models/grc_module_model.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_status.dart';

import 'grc_module_data_source.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_firebase_data_source.dart
/// Purpose: Contains the GRCModuleFirebaseDataSource class, the concrete
///          Cloud Firestore implementation of GRCModuleDataSource.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleFirebaseDataSource]
///
/// purpose: implement [GRCModuleDataSource] using Cloud Firestore as the
///          storage backend. Every document is stored using the keys
///          produced by [GRCModuleModel.toJson]/[GRCModuleModel.fromJson].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleFirebaseDataSource implements GRCModuleDataSource {
  GRCModuleFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(GrcFirebasePaths.modulesCollection);

  /// function name: [create]
  ///
  /// purpose: write a brand new GRC Module document to Firestore, using the
  ///          model's id as the document id.
  ///
  /// parameters:
  ///            [GRCModuleModel] model: the model instance to be created
  ///
  /// return type: [Future<GRCModuleModel>] - the created model instance, or throws an Exception on failure
  @override
  Future<GRCModuleModel> create(GRCModuleModel model) async {
    try {
      await _collection.doc(model.moduleId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the GRC Module: $e');
    }
  }

  /// function name: [get]
  ///
  /// purpose: fetch a single GRC Module document from Firestore by its id.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the document to fetch
  ///
  /// return type: [Future<GRCModuleModel?>] - the matching model, null if not found, or throws an Exception on failure
  @override
  Future<GRCModuleModel?> get(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return GRCModuleModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the GRC Module: $e');
    }
  }

  /// function name: [getAll]
  ///
  /// purpose: fetch GRC Module documents stored in the collection.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when false (default), soft-deleted
  ///            records (latest revision has isDeleted = true) are excluded
  ///            from the result
  ///
  /// return type: [Future<List<GRCModuleModel>>] - the list of matching model instances, or throws an Exception on failure
  @override
  Future<List<GRCModuleModel>> getAll({bool includeDeleted = false}) async {
    try {
      final snapshot = await _collection.get();
      final models =
          snapshot.docs.map((doc) => GRCModuleModel.fromJson(doc.data()));
      if (includeDeleted) return models.toList();
      return models
          .where((m) => m.status.last != GrcModuleStatus.removed.value)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch the GRC Modules: $e');
    }
  }

  /// function name: [update]
  ///
  /// purpose: overwrite an existing GRC Module document with [updatedModel],
  ///          which is expected to already contain the newly appended
  ///          revision (produced via [GRCModuleModel.copyWithUpdate]).
  ///
  /// parameters:
  ///            [GRCModuleModel] updatedModel: the model instance with the new revision appended
  ///
  /// return type: [Future<GRCModuleModel>] - the persisted, updated model instance, or throws an Exception if the document does not exist or the write fails
  @override
  Future<GRCModuleModel> update(GRCModuleModel updatedModel) async {
    try {
      final docRef = _collection.doc(updatedModel.moduleId);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a Module that does not exist (id: ${updatedModel.moduleId})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the GRC Module: $e');
    }
  }

  /// function name: [delete]
  ///
  /// purpose: soft-delete a GRC Module document. Reads the current document,
  ///          appends a new revision via [GRCModuleModel.copyWithUpdate] with
  ///          isDeleted = true, then overwrites the document so the full
  ///          history (and the ability to restore it later) is kept intact.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the document to soft-delete
  ///            [String] editorId: id of the user performing the delete
  ///
  /// return type: [Future<GRCModuleModel>] - the model instance after the delete revision has been appended, or throws an Exception on failure
  @override
  Future<GRCModuleModel> delete(String id, {required String editorId}) async {
    try {
      final current = await get(id);
      if (current == null) {
        throw Exception('Cannot delete a Module that does not exist (id: $id)');
      }
      final deletedModel = current.copyWithUpdate(
        status: GrcModuleStatus.removed.value,
        modifierEmail: editorId,
      );
      await _collection.doc(id).set(deletedModel.toJson());
      return deletedModel;
    } catch (e) {
      throw Exception('Failed to delete the GRC Module: $e');
    }
  }

  /// function name: [restore]
  ///
  /// purpose: restore a previously soft-deleted GRC Module document by
  ///          appending a new revision that reinstates whatever status the
  ///          module had immediately before it was removed (the entry right
  ///          before the trailing "Removed" one in its status history) —
  ///          not a hardcoded "Active". If that status was "Inactive", the
  ///          module comes back Inactive; otherwise it's re-derived from
  ///          Activation_Date (see GRCModuleModel.copyWithUpdate), so a
  ///          module that was Scheduled/Active before removal correctly
  ///          reflects the current date on restore.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the document to restore
  ///            [String] editorId: id of the user performing the restore
  ///
  /// return type: [Future<GRCModuleModel>] - the model instance after the restore revision has been appended, or throws an Exception on failure
  @override
  Future<GRCModuleModel> restore(String id, {required String editorId}) async {
    try {
      final current = await get(id);
      if (current == null) {
        throw Exception(
            'Cannot restore a Module that does not exist (id: $id)');
      }
      // status.last is 'Removed'; the entry right before it is what the
      // module's status was immediately prior to being removed.
      final statusBeforeRemoval = current.status[current.status.length - 2];
      final restoredModel = current.copyWithUpdate(
        status: statusBeforeRemoval,
        modifierEmail: editorId,
      );
      await _collection.doc(id).set(restoredModel.toJson());
      return restoredModel;
    } catch (e) {
      throw Exception('Failed to restore the GRC Module: $e');
    }
  }
}
