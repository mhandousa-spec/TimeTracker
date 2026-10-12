// ****************** FILE INFO ******************
// File Name: crm_discounts_base_repository.dart
// Purpose: Abstract repository interface for CRM Discount operations
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';

abstract class CrmDiscountsBaseRepository {
  Stream<Either<Failure, List<CrmDiscountModel>>> watchDiscounts();

  Future<Either<Failure, List<CrmDiscountModel>>> getDiscounts();

  Future<Either<Failure, CrmDiscountModel>> createDiscount({
    required CrmDiscountModel discount,
    required String userEmail,
  });

  Future<Either<Failure, void>> updateDiscount({
    required CrmDiscountModel discount,
    required String userEmail,
  });

  Future<Either<Failure, void>> deleteDiscount({
    required CrmDiscountModel discount,
    required String userEmail,
  });

  Future<Either<Failure, void>> toggleStatus({
    required String discountId,
    required bool isActive,
    required String userEmail,
  });
}
