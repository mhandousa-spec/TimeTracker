// ****************** FILE INFO ******************
// File Name: crm_category_and_tags_base_repository.dart
// Purpose: Feature-facing repository contract for CRM Activity Categories & Tags
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';

abstract class CrmCategoryAndTagsBaseRepository {
  Stream<Either<Failure, List<CrmCategoryModel>>> watchCategories();

  Future<Either<Failure, CrmCategoryModel>> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<CrmCategoryTypeModel> types,
    String? categoryId,
  });

  Future<Either<Failure, void>> updateCategory({
    required CrmCategoryModel category,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeCategory({
    required CrmCategoryModel category,
    required String changedBy,
  });

  Future<Either<Failure, void>> toggleCategoryStatus({
    required String categoryId,
    required bool isActive,
    required String changedBy,
  });

  Stream<Either<Failure, List<CrmTagModel>>> watchTags();

  Future<Either<Failure, CrmTagModel>> createTag({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    String? tagId,
  });

  Future<Either<Failure, void>> updateTag({
    required CrmTagModel tag,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeTag({
    required CrmTagModel tag,
    required String changedBy,
  });

  Future<Either<Failure, void>> toggleTagStatus({
    required String tagId,
    required bool isActive,
    required String changedBy,
  });
}
