// ****************** FILE INFO ******************
// File Name: crm_relationship_repository.dart
// Purpose: Repository facade for CRM relationship category operations
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/data_source/crm_relationship_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/domain/interfaces/crm_relationship_base_repository.dart';

class CrmRelationshipRepository implements CrmRelationshipBaseRepository {
  final CrmRelationshipRemoteDataSource remoteDataSource;

  CrmRelationshipRepository({
    CrmRelationshipRemoteDataSource? remoteDataSource,
  }) : remoteDataSource = remoteDataSource ?? CrmRelationshipRemoteDataSource();

  @override
  Stream<Either<Failure, List<CrmRelationshipCategoryModel>>>
      watchRelationshipCategories() {
    return remoteDataSource.watchRelationshipCategories();
  }

  @override
  Future<Either<Failure, CrmRelationshipCategoryModel>>
      createRelationshipCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<Map<String, String>> types,
    String iconUrl = '',
    String? categoryId,
  }) {
    return remoteDataSource.createRelationshipCategory(
      nameEn: nameEn,
      nameAr: nameAr,
      status: status,
      userEmail: userEmail,
      types: types,
      iconUrl: iconUrl,
      categoryId: categoryId,
    );
  }

  @override
  Future<Either<Failure, void>> updateRelationshipCategory({
    required CrmRelationshipCategoryModel category,
    required String changedBy,
  }) {
    return remoteDataSource.updateRelationshipCategory(
      category: category,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeRelationshipCategory({
    required CrmRelationshipCategoryModel category,
    required String changedBy,
  }) {
    return remoteDataSource.removeRelationshipCategory(
      category: category,
      changedBy: changedBy,
    );
  }
}
