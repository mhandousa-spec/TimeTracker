/// Module: My Audits (Control Owner)
/// Description: Cloud Firestore implementation of [MyAuditDataSource].
///              Firestore path: GRC Modules/{Module_ID}/My Audit/{My_Audit_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/my_audit/data/models/my_audit_model.dart';

import 'my_audit_data_source.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

class MyAuditFirebaseDataSource implements MyAuditDataSource {
  MyAuditFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath => GrcFirebasePaths.modulesCollection;
  static const String _myAuditSubcollectionPath = 'My Audit';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_myAuditSubcollectionPath);

  @override
  Future<MyAuditModel?> get(String id, {required String moduleId}) async {
    try {
      final doc = await _collection(moduleId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return MyAuditModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the My Audit: $e');
    }
  }

  @override
  Future<List<MyAuditModel>> getAll({required String moduleId}) async {
    try {
      final snapshot = await _collection(moduleId).get();
      return snapshot.docs
          .map((doc) => MyAuditModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch the My Audits: $e');
    }
  }

  @override
  Future<MyAuditModel> create(MyAuditModel model,
      {required String moduleId}) async {
    try {
      await _collection(moduleId).doc(model.auditId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the My Audit: $e');
    }
  }

  @override
  Future<MyAuditModel> update(MyAuditModel model,
      {required String moduleId}) async {
    try {
      await _collection(moduleId).doc(model.auditId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to update the My Audit: $e');
    }
  }
}
