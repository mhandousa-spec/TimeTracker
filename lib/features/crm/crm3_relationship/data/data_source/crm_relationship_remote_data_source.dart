// ****************** FILE INFO ******************
// File Name: crm_relationship_remote_data_source.dart
// Purpose: Firestore data source for CRM relationship category CRUD logic
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_type_model.dart';

class CrmRelationshipRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmRelationshipRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<Either<Failure, List<CrmRelationshipCategoryModel>>>
      watchRelationshipCategories() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.relationshipCategories)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmRelationshipCategoryModel> items = snapshot.docs
            .map((doc) => CrmRelationshipCategoryModel.fromMap(doc.data()))
            .where((category) => !category.isDeleted)
            .toList()
          ..sort(_sortCategories);
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmRelationshipCategoryModel>>
      createRelationshipCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<Map<String, String>> types,
    String iconUrl = '',
    String? categoryId,
  }) async {
    try {
      final String id = categoryId ??
          _firestore
              .collection(CrmFirestorePaths.relationshipCategories)
              .doc()
              .id;
      final int order = await _getNextRelationshipOrder();
      final bool isActive = status.toLowerCase() == 'active';
      final CrmRelationshipCategoryModel category =
          CrmRelationshipCategoryModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        status: status,
        iconUrl: iconUrl,
        isActive: isActive,
        isDeleted: false,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
        types: _mapTypes(types),
      );

      await _firestore
          .collection(CrmFirestorePaths.relationshipCategories)
          .doc(category.id)
          .set(category.toMap());

      return Right(category);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateRelationshipCategory({
    required CrmRelationshipCategoryModel category,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.relationshipCategories)
          .doc(category.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(
          FeatureFailure('Relationship category not found: ${category.id}'),
        );
      }

      final CrmRelationshipCategoryModel existing =
          CrmRelationshipCategoryModel.fromMap(snapshot.data()!);
      final CrmRelationshipCategoryModel updated = category.copyWith(
        audit: (existing.audit ?? CrmAuditModel.now(userEmail: changedBy))
            .markUpdated(userEmail: changedBy),
      );

      await _firestore
          .collection(CrmFirestorePaths.relationshipCategories)
          .doc(updated.id)
          .set(updated.toMap(), SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeRelationshipCategory({
    required CrmRelationshipCategoryModel category,
    required String changedBy,
  }) async {
    final Timestamp now = Timestamp.now();
    final String normalizedChangedBy = changedBy.trim().toLowerCase();

    try {
      await _firestore
          .collection(CrmFirestorePaths.relationshipCategories)
          .doc(category.id)
          .set(
        {
          CrmFirestoreKeys.STATUS_KEY: 'deleted',
          CrmFirestoreKeys.IS_ACTIVE_KEY: false,
          CrmFirestoreKeys.IS_DELETED_KEY: true,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
              now,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
              normalizedChangedBy,
        },
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  List<CrmRelationshipTypeModel> _mapTypes(List<Map<String, String>> types) {
    return types
        .map(
          (type) => CrmRelationshipTypeModel(
            id: (type[CrmFirestoreKeys.ID_KEY] ?? '').trim().isNotEmpty
                ? type[CrmFirestoreKeys.ID_KEY]!.trim()
                : 'relationship_type_${DateTime.now().microsecondsSinceEpoch}'
                    '_${types.indexOf(type)}',
            nameEn: (type[CrmFirestoreKeys.NAME_EN_KEY] ?? '').trim(),
            nameAr: (type[CrmFirestoreKeys.NAME_AR_KEY] ?? '').trim(),
          ),
        )
        .toList();
  }

  Future<int> _getNextRelationshipOrder() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(CrmFirestorePaths.relationshipCategories)
        .get();
    if (snapshot.docs.isEmpty) return 0;
    final List<int> orders = snapshot.docs
        .map(
          (doc) =>
              int.tryParse(
                (doc.data()[CrmFirestoreKeys.ORDER_KEY] ?? 0).toString(),
              ) ??
              0,
        )
        .toList();
    orders.sort();
    return orders.last + 1;
  }

  static int _sortCategories(
    CrmRelationshipCategoryModel a,
    CrmRelationshipCategoryModel b,
  ) {
    final int orderCompare = a.order.compareTo(b.order);
    if (orderCompare != 0) return orderCompare;
    final DateTime aUpdated = a.audit?.updatedAt ?? DateTime(1970);
    final DateTime bUpdated = b.audit?.updatedAt ?? DateTime(1970);
    final int updatedCompare = bUpdated.compareTo(aUpdated);
    if (updatedCompare != 0) return updatedCompare;
    return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
  }
}
