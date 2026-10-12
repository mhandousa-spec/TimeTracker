// ****************** FILE INFO ******************
// File Name: crm_template_model.dart
// Purpose: Data model representing a CRM client template
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

import 'crm_audit_model.dart';

class CrmTemplateModel {
  final String id;
  final String clientTypeId;
  final String nameEn;
  final String nameAr;
  final String status;
  final int version;
  final int fieldCount;
  final int sectionCount;
  final int pageCount;
  final int? defaultsVersion;
  final DateTime? publishedAt;
  final CrmAuditModel audit;

  const CrmTemplateModel({
    required this.id,
    required this.clientTypeId,
    required this.nameEn,
    required this.nameAr,
    this.status = 'draft',
    this.version = 1,
    this.fieldCount = 0,
    this.sectionCount = 0,
    this.pageCount = 0,
    this.defaultsVersion,
    this.publishedAt,
    required this.audit,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.CLIENT_TYPE_ID_KEY: clientTypeId,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.STATUS_KEY: status,
      CrmFirestoreKeys.VERSION_KEY: version,
      CrmFirestoreKeys.FIELD_COUNT_KEY: fieldCount,
      CrmFirestoreKeys.SECTION_COUNT_KEY: sectionCount,
      CrmFirestoreKeys.PAGE_COUNT_KEY: pageCount,
      if (defaultsVersion != null)
        CrmFirestoreKeys.DEFAULTS_VERSION_KEY: defaultsVersion,
      CrmFirestoreKeys.PUBLISHED_AT_KEY:
          publishedAt == null ? null : Timestamp.fromDate(publishedAt!),
      CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
    };
  }

  factory CrmTemplateModel.fromMap(Map<String, dynamic> map) {
    return CrmTemplateModel(
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
      status:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.STATUS_KEY, 'status') ??
                  'draft')
              .toString(),
      version: (CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.VERSION_KEY,
            'version',
          ) as num?)
              ?.toInt() ??
          1,
      fieldCount: (CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.FIELD_COUNT_KEY,
            'fieldCount',
          ) as num?)
              ?.toInt() ??
          0,
      sectionCount: (CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.SECTION_COUNT_KEY,
            'sectionCount',
          ) as num?)
              ?.toInt() ??
          0,
      pageCount: (CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.PAGE_COUNT_KEY,
            'pageCount',
          ) as num?)
              ?.toInt() ??
          0,
      defaultsVersion: (CrmFirestoreKeys.read(
        map,
        CrmFirestoreKeys.DEFAULTS_VERSION_KEY,
        'defaultsVersion',
      ) as num?)
          ?.toInt(),
      publishedAt: _readNullableDateTime(
        CrmFirestoreKeys.read(
          map,
          CrmFirestoreKeys.PUBLISHED_AT_KEY,
          'publishedAt',
        ),
      ),
      audit: CrmAuditModel.fromMap(
        Map<String, dynamic>.from(
          CrmFirestoreKeys.read(map, CrmFirestoreKeys.AUDIT_KEY, 'audit')
                  as Map? ??
              const {},
        ),
      ),
    );
  }

  CrmTemplateModel copyWith({
    String? id,
    String? clientTypeId,
    String? nameEn,
    String? nameAr,
    String? status,
    int? version,
    int? fieldCount,
    int? sectionCount,
    int? pageCount,
    int? defaultsVersion,
    DateTime? publishedAt,
    CrmAuditModel? audit,
  }) {
    return CrmTemplateModel(
      id: id ?? this.id,
      clientTypeId: clientTypeId ?? this.clientTypeId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      status: status ?? this.status,
      version: version ?? this.version,
      fieldCount: fieldCount ?? this.fieldCount,
      sectionCount: sectionCount ?? this.sectionCount,
      pageCount: pageCount ?? this.pageCount,
      defaultsVersion: defaultsVersion ?? this.defaultsVersion,
      publishedAt: publishedAt ?? this.publishedAt,
      audit: audit ?? this.audit,
    );
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
