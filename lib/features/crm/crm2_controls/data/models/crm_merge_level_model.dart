// ****************** FILE INFO ******************
// File Name: crm_merge_level_model.dart
// Purpose: Data model representing a CRM merge possible level in Controls
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmMergeLevelModel {
  static const String ID = CrmFirestoreKeys.ID_KEY;
  static const String NAME_EN = CrmFirestoreKeys.NAME_EN_KEY;
  static const String NAME_AR = CrmFirestoreKeys.NAME_AR_KEY;
  static const String RANGE_FROM = CrmFirestoreKeys.RANGE_FROM_KEY;
  static const String RANGE_TO = CrmFirestoreKeys.RANGE_TO_KEY;
  static const String COLOR_HEX = CrmFirestoreKeys.COLOR_HEX_KEY;
  static const String IS_ACTIVE = CrmFirestoreKeys.IS_ACTIVE_KEY;
  static const String IS_DELETED = CrmFirestoreKeys.IS_DELETED_KEY;
  static const String ORDER = CrmFirestoreKeys.ORDER_KEY;
  static const String AUDIT = CrmFirestoreKeys.AUDIT_KEY;

  final String id;
  final String nameEn;
  final String nameAr;
  final double rangeFrom;
  final double rangeTo;
  final String colorHex;
  final bool isActive;
  final bool isDeleted;
  final int order;
  final CrmAuditModel? audit;
  final VoidCallback? onTap;

  const CrmMergeLevelModel({
    required this.id,
    this.nameEn = '',
    this.nameAr = '',
    this.rangeFrom = 0.0,
    this.rangeTo = 0.0,
    this.colorHex = '#FFD043',
    this.isActive = true,
    this.isDeleted = false,
    this.order = 0,
    this.audit,
    this.onTap,
  });

  String get displayName => nameEn.isNotEmpty ? nameEn : nameAr;

  Color get color {
    final String cleanHex = colorHex.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    } else if (cleanHex.length == 8) {
      return Color(int.parse(cleanHex, radix: 16));
    }
    return const Color(0xFFFFD043);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.RANGE_FROM_KEY: rangeFrom,
      CrmFirestoreKeys.RANGE_TO_KEY: rangeTo,
      CrmFirestoreKeys.COLOR_HEX_KEY: colorHex,
      CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.ORDER_KEY: order,
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
    };
  }

  factory CrmMergeLevelModel.fromMap(
    Map<String, dynamic> map, {
    VoidCallback? onTap,
  }) {
    final String nameEn = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.NAME_EN_KEY,
              'nameEn',
            ) ??
            '')
        .toString();
    final String nameAr = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.NAME_AR_KEY,
              'nameAr',
            ) ??
            '')
        .toString();
    final dynamic rawRange = CrmFirestoreKeys.read(
      map,
      CrmFirestoreKeys.RANGE_FROM_KEY,
      'rangeFrom',
    );
    final double rangeFrom = rawRange is num
        ? rawRange.toDouble()
        : double.tryParse(rawRange?.toString() ?? '0') ?? 0.0;
    final dynamic rawRangeTo = CrmFirestoreKeys.read(
      map,
      CrmFirestoreKeys.RANGE_TO_KEY,
      'rangeTo',
    );
    final double rangeTo = rawRangeTo is num
        ? rawRangeTo.toDouble()
        : double.tryParse(rawRangeTo?.toString() ?? '') ?? rangeFrom;
    final String colorHex = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.COLOR_HEX_KEY,
              'colorHex',
            ) ??
            '#FFD043')
        .toString();
    final dynamic auditData = CrmFirestoreKeys.read(
      map,
      CrmFirestoreKeys.AUDIT_KEY,
      'audit',
    );

    return CrmMergeLevelModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      nameEn: nameEn,
      nameAr: nameAr,
      rangeFrom: rangeFrom,
      rangeTo: rangeTo,
      colorHex: colorHex.isNotEmpty ? colorHex : '#FFD043',
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

  factory CrmMergeLevelModel.getEmptyModel() {
    return const CrmMergeLevelModel(
      id: '',
      nameEn: '',
      nameAr: '',
      rangeFrom: 0.0,
      rangeTo: 0.0,
      colorHex: '#FFD043',
      isActive: true,
      isDeleted: false,
      order: 0,
    );
  }

  CrmMergeLevelModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    double? rangeFrom,
    double? rangeTo,
    String? colorHex,
    bool? isActive,
    bool? isDeleted,
    int? order,
    CrmAuditModel? audit,
    VoidCallback? onTap,
  }) {
    return CrmMergeLevelModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      rangeFrom: rangeFrom ?? this.rangeFrom,
      rangeTo: rangeTo ?? this.rangeTo,
      colorHex: colorHex ?? this.colorHex,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      audit: audit ?? this.audit,
      onTap: onTap ?? this.onTap,
    );
  }
}
