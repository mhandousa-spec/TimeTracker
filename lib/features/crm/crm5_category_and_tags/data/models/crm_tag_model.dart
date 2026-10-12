// ****************** FILE INFO ******************
// File Name: crm_tag_model.dart
// Purpose: Data model for Activity Tags in CRM
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmTagModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String status;
  final bool isActive;
  final bool isDeleted;
  final int order;
  final CrmAuditModel? audit;

  const CrmTagModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.status,
    required this.isActive,
    required this.isDeleted,
    required this.order,
    this.audit,
  });

  String localizedName(bool isArabic) {
    if (isArabic) {
      return nameAr.isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  factory CrmTagModel.getEmptyModel() {
    return const CrmTagModel(
      id: '',
      nameEn: '',
      nameAr: '',
      status: 'active',
      isActive: true,
      isDeleted: false,
      order: 0,
    );
  }

  factory CrmTagModel.fromMap(Map<String, dynamic> map) {
    final dynamic rawAudit = map[CrmFirestoreKeys.AUDIT_KEY];
    CrmAuditModel? parsedAudit;
    if (rawAudit is Map<String, dynamic>) {
      parsedAudit = CrmAuditModel.fromMap(rawAudit);
    } else if (rawAudit is Map) {
      parsedAudit = CrmAuditModel.fromMap(Map<String, dynamic>.from(rawAudit));
    }

    final String statusStr =
        (map[CrmFirestoreKeys.STATUS_KEY] ?? 'active').toString();
    final bool active = map[CrmFirestoreKeys.IS_ACTIVE_KEY] as bool? ??
        (statusStr.toLowerCase() == 'active');

    return CrmTagModel(
      id: (map[CrmFirestoreKeys.ID_KEY] ?? '').toString(),
      nameEn: (map[CrmFirestoreKeys.NAME_EN_KEY] ?? '').toString(),
      nameAr: (map[CrmFirestoreKeys.NAME_AR_KEY] ?? '').toString(),
      status: statusStr,
      isActive: active,
      isDeleted: map[CrmFirestoreKeys.IS_DELETED_KEY] as bool? ?? false,
      order: (map[CrmFirestoreKeys.ORDER_KEY] as num?)?.toInt() ?? 0,
      audit: parsedAudit,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.STATUS_KEY: status,
      CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.ORDER_KEY: order,
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
    };
  }

  CrmTagModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? status,
    bool? isActive,
    bool? isDeleted,
    int? order,
    CrmAuditModel? audit,
  }) {
    return CrmTagModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      audit: audit ?? this.audit,
    );
  }
}
