// ****************** FILE INFO ******************
// File Name: crm_field_type_model.dart
// Purpose: Data model representing available CRM template field types
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmFieldTypeModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String iconKey;
  final String valueType;
  final String inputType;
  final List<String> allowedClientTypeIds;
  final bool isSystem;
  final bool isActive;
  final int order;

  const CrmFieldTypeModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.iconKey,
    required this.valueType,
    required this.inputType,
    required this.allowedClientTypeIds,
    this.isSystem = true,
    this.isActive = true,
    required this.order,
  });

  bool isAllowedForClientType(String clientTypeId) {
    const List<String> defaultClientTypes = ['person', 'company', 'government'];
    if (!defaultClientTypes.contains(clientTypeId)) return true;
    return allowedClientTypeIds.contains('*') ||
        allowedClientTypeIds.contains(clientTypeId);
  }

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.ICON_KEY: iconKey,
      CrmFirestoreKeys.VALUE_TYPE_KEY: valueType,
      CrmFirestoreKeys.INPUT_TYPE_KEY: inputType,
      CrmFirestoreKeys.ALLOWED_CLIENT_TYPE_IDS_KEY: allowedClientTypeIds,
      CrmFirestoreKeys.IS_SYSTEM_KEY: isSystem,
      CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
      CrmFirestoreKeys.ORDER_KEY: order,
    };
  }

  factory CrmFieldTypeModel.fromMap(Map<String, dynamic> map) {
    return CrmFieldTypeModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      nameEn:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_EN_KEY, 'nameEn') ??
                  '')
              .toString(),
      nameAr:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_AR_KEY, 'nameAr') ??
                  '')
              .toString(),
      iconKey:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ICON_KEY, 'iconKey') ??
                  '')
              .toString(),
      valueType: (CrmFirestoreKeys.read(
                  map, CrmFirestoreKeys.VALUE_TYPE_KEY, 'valueType') ??
              'string')
          .toString(),
      inputType: (CrmFirestoreKeys.read(
                  map, CrmFirestoreKeys.INPUT_TYPE_KEY, 'inputType') ??
              'text')
          .toString(),
      allowedClientTypeIds: List<String>.from(
        CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.ALLOWED_CLIENT_TYPE_IDS_KEY,
              'allowedClientTypeIds',
            ) as List? ??
            const [],
      ),
      isSystem: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_SYSTEM_KEY,
            'isSystem',
          ) !=
          false,
      isActive: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_ACTIVE_KEY,
            'isActive',
          ) !=
          false,
      order: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order')
                  as num?)
              ?.toInt() ??
          0,
    );
  }
}
