// ****************** FILE INFO ******************
// File Name: crm_client_relationship_model.dart
// Purpose: Data model representing a relationship between a client and a related entity (employee, company, client)
// Author: Mohand Adel
// Created At: 26/08/2026
// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmClientRelationshipModel {
  final String id;
  final String clientId;
  final String categoryId;
  final String categoryNameEn;
  final String categoryNameAr;
  final String typeId;
  final String typeNameEn;
  final String typeNameAr;
  final String relatedEntityId;
  final String relatedEntityName;
  final String? relatedEntityNameAr;
  final String relatedEntityType; // 'employee', 'client', 'company'
  final String? relatedEntityRole;
  final String? relatedEntityAvatar;
  final String? relatedEntityPhone;
  final String? relatedEntityEmail;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? noteEn;
  final String? noteAr;
  final String status; // 'active', 'inactive', 'deleted'
  final CrmAuditModel? audit;

  static const String ID = 'Id';
  static const String CLIENT_ID = 'Client_Id';
  static const String CATEGORY_ID = 'Category_Id';
  static const String CATEGORY_NAME_EN = 'Category_Name_En';
  static const String CATEGORY_NAME_AR = 'Category_Name_Ar';
  static const String TYPE_ID = 'Type_Id';
  static const String TYPE_NAME_EN = 'Type_Name_En';
  static const String TYPE_NAME_AR = 'Type_Name_Ar';
  static const String RELATED_ENTITY_ID = 'Related_Entity_Id';
  static const String RELATED_ENTITY_NAME = 'Related_Entity_Name';
  static const String RELATED_ENTITY_NAME_AR = 'Related_Entity_Name_Ar';
  static const String RELATED_ENTITY_TYPE = 'Related_Entity_Type';
  static const String RELATED_ENTITY_ROLE = 'Related_Entity_Role';
  static const String RELATED_ENTITY_AVATAR = 'Related_Entity_Avatar';
  static const String RELATED_ENTITY_PHONE = 'Related_Entity_Phone';
  static const String RELATED_ENTITY_EMAIL = 'Related_Entity_Email';
  static const String START_DATE = 'Start_Date';
  static const String END_DATE = 'End_Date';
  static const String NOTE_EN = 'Note_En';
  static const String NOTE_AR = 'Note_Ar';
  static const String STATUS = 'Status';
  static const String AUDIT = 'Audit';

  const CrmClientRelationshipModel({
    required this.id,
    required this.clientId,
    required this.categoryId,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.typeId,
    required this.typeNameEn,
    required this.typeNameAr,
    required this.relatedEntityId,
    required this.relatedEntityName,
    this.relatedEntityNameAr,
    this.relatedEntityType = 'employee',
    this.relatedEntityRole,
    this.relatedEntityAvatar,
    this.relatedEntityPhone,
    this.relatedEntityEmail,
    this.startDate,
    this.endDate,
    this.noteEn,
    this.noteAr,
    this.status = 'active',
    this.audit,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isDeleted => status.toLowerCase() == 'deleted';

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CLIENT_ID: clientId,
      CATEGORY_ID: categoryId,
      CATEGORY_NAME_EN: categoryNameEn,
      CATEGORY_NAME_AR: categoryNameAr,
      TYPE_ID: typeId,
      TYPE_NAME_EN: typeNameEn,
      TYPE_NAME_AR: typeNameAr,
      RELATED_ENTITY_ID: relatedEntityId,
      RELATED_ENTITY_NAME: relatedEntityName,
      if (relatedEntityNameAr != null)
        RELATED_ENTITY_NAME_AR: relatedEntityNameAr,
      RELATED_ENTITY_TYPE: relatedEntityType,
      if (relatedEntityRole != null) RELATED_ENTITY_ROLE: relatedEntityRole,
      if (relatedEntityAvatar != null)
        RELATED_ENTITY_AVATAR: relatedEntityAvatar,
      if (relatedEntityPhone != null) RELATED_ENTITY_PHONE: relatedEntityPhone,
      if (relatedEntityEmail != null) RELATED_ENTITY_EMAIL: relatedEntityEmail,
      if (startDate != null) START_DATE: Timestamp.fromDate(startDate!),
      if (endDate != null) END_DATE: Timestamp.fromDate(endDate!),
      if (noteEn != null) NOTE_EN: noteEn,
      if (noteAr != null) NOTE_AR: noteAr,
      CrmFirestoreKeys.STATUS_KEY: status,
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
    };
  }

  factory CrmClientRelationshipModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
      return null;
    }

    final dynamic auditData =
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.AUDIT_KEY, 'audit');
    final String resolvedStatus =
        (CrmFirestoreKeys.read(map, CrmFirestoreKeys.STATUS_KEY, 'status') ??
                'active')
            .toString();

    return CrmClientRelationshipModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      clientId:
          (CrmFirestoreKeys.read(map, CLIENT_ID, 'clientId') ?? '').toString(),
      categoryId: (CrmFirestoreKeys.read(map, CATEGORY_ID, 'categoryId') ?? '')
          .toString(),
      categoryNameEn:
          (CrmFirestoreKeys.read(map, CATEGORY_NAME_EN, 'categoryNameEn') ?? '')
              .toString(),
      categoryNameAr:
          (CrmFirestoreKeys.read(map, CATEGORY_NAME_AR, 'categoryNameAr') ?? '')
              .toString(),
      typeId: (CrmFirestoreKeys.read(map, TYPE_ID, 'typeId') ?? '').toString(),
      typeNameEn: (CrmFirestoreKeys.read(map, TYPE_NAME_EN, 'typeNameEn') ?? '')
          .toString(),
      typeNameAr: (CrmFirestoreKeys.read(map, TYPE_NAME_AR, 'typeNameAr') ?? '')
          .toString(),
      relatedEntityId:
          (CrmFirestoreKeys.read(map, RELATED_ENTITY_ID, 'relatedEntityId') ??
                  '')
              .toString(),
      relatedEntityName: (CrmFirestoreKeys.read(
                  map, RELATED_ENTITY_NAME, 'relatedEntityName') ??
              '')
          .toString(),
      relatedEntityNameAr: CrmFirestoreKeys.read(
              map, RELATED_ENTITY_NAME_AR, 'relatedEntityNameAr')
          ?.toString(),
      relatedEntityType: (CrmFirestoreKeys.read(
                  map, RELATED_ENTITY_TYPE, 'relatedEntityType') ??
              'employee')
          .toString(),
      relatedEntityRole:
          CrmFirestoreKeys.read(map, RELATED_ENTITY_ROLE, 'relatedEntityRole')
              ?.toString(),
      relatedEntityAvatar: CrmFirestoreKeys.read(
              map, RELATED_ENTITY_AVATAR, 'relatedEntityAvatar')
          ?.toString(),
      relatedEntityPhone:
          CrmFirestoreKeys.read(map, RELATED_ENTITY_PHONE, 'relatedEntityPhone')
              ?.toString(),
      relatedEntityEmail:
          CrmFirestoreKeys.read(map, RELATED_ENTITY_EMAIL, 'relatedEntityEmail')
              ?.toString(),
      startDate: parseDate(CrmFirestoreKeys.read(map, START_DATE, 'startDate')),
      endDate: parseDate(CrmFirestoreKeys.read(map, END_DATE, 'endDate')),
      noteEn: CrmFirestoreKeys.read(map, NOTE_EN, 'noteEn')?.toString(),
      noteAr: CrmFirestoreKeys.read(map, NOTE_AR, 'noteAr')?.toString(),
      status: resolvedStatus,
      audit: auditData is Map<String, dynamic>
          ? CrmAuditModel.fromMap(auditData)
          : null,
    );
  }

  factory CrmClientRelationshipModel.getEmptyModel() {
    return const CrmClientRelationshipModel(
      id: '',
      clientId: '',
      categoryId: '',
      categoryNameEn: '',
      categoryNameAr: '',
      typeId: '',
      typeNameEn: '',
      typeNameAr: '',
      relatedEntityId: '',
      relatedEntityName: '',
      status: 'active',
    );
  }

  CrmClientRelationshipModel copyWith({
    String? id,
    String? clientId,
    String? categoryId,
    String? categoryNameEn,
    String? categoryNameAr,
    String? typeId,
    String? typeNameEn,
    String? typeNameAr,
    String? relatedEntityId,
    String? relatedEntityName,
    String? relatedEntityNameAr,
    String? relatedEntityType,
    String? relatedEntityRole,
    String? relatedEntityAvatar,
    String? relatedEntityPhone,
    String? relatedEntityEmail,
    DateTime? startDate,
    DateTime? endDate,
    String? noteEn,
    String? noteAr,
    String? status,
    CrmAuditModel? audit,
  }) {
    return CrmClientRelationshipModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      categoryId: categoryId ?? this.categoryId,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      typeId: typeId ?? this.typeId,
      typeNameEn: typeNameEn ?? this.typeNameEn,
      typeNameAr: typeNameAr ?? this.typeNameAr,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityName: relatedEntityName ?? this.relatedEntityName,
      relatedEntityNameAr: relatedEntityNameAr ?? this.relatedEntityNameAr,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityRole: relatedEntityRole ?? this.relatedEntityRole,
      relatedEntityAvatar: relatedEntityAvatar ?? this.relatedEntityAvatar,
      relatedEntityPhone: relatedEntityPhone ?? this.relatedEntityPhone,
      relatedEntityEmail: relatedEntityEmail ?? this.relatedEntityEmail,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      noteEn: noteEn ?? this.noteEn,
      noteAr: noteAr ?? this.noteAr,
      status: status ?? this.status,
      audit: audit ?? this.audit,
    );
  }
}
