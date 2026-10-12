// ****************** FILE INFO ******************
// File Name: crm_audit_model.dart
// Purpose: Shared audit metadata model for CRM Firestore documents
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmAuditModel {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  const CrmAuditModel({
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  factory CrmAuditModel.now({required String userEmail}) {
    final DateTime now = DateTime.now();
    final String normalizedEmail = userEmail.trim().toLowerCase();
    return CrmAuditModel(
      createdAt: now,
      updatedAt: now,
      createdBy: normalizedEmail,
      updatedBy: normalizedEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.CREATED_AT_KEY: Timestamp.fromDate(createdAt),
      CrmFirestoreKeys.UPDATED_AT_KEY: Timestamp.fromDate(updatedAt),
      CrmFirestoreKeys.CREATED_BY_KEY: createdBy,
      CrmFirestoreKeys.UPDATED_BY_KEY: updatedBy,
    };
  }

  factory CrmAuditModel.fromMap(Map<String, dynamic> map) {
    return CrmAuditModel(
      createdAt: _readDateTime(
        CrmFirestoreKeys.read(
          map,
          CrmFirestoreKeys.CREATED_AT_KEY,
          'createdAt',
        ),
      ),
      updatedAt: _readDateTime(
        CrmFirestoreKeys.read(
          map,
          CrmFirestoreKeys.UPDATED_AT_KEY,
          'updatedAt',
        ),
      ),
      createdBy: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.CREATED_BY_KEY,
                'createdBy',
              ) ??
              '')
          .toString(),
      updatedBy: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.UPDATED_BY_KEY,
                'updatedBy',
              ) ??
              '')
          .toString(),
    );
  }

  CrmAuditModel copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CrmAuditModel(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  CrmAuditModel markUpdated({required String userEmail}) {
    return copyWith(
      updatedAt: DateTime.now(),
      updatedBy: userEmail.trim().toLowerCase(),
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
