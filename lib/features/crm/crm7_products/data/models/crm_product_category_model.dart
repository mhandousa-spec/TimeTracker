// ****************** FILE INFO ******************
// File Name: crm_product_category_model.dart
// Purpose: Persisted CRM product category model with bilingual metadata.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmProductCategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String noteEn;
  final String noteAr;
  final String clientTypeId;
  final List<String> tagIds;
  final String status;
  final bool isActive;
  final bool isDeleted;
  final int order;
  final CrmAuditModel? audit;

  const CrmProductCategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.noteEn,
    required this.noteAr,
    required this.clientTypeId,
    this.tagIds = const <String>[],
    this.status = 'active',
    this.isActive = true,
    this.isDeleted = false,
    this.order = 0,
    this.audit,
  });

  factory CrmProductCategoryModel.empty() => const CrmProductCategoryModel(
        id: '',
        nameEn: '',
        nameAr: '',
        noteEn: '',
        noteAr: '',
        clientTypeId: '',
      );

  factory CrmProductCategoryModel.fromMap(Map<String, dynamic> map) {
    final dynamic rawAudit = map[CrmFirestoreKeys.AUDIT_KEY];
    final String status =
        (map[CrmFirestoreKeys.STATUS_KEY] ?? 'active').toString();
    return CrmProductCategoryModel(
      id: (map[CrmFirestoreKeys.ID_KEY] ?? '').toString(),
      nameEn: (map[CrmFirestoreKeys.NAME_EN_KEY] ?? '').toString(),
      nameAr: (map[CrmFirestoreKeys.NAME_AR_KEY] ?? '').toString(),
      noteEn: (map[CrmFirestoreKeys.NOTE_EN_KEY] ?? '').toString(),
      noteAr: (map[CrmFirestoreKeys.NOTE_AR_KEY] ?? '').toString(),
      clientTypeId: (map[CrmFirestoreKeys.CLIENT_TYPE_ID_KEY] ?? '').toString(),
      tagIds: List<String>.from(
          map[CrmFirestoreKeys.TAG_IDS_KEY] ?? const <String>[]),
      status: status,
      isActive:
          map[CrmFirestoreKeys.IS_ACTIVE_KEY] as bool? ?? status == 'active',
      isDeleted: map[CrmFirestoreKeys.IS_DELETED_KEY] as bool? ?? false,
      order: (map[CrmFirestoreKeys.ORDER_KEY] as num?)?.toInt() ?? 0,
      audit: rawAudit is Map<String, dynamic>
          ? CrmAuditModel.fromMap(rawAudit)
          : null,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        CrmFirestoreKeys.ID_KEY: id,
        CrmFirestoreKeys.NAME_EN_KEY: nameEn,
        CrmFirestoreKeys.NAME_AR_KEY: nameAr,
        CrmFirestoreKeys.NOTE_EN_KEY: noteEn,
        CrmFirestoreKeys.NOTE_AR_KEY: noteAr,
        CrmFirestoreKeys.CLIENT_TYPE_ID_KEY: clientTypeId,
        CrmFirestoreKeys.TAG_IDS_KEY: tagIds,
        CrmFirestoreKeys.STATUS_KEY: status,
        CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
        CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
        CrmFirestoreKeys.ORDER_KEY: order,
        if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
      };

  String localizedName(bool isArabic) =>
      isArabic && nameAr.isNotEmpty ? nameAr : nameEn;
  String localizedNote(bool isArabic) =>
      isArabic && noteAr.isNotEmpty ? noteAr : noteEn;

  CrmProductCategoryModel copyWith({
    String? nameEn,
    String? nameAr,
    String? noteEn,
    String? noteAr,
    String? clientTypeId,
    List<String>? tagIds,
    String? status,
    bool? isActive,
    bool? isDeleted,
    int? order,
    CrmAuditModel? audit,
  }) =>
      CrmProductCategoryModel(
        id: id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        noteEn: noteEn ?? this.noteEn,
        noteAr: noteAr ?? this.noteAr,
        clientTypeId: clientTypeId ?? this.clientTypeId,
        tagIds: tagIds ?? this.tagIds,
        status: status ?? this.status,
        isActive: isActive ?? this.isActive,
        isDeleted: isDeleted ?? this.isDeleted,
        order: order ?? this.order,
        audit: audit ?? this.audit,
      );
}
