// ****************** FILE INFO ******************
// File Name: crm_client_type_model.dart
// Purpose: Data model representing a CRM client type in Controls
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

import 'crm_audit_model.dart';

class CrmClientTypeModel {
  final String id;
  final String title;
  final String nameEn;
  final String nameAr;
  final String svgAsset;
  final String iconKey;
  final String iconUrl;
  final String? systemKey;
  final bool isDefault;
  final bool isActive;
  final bool isDeleted;
  final int order;
  final CrmAuditModel? audit;
  final VoidCallback? onTap;

  const CrmClientTypeModel({
    required this.id,
    required this.title,
    this.nameEn = '',
    this.nameAr = '',
    required this.svgAsset,
    this.iconKey = '',
    this.iconUrl = '',
    this.systemKey,
    this.isDefault = false,
    this.isActive = true,
    this.isDeleted = false,
    this.order = 0,
    this.audit,
    this.onTap,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.SYSTEM_KEY: systemKey,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn.isNotEmpty ? nameEn : title,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.TITLE_KEY: title,
      CrmFirestoreKeys.SVG_ASSET_KEY: svgAsset,
      CrmFirestoreKeys.ICON_KEY: iconKey,
      CrmFirestoreKeys.ICON_URL_KEY: iconUrl,
      CrmFirestoreKeys.IS_DEFAULT_KEY: isDefault,
      CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.ORDER_KEY: order,
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
    };
  }

  factory CrmClientTypeModel.fromMap(
    Map<String, dynamic> map, {
    VoidCallback? onTap,
  }) {
    final String nameEn = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.NAME_EN_KEY,
              'nameEn',
            ) ??
            CrmFirestoreKeys.read(map, CrmFirestoreKeys.TITLE_KEY, 'title') ??
            '')
        .toString();
    final dynamic auditData = CrmFirestoreKeys.read(
      map,
      CrmFirestoreKeys.AUDIT_KEY,
      'audit',
    );
    return CrmClientTypeModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      title: nameEn,
      nameEn: nameEn,
      nameAr:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_AR_KEY, 'nameAr') ??
                  '')
              .toString(),
      svgAsset: (CrmFirestoreKeys.read(
                  map, CrmFirestoreKeys.SVG_ASSET_KEY, 'svgAsset') ??
              '')
          .toString(),
      iconKey:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ICON_KEY, 'iconKey') ??
                  '')
              .toString(),
      iconUrl: (CrmFirestoreKeys.read(
                  map, CrmFirestoreKeys.ICON_URL_KEY, 'iconUrl') ??
              '')
          .toString(),
      systemKey: CrmFirestoreKeys.read(
        map,
        CrmFirestoreKeys.SYSTEM_KEY,
        'systemKey',
      )?.toString(),
      isDefault: CrmFirestoreKeys.read(
              map, CrmFirestoreKeys.IS_DEFAULT_KEY, 'isDefault') ==
          true,
      isActive: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_ACTIVE_KEY,
            'isActive',
          ) !=
          false,
      isDeleted: CrmFirestoreKeys.read(
              map, CrmFirestoreKeys.IS_DELETED_KEY, 'isDeleted') ==
          true,
      order: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order')
                  as num?)
              ?.toInt() ??
          0,
      audit: auditData is Map<String, dynamic>
          ? CrmAuditModel.fromMap(auditData)
          : null,
      onTap: onTap,
    );
  }

  CrmClientTypeModel copyWith({
    String? id,
    String? title,
    String? nameEn,
    String? nameAr,
    String? svgAsset,
    String? iconKey,
    String? iconUrl,
    String? systemKey,
    bool? isDefault,
    bool? isActive,
    bool? isDeleted,
    int? order,
    CrmAuditModel? audit,
    VoidCallback? onTap,
  }) {
    return CrmClientTypeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      svgAsset: svgAsset ?? this.svgAsset,
      iconKey: iconKey ?? this.iconKey,
      iconUrl: iconUrl ?? this.iconUrl,
      systemKey: systemKey ?? this.systemKey,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      audit: audit ?? this.audit,
      onTap: onTap ?? this.onTap,
    );
  }
}
