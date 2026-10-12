// ****************** FILE INFO ******************
// File Name: crm_controls_base_repository.dart
// Purpose: Abstract contract for the CRM controls repository. Presentation
//          depends on this interface instead of the concrete repository.
// Author: Mohand Adel
// Created At: 12/08/2026

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_template_draft_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_layout_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';

/// Feature-facing contract for CRM controls schema and template operations.
///
/// Cubits and pages depend on this abstraction (rule 5); the concrete
/// [CrmControlsRepository] implements it and owns data-source orchestration.
abstract class CrmControlsBaseRepository {
  Future<Either<Failure, void>> ensureDefaults({required String userEmail});

  Stream<Either<Failure, List<CrmClientTypeModel>>> watchClientTypes();

  Stream<Either<Failure, List<CrmFieldTypeModel>>> watchFieldTypes({
    required String clientTypeId,
  });

  Future<Either<Failure, CrmClientTypeModel>> createClientType({
    required String nameEn,
    required String nameAr,
    required String userEmail,
    String iconUrl = '',
    String svgAsset = '',
    String iconKey = '',
    String? typeId,
  });

  Future<Either<Failure, void>> updateClientType({
    required CrmClientTypeModel clientType,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeClientType({
    required CrmClientTypeModel clientType,
    required String changedBy,
  });

  Future<Either<Failure, String>> uploadClientTypeIcon({
    required File image,
    required String typeId,
  });

  Future<Either<Failure, CrmTemplateModel>> createTemplateDraft({
    required String clientTypeId,
    required String nameEn,
    required String nameAr,
    required String userEmail,
    String? templateId,
  });

  Future<Either<Failure, void>> ensureTemplateDefaults({
    required String templateId,
    required String clientTypeId,
    required String userEmail,
  });

  Future<Either<Failure, void>> syncDefaultsForAllTemplates({
    required String userEmail,
  });

  Stream<Either<Failure, List<CrmTemplateModel>>> watchTemplates();

  Stream<Either<Failure, CrmTemplateModel?>> watchTemplate({
    required String templateId,
  });

  Stream<Either<Failure, List<CrmTemplateSectionModel>>> watchTemplateSections({
    required String templateId,
  });

  Stream<Either<Failure, List<CrmTemplateFieldModel>>> watchTemplateFields({
    required String templateId,
  });

  Stream<Either<Failure, CrmTemplateLayoutModel?>> watchTemplateLayout({
    required String templateId,
  });

  Future<Either<Failure, void>> addTemplateField({
    required CrmTemplateFieldModel field,
    required String changedBy,
  });

  Future<Either<Failure, void>> updateTemplateField({
    required CrmTemplateFieldModel field,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeTemplateField({
    required String templateId,
    required String fieldId,
    required String changedBy,
  });

  Future<Either<Failure, void>> addTemplateSection({
    required CrmTemplateSectionModel section,
    required String changedBy,
  });

  Future<Either<Failure, void>> updateTemplateSection({
    required CrmTemplateSectionModel section,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeTemplateSection({
    required String templateId,
    required String sectionId,
    required String changedBy,
  });

  Future<Either<Failure, void>> saveTemplateSectionWithFields({
    required CrmTemplateSectionModel section,
    required List<CrmTemplateFieldModel> fields,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeTemplateSectionWithFields({
    required String templateId,
    required String sectionId,
    required String changedBy,
  });

  Future<Either<Failure, void>> saveTemplateLayout({
    required CrmTemplateLayoutModel layout,
    required String changedBy,
  });

  Future<Either<Failure, void>> updateTemplateStatus({
    required String templateId,
    required String status,
    required String changedBy,
  });

  Future<Either<Failure, void>> updateTemplateNames({
    required String templateId,
    required String nameEn,
    required String nameAr,
    required String changedBy,
  });

  Future<Either<Failure, void>> ensureDefaultSavedSections({
    required String clientTypeId,
    required String userEmail,
  });

  Stream<Either<Failure, List<CrmSavedSectionModel>>> watchSavedSections({
    required String clientTypeId,
  });

  Stream<Either<Failure, List<CrmSavedSectionFieldModel>>>
      watchSavedSectionFields({
    required String savedSectionId,
  });

  Future<Either<Failure, void>> saveReusableSectionWithFields({
    required CrmSavedSectionModel section,
    required List<CrmSavedSectionFieldModel> fields,
    required String changedBy,
  });

  Future<Either<Failure, CrmSavedSectionTemplateDraftModel>>
      buildTemplateSectionFromSavedSection({
    required String templateId,
    required String clientTypeId,
    required CrmSavedSectionModel savedSection,
    required int order,
    required String changedBy,
  });

  Stream<Either<Failure, List<CrmMergeLevelModel>>> watchMergeLevels();

  Stream<Either<Failure, CrmMergeSettingsModel>> watchMergeSettings();

  Future<Either<Failure, void>> saveMergeSettings({
    required CrmMergeSettingsModel settings,
    required String changedBy,
  });

  Future<Either<Failure, CrmMergeLevelModel>> createMergeLevel({
    required String nameEn,
    required String nameAr,
    required double rangeFrom,
    required double rangeTo,
    required String colorHex,
    required String userEmail,
    String? levelId,
  });

  Future<Either<Failure, void>> updateMergeLevel({
    required CrmMergeLevelModel level,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeMergeLevel({
    required CrmMergeLevelModel level,
    required String changedBy,
  });
}
