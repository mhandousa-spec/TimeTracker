// lib/features/grc/control_owner/data/data_source/owner_firebase_data_source.dart
/// Module: Control Owner Management
/// Description: Cloud Firestore implementation of [OwnerDataSource].
///              Firestore path:
///              GRC Modules/{Module_ID}/Control Owners/{Owner_Email}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: cloud_firestore, OwnerDataSource, OwnerModel

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/control_owner/data/models/owner_model.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';

import 'owner_data_source.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

class OwnerFirebaseDataSource implements OwnerDataSource {
  OwnerFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath =>
     GrcFirebasePaths.modulesCollection;
  static const String _ownersSubcollectionPath = 'Control Owners';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_ownersSubcollectionPath);

  @override
  Future<OwnerModel> create(
    OwnerModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.ownerEmail).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Control Owner: $e');
    }
  }

  @override
  Future<OwnerModel?> get(
    String ownerEmail, {
    required String moduleId,
  }) async {
    try {
      final doc = await _collection(moduleId).doc(ownerEmail).get();
      if (!doc.exists || doc.data() == null) return null;
      return OwnerModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Control Owner: $e');
    }
  }

  @override
  Future<List<OwnerModel>> getAll({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    try {
      final snapshot = await _collection(moduleId).get();
      final models =
          snapshot.docs.map((doc) => OwnerModel.fromJson(doc.data()));
      if (includeRemoved) return models.toList();
      return models.where((m) => m.status.last != OwnerStatus.removed.value).toList();
    } catch (e) {
      throw Exception('Failed to fetch the Control Owners: $e');
    }
  }

  @override
  Future<OwnerModel> update(
    OwnerModel updatedModel, {
    required String moduleId,
  }) async {
    try {
      final docRef = _collection(moduleId).doc(updatedModel.ownerEmail);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a Control Owner that does not exist (email: ${updatedModel.ownerEmail})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the Control Owner: $e');
    }
  }
}
