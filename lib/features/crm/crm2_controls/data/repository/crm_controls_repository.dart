// ****************** FILE INFO ******************
// File Name: crm_controls_repository.dart
// Purpose: Repository facade for CRM controls schema and template operations
// Author: Mohand Adel
// Created At: 04/08/2026

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/data_source/crm_controls_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/data_source/crm_saved_sections_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/data_source/crm_template_section_editor_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/data_source/crm_templates_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
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

class CrmControlsRepository implements CrmControlsBaseRepository {
  final CrmControlsRemoteDataSource remoteDataSource;
  final CrmTemplatesRemoteDataSource templatesRemoteDataSource;
  final CrmTemplateSectionEditorRemoteDataSource sectionEditorRemoteDataSource;
  final CrmSavedSectionsRemoteDataSource savedSectionsRemoteDataSource;

  CrmControlsRepository({
    CrmControlsRemoteDataSource? remoteDataSource,
    CrmTemplatesRemoteDataSource? templatesRemoteDataSource,
    CrmTemplateSectionEditorRemoteDataSource? sectionEditorRemoteDataSource,
    CrmSavedSectionsRemoteDataSource? savedSectionsRemoteDataSource,
  })  : remoteDataSource = remoteDataSource ?? CrmControlsRemoteDataSource(),
        templatesRemoteDataSource =
            templatesRemoteDataSource ?? CrmTemplatesRemoteDataSource(),
        sectionEditorRemoteDataSource = sectionEditorRemoteDataSource ??
            CrmTemplateSectionEditorRemoteDataSource(),
        savedSectionsRemoteDataSource =
            savedSectionsRemoteDataSource ?? CrmSavedSectionsRemoteDataSource();

  @override
  Future<Either<Failure, void>> ensureDefaults({
    required String userEmail,
  }) {
    return remoteDataSource.ensureDefaults(userEmail: userEmail);
  }

  @override
  Stream<Either<Failure, List<CrmClientTypeModel>>> watchClientTypes() {
    return remoteDataSource.watchClientTypes();
  }

  @override
  Stream<Either<Failure, List<CrmFieldTypeModel>>> watchFieldTypes({
    required String clientTypeId,
  }) {
    return remoteDataSource.watchFieldTypes(clientTypeId: clientTypeId);
  }

  @override
  Future<Either<Failure, CrmClientTypeModel>> createClientType({
    required String nameEn,
    required String nameAr,
    required String userEmail,
    String iconUrl = '',
    String svgAsset = '',
    String iconKey = '',
    String? typeId,
  }) {
    return remoteDataSource.createClientType(
      nameEn: nameEn,
      nameAr: nameAr,
      userEmail: userEmail,
      iconUrl: iconUrl,
      svgAsset: svgAsset,
      iconKey: iconKey,
      typeId: typeId,
    );
  }

