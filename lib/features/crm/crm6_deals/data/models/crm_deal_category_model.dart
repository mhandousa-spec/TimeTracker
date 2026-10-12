// ****************** FILE INFO ******************
// File Name: crm_deal_category_model.dart
// Purpose: Data model for CRM Deal Categories with Firestore serialization
// Author: Mohand Adel
// Created At: 22/08/2026

// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmDealCategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String status;
  final int order;
  final bool isDeleted;
  final CrmAuditModel? audit;

  static const String ID = 'Id';
  static const String NAME_EN = 'Name_En';
  static const String NAME_AR = 'Name_Ar';
  static const String STATUS = 'Status';
  static const String ORDER = 'Order';
  static const String IS_DELETED = 'Is_Deleted';
  static const String AUDIT = 'Audit';

  const CrmDealCategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.status = 'active',
    this.order = 0,
    this.isDeleted = false,
    this.audit,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isInactive => !isActive;

  factory CrmDealCategoryModel.getEmptyModel() {
    return const CrmDealCategoryModel(
      id: '',
      nameEn: '',
      nameAr: '',
      status: 'active',
      order: 0,
      isDeleted: false,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.STATUS_KEY: status,
      CrmFirestoreKeys.ORDER_KEY: order,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
    };
    if (audit != null) {
      map[CrmFirestoreKeys.AUDIT_KEY] = audit!.toMap();
    }
    return map;
  }

  factory CrmDealCategoryModel.fromMap(Map<String, dynamic> map) {
    CrmAuditModel? auditModel;
    final dynamic rawAudit = CrmFirestoreKeys.read(
      map,
      CrmFirestoreKeys.AUDIT_KEY,
      'audit',
    );
    if (rawAudit is Map<String, dynamic>) {
      auditModel = CrmAuditModel.fromMap(rawAudit);
    }

    return CrmDealCategoryModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      nameEn: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.NAME_EN_KEY,
                'nameEn',
              ) ??
              '')
          .toString(),
      nameAr: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.NAME_AR_KEY,
                'nameAr',
              ) ??
              '')
          .toString(),
      status: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.STATUS_KEY,
                'status',
              ) ??
              'active')
          .toString(),
      order: _asInt(
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order'),
      ),
      isDeleted: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_DELETED_KEY,
            'isDeleted',
          ) ==
          true,
      audit: auditModel,
    );
  }

  CrmDealCategoryModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? status,
    int? order,
    bool? isDeleted,
    CrmAuditModel? audit,
  }) {
    return CrmDealCategoryModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      status: status ?? this.status,
      order: order ?? this.order,
      isDeleted: isDeleted ?? this.isDeleted,
      audit: audit ?? this.audit,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
