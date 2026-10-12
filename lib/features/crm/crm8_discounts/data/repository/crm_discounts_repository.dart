// ****************** FILE INFO ******************
// File Name: crm_discounts_repository.dart
// Purpose: Repository implementation for CRM Discount operations
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/data_source/crm_discounts_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/domain/interfaces/crm_discounts_base_repository.dart';

class CrmDiscountsRepository implements CrmDiscountsBaseRepository {
  final CrmDiscountsRemoteDataSource _remoteDataSource;

  CrmDiscountsRepository({CrmDiscountsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CrmDiscountsRemoteDataSource();

  @override
  Stream<Either<Failure, List<CrmDiscountModel>>> watchDiscounts() {
    return _remoteDataSource.watchDiscounts();
  }

  @override
  Future<Either<Failure, List<CrmDiscountModel>>> getDiscounts() {
    return _remoteDataSource.getDiscounts();
  }

  @override
  Future<Either<Failure, CrmDiscountModel>> createDiscount({
    required CrmDiscountModel discount,
    required String userEmail,
  }) {
    return _remoteDataSource.createDiscount(discount, userEmail);
  }

  @override
  Future<Either<Failure, void>> updateDiscount({
    required CrmDiscountModel discount,
    required String userEmail,
  }) {
    return _remoteDataSource.updateDiscount(discount, userEmail);
  }

  @override
  Future<Either<Failure, void>> deleteDiscount({
    required CrmDiscountModel discount,
    required String userEmail,
  }) {
    return _remoteDataSource.deleteDiscount(discount, userEmail);
  }

  @override
  Future<Either<Failure, void>> toggleStatus({
    required String discountId,
    required bool isActive,
    required String userEmail,
  }) {
    return _remoteDataSource.toggleStatus(discountId, isActive, userEmail);
  }
}
