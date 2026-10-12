// ****************** FILE INFO ******************
// File Name: crm_saved_section_model.dart
// Purpose: Data model for reusable CRM saved sections
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmSavedSectionModel {
  final String id;
  final String clientTypeId;
  final String nameEn;
  final String nameAr;
  final String systemKey;
  final bool isSystem;
  final bool isDefault;
  final bool isDeleted;
  final Map<String, dynamic> configuration;
  final int order;
  final String status;
  final CrmAuditModel audit;

  const CrmSavedSectionModel({
    required this.id,
    required this.clientTypeId,
    required this.nameEn,
    required this.nameAr,
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
      CrmFirestoreKeys.CLIENT_TYPE_ID_KEY: clientTypeId,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
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

  factory CrmSavedSectionModel.fromMap(Map<String, dynamic> map) {
    return CrmSavedSectionModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      clientTypeId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.CLIENT_TYPE_ID_KEY,
                'clientTypeId',
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

  factory CrmSavedSectionModel.fromTemplateSection({
    required String id,
    required CrmTemplateSectionModel section,
    required CrmAuditModel audit,
    bool isSystem = false,
    bool isDefault = false,
    int? order,
  }) {
    return CrmSavedSectionModel(
      id: id,
      clientTypeId: section.clientTypeId,
      nameEn: section.nameEn,
      nameAr: section.nameAr,
      systemKey: section.systemKey,
      isSystem: isSystem,
      isDefault: isDefault,
      isDeleted: false,
      configuration: section.configuration,
      order: order ?? section.order,
      status: section.status,
      audit: audit,
    );
  }

  CrmSavedSectionModel copyWith({
    String? id,
    String? clientTypeId,
    String? nameEn,
    String? nameAr,
    String? systemKey,
    bool? isSystem,
    bool? isDefault,
    bool? isDeleted,
    Map<String, dynamic>? configuration,
    int? order,
    String? status,
    CrmAuditModel? audit,
  }) {
    return CrmSavedSectionModel(
      id: id ?? this.id,
      clientTypeId: clientTypeId ?? this.clientTypeId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      systemKey: systemKey ?? this.systemKey,
      isSystem: isSystem ?? this.isSystem,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      configuration: configuration ?? this.configuration,
      order: order ?? this.order,
      status: status ?? this.status,
      audit: audit ?? this.audit,
    );
  }
}
