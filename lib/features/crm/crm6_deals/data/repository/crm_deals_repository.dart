// ****************** FILE INFO ******************
// File Name: crm_deals_repository.dart
// Purpose: Concrete repository implementation for CRM Deal Categories & Stages
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/data_source/crm_deals_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_stage_checklist_item_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_deals_base_repository.dart';

class CrmDealsRepository implements CrmDealsBaseRepository {
  final CrmDealsRemoteDataSource _remoteDataSource;

  CrmDealsRepository({
    CrmDealsRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? CrmDealsRemoteDataSource();

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  @override
  Stream<Either<Failure, List<CrmDealCategoryModel>>> watchCategories() {
    return _remoteDataSource.watchCategories();
  }

  @override
  Future<Either<Failure, CrmDealCategoryModel>> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    String? categoryId,
  }) {
    return _remoteDataSource.createCategory(
      nameEn: nameEn,
      nameAr: nameAr,
      status: status,
      userEmail: userEmail,
      categoryId: categoryId,
    );
  }

  @override
  Future<Either<Failure, void>> updateCategory({
    required CrmDealCategoryModel category,
    required String changedBy,
  }) {
    return _remoteDataSource.updateCategory(
      category: category,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeCategory({
    required CrmDealCategoryModel category,
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
  // Stages
  // ---------------------------------------------------------------------------

  @override
  Stream<Either<Failure, List<CrmDealStageModel>>> watchStages() {
    return _remoteDataSource.watchStages();
  }

  @override
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
  }) {
    return _remoteDataSource.createStage(
      nameEn: nameEn,
      nameAr: nameAr,
      status: status,
      userEmail: userEmail,
      probability: probability,
      color: color,
      order: order,
      checklistItems: checklistItems,
      stageId: stageId,
    );
  }

  @override
  Future<Either<Failure, void>> updateStage({
    required CrmDealStageModel stage,
    required String changedBy,
  }) {
    return _remoteDataSource.updateStage(
      stage: stage,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeStage({
    required CrmDealStageModel stage,
    required String changedBy,
  }) {
    return _remoteDataSource.removeStage(
      stage: stage,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> toggleStageStatus({
    required String stageId,
    required bool isActive,
    required String changedBy,
  }) {
    return _remoteDataSource.toggleStageStatus(
      stageId: stageId,
      isActive: isActive,
      changedBy: changedBy,
    );
  }
}
