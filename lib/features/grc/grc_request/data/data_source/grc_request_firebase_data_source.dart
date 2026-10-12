/// Module: GRC Request Management
/// Description: Cloud Firestore implementation of [GrcRequestDataSource].
///              Firestore path: GRC Modules/{Module_ID}/Champion Requests/{Request_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: cloud_firestore, GrcRequestDataSource, GrcRequestModel
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/grc_request/data/models/grc_request_model.dart';

import 'grc_request_data_source.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

class GrcRequestFirebaseDataSource implements GrcRequestDataSource {
  GrcRequestFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath =>
      GrcFirebasePaths.modulesCollection;
  static const String _requestsSubcollectionPath = 'Requests';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_requestsSubcollectionPath);

  @override
  Future<GrcRequestModel> create(
    GrcRequestModel model, {
    required String moduleId,
  }) async {
    try {
      final docRef = _collection(moduleId).doc();
      final withId = GrcRequestModel(
        id: docRef.id,
        moduleId: model.moduleId,
        type: model.type,
        status: model.status,
        requestedBy: model.requestedBy,
        requestDate: model.requestDate,
        note: model.note,
        rejectionReason: model.rejectionReason,
        decidedBy: model.decidedBy,
        decisionDate: model.decisionDate,
        currentChampionEmail: model.currentChampionEmail,
        newChampionEmail: model.newChampionEmail,
        controls: model.controls,
        startDate: model.startDate,
        endDate: model.endDate,
        appliedAt: model.appliedAt,
      );
      await docRef.set(withId.toJson());
      return withId;
    } catch (e) {
      throw Exception('Failed to create the GRC Request: $e');
    }
  }

  @override
  Future<List<GrcRequestModel>> getAll({required String moduleId}) async {
    try {
      final snapshot = await _collection(moduleId).get();
      return snapshot.docs
          .map((doc) => GrcRequestModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch the GRC Requests: $e');
    }
  }

  @override
  Future<GrcRequestModel> update(
    GrcRequestModel updatedModel, {
    required String moduleId,
  }) async {
    try {
      final docRef = _collection(moduleId).doc(updatedModel.id);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a GRC Request that does not exist (id: ${updatedModel.id})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the GRC Request: $e');
    }
  }
}
