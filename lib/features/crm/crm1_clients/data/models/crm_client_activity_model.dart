// ****************** FILE INFO ******************
// File Name: crm_client_activity_model.dart
// Purpose: Persistent client activity record.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';

class CrmClientActivityModel {
  final String id;
  final String clientId;
  final String categoryId;
  final String categoryName;
  final String typeId;
  final String typeName;
  final String subjectEn;
  final String subjectAr;
  final String assigneeId;
  final String assigneeName;
  final String? assigneeRole;
  final List<String> tagIds;
  final List<String> tagNames;
  final String? dealLabel;
  final String noteEn;
  final String noteAr;
  final DateTime dueAt;
  final DateTime? completedAt;
  final String status;
  final bool isDeleted;
  final CrmAuditModel? audit;

  const CrmClientActivityModel({
    required this.id,
    required this.clientId,
    required this.categoryId,
    required this.categoryName,
    required this.typeId,
    required this.typeName,
    required this.subjectEn,
    required this.subjectAr,
    required this.assigneeId,
    required this.assigneeName,
    required this.tagIds,
    required this.tagNames,
    required this.noteEn,
    required this.noteAr,
    required this.dueAt,
    required this.status,
    this.assigneeRole,
    this.dealLabel,
    this.completedAt,
    this.isDeleted = false,
    this.audit,
  });

  bool get isDraft => status == 'draft';
  bool get isDeletedRecord => isDeleted || status == 'deleted';

  factory CrmClientActivityModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }

    final dynamic rawAudit = map['Audit'];
    return CrmClientActivityModel(
      id: (map['Id'] ?? '').toString(),
      clientId: (map['Client_Id'] ?? '').toString(),
      categoryId: (map['Category_Id'] ?? '').toString(),
      categoryName: (map['Category_Name'] ?? '').toString(),
      typeId: (map['Type_Id'] ?? '').toString(),
      typeName: (map['Type_Name'] ?? '').toString(),
      subjectEn: (map['Subject_En'] ?? '').toString(),
      subjectAr: (map['Subject_Ar'] ?? '').toString(),
      assigneeId: (map['Assignee_Id'] ?? '').toString(),
      assigneeName: (map['Assignee_Name'] ?? '').toString(),
      assigneeRole: map['Assignee_Role']?.toString(),
      tagIds: List<String>.from(map['Tag_Ids'] as List? ?? const []),
      tagNames: List<String>.from(map['Tag_Names'] as List? ?? const []),
      dealLabel: map['Deal_Label']?.toString(),
      noteEn: (map['Note_En'] ?? '').toString(),
      noteAr: (map['Note_Ar'] ?? '').toString(),
      dueAt: parseDate(map['Due_At']),
      completedAt:
          map['Completed_At'] == null ? null : parseDate(map['Completed_At']),
      status: (map['Status'] ?? 'scheduled').toString(),
      isDeleted: map['Is_Deleted'] as bool? ?? false,
      audit: rawAudit is Map<String, dynamic>
          ? CrmAuditModel.fromMap(rawAudit)
          : null,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'Id': id,
        'Client_Id': clientId,
        'Category_Id': categoryId,
        'Category_Name': categoryName,
        'Type_Id': typeId,
        'Type_Name': typeName,
        'Subject_En': subjectEn,
        'Subject_Ar': subjectAr,
        'Assignee_Id': assigneeId,
        'Assignee_Name': assigneeName,
        if (assigneeRole != null) 'Assignee_Role': assigneeRole,
        'Tag_Ids': tagIds,
        'Tag_Names': tagNames,
        if (dealLabel != null) 'Deal_Label': dealLabel,
        'Note_En': noteEn,
        'Note_Ar': noteAr,
        'Due_At': Timestamp.fromDate(dueAt),
        if (completedAt != null)
          'Completed_At': Timestamp.fromDate(completedAt!),
        'Status': status,
        'Is_Deleted': isDeleted,
        if (audit != null) 'Audit': audit!.toMap(),
      };

  CrmClientActivityModel copyWith(
          {String? id,
          String? clientId,
          String? categoryId,
          String? categoryName,
          String? typeId,
          String? typeName,
          String? subjectEn,
          String? subjectAr,
          String? assigneeId,
          String? assigneeName,
          String? assigneeRole,
          List<String>? tagIds,
          List<String>? tagNames,
          String? dealLabel,
          String? noteEn,
          String? noteAr,
          DateTime? dueAt,
          DateTime? completedAt,
          String? status,
          bool? isDeleted,
          CrmAuditModel? audit}) =>
      CrmClientActivityModel(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        typeId: typeId ?? this.typeId,
        typeName: typeName ?? this.typeName,
        subjectEn: subjectEn ?? this.subjectEn,
        subjectAr: subjectAr ?? this.subjectAr,
        assigneeId: assigneeId ?? this.assigneeId,
        assigneeName: assigneeName ?? this.assigneeName,
        assigneeRole: assigneeRole ?? this.assigneeRole,
        tagIds: tagIds ?? this.tagIds,
        tagNames: tagNames ?? this.tagNames,
        dealLabel: dealLabel ?? this.dealLabel,
        noteEn: noteEn ?? this.noteEn,
        noteAr: noteAr ?? this.noteAr,
        dueAt: dueAt ?? this.dueAt,
        completedAt: completedAt ?? this.completedAt,
        status: status ?? this.status,
        isDeleted: isDeleted ?? this.isDeleted,
        audit: audit ?? this.audit,
      );
}
