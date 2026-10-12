// ****************** FILE INFO ******************
// File Name: crm_template_section_model.dart
// Purpose: Data model representing a CRM template section
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

import 'crm_audit_model.dart';

class CrmTemplateSectionModel {
  final String id;
  final String templateId;
  final String clientTypeId;
  final String nameEn;
  final String nameAr;
  final String systemKey;
  final bool isDefault;
  final bool isDeleted;
  final Map<String, dynamic> configuration;
  final int order;
  final bool isCollapsible;
  final String status;
  final CrmAuditModel audit;

  const CrmTemplateSectionModel({
    required this.id,
    required this.templateId,
    required this.clientTypeId,
    required this.nameEn,
    required this.nameAr,
    this.systemKey = '',
    this.isDefault = false,
    this.isDeleted = false,
    this.configuration = const {},
    required this.order,
    this.isCollapsible = true,
    this.status = 'active',
    required this.audit,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.TEMPLATE_ID_KEY: templateId,
      CrmFirestoreKeys.CLIENT_TYPE_ID_KEY: clientTypeId,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.SYSTEM_KEY: systemKey,
      CrmFirestoreKeys.IS_DEFAULT_KEY: isDefault,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.CONFIGURATION_KEY: configuration,
      CrmFirestoreKeys.ORDER_KEY: order,
      CrmFirestoreKeys.IS_COLLAPSIBLE_KEY: isCollapsible,
      CrmFirestoreKeys.STATUS_KEY: status,
      CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
    };
  }

  factory CrmTemplateSectionModel.fromMap(Map<String, dynamic> map) {
    return CrmTemplateSectionModel(
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
      isCollapsible: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_COLLAPSIBLE_KEY,
            'isCollapsible',
          ) !=
          false,
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

  CrmTemplateSectionModel copyWith({
    String? id,
    String? templateId,
    String? clientTypeId,
    String? nameEn,
    String? nameAr,
    String? systemKey,
    bool? isDefault,
    bool? isDeleted,
    Map<String, dynamic>? configuration,
    int? order,
    bool? isCollapsible,
    String? status,
    CrmAuditModel? audit,
  }) {
    return CrmTemplateSectionModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      clientTypeId: clientTypeId ?? this.clientTypeId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      systemKey: systemKey ?? this.systemKey,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      configuration: configuration ?? this.configuration,
      order: order ?? this.order,
      isCollapsible: isCollapsible ?? this.isCollapsible,
      status: status ?? this.status,
      audit: audit ?? this.audit,
    );
  }
}
