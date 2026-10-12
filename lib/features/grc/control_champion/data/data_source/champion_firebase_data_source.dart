/// Module: Control Champion Management
/// Description: Cloud Firestore implementation of [ChampionDataSource].
///              Firestore path:
///              GRC Modules/{Module_ID}/Control Champions/{Champion_Email}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: cloud_firestore, ChampionDataSource, ChampionModel

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/control_champion/data/models/champion_model.dart';

import 'champion_data_source.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

class ChampionFirebaseDataSource implements ChampionDataSource {
  ChampionFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath =>
      GrcFirebasePaths.modulesCollection;
  static const String _championsSubcollectionPath = 'Control Champions';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_championsSubcollectionPath);

  @override
  Future<ChampionModel> create(
    ChampionModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.championEmail).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Control Champion: $e');
    }
  }

  @override
  Future<ChampionModel?> get(
    String championEmail, {
    required String moduleId,
  }) async {
    try {
      final doc = await _collection(moduleId).doc(championEmail).get();
      if (!doc.exists || doc.data() == null) return null;
      return ChampionModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Control Champion: $e');
    }
  }

  @override
  Future<List<ChampionModel>> getAll({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    try {
      final snapshot = await _collection(moduleId).get();
      final models =
          snapshot.docs.map((doc) => ChampionModel.fromJson(doc.data()));
      if (includeRemoved) return models.toList();
      return models.where((m) => m.status.last != 'Removed').toList();
    } catch (e) {
      throw Exception('Failed to fetch the Control Champions: $e');
    }
  }

  @override
  Future<ChampionModel> update(
    ChampionModel updatedModel, {
    required String moduleId,
  }) async {
    try {
      final docRef = _collection(moduleId).doc(updatedModel.championEmail);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a Control Champion that does not exist (email: ${updatedModel.championEmail})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the Control Champion: $e');
    }
  }
}
