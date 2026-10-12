// ****************** FILE INFO ******************
// File Name: crm_discounts_remote_data_source.dart
// Purpose: Firestore data source for CRM discount rules
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';

class CrmDiscountsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmDiscountsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<Either<Failure, List<CrmDiscountModel>>> watchDiscounts() async* {
    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _firestore
              .collection(CrmFirestorePaths.discounts)
              .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
              .snapshots()) {
        final List<CrmDiscountModel> items = snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                CrmDiscountModel.fromMap(doc.data()))
            .where((CrmDiscountModel item) => !item.isDeleted)
            .toList()
          ..sort((CrmDiscountModel a, CrmDiscountModel b) => a.order != b.order
              ? a.order.compareTo(b.order)
              : a.nameEn.compareTo(b.nameEn));
        yield Right<Failure, List<CrmDiscountModel>>(items);
      }
    } catch (error) {
      yield Left<Failure, List<CrmDiscountModel>>(
          FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, List<CrmDiscountModel>>> getDiscounts() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.discounts)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .get();

      final List<CrmDiscountModel> items = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              CrmDiscountModel.fromMap(doc.data()))
          .where((CrmDiscountModel item) => !item.isDeleted)
          .toList()
        ..sort((CrmDiscountModel a, CrmDiscountModel b) => a.order != b.order
            ? a.order.compareTo(b.order)
            : a.nameEn.compareTo(b.nameEn));

      return Right<Failure, List<CrmDiscountModel>>(items);
    } catch (error) {
      return Left<Failure, List<CrmDiscountModel>>(
          FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, CrmDiscountModel>> createDiscount(
    CrmDiscountModel discount,
    String userEmail,
  ) async {
    try {
      final String id =
          _firestore.collection(CrmFirestorePaths.discounts).doc().id;
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(CrmFirestorePaths.discounts).get();
      final int order = snapshot.docs.fold<int>(
            0,
            (int value, QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                ((doc.data()[CrmFirestoreKeys.ORDER_KEY] as num?)?.toInt() ??
                            0) >
                        value
                    ? ((doc.data()[CrmFirestoreKeys.ORDER_KEY] as num?)
                            ?.toInt() ??
                        0)
                    : value,
          ) +
          1;

      final CrmDiscountModel created = discount.copyWith(
        id: id,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );

      await _firestore
          .collection(CrmFirestorePaths.discounts)
          .doc(id)
          .set(created.toMap());

      return Right<Failure, CrmDiscountModel>(created);
    } catch (error) {
      return Left<Failure, CrmDiscountModel>(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> updateDiscount(
    CrmDiscountModel discount,
    String userEmail,
  ) async {
    try {
      final CrmDiscountModel updated = discount.copyWith(
        audit: CrmAuditModel.now(userEmail: userEmail),
      );
      await _firestore
          .collection(CrmFirestorePaths.discounts)
          .doc(discount.id)
          .set(updated.toMap(), SetOptions(merge: true));
      return const Right<Failure, void>(null);
    } catch (error) {
      return Left<Failure, void>(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> deleteDiscount(
    CrmDiscountModel discount,
    String userEmail,
  ) async {
    try {
      await _firestore
          .collection(CrmFirestorePaths.discounts)
          .doc(discount.id)
          .update(<String, dynamic>{
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.STATUS_KEY: 'deleted',
        CrmFirestoreKeys.AUDIT_KEY:
            CrmAuditModel.now(userEmail: userEmail).toMap(),
      });
      return const Right<Failure, void>(null);
    } catch (error) {
      return Left<Failure, void>(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> toggleStatus(
    String discountId,
    bool isActive,
    String userEmail,
  ) async {
    try {
      await _firestore
          .collection(CrmFirestorePaths.discounts)
          .doc(discountId)
          .update(<String, dynamic>{
        CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
        CrmFirestoreKeys.STATUS_KEY: isActive ? 'active' : 'inactive',
        CrmFirestoreKeys.AUDIT_KEY:
            CrmAuditModel.now(userEmail: userEmail).toMap(),
      });
      return const Right<Failure, void>(null);
    } catch (error) {
      return Left<Failure, void>(FirebaseFailure(error.toString()));
    }
  }
}
