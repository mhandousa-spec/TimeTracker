// ****************** FILE INFO ******************
// File Name: crm_products_remote_data_source.dart
// Purpose: Firestore data source for CRM product categories and product items.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';

class CrmProductsRemoteDataSource {
  final FirebaseFirestore _firestore;
  CrmProductsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== CATEGORIES ====================

  Stream<Either<Failure, List<CrmProductCategoryModel>>>
      watchCategories() async* {
    try {
      await for (final snapshot in _firestore
          .collection(CrmFirestorePaths.productCategories)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots()) {
        final items = snapshot.docs
            .map((doc) => CrmProductCategoryModel.fromMap(doc.data()))
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

  Future<Either<Failure, CrmProductCategoryModel>> createCategory(
      CrmProductCategoryModel category, String userEmail) async {
    try {
      final id =
          _firestore.collection(CrmFirestorePaths.productCategories).doc().id;
      final snapshot = await _firestore
          .collection(CrmFirestorePaths.productCategories)
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
      final created = CrmProductCategoryModel(
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
          .collection(CrmFirestorePaths.productCategories)
          .doc(id)
          .set(created.toMap());
      return Right(created);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> updateCategory(
          CrmProductCategoryModel category, String userEmail) =>
      _updateCategory(
          category.id,
          category.copyWith(audit: CrmAuditModel.now(userEmail: userEmail)),
          userEmail,
          replace: category);

  Future<Either<Failure, void>> deleteCategory(
      CrmProductCategoryModel category, String userEmail) async {
    try {
      await _firestore
          .collection(CrmFirestorePaths.productCategories)
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
          .collection(CrmFirestorePaths.productCategories)
          .doc(id)
          .get();
      final current = snapshot.data() == null
          ? null
          : CrmProductCategoryModel.fromMap(snapshot.data()!);
      if (current == null) {
        return Left(FeatureFailure('Category not found: $id'));
      }
      await _firestore
          .collection(CrmFirestorePaths.productCategories)
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
      String id, CrmProductCategoryModel _, String userEmail,
      {required CrmProductCategoryModel replace}) async {
    try {
      final snapshot = await _firestore
          .collection(CrmFirestorePaths.productCategories)
          .doc(id)
          .get();
      final current = snapshot.data() == null
          ? null
          : CrmProductCategoryModel.fromMap(snapshot.data()!);
      if (current == null) {
        return Left(FeatureFailure('Category not found: $id'));
      }
      await _firestore
          .collection(CrmFirestorePaths.productCategories)
          .doc(id)
          .update(replace
              .copyWith(audit: _updatedAudit(current.audit, userEmail))
              .toMap());
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  // ==================== PRODUCT ITEMS ====================

  Stream<Either<Failure, List<CrmProductItemModel>>> watchProducts() async* {
    try {
      await for (final snapshot in _firestore
          .collection(CrmFirestorePaths.products)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots()) {
        final items = snapshot.docs
            .map((doc) => CrmProductItemModel.fromMap(doc.data()))
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

  Future<Either<Failure, CrmProductItemModel>> createProduct(
      CrmProductItemModel product, String userEmail) async {
    try {
      final id = _firestore.collection(CrmFirestorePaths.products).doc().id;
      final snapshot =
          await _firestore.collection(CrmFirestorePaths.products).get();
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

      final existing = snapshot.docs
          .map((doc) => CrmProductItemModel.fromMap(doc.data()))
          .toList();

      final generatedCode = product.code.isNotEmpty
          ? product.code
          : CrmProductItemModel.generateCode(existing);

      final created = product.copyWith(
        id: id,
        code: generatedCode,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );

      await _firestore
          .collection(CrmFirestorePaths.products)
          .doc(id)
          .set(created.toMap());
      return Right(created);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> updateProduct(
      CrmProductItemModel product, String userEmail) async {
    try {
      final snapshot = await _firestore
          .collection(CrmFirestorePaths.products)
          .doc(product.id)
          .get();
      final current = snapshot.data() == null
          ? null
          : CrmProductItemModel.fromMap(snapshot.data()!);
      if (current == null) {
        return Left(FeatureFailure('Product not found: ${product.id}'));
      }
      await _firestore
          .collection(CrmFirestorePaths.products)
          .doc(product.id)
          .update(product
              .copyWith(audit: _updatedAudit(current.audit, userEmail))
              .toMap());
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> deleteProduct(
      CrmProductItemModel product, String userEmail) async {
    try {
      await _firestore
          .collection(CrmFirestorePaths.products)
          .doc(product.id)
          .update(<String, dynamic>{
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.STATUS_KEY: 'deleted',
        CrmFirestoreKeys.AUDIT_KEY:
            _updatedAudit(product.audit, userEmail).toMap(),
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> setProductActive(
      String id, bool isActive, String userEmail) async {
    try {
      final snapshot =
          await _firestore.collection(CrmFirestorePaths.products).doc(id).get();
      final current = snapshot.data() == null
          ? null
          : CrmProductItemModel.fromMap(snapshot.data()!);
      if (current == null) {
        return Left(FeatureFailure('Product not found: $id'));
      }
      await _firestore
          .collection(CrmFirestorePaths.products)
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

  CrmAuditModel _updatedAudit(CrmAuditModel? audit, String userEmail) =>
      (audit ?? CrmAuditModel.now(userEmail: userEmail))
          .copyWith(updatedAt: DateTime.now(), updatedBy: userEmail);
}
