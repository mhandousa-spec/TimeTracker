// ****************** FILE INFO ******************
// File Name: crm_deals_base_repository.dart
// Purpose: Abstract domain repository interface for CRM Deals Controls
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_stage_checklist_item_model.dart';

abstract class CrmDealsBaseRepository {
  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------
  Stream<Either<Failure, List<CrmDealCategoryModel>>> watchCategories();

  Future<Either<Failure, CrmDealCategoryModel>> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    String? categoryId,
  });

  Future<Either<Failure, void>> updateCategory({
    required CrmDealCategoryModel category,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeCategory({
    required CrmDealCategoryModel category,
    required String changedBy,
  });

  Future<Either<Failure, void>> toggleCategoryStatus({
    required String categoryId,
    required bool isActive,
    required String changedBy,
  });

  // ---------------------------------------------------------------------------
  // Stages
  // ---------------------------------------------------------------------------
  Stream<Either<Failure, List<CrmDealStageModel>>> watchStages();

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
  });

  Future<Either<Failure, void>> updateStage({
    required CrmDealStageModel stage,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeStage({
    required CrmDealStageModel stage,
    required String changedBy,
  });

  Future<Either<Failure, void>> toggleStageStatus({
    required String stageId,
    required bool isActive,
    required String changedBy,
  });
}
