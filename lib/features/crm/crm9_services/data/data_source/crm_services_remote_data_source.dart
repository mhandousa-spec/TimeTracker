// ****************** FILE INFO ******************
// File Name: crm_services_remote_data_source.dart
// Purpose: Firestore data source for CRM service categories and service items.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';

class CrmServicesRemoteDataSource {
  final FirebaseFirestore _firestore;
  CrmServicesRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== CATEGORIES ====================

  Stream<Either<Failure, List<CrmServiceCategoryModel>>>
      watchCategories() async* {
    try {
      await for (final snapshot in _firestore
          .collection(CrmFirestorePaths.serviceCategories)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots()) {
        final items = snapshot.docs
            .map((doc) => CrmServiceCategoryModel.fromMap(doc.data()))
            .where((item) => !item.isDeleted)
            .toList()
          ..sort((a, b) => a.order != b.order
              ? a.order.compareTo(b.order)
              : a.nameEn.compareTo(b.nameEn));
        yield Right(items);
      }
    } catch (error) {
      yield Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, CrmServiceCategoryModel>> createCategory(
      CrmServiceCategoryModel category, String userEmail) async {
    try {
      final id =
          _firestore.collection(CrmFirestorePaths.serviceCategories).doc().id;
      final snapshot = await _firestore
          .collection(CrmFirestorePaths.serviceCategories)
          .get();
      final order = snapshot.docs.fold<int>(
              0,
              (value, doc) =>
                  ((doc.data()[CrmFirestoreKeys.ORDER_KEY] as num?)?.toInt() ??
                              0) >
                          value
                      ? ((doc.data()[CrmFirestoreKeys.ORDER_KEY] as num?)
                              ?.toInt() ??
                          0)
                      : value) +
          1;
      final created = CrmServiceCategoryModel(
        id: id,
        nameEn: category.nameEn,
        nameAr: category.nameAr,
        noteEn: category.noteEn,
        noteAr: category.noteAr,
        clientTypeId: category.clientTypeId,
        tagIds: category.tagIds,
        status: category.status,
        isActive: category.isActive,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );
      await _firestore
          .collection(CrmFirestorePaths.serviceCategories)
          .doc(id)
          .set(created.toMap());
      return Right(created);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> updateCategory(
          CrmServiceCategoryModel category, String userEmail) =>
      _updateCategory(
          category.id,
          category.copyWith(audit: CrmAuditModel.now(userEmail: userEmail)),
          userEmail,
          replace: category);

  Future<Either<Failure, void>> deleteCategory(
      CrmServiceCategoryModel category, String userEmail) async {
    try {
      await _firestore
          .collection(CrmFirestorePaths.serviceCategories)
          .doc(category.id)
          .update(<String, dynamic>{
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.STATUS_KEY: 'deleted',
        CrmFirestoreKeys.AUDIT_KEY:
            _updatedAudit(category.audit, userEmail).toMap(),
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> setCategoryActive(
      String id, bool isActive, String userEmail) async {
    try {
      final snapshot = await _firestore
          .collection(CrmFirestorePaths.serviceCategories)
          .doc(id)
          .get();
      final current = snapshot.data() == null
          ? null
          : CrmServiceCategoryModel.fromMap(snapshot.data()!);
      if (current == null) {
        return Left(FeatureFailure('Category not found: $id'));
      }
      await _firestore
          .collection(CrmFirestorePaths.serviceCategories)
          .doc(id)
          .update(<String, dynamic>{
        CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
        CrmFirestoreKeys.STATUS_KEY: isActive ? 'active' : 'inactive',
        CrmFirestoreKeys.AUDIT_KEY:
            _updatedAudit(current.audit, userEmail).toMap(),
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> _updateCategory(
      String id, CrmServiceCategoryModel _, String userEmail,
      {required CrmServiceCategoryModel replace}) async {
    try {
      final snapshot = await _firestore
          .collection(CrmFirestorePaths.serviceCategories)
          .doc(id)
          .get();
      final current = snapshot.data() == null
          ? null
          : CrmServiceCategoryModel.fromMap(snapshot.data()!);
      if (current == null) {
        return Left(FeatureFailure('Category not found: $id'));
      }
      final updated = replace.copyWith(
        id: id,
        order: current.order,
        audit: _updatedAudit(current.audit, userEmail),
      );
      await _firestore
          .collection(CrmFirestorePaths.serviceCategories)
          .doc(id)
          .set(updated.toMap());
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  // ==================== SERVICE ITEMS ====================

  Stream<Either<Failure, List<CrmServiceItemModel>>> watchServices() async* {
    try {
      await for (final snapshot in _firestore
          .collection(CrmFirestorePaths.services)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots()) {
        final items = snapshot.docs
            .map((doc) => CrmServiceItemModel.fromMap(doc.data()))
            .where((item) => !item.isDeleted)
            .toList()
          ..sort((a, b) => a.order != b.order
              ? a.order.compareTo(b.order)
              : a.nameEn.compareTo(b.nameEn));
        yield Right(items);
      }
    } catch (error) {
      yield Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, CrmServiceItemModel>> createService(
      CrmServiceItemModel service, String userEmail) async {
    try {
      final id = _firestore.collection(CrmFirestorePaths.services).doc().id;
      final snapshot =
          await _firestore.collection(CrmFirestorePaths.services).get();
      final order = snapshot.docs.fold<int>(
              0,
              (value, doc) =>
                  ((doc.data()[CrmFirestoreKeys.ORDER_KEY] as num?)?.toInt() ??
                              0) >
                          value
                      ? ((doc.data()[CrmFirestoreKeys.ORDER_KEY] as num?)
                              ?.toInt() ??
                          0)
                      : value) +
          1;
      final created = service.copyWith(
        id: id,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );
      await _firestore
          .collection(CrmFirestorePaths.services)
          .doc(id)
          .set(created.toMap());
      return Right(created);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> updateService(
          CrmServiceItemModel service, String userEmail) =>
      _updateService(
          service.id,
          service.copyWith(audit: CrmAuditModel.now(userEmail: userEmail)),
          userEmail,
          replace: service);

  Future<Either<Failure, void>> deleteService(
      CrmServiceItemModel service, String userEmail) async {
    try {
      await _firestore
          .collection(CrmFirestorePaths.services)
          .doc(service.id)
          .update(<String, dynamic>{
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.STATUS_KEY: 'Deleted',
        CrmFirestoreKeys.AUDIT_KEY:
            _updatedAudit(service.audit, userEmail).toMap(),
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> setServiceActive(
      String id, bool isActive, String userEmail) async {
    try {
      final snapshot =
          await _firestore.collection(CrmFirestorePaths.services).doc(id).get();
      final current = snapshot.data() == null
          ? null
          : CrmServiceItemModel.fromMap(snapshot.data()!);
      if (current == null) {
        return Left(FeatureFailure('Service not found: $id'));
      }
      await _firestore
          .collection(CrmFirestorePaths.services)
          .doc(id)
          .update(<String, dynamic>{
        CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
        CrmFirestoreKeys.STATUS_KEY: isActive ? 'Active' : 'Inactive',
        CrmFirestoreKeys.AUDIT_KEY:
            _updatedAudit(current.audit, userEmail).toMap(),
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> _updateService(
      String id, CrmServiceItemModel _, String userEmail,
      {required CrmServiceItemModel replace}) async {
    try {
      final snapshot =
          await _firestore.collection(CrmFirestorePaths.services).doc(id).get();
      final current = snapshot.data() == null
          ? null
          : CrmServiceItemModel.fromMap(snapshot.data()!);
      if (current == null) {
        return Left(FeatureFailure('Service not found: $id'));
      }
      final updated = replace.copyWith(
        id: id,
        order: current.order,
        audit: _updatedAudit(current.audit, userEmail),
      );
      await _firestore
          .collection(CrmFirestorePaths.services)
          .doc(id)
          .set(updated.toMap());
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  CrmAuditModel _updatedAudit(CrmAuditModel? current, String userEmail) {
    if (current == null) {
      return CrmAuditModel.now(userEmail: userEmail);
    }
    return current.copyWith(
      updatedBy: userEmail,
      updatedAt: DateTime.now(),
    );
  }
}
