// ****************** FILE INFO ******************
// File Name: crm_deal_document_model.dart
// Purpose: Data model for documents and attachments associated with CRM Deals
// Author: Mohand Adel
// Created At: 29/08/2026
// ignore_for_file: constant_identifier_names

class CrmDealDocumentModel {
  final String id;
  final String dealId;
  final String name;
  final String url;
  final int sizeBytes;
  final String extension;
  final String uploadedBy; // 'Staff' or 'Client'
  final String uploadedByName;
  final DateTime uploadedAt;
  final String storagePath;
  final bool isDeleted;

  static const String ID = 'id';
  static const String DEAL_ID = 'dealId';
  static const String NAME = 'name';
  static const String URL = 'url';
  static const String SIZE_BYTES = 'sizeBytes';
  static const String EXTENSION = 'extension';
  static const String UPLOADED_BY = 'uploadedBy';
  static const String UPLOADED_BY_NAME = 'uploadedByName';
  static const String UPLOADED_AT = 'uploadedAt';
  static const String STORAGE_PATH = 'storagePath';
  static const String IS_DELETED = 'isDeleted';

  const CrmDealDocumentModel({
    required this.id,
    required this.dealId,
    required this.name,
    required this.url,
    required this.sizeBytes,
    required this.extension,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.uploadedAt,
    required this.storagePath,
    this.isDeleted = false,
  });

  bool get isPdf {
    final String ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'pdf';
  }

  bool get isWord {
    final String ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'doc' || ext == 'docx';
  }

  bool get isExcel {
    final String ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'xls' || ext == 'xlsx' || ext == 'csv';
  }

  bool get isPowerPoint {
    final String ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'ppt' || ext == 'pptx';
  }

  bool get isImage {
    final String ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'jpg' ||
        ext == 'jpeg' ||
        ext == 'png' ||
        ext == 'webp' ||
        ext == 'gif' ||
        ext == 'svg';
  }

  String get formattedSize {
    if (sizeBytes <= 0) return '0 B';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ID: id,
      DEAL_ID: dealId,
      NAME: name,
      URL: url,
      SIZE_BYTES: sizeBytes,
      EXTENSION: extension,
      UPLOADED_BY: uploadedBy,
      UPLOADED_BY_NAME: uploadedByName,
      UPLOADED_AT: uploadedAt.toIso8601String(),
      STORAGE_PATH: storagePath,
      IS_DELETED: isDeleted,
    };
  }

  factory CrmDealDocumentModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    DateTime parsedDate;
    final dynamic rawDate = map[UPLOADED_AT];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return CrmDealDocumentModel(
      id: id ?? map[ID] as String? ?? '',
      dealId: map[DEAL_ID] as String? ?? '',
      name: map[NAME] as String? ?? '',
      url: map[URL] as String? ?? '',
      sizeBytes: (map[SIZE_BYTES] as num?)?.toInt() ?? 0,
      extension: map[EXTENSION] as String? ?? 'pdf',
      uploadedBy: map[UPLOADED_BY] as String? ?? 'Staff',
      uploadedByName: map[UPLOADED_BY_NAME] as String? ?? 'Amro Handousa',
      uploadedAt: parsedDate,
      storagePath: map[STORAGE_PATH] as String? ?? '',
      isDeleted: map[IS_DELETED] as bool? ?? false,
    );
  }

  CrmDealDocumentModel copyWith({
    String? id,
    String? dealId,
    String? name,
    String? url,
    int? sizeBytes,
    String? extension,
    String? uploadedBy,
    String? uploadedByName,
    DateTime? uploadedAt,
    String? storagePath,
    bool? isDeleted,
  }) {
    return CrmDealDocumentModel(
      id: id ?? this.id,
      dealId: dealId ?? this.dealId,
      name: name ?? this.name,
      url: url ?? this.url,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      extension: extension ?? this.extension,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      storagePath: storagePath ?? this.storagePath,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
