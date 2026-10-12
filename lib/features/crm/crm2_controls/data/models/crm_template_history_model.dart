// ****************** FILE INFO ******************
// File Name: crm_template_history_model.dart
// Purpose: Data model for CRM template change history tracking
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmTemplateHistoryModel {
  final String id;
  final String templateId;
  final String targetType;
  final String targetId;
  final String action;
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
  final String changedBy;
  final DateTime changedAt;

  const CrmTemplateHistoryModel({
    required this.id,
    required this.templateId,
    required this.targetType,
    required this.targetId,
    required this.action,
    this.before = const {},
    this.after = const {},
    required this.changedBy,
    required this.changedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.TEMPLATE_ID_KEY: templateId,
      CrmFirestoreKeys.TARGET_TYPE_KEY: targetType,
      CrmFirestoreKeys.TARGET_ID_KEY: targetId,
      CrmFirestoreKeys.ACTION_KEY: action,
      CrmFirestoreKeys.BEFORE_KEY: before,
      CrmFirestoreKeys.AFTER_KEY: after,
      CrmFirestoreKeys.CHANGED_BY_KEY: changedBy,
      CrmFirestoreKeys.CHANGED_AT_KEY: Timestamp.fromDate(changedAt),
    };
  }

  factory CrmTemplateHistoryModel.fromMap(Map<String, dynamic> map) {
    return CrmTemplateHistoryModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      templateId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.TEMPLATE_ID_KEY,
                'templateId',
              ) ??
              '')
          .toString(),
      targetType: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.TARGET_TYPE_KEY,
                'targetType',
              ) ??
              '')
          .toString(),
      targetId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.TARGET_ID_KEY,
                'targetId',
              ) ??
              '')
          .toString(),
      action:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ACTION_KEY, 'action') ??
                  '')
              .toString(),
      before: Map<String, dynamic>.from(
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.BEFORE_KEY, 'before')
                as Map? ??
            const {},
      ),
      after: Map<String, dynamic>.from(
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.AFTER_KEY, 'after')
                as Map? ??
            const {},
      ),
      changedBy: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.CHANGED_BY_KEY,
                'changedBy',
              ) ??
              '')
          .toString(),
      changedAt: _readDateTime(
        CrmFirestoreKeys.read(
          map,
          CrmFirestoreKeys.CHANGED_AT_KEY,
          'changedAt',
        ),
      ),
    );
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
