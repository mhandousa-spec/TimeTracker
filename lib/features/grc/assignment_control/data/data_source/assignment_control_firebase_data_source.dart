/// Module: Assignment Controls (Control Champion)
/// Description: Cloud Firestore implementation of
///              [AssignmentControlDataSource]. Firestore path:
///              GRC Modules/{Module_ID}/Assignment Controls/{Assignment_Controls_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/models/assignment_control_model.dart';

import 'assignment_control_data_source.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

class AssignmentControlFirebaseDataSource implements AssignmentControlDataSource {
  AssignmentControlFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath =>
      GrcFirebasePaths.modulesCollection;
  static const String _assignmentControlsSubcollectionPath =
      'Assignment Controls';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_assignmentControlsSubcollectionPath);

  @override
  Future<AssignmentControlModel?> get(
    String id, {
    required String moduleId,
  }) async {
    try {
      final doc = await _collection(moduleId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return AssignmentControlModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Assignment Control: $e');
    }
  }

  @override
  Future<AssignmentControlModel> create(
    AssignmentControlModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.submissionId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Assignment Control: $e');
    }
  }

  @override
  Future<AssignmentControlModel> update(
    AssignmentControlModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.submissionId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to update the Assignment Control: $e');
    }
  }
}
