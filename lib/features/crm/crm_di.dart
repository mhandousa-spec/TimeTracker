// ****************** FILE INFO ******************
// File Name: crm_di.dart
// Purpose: Central GetX registration of CRM repositories so Cubits and pages
//          resolve dependencies instead of instantiating them (rule 18).
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:get/get.dart';

import 'package:knowticed_plus/features/crm/crm1_clients/data/repository/crm_clients_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/usecases/upload_client_files_use_case.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/repository/crm_controls_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/repository/crm_relationship_repository.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/domain/interfaces/crm_relationship_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/repository/crm_terms_repository.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/domain/interfaces/crm_terms_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/repository/crm_category_and_tags_repository.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/domain/interfaces/crm_category_and_tags_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/repository/crm_deals_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/repository/crm_products_repository.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/interfaces/crm_products_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/repository/crm_discounts_repository.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/domain/interfaces/crm_discounts_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/repository/crm_services_repository.dart';
import 'package:knowticed_plus/features/crm/crm9_services/domain/interfaces/crm_services_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/repository/crm_teams_repository.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/interfaces/crm_teams_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/repository/crm_duplicates_repository.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/interfaces/crm_duplicates_repository_interface.dart';

/// Registers CRM dependencies once (idempotent). Call before any CRM Cubit or
/// page is created — `CrmScreenHost.initState` does this for the whole module.
void registerCrmDependencies() {
  if (!Get.isRegistered<CrmControlsBaseRepository>()) {
    Get.put<CrmControlsBaseRepository>(
      CrmControlsRepository(),
      permanent: true,
    );
  }
  if (!Get.isRegistered<CrmClientsBaseRepository>()) {
    Get.put<CrmClientsBaseRepository>(
      CrmClientsRepository(),
      permanent: true,
    );
  }
  if (!Get.isRegistered<CrmRelationshipBaseRepository>()) {
    Get.put<CrmRelationshipBaseRepository>(
      CrmRelationshipRepository(),
      permanent: true,
    );
  }
  if (!Get.isRegistered<CrmTermsBaseRepository>()) {
    Get.put<CrmTermsBaseRepository>(
      CrmTermsRepository(),
      permanent: true,
    );
  }
  if (!Get.isRegistered<CrmCategoryAndTagsBaseRepository>()) {
    Get.put<CrmCategoryAndTagsBaseRepository>(
      CrmCategoryAndTagsRepository(),
      permanent: true,
    );
  }
  if (!Get.isRegistered<CrmDealsBaseRepository>()) {
    Get.put<CrmDealsBaseRepository>(
      CrmDealsRepository(),
      permanent: true,
    );
  }
  if (!Get.isRegistered<CrmProductsBaseRepository>()) {
    Get.put<CrmProductsBaseRepository>(CrmProductsRepository(),
        permanent: true);
  }
  if (!Get.isRegistered<CrmDiscountsBaseRepository>()) {
    Get.put<CrmDiscountsBaseRepository>(CrmDiscountsRepository(),
        permanent: true);
  }
  if (!Get.isRegistered<CrmServicesBaseRepository>()) {
    Get.put<CrmServicesBaseRepository>(CrmServicesRepository(),
        permanent: true);
  }
  if (!Get.isRegistered<CrmTeamsBaseRepository>()) {
    Get.put<CrmTeamsBaseRepository>(CrmTeamsRepository(), permanent: true);
  }
  if (!Get.isRegistered<ICrmDuplicatesRepository>()) {
    Get.put<ICrmDuplicatesRepository>(
        CrmDuplicatesRepository(
          clientsRepository: Get.find<CrmClientsBaseRepository>(),
          controlsRepository: Get.find<CrmControlsBaseRepository>(),
        ),
        permanent: true);
  }
  if (!Get.isRegistered<UploadClientFilesUseCase>()) {
    Get.put<UploadClientFilesUseCase>(
      UploadClientFilesUseCase(Get.find<CrmClientsBaseRepository>()),
      permanent: true,
    );
  }
}
