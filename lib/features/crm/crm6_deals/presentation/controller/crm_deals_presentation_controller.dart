// ****************** FILE INFO ******************
// File Name: crm_deals_presentation_controller.dart
// Purpose: Builds localized display values for CRM Deals presentation widgets
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:get/get.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDealsPresentationController {
  const CrmDealsPresentationController();

  String categoryDisplayName(CrmDealCategoryModel category) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final String preferred = isArabic ? category.nameAr : category.nameEn;
    final String fallback = isArabic ? category.nameEn : category.nameAr;
    final String displayName = preferred.isNotEmpty ? preferred : fallback;
    return displayName.isNotEmpty ? displayName : S.current.crmDealCategory;
  }

  String stageDisplayName(CrmDealStageModel stage) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final String preferred = isArabic ? stage.nameAr : stage.nameEn;
    final String fallback = isArabic ? stage.nameEn : stage.nameAr;
    final String displayName = preferred.isNotEmpty ? preferred : fallback;
    return displayName.isNotEmpty ? displayName : S.current.crmDealStage;
  }

  String statusLabel(bool isActive) {
    return isActive ? S.current.crmActive : S.current.crmInactive;
  }

  String statusOption(bool isActive) => isActive ? 'Active' : 'Inactive';

  String stageProbabilityLabel(CrmDealStageModel stage) {
    return '${stage.probability}%';
  }

  String stageCardProbabilityLabel(CrmDealStageModel stage) {
    return stage.probability > 0 ? stageProbabilityLabel(stage) : '';
  }
}