  @override
  Future<Either<Failure, void>> updateClientType({
    required CrmClientTypeModel clientType,
    required String changedBy,
  }) {
    return remoteDataSource.updateClientType(
      clientType: clientType,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeClientType({
    required CrmClientTypeModel clientType,
    required String changedBy,
  }) {
    return remoteDataSource.removeClientType(
      clientType: clientType,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, String>> uploadClientTypeIcon({
    required File image,
    required String typeId,
  }) {
    return remoteDataSource.uploadClientTypeIcon(
      image: image,
      typeId: typeId,
    );
  }

  @override
  Future<Either<Failure, CrmTemplateModel>> createTemplateDraft({
    required String clientTypeId,
    required String nameEn,
    required String nameAr,
    required String userEmail,
    String? templateId,
  }) {
    return templatesRemoteDataSource.createTemplateDraft(
      clientTypeId: clientTypeId,
      nameEn: nameEn,
      nameAr: nameAr,
      userEmail: userEmail,
      templateId: templateId,
    );
  }

  @override
  Future<Either<Failure, void>> ensureTemplateDefaults({
    required String templateId,
    required String clientTypeId,
    required String userEmail,
  }) {
    return templatesRemoteDataSource.ensureTemplateDefaults(
      templateId: templateId,
      clientTypeId: clientTypeId,
      userEmail: userEmail,
    );
  }

  @override
  Future<Either<Failure, void>> syncDefaultsForAllTemplates({
    required String userEmail,
  }) {
    return templatesRemoteDataSource.syncDefaultsForAllTemplates(
      userEmail: userEmail,
    );
  }

  @override
  Stream<Either<Failure, List<CrmTemplateModel>>> watchTemplates() {
    return templatesRemoteDataSource.watchTemplates();
  }

  @override
  Stream<Either<Failure, CrmTemplateModel?>> watchTemplate({
    required String templateId,
  }) {
    return templatesRemoteDataSource.watchTemplate(templateId: templateId);
  }

  @override
  Stream<Either<Failure, List<CrmTemplateSectionModel>>> watchTemplateSections({
    required String templateId,
  }) {
    return templatesRemoteDataSource.watchTemplateSections(
      templateId: templateId,
    );
  }

  @override
  Stream<Either<Failure, List<CrmTemplateFieldModel>>> watchTemplateFields({
    required String templateId,
  }) {
    return templatesRemoteDataSource.watchTemplateFields(
        templateId: templateId);
  }

  @override
  Stream<Either<Failure, CrmTemplateLayoutModel?>> watchTemplateLayout({
    required String templateId,
  }) {
    return templatesRemoteDataSource.watchTemplateLayout(
        templateId: templateId);
  }

  @override
  Future<Either<Failure, void>> addTemplateField({
    required CrmTemplateFieldModel field,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.addTemplateField(
      field: field,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> updateTemplateField({
    required CrmTemplateFieldModel field,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.updateTemplateField(
      field: field,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeTemplateField({
    required String templateId,
    required String fieldId,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.removeTemplateField(
      templateId: templateId,
      fieldId: fieldId,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> addTemplateSection({
    required CrmTemplateSectionModel section,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.addTemplateSection(
      section: section,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> updateTemplateSection({
    required CrmTemplateSectionModel section,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.updateTemplateSection(
      section: section,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeTemplateSection({
    required String templateId,
    required String sectionId,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.removeTemplateSection(
      templateId: templateId,
      sectionId: sectionId,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> saveTemplateSectionWithFields({
    required CrmTemplateSectionModel section,
    required List<CrmTemplateFieldModel> fields,
    required String changedBy,
  }) {
    return sectionEditorRemoteDataSource.saveSectionWithFields(
      section: section,
      fields: fields,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeTemplateSectionWithFields({
    required String templateId,
    required String sectionId,
    required String changedBy,
  }) {
    return sectionEditorRemoteDataSource.removeSectionWithFields(
      templateId: templateId,
      sectionId: sectionId,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> saveTemplateLayout({
    required CrmTemplateLayoutModel layout,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.saveTemplateLayout(
      layout: layout,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> updateTemplateStatus({
    required String templateId,
    required String status,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.updateTemplateStatus(
      templateId: templateId,
      status: status,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> updateTemplateNames({
    required String templateId,
    required String nameEn,
    required String nameAr,
    required String changedBy,
  }) {
    return templatesRemoteDataSource.updateTemplateNames(
      templateId: templateId,
      nameEn: nameEn,
      nameAr: nameAr,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> ensureDefaultSavedSections({
    required String clientTypeId,
    required String userEmail,
  }) {
    return savedSectionsRemoteDataSource.ensureDefaultSavedSections(
      clientTypeId: clientTypeId,
      userEmail: userEmail,
    );
  }

  @override
  Stream<Either<Failure, List<CrmSavedSectionModel>>> watchSavedSections({
    required String clientTypeId,
  }) {
    return savedSectionsRemoteDataSource.watchSavedSections(
      clientTypeId: clientTypeId,
    );
  }

  @override
  Stream<Either<Failure, List<CrmSavedSectionFieldModel>>>
      watchSavedSectionFields({
    required String savedSectionId,
  }) {
    return savedSectionsRemoteDataSource.watchSavedSectionFields(
      savedSectionId: savedSectionId,
    );
  }

  @override
  Future<Either<Failure, void>> saveReusableSectionWithFields({
    required CrmSavedSectionModel section,
    required List<CrmSavedSectionFieldModel> fields,
    required String changedBy,
  }) {
    return savedSectionsRemoteDataSource.saveReusableSectionWithFields(
      section: section,
      fields: fields,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, CrmSavedSectionTemplateDraftModel>>
      buildTemplateSectionFromSavedSection({
    required String templateId,
    required String clientTypeId,
    required CrmSavedSectionModel savedSection,
    required int order,
    required String changedBy,
  }) {
    return savedSectionsRemoteDataSource.buildTemplateSectionFromSavedSection(
      templateId: templateId,
      clientTypeId: clientTypeId,
      savedSection: savedSection,
      order: order,
      changedBy: changedBy,
    );
  }

  @override
  Stream<Either<Failure, List<CrmMergeLevelModel>>> watchMergeLevels() {
    return remoteDataSource.watchMergeLevels();
  }

  @override
  Stream<Either<Failure, CrmMergeSettingsModel>> watchMergeSettings() {
    return remoteDataSource.watchMergeSettings();
  }

  @override
  Future<Either<Failure, void>> saveMergeSettings({
    required CrmMergeSettingsModel settings,
    required String changedBy,
  }) {
    return remoteDataSource.saveMergeSettings(
      settings: settings,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, CrmMergeLevelModel>> createMergeLevel({
    required String nameEn,
    required String nameAr,
    required double rangeFrom,
    required double rangeTo,
    required String colorHex,
    required String userEmail,
    String? levelId,
  }) {
    return remoteDataSource.createMergeLevel(
      nameEn: nameEn,
      nameAr: nameAr,
      rangeFrom: rangeFrom,
      rangeTo: rangeTo,
      colorHex: colorHex,
      userEmail: userEmail,
      levelId: levelId,
    );
  }

  @override
  Future<Either<Failure, void>> updateMergeLevel({
    required CrmMergeLevelModel level,
    required String changedBy,
  }) {
    return remoteDataSource.updateMergeLevel(
      level: level,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeMergeLevel({
    required CrmMergeLevelModel level,
    required String changedBy,
  }) {
    return remoteDataSource.removeMergeLevel(
      level: level,
      changedBy: changedBy,
    );
  }
}
