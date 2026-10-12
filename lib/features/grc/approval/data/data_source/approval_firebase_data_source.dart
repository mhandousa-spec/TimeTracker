/// Module: Approvals (Department Manager)
/// Description: Cloud Firestore implementation of [ApprovalDataSource].
///              Firestore path: grc/{Module_ID}/Approvals/{Approval_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/approval/data/models/approval_model.dart';

import 'approval_data_source.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

class ApprovalFirebaseDataSource implements ApprovalDataSource {
  ApprovalFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath => GrcFirebasePaths.modulesCollection;
  static const String _approvalsSubcollectionPath = 'Approvals';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_approvalsSubcollectionPath);

  @override
  Future<ApprovalModel?> get(String id, {required String moduleId}) async {
    try {
      final doc = await _collection(moduleId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return ApprovalModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Approval: $e');
    }
  }

  @override
  Future<List<ApprovalModel>> getAll({required String moduleId}) async {
    try {
      final snapshot = await _collection(moduleId).get();
      return snapshot.docs.map((doc) => ApprovalModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch the Approvals: $e');
    }
  }

  @override
  Future<ApprovalModel> create(
    ApprovalModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.requestId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Approval: $e');
    }
  }

  @override
  Future<ApprovalModel> update(
    ApprovalModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.requestId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to update the Approval: $e');
    }
  }
}
