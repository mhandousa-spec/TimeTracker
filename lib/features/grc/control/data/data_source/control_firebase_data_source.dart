/// Module: Policy Management
/// Description: Firebase (Cloud Firestore) implementation of the Control
///              data source. Handles all Firestore read/write operations
///              for Control documents nested under a Policy document.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: cloud_firestore, ControlDataSource, ControlModel,
///               PolicyFirebaseDataSource
/// Revision History: 2026-07-14 - Initial creation, split out of the old
///                                nested-controls handling in
///                                PolicyFirebaseDataSource now that Controls
///                                are their own subcollection (Mohamed
///                                Magdy Abdelkhalek)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/grc/control/data/models/control_model.dart';

import 'control_data_source.dart';
import '../../../policy/data/data_source/policy_firebase_data_source.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_firebase_data_source.dart
/// Purpose: Contains the ControlFirebaseDataSource class, the concrete
///          Cloud Firestore implementation of [ControlDataSource].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 14/7/2026

/// class name: [ControlFirebaseDataSource]
///
/// purpose: implement [ControlDataSource] using Cloud Firestore as the
///          storage backend. Every document is stored using the keys
///          produced by [ControlModel.toJson] / [ControlModel.fromJson].
///          Firestore path: GRC_Modules/{Module_ID}/Policies/{Policy_ID}/
///          Controls/{Control_ID}. Reuses
///          [PolicyFirebaseDataSource.collection] to reach the parent
///          Policy document so both data sources always agree on the same
///          base path.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 14/7/2026
class ControlFirebaseDataSource implements ControlDataSource {
  ControlFirebaseDataSource({
    FirebaseFirestore? firestore,
    PolicyFirebaseDataSource? policyDataSource,
  }) : _policyDataSource =
            policyDataSource ?? PolicyFirebaseDataSource(firestore: firestore);

  final PolicyFirebaseDataSource _policyDataSource;

  static const String _controlsSubcollectionPath = 'Controls';

  CollectionReference<Map<String, dynamic>> _collection(
    String moduleId,
    String policyId,
  ) =>
      _policyDataSource
          .collection(moduleId)
          .doc(policyId)
          .collection(_controlsSubcollectionPath);

  @override
  Future<ControlModel> create(
    ControlModel model, {
    required String moduleId,
    required String policyId,
  }) async {
    try {
      await _collection(moduleId, policyId).doc(model.id).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Control: $e');
    }
  }

  @override
  Future<ControlModel?> get(
    String id, {
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final doc = await _collection(moduleId, policyId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return ControlModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Control: $e');
    }
  }

  @override
  Future<List<ControlModel>> getAll({
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final snapshot = await _collection(moduleId, policyId).get();
      return snapshot.docs
          .map((doc) => ControlModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch the Controls: $e');
    }
  }

  @override
  Future<ControlModel> update(
    ControlModel updatedModel, {
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final docRef = _collection(moduleId, policyId).doc(updatedModel.id);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a Control that does not exist (id: ${updatedModel.id})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the Control: $e');
    }
  }

  @override
  Future<void> delete(
    String id, {
    required String moduleId,
    required String policyId,
  }) async {
    try {
      await _collection(moduleId, policyId).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete the Control: $e');
    }
  }
}
