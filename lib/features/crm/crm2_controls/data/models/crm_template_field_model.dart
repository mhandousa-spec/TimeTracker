// ****************** FILE INFO ******************
// File Name: crm_template_field_model.dart
// Purpose: Data model representing a CRM template field
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

import 'crm_audit_model.dart';

class CrmTemplateFieldModel {
  final String id;
  final String templateId;
  final String clientTypeId;
  final String? sectionId;
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
  final bool isDefault;
  final bool isDeleted;
  final Map<String, dynamic> configuration;
  final int order;
  final String status;
  final CrmAuditModel audit;

  const CrmTemplateFieldModel({
    required this.id,
    required this.templateId,
    required this.clientTypeId,
    this.sectionId,
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
      CrmFirestoreKeys.TEMPLATE_ID_KEY: templateId,
      CrmFirestoreKeys.CLIENT_TYPE_ID_KEY: clientTypeId,
      CrmFirestoreKeys.SECTION_ID_KEY: sectionId,
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
      CrmFirestoreKeys.IS_DEFAULT_KEY: isDefault,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.CONFIGURATION_KEY: configuration,
      CrmFirestoreKeys.ORDER_KEY: order,
      CrmFirestoreKeys.STATUS_KEY: status,
      CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
    };
  }

  factory CrmTemplateFieldModel.fromMap(Map<String, dynamic> map) {
    return CrmTemplateFieldModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      templateId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.TEMPLATE_ID_KEY,
                'templateId',
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
      sectionId: CrmFirestoreKeys.read(
              map, CrmFirestoreKeys.SECTION_ID_KEY, 'sectionId')
          ?.toString(),
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
      options: List<String>.from(
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.OPTIONS_KEY, 'options')
                as List? ??
            const [],
      ),
      systemKey: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.SYSTEM_KEY,
                'systemKey',
              ) ??
              '')
          .toString(),
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

  CrmTemplateFieldModel copyWith({
    String? id,
    String? templateId,
    String? clientTypeId,
    String? sectionId,
    String? fieldTypeId,
    String? nameEn,
    String? nameAr,
    int? maxCharacters,
    String? validationType,
    bool? isRequired,
    String? errorMessageEn,
    String? errorMessageAr,
    bool? showBothLanguages,
    List<String>? options,
    String? systemKey,
    bool? isDefault,
    bool? isDeleted,
    Map<String, dynamic>? configuration,
    int? order,
    String? status,
    CrmAuditModel? audit,
  }) {
    return CrmTemplateFieldModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      clientTypeId: clientTypeId ?? this.clientTypeId,
      sectionId: sectionId ?? this.sectionId,
      fieldTypeId: fieldTypeId ?? this.fieldTypeId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      maxCharacters: maxCharacters ?? this.maxCharacters,
      validationType: validationType ?? this.validationType,
      isRequired: isRequired ?? this.isRequired,
      errorMessageEn: errorMessageEn ?? this.errorMessageEn,
      errorMessageAr: errorMessageAr ?? this.errorMessageAr,
      showBothLanguages: showBothLanguages ?? this.showBothLanguages,
      options: options ?? this.options,
      systemKey: systemKey ?? this.systemKey,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      configuration: configuration ?? this.configuration,
      order: order ?? this.order,
      status: status ?? this.status,
      audit: audit ?? this.audit,
    );
  }
}
