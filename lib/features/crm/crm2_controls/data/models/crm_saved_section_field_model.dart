// ****************** FILE INFO ******************
// File Name: crm_saved_section_field_model.dart
// Purpose: Data model for reusable CRM saved section fields
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmSavedSectionFieldModel {
  final String id;
  final String savedSectionId;
  final String clientTypeId;
  final String fieldTypeId;
  final String nameEn;
  final String nameAr;
  final int? maxCharacters;
  final String validationType;
  final bool isRequired;
  final String errorMessageEn;
  final String errorMessageAr;
  final bool showBothLanguages;
  final List<String> options;
  final String systemKey;
  final bool isSystem;
  final bool isDefault;
  final bool isDeleted;
  final Map<String, dynamic> configuration;
  final int order;
  final String status;
  final CrmAuditModel audit;

  const CrmSavedSectionFieldModel({
    required this.id,
    required this.savedSectionId,
    required this.clientTypeId,
    required this.fieldTypeId,
    required this.nameEn,
    required this.nameAr,
    this.maxCharacters,
    this.validationType = 'none',
    this.isRequired = false,
    this.errorMessageEn = '',
    this.errorMessageAr = '',
    this.showBothLanguages = true,
    this.options = const [],
    this.systemKey = '',
    this.isSystem = false,
    this.isDefault = false,
    this.isDeleted = false,
    this.configuration = const {},
    required this.order,
    this.status = 'active',
    required this.audit,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.SAVED_SECTION_ID_KEY: savedSectionId,
      CrmFirestoreKeys.CLIENT_TYPE_ID_KEY: clientTypeId,
      CrmFirestoreKeys.FIELD_TYPE_ID_KEY: fieldTypeId,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.MAX_CHARACTERS_KEY: maxCharacters,
      CrmFirestoreKeys.VALIDATION_TYPE_KEY: validationType,
      CrmFirestoreKeys.IS_REQUIRED_KEY: isRequired,
      CrmFirestoreKeys.ERROR_MESSAGE_EN_KEY: errorMessageEn,
      CrmFirestoreKeys.ERROR_MESSAGE_AR_KEY: errorMessageAr,
      CrmFirestoreKeys.SHOW_BOTH_LANGUAGES_KEY: showBothLanguages,
      CrmFirestoreKeys.OPTIONS_KEY: options,
      CrmFirestoreKeys.SYSTEM_KEY: systemKey,
      CrmFirestoreKeys.IS_SYSTEM_KEY: isSystem,
      CrmFirestoreKeys.IS_DEFAULT_KEY: isDefault,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.CONFIGURATION_KEY: configuration,
      CrmFirestoreKeys.ORDER_KEY: order,
      CrmFirestoreKeys.STATUS_KEY: status,
      CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
    };
  }

  factory CrmSavedSectionFieldModel.fromMap(Map<String, dynamic> map) {
    return CrmSavedSectionFieldModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      savedSectionId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.SAVED_SECTION_ID_KEY,
                'savedSectionId',
              ) ??
              '')
          .toString(),
      clientTypeId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.CLIENT_TYPE_ID_KEY,
                'clientTypeId',
              ) ??
              '')
          .toString(),
      fieldTypeId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.FIELD_TYPE_ID_KEY,
                'fieldTypeId',
              ) ??
              '')
          .toString(),
      nameEn:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_EN_KEY, 'nameEn') ??
                  '')
              .toString(),
      nameAr:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_AR_KEY, 'nameAr') ??
                  '')
              .toString(),
      maxCharacters: (CrmFirestoreKeys.read(
        map,
        CrmFirestoreKeys.MAX_CHARACTERS_KEY,
        'maxCharacters',
      ) as num?)
          ?.toInt(),
      validationType: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.VALIDATION_TYPE_KEY,
                'validationType',
              ) ??
              'none')
          .toString(),
      isRequired: CrmFirestoreKeys.read(
              map, CrmFirestoreKeys.IS_REQUIRED_KEY, 'isRequired') ==
          true,
      errorMessageEn: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.ERROR_MESSAGE_EN_KEY,
                'errorMessageEn',
              ) ??
              '')
          .toString(),
      errorMessageAr: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.ERROR_MESSAGE_AR_KEY,
                'errorMessageAr',
              ) ??
              '')
          .toString(),
      showBothLanguages: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.SHOW_BOTH_LANGUAGES_KEY,
            'showBothLanguages',
          ) !=
          false,
      options: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.OPTIONS_KEY,
                'options',
              ) as List? ??
              const [])
          .map((option) => option.toString())
          .toList(),
      systemKey: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.SYSTEM_KEY,
                'systemKey',
              ) ??
              '')
          .toString(),
      isSystem: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_SYSTEM_KEY,
            'isSystem',
          ) ==
          true,
      isDefault: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_DEFAULT_KEY,
            'isDefault',
          ) ==
          true,
      isDeleted: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_DELETED_KEY,
            'isDeleted',
          ) ==
          true,
      configuration: Map<String, dynamic>.from(
        CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.CONFIGURATION_KEY,
              'configuration',
            ) as Map? ??
            const {},
      ),
      order: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order')
                  as num?)
              ?.toInt() ??
          0,
      status:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.STATUS_KEY, 'status') ??
                  'active')
              .toString(),
      audit: CrmAuditModel.fromMap(
        Map<String, dynamic>.from(
          CrmFirestoreKeys.read(map, CrmFirestoreKeys.AUDIT_KEY, 'audit')
                  as Map? ??
              const {},
        ),
      ),
    );
  }

  factory CrmSavedSectionFieldModel.fromTemplateField({
    required String id,
    required String savedSectionId,
    required CrmTemplateFieldModel field,
    required CrmAuditModel audit,
    bool isSystem = false,
    bool isDefault = false,
    int? order,
  }) {
    return CrmSavedSectionFieldModel(
      id: id,
      savedSectionId: savedSectionId,
      clientTypeId: field.clientTypeId,
      fieldTypeId: field.fieldTypeId,
      nameEn: field.nameEn,
      nameAr: field.nameAr,
      maxCharacters: field.maxCharacters,
      validationType: field.validationType,
      isRequired: field.isRequired,
      errorMessageEn: field.errorMessageEn,
      errorMessageAr: field.errorMessageAr,
      showBothLanguages: field.showBothLanguages,
      options: field.options,
      systemKey: field.systemKey,
      isSystem: isSystem,
      isDefault: isDefault,
      isDeleted: false,
      configuration: field.configuration,
      order: order ?? field.order,
      status: field.status,
      audit: audit,
    );
  }

  CrmTemplateFieldModel toTemplateField({
    required String id,
    required String templateId,
    required String sectionId,
    required String clientTypeId,
    required CrmAuditModel audit,
    required int order,
    required String sourceSavedSectionId,
  }) {
    return CrmTemplateFieldModel(
      id: id,
      templateId: templateId,
      clientTypeId: clientTypeId,
      sectionId: sectionId,
      fieldTypeId: fieldTypeId,
      nameEn: nameEn,
      nameAr: nameAr,
      maxCharacters: maxCharacters,
      validationType: validationType,
      isRequired: isRequired,
      errorMessageEn: errorMessageEn,
      errorMessageAr: errorMessageAr,
      showBothLanguages: showBothLanguages,
      options: options,
      systemKey: systemKey,
      isDefault: false,
      isDeleted: false,
      configuration: {
        ...configuration,
        CrmFirestoreKeys.SOURCE_SAVED_SECTION_ID_KEY: sourceSavedSectionId,
        CrmFirestoreKeys.SOURCE_SAVED_SECTION_FIELD_ID_KEY: this.id,
        CrmFirestoreKeys.SOURCE_SYSTEM_KEY_KEY: systemKey,
      },
      order: order,
      status: status,
      audit: audit,
    );
  }
}
