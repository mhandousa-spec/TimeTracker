// ****************** FILE INFO ******************
// File Name: crm_category_and_tags_remote_data_source.dart
// Purpose: Firestore remote data source for CRM Activity Categories & Tags
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';

class CrmCategoryAndTagsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmCategoryAndTagsRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Categories CRUD
  // ---------------------------------------------------------------------------

  Stream<Either<Failure, List<CrmCategoryModel>>> watchCategories() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmCategoryModel> items = snapshot.docs
            .map((doc) => CrmCategoryModel.fromMap(doc.data()))
            .where((cat) => !cat.isDeleted)
            .toList()
          ..sort(_sortCategories);
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmCategoryModel>> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<CrmCategoryTypeModel> types,
    String? categoryId,
  }) async {
    try {
      final String id = categoryId ??
          _firestore.collection(CrmFirestorePaths.activityCategories).doc().id;
      final int order = await _getNextCategoryOrder();
      final bool isActive = status.toLowerCase() == 'active';
      final CrmCategoryModel category = CrmCategoryModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        status: status,
        isActive: isActive,
        isDeleted: false,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
        types: types,
      );

      await _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .doc(category.id)
          .set(category.toMap());

      return Right(category);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateCategory({
    required CrmCategoryModel category,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .doc(category.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Category not found: ${category.id}'));
      }

      final CrmCategoryModel existing =
          CrmCategoryModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final CrmCategoryModel updated = category.copyWith(audit: audit);

      await _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .doc(category.id)
          .update(updated.toMap());

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeCategory({
    required CrmCategoryModel category,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .doc(category.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Category not found: ${category.id}'));
      }

      final CrmCategoryModel existing =
          CrmCategoryModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final Map<String, dynamic> updatePayload = {
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.STATUS_KEY: 'deleted',
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      };

      await _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .doc(category.id)
          .update(updatePayload);

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> toggleCategoryStatus({
    required String categoryId,
    required bool isActive,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .doc(categoryId)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Category not found: $categoryId'));
      }

      final CrmCategoryModel existing =
          CrmCategoryModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final String newStatus = isActive ? 'active' : 'inactive';
      await _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .doc(categoryId)
          .update({
        CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
        CrmFirestoreKeys.STATUS_KEY: newStatus,
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      });

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Tags CRUD
  // ---------------------------------------------------------------------------

  Stream<Either<Failure, List<CrmTagModel>>> watchTags() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.activityTags)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmTagModel> items = snapshot.docs
            .map((doc) => CrmTagModel.fromMap(doc.data()))
            .where((tag) => !tag.isDeleted)
            .toList()
          ..sort(_sortTags);
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmTagModel>> createTag({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    String? tagId,
  }) async {
    try {
      final String id = tagId ??
          _firestore.collection(CrmFirestorePaths.activityTags).doc().id;
      final int order = await _getNextTagOrder();
      final bool isActive = status.toLowerCase() == 'active';
      final CrmTagModel tag = CrmTagModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        status: status,
        isActive: isActive,
        isDeleted: false,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );

      await _firestore
          .collection(CrmFirestorePaths.activityTags)
          .doc(tag.id)
          .set(tag.toMap());

      return Right(tag);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateTag({
    required CrmTagModel tag,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.activityTags)
          .doc(tag.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Tag not found: ${tag.id}'));
      }

      final CrmTagModel existing = CrmTagModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final CrmTagModel updated = tag.copyWith(audit: audit);

      await _firestore
          .collection(CrmFirestorePaths.activityTags)
          .doc(tag.id)
          .update(updated.toMap());

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeTag({
    required CrmTagModel tag,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.activityTags)
          .doc(tag.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Tag not found: ${tag.id}'));
      }

      final CrmTagModel existing = CrmTagModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final Map<String, dynamic> updatePayload = {
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.STATUS_KEY: 'deleted',
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      };

      await _firestore
          .collection(CrmFirestorePaths.activityTags)
          .doc(tag.id)
          .update(updatePayload);

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> toggleTagStatus({
    required String tagId,
    required bool isActive,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.activityTags)
          .doc(tagId)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Tag not found: $tagId'));
      }

      final CrmTagModel existing = CrmTagModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final String newStatus = isActive ? 'active' : 'inactive';
      await _firestore
          .collection(CrmFirestorePaths.activityTags)
          .doc(tagId)
          .update({
        CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
        CrmFirestoreKeys.STATUS_KEY: newStatus,
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      });

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<int> _getNextCategoryOrder() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.activityCategories)
          .get();
      int highest = 0;
      for (final doc in snapshot.docs) {
        final dynamic raw = doc.data()[CrmFirestoreKeys.ORDER_KEY];
        if (raw is int && raw > highest) {
          highest = raw;
        }
      }
      return highest + 1;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _getNextTagOrder() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(CrmFirestorePaths.activityTags).get();
      int highest = 0;
      for (final doc in snapshot.docs) {
        final dynamic raw = doc.data()[CrmFirestoreKeys.ORDER_KEY];
        if (raw is int && raw > highest) {
          highest = raw;
        }
      }
      return highest + 1;
    } catch (_) {
      return 0;
    }
  }

  int _sortCategories(CrmCategoryModel a, CrmCategoryModel b) {
    if (a.order != b.order) {
      return a.order.compareTo(b.order);
    }
    return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
  }

  int _sortTags(CrmTagModel a, CrmTagModel b) {
    if (a.order != b.order) {
      return a.order.compareTo(b.order);
    }
    return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
  }
}
