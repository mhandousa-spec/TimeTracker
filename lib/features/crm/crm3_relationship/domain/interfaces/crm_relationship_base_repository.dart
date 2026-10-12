// ****************** FILE INFO ******************
// File Name: crm_relationship_base_repository.dart
// Purpose: Feature-facing repository contract for CRM relationship categories
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';

abstract class CrmRelationshipBaseRepository {
  Stream<Either<Failure, List<CrmRelationshipCategoryModel>>>
      watchRelationshipCategories();

  Future<Either<Failure, CrmRelationshipCategoryModel>>
      createRelationshipCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<Map<String, String>> types,
    String iconUrl = '',
    String? categoryId,
  });

  Future<Either<Failure, void>> updateRelationshipCategory({
    required CrmRelationshipCategoryModel category,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeRelationshipCategory({
    required CrmRelationshipCategoryModel category,
    required String changedBy,
  });
}
