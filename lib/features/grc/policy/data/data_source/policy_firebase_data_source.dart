/// Module: Policy Management
/// Description: Firebase (Cloud Firestore) implementation of the Policy
///              data source. Handles all Firestore read/write operations for
///              Policy documents. Controls are handled separately by
///              [ControlFirebaseDataSource] since they now live in their own
///              subcollection under each Policy document.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: cloud_firestore, PolicyDataSource, PolicyModel, PolicyStatus
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Migrated to the new schema: soft-delete /
///                                restore now toggle PolicyStatus.removed
///                                instead of an Is_Deleted flag, and the
///                                nested Controls handling was removed
///                                (Controls now live in their own
///                                subcollection managed by
///                                ControlFirebaseDataSource) (Mohamed Magdy
///                                Abdelkhalek)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/policy/data/models/policy_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';

import 'policy_data_source.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_firebase_data_source.dart
/// Purpose: Contains the PolicyFirebaseDataSource class, the concrete
///          Cloud Firestore implementation of [PolicyDataSource].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyFirebaseDataSource]
///
/// purpose: implement [PolicyDataSource] using Cloud Firestore as the
///          storage backend. Every document is stored using the keys
///          produced by [PolicyModel.toJson] / [PolicyModel.fromJson].
///          Firestore path: GRC_Modules/{Module_ID}/Policies/{Policy_ID}
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class PolicyFirebaseDataSource implements PolicyDataSource {
  PolicyFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath => GrcFirebasePaths.modulesCollection;
  static const String _policiesSubcollectionPath = 'Policies';

  /// function name: [collection]
  ///
  /// purpose: expose the Policies subcollection reference for a given
  ///          Module so other data sources (e.g. [ControlFirebaseDataSource])
  ///          can build the nested Controls path off of the same Policy
  ///          document without duplicating the base path logic.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module document
  ///
  /// return type: [CollectionReference<Map<String, dynamic>>] - the Policies subcollection reference
  CollectionReference<Map<String, dynamic>> collection(String moduleId) =>
      _collection(moduleId);

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_policiesSubcollectionPath);

  @override
  Future<PolicyModel> create(PolicyModel model,
      {required String moduleId}) async {
    try {
      await _collection(moduleId).doc(model.id).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Policy: $e');
    }
  }

  @override
  Future<PolicyModel?> get(String id, {required String moduleId}) async {
    try {
      final doc = await _collection(moduleId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return PolicyModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Policy: $e');
    }
  }

  @override
  Future<List<PolicyModel>> getAll({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    try {
      final snapshot = await _collection(moduleId).get();
      final models =
          snapshot.docs.map((doc) => PolicyModel.fromJson(doc.data()));
      if (includeRemoved) return models.toList();
      return models
          .where((m) => m.status.last != PolicyStatus.removed.value)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch the Policies: $e');
    }
  }

  @override
  Future<PolicyModel> update(PolicyModel updatedModel,
      {required String moduleId}) async {
    try {
      final docRef = _collection(moduleId).doc(updatedModel.id);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a Policy that does not exist (id: ${updatedModel.id})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the Policy: $e');
    }
  }

  @override
  Future<PolicyModel> delete(
    String id, {
    required String moduleId,
    required String editorId,
  }) async {
    try {
      final current = await get(id, moduleId: moduleId);
      if (current == null) {
        throw Exception(
          'Cannot delete a Policy that does not exist (id: $id)',
        );
      }
      final removedModel = current.copyWithUpdate(
        status: PolicyStatus.removed,
        editorId: editorId,
      );
      await _collection(moduleId).doc(id).set(removedModel.toJson());
      return removedModel;
    } catch (e) {
      throw Exception('Failed to delete the Policy: $e');
    }
  }

  @override
  Future<PolicyModel> restore(
    String id, {
    required String moduleId,
    required String editorId,
  }) async {
    try {
      final current = await get(id, moduleId: moduleId);
      if (current == null) {
        throw Exception(
          'Cannot restore a Policy that does not exist (id: $id)',
        );
      }
      final restoredModel = current.copyWithUpdate(
        status: _statusBeforeRemoval(current),
        editorId: editorId,
      );
      await _collection(moduleId).doc(id).set(restoredModel.toJson());
      return restoredModel;
    } catch (e) {
      throw Exception('Failed to restore the Policy: $e');
    }
  }

  /// function name: [_statusBeforeRemoval]
  ///
  /// purpose: walk the Policy's status history backwards from the entry
  ///          right before the latest one, looking for the last status that
  ///          was not [PolicyStatus.removed], so restoring a Policy puts it
  ///          back where it was instead of always defaulting to Draft.
  ///
  /// parameters:
  ///            [PolicyModel] model: the current Policy model (latest status assumed to be Removed)
  ///
  /// return type: [PolicyStatus] - the status to restore to, or [PolicyStatus.draft] if no prior status is found
  PolicyStatus _statusBeforeRemoval(PolicyModel model) {
    for (var i = model.status.length - 2; i >= 0; i--) {
      final previous = PolicyStatus.fromString(model.status[i]);
      if (previous != PolicyStatus.removed) return previous;
    }
    return PolicyStatus.draft;
  }
}
