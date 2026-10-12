// ****************** FILE INFO ******************
// File Name: crm_client_document_model.dart
// Purpose: Persistent client document record model.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmClientDocumentModel {
  final String id;
  final String clientId;
  final String name;
  final String url;
  final int sizeBytes;
  final String extension;
  final String uploadedBy;
  final String uploadedByName;
  final DateTime uploadedAt;
  final String storagePath;
  final bool isDeleted;
  final CrmAuditModel? audit;

  const CrmClientDocumentModel({
    required this.id,
    required this.clientId,
    required this.name,
    required this.url,
    required this.sizeBytes,
    required this.extension,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.uploadedAt,
    required this.storagePath,
    this.isDeleted = false,
    this.audit,
  });

  bool get isPdf {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'pdf';
  }

  bool get isWord {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'doc' || ext == 'docx';
  }

  bool get isExcel {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'xls' || ext == 'xlsx' || ext == 'csv';
  }

  bool get isPowerPoint {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'ppt' || ext == 'pptx';
  }

  bool get isImage {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'png' ||
        ext == 'jpg' ||
        ext == 'jpeg' ||
        ext == 'svg' ||
        ext == 'webp';
  }

  String get formattedSize {
    if (sizeBytes <= 0) return '0 KB';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      final double kb = sizeBytes / 1024;
      return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    }
    final double mb = sizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedUploadDate {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final String day = uploadedAt.day.toString().padLeft(2, '0');
    final String month = months[uploadedAt.month - 1];
    final String year = uploadedAt.year.toString();
    return '$day $month $year';
  }

  factory CrmClientDocumentModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    }

    final String nameVal =
        (map[CrmFirestoreKeys.DOC_NAME_KEY] ?? map['name'] ?? '').toString();
    String extVal =
        (map[CrmFirestoreKeys.DOC_EXTENSION_KEY] ?? map['extension'] ?? '')
            .toString();
    if (extVal.isEmpty && nameVal.contains('.')) {
      extVal = nameVal.split('.').last;
    }

    return CrmClientDocumentModel(
      id: (map[CrmFirestoreKeys.ID_KEY] ?? map['id'] ?? '').toString(),
      clientId: (map['Client_Id'] ?? map['clientId'] ?? '').toString(),
      name: nameVal,
      url: (map[CrmFirestoreKeys.DOC_URL_KEY] ?? map['url'] ?? '').toString(),
      sizeBytes: (map[CrmFirestoreKeys.DOC_SIZE_KEY] ?? map['sizeBytes'] ?? 0)
              as int? ??
          0,
      extension: extVal,
      uploadedBy:
          (map[CrmFirestoreKeys.DOC_UPLOADED_BY_KEY] ?? map['uploadedBy'] ?? '')
              .toString(),
      uploadedByName: (map[CrmFirestoreKeys.DOC_UPLOADED_BY_NAME_KEY] ??
              map['uploadedByName'] ??
              '')
          .toString(),
      uploadedAt: parseDate(
          map[CrmFirestoreKeys.DOC_UPLOADED_AT_KEY] ?? map['uploadedAt']),
      storagePath: (map[CrmFirestoreKeys.DOC_STORAGE_PATH_KEY] ??
              map['storagePath'] ??
              '')
          .toString(),
      isDeleted: (map[CrmFirestoreKeys.IS_DELETED_KEY] ??
              map['isDeleted'] ??
              false) as bool? ??
          false,
      audit: map[CrmFirestoreKeys.AUDIT_KEY] is Map<String, dynamic>
          ? CrmAuditModel.fromMap(
              map[CrmFirestoreKeys.AUDIT_KEY] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CrmFirestoreKeys.ID_KEY: id,
      'Client_Id': clientId,
      CrmFirestoreKeys.DOC_NAME_KEY: name,
      CrmFirestoreKeys.DOC_URL_KEY: url,
      CrmFirestoreKeys.DOC_SIZE_KEY: sizeBytes,
      CrmFirestoreKeys.DOC_EXTENSION_KEY: extension,
      CrmFirestoreKeys.DOC_UPLOADED_BY_KEY: uploadedBy,
      CrmFirestoreKeys.DOC_UPLOADED_BY_NAME_KEY: uploadedByName,
      CrmFirestoreKeys.DOC_UPLOADED_AT_KEY: Timestamp.fromDate(uploadedAt),
      CrmFirestoreKeys.DOC_STORAGE_PATH_KEY: storagePath,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
    };
  }

  CrmClientDocumentModel copyWith({
    String? id,
    String? clientId,
    String? name,
    String? url,
    int? sizeBytes,
    String? extension,
    String? uploadedBy,
    String? uploadedByName,
    DateTime? uploadedAt,
    String? storagePath,
    bool? isDeleted,
    CrmAuditModel? audit,
  }) {
    return CrmClientDocumentModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      url: url ?? this.url,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      extension: extension ?? this.extension,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      storagePath: storagePath ?? this.storagePath,
      isDeleted: isDeleted ?? this.isDeleted,
      audit: audit ?? this.audit,
    );
  }

  factory CrmClientDocumentModel.getEmptyModel() {
    return CrmClientDocumentModel(
      id: '',
      clientId: '',
      name: '',
      url: '',
      sizeBytes: 0,
      extension: '',
      uploadedBy: '',
      uploadedByName: '',
      uploadedAt: DateTime.now(),
      storagePath: '',
      isDeleted: false,
    );
  }
}
