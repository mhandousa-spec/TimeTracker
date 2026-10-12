// ****************** FILE INFO ******************
// File Name: crm_category_and_tags_repository.dart
// Purpose: Concrete repository implementation for Activity Categories & Tags
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/data_source/crm_category_and_tags_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/domain/interfaces/crm_category_and_tags_base_repository.dart';

class CrmCategoryAndTagsRepository implements CrmCategoryAndTagsBaseRepository {
  final CrmCategoryAndTagsRemoteDataSource _remoteDataSource;

  CrmCategoryAndTagsRepository({
    CrmCategoryAndTagsRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? CrmCategoryAndTagsRemoteDataSource();

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  @override
  Stream<Either<Failure, List<CrmCategoryModel>>> watchCategories() {
    return _remoteDataSource.watchCategories();
  }

  @override
  Future<Either<Failure, CrmCategoryModel>> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<CrmCategoryTypeModel> types,
    String? categoryId,
  }) {
    return _remoteDataSource.createCategory(
      nameEn: nameEn,
      nameAr: nameAr,
      status: status,
      userEmail: userEmail,
      types: types,
      categoryId: categoryId,
    );
  }

  @override
  Future<Either<Failure, void>> updateCategory({
    required CrmCategoryModel category,
    required String changedBy,
  }) {
    return _remoteDataSource.updateCategory(
      category: category,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeCategory({
    required CrmCategoryModel category,
    required String changedBy,
  }) {
    return _remoteDataSource.removeCategory(
      category: category,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> toggleCategoryStatus({
    required String categoryId,
    required bool isActive,
    required String changedBy,
  }) {
    return _remoteDataSource.toggleCategoryStatus(
      categoryId: categoryId,
      isActive: isActive,
      changedBy: changedBy,
    );
  }

  // ---------------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------------

  @override
  Stream<Either<Failure, List<CrmTagModel>>> watchTags() {
    return _remoteDataSource.watchTags();
  }

  @override
  Future<Either<Failure, CrmTagModel>> createTag({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    String? tagId,
  }) {
    return _remoteDataSource.createTag(
      nameEn: nameEn,
      nameAr: nameAr,
      status: status,
      userEmail: userEmail,
      tagId: tagId,
    );
  }

  @override
  Future<Either<Failure, void>> updateTag({
    required CrmTagModel tag,
    required String changedBy,
  }) {
    return _remoteDataSource.updateTag(
      tag: tag,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeTag({
    required CrmTagModel tag,
    required String changedBy,
  }) {
    return _remoteDataSource.removeTag(
      tag: tag,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> toggleTagStatus({
    required String tagId,
    required bool isActive,
    required String changedBy,
  }) {
    return _remoteDataSource.toggleTagStatus(
      tagId: tagId,
      isActive: isActive,
      changedBy: changedBy,
    );
  }
}
