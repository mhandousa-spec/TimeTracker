// ****************** FILE INFO ******************
// File Name: crm_client_relationship_remote_data_source.dart
// Purpose: Remote data source for managing client relationships in Cloud Firestore
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';

class CrmClientRelationshipRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmClientRelationshipRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _relationshipsRef(String clientId) {
    return _firestore.collection(
        '${CrmFirestorePaths.clientRecords}/$clientId/Relationships');
  }

  CollectionReference<Map<String, dynamic>> get _categoriesRef {
    return _firestore.collection(CrmFirestorePaths.relationshipCategories);
  }

  /// Watches all relationship categories from CRM Controls
  Stream<List<CrmRelationshipCategoryModel>> watchCategories() {
    return _categoriesRef
        .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final List<CrmRelationshipCategoryModel> list = [];
      for (final doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        data[CrmFirestoreKeys.ID_KEY] = doc.id;
        final category = CrmRelationshipCategoryModel.fromMap(data);
        if (!category.isDeleted) {
          list.add(category);
        }
      }
      return list;
    });
  }

  /// Watches active relationships for a specific client
  Stream<List<CrmClientRelationshipModel>> watchClientRelationships(
      String clientId) {
    return _relationshipsRef(clientId).snapshots().map((snapshot) {
      final List<CrmClientRelationshipModel> list = [];
      for (final doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        data[CrmFirestoreKeys.ID_KEY] = doc.id;
        final model = CrmClientRelationshipModel.fromMap(data);
        if (!model.isDeleted) {
          list.add(model);
        }
      }
      return list;
    });
  }

  /// Creates a new client relationship
  Future<bool> createRelationship({
    required String clientId,
    required CrmClientRelationshipModel relationship,
    required CrmAuditModel audit,
  }) async {
    try {
      final docRef = _relationshipsRef(clientId).doc();
      final model = relationship.copyWith(
        id: docRef.id,
        clientId: clientId,
        audit: audit,
      );
      await docRef.set(model.toMap());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Updates an existing client relationship
  Future<bool> updateRelationship({
    required String clientId,
    required CrmClientRelationshipModel relationship,
    required CrmAuditModel audit,
  }) async {
    try {
      final model = relationship.copyWith(audit: audit);
      await _relationshipsRef(clientId).doc(model.id).update(model.toMap());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Soft deletes a client relationship
  Future<bool> deleteRelationship({
    required String clientId,
    required String relationshipId,
    required CrmAuditModel audit,
  }) async {
    try {
      await _relationshipsRef(clientId).doc(relationshipId).update({
        CrmFirestoreKeys.STATUS_KEY: 'deleted',
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
