// ****************** FILE INFO ******************
// File Name: crm_deals_remote_data_source.dart
// Purpose: Firestore remote data source for CRM Deal Categories & Stages
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_stage_checklist_item_model.dart';

class CrmDealsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmDealsRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Categories CRUD
  // ---------------------------------------------------------------------------

  Stream<Either<Failure, List<CrmDealCategoryModel>>> watchCategories() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.dealCategories)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmDealCategoryModel> items = snapshot.docs
            .map((doc) => CrmDealCategoryModel.fromMap(doc.data()))
            .where((cat) => !cat.isDeleted)
            .toList()
          ..sort(_sortCategories);
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmDealCategoryModel>> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    String? categoryId,
  }) async {
    try {
      final String id = categoryId ??
          _firestore.collection(CrmFirestorePaths.dealCategories).doc().id;
      final int order = await _getNextCategoryOrder();
      final CrmDealCategoryModel category = CrmDealCategoryModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        status: status,
        isDeleted: false,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );

      await _firestore
          .collection(CrmFirestorePaths.dealCategories)
          .doc(category.id)
          .set(category.toMap());

      return Right(category);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateCategory({
    required CrmDealCategoryModel category,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.dealCategories)
          .doc(category.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Category not found: ${category.id}'));
      }

      final CrmDealCategoryModel existing =
          CrmDealCategoryModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final CrmDealCategoryModel updated = category.copyWith(audit: audit);

      await _firestore
          .collection(CrmFirestorePaths.dealCategories)
          .doc(category.id)
          .update(updated.toMap());

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeCategory({
    required CrmDealCategoryModel category,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.dealCategories)
          .doc(category.id)
          .get();

      final CrmAuditModel audit = (snapshot.exists && snapshot.data() != null)
          ? (CrmDealCategoryModel.fromMap(snapshot.data()!).audit ??
                  CrmAuditModel.now(userEmail: changedBy))
              .copyWith(
              updatedAt: DateTime.now(),
              updatedBy: changedBy.trim().toLowerCase(),
            )
          : CrmAuditModel.now(userEmail: changedBy);

      await _firestore
          .collection(CrmFirestorePaths.dealCategories)
          .doc(category.id)
          .update({
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      });

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
      final DocumentReference<Map<String, dynamic>> ref = _firestore
          .collection(CrmFirestorePaths.dealCategories)
          .doc(categoryId);
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Category not found: $categoryId'));
      }

      final CrmDealCategoryModel existing =
          CrmDealCategoryModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      await ref.update({
        CrmFirestoreKeys.STATUS_KEY: isActive ? 'active' : 'inactive',
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      });

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Stages CRUD
  // ---------------------------------------------------------------------------

  Stream<Either<Failure, List<CrmDealStageModel>>> watchStages() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.dealStages)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmDealStageModel> items = snapshot.docs
            .map((doc) => CrmDealStageModel.fromMap(doc.data()))
            .where((stg) => !stg.isDeleted)
            .toList()
          ..sort(_sortStages);
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmDealStageModel>> createStage({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    int probability = 0,
    String color = '',
    int? order,
    List<CrmStageChecklistItemModel> checklistItems =
        const <CrmStageChecklistItemModel>[],
    String? stageId,
  }) async {
    try {
      final String id = stageId ??
          _firestore.collection(CrmFirestorePaths.dealStages).doc().id;
      final int resolvedOrder = order ?? await _getNextStageOrder();
      final CrmDealStageModel stage = CrmDealStageModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        status: status,
        probability: probability,
        color: color,
        isDeleted: false,
        order: resolvedOrder,
        checklistItems: checklistItems,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );

      await _firestore
          .collection(CrmFirestorePaths.dealStages)
          .doc(stage.id)
          .set(stage.toMap());

      return Right(stage);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateStage({
    required CrmDealStageModel stage,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.dealStages)
          .doc(stage.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Stage not found: ${stage.id}'));
      }

      final CrmDealStageModel existing =
          CrmDealStageModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final CrmDealStageModel updated = stage.copyWith(audit: audit);

      await _firestore
          .collection(CrmFirestorePaths.dealStages)
          .doc(stage.id)
          .update(updated.toMap());

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeStage({
    required CrmDealStageModel stage,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.dealStages)
          .doc(stage.id)
          .get();

      final CrmAuditModel audit = (snapshot.exists && snapshot.data() != null)
          ? (CrmDealStageModel.fromMap(snapshot.data()!).audit ??
                  CrmAuditModel.now(userEmail: changedBy))
              .copyWith(
              updatedAt: DateTime.now(),
              updatedBy: changedBy.trim().toLowerCase(),
            )
          : CrmAuditModel.now(userEmail: changedBy);

      await _firestore
          .collection(CrmFirestorePaths.dealStages)
          .doc(stage.id)
          .update({
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      });

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> toggleStageStatus({
    required String stageId,
    required bool isActive,
    required String changedBy,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> ref =
          _firestore.collection(CrmFirestorePaths.dealStages).doc(stageId);
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Stage not found: $stageId'));
      }

      final CrmDealStageModel existing =
          CrmDealStageModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      await ref.update({
        CrmFirestoreKeys.STATUS_KEY: isActive ? 'active' : 'inactive',
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

  int _sortCategories(CrmDealCategoryModel a, CrmDealCategoryModel b) {
    if (a.order != b.order) return a.order.compareTo(b.order);
    final DateTime aCreated = a.audit?.createdAt ?? DateTime(1970);
    final DateTime bCreated = b.audit?.createdAt ?? DateTime(1970);
    final int createdCompare = aCreated.compareTo(bCreated);
    if (createdCompare != 0) return createdCompare;
    return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
  }

  int _sortStages(CrmDealStageModel a, CrmDealStageModel b) {
    if (a.order != b.order) return a.order.compareTo(b.order);
    final DateTime aCreated = a.audit?.createdAt ?? DateTime(1970);
    final DateTime bCreated = b.audit?.createdAt ?? DateTime(1970);
    final int createdCompare = aCreated.compareTo(bCreated);
    if (createdCompare != 0) return createdCompare;
    return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
  }

  Future<int> _getNextCategoryOrder() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(CrmFirestorePaths.dealCategories).get();
      if (snapshot.docs.isEmpty) return 0;
      int highest = 0;
      for (final doc in snapshot.docs) {
        final dynamic raw = doc.data()[CrmFirestoreKeys.ORDER_KEY];
        final int val = int.tryParse(raw?.toString() ?? '0') ?? 0;
        if (val > highest) {
          highest = val;
        }
      }
      return highest + 1;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _getNextStageOrder() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(CrmFirestorePaths.dealStages).get();
      if (snapshot.docs.isEmpty) return 0;
      int highest = 0;
      for (final doc in snapshot.docs) {
        final dynamic raw = doc.data()[CrmFirestoreKeys.ORDER_KEY];
        final int val = int.tryParse(raw?.toString() ?? '0') ?? 0;
        if (val > highest) {
          highest = val;
        }
      }
      return highest + 1;
    } catch (_) {
      return 0;
    }
  }
}
