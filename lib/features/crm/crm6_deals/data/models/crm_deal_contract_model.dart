// ****************** FILE INFO ******************
// File Name: crm_deal_contract_model.dart
// Purpose: Data model for Deals Contracts with versioning, employee, dates, and file details
// Author: Mohand Adel
// Created At: 29/08/2026
// ignore_for_file: constant_identifier_names

class CrmDealContractModel {
  final String id;
  final String dealId;
  final String title;
  final String fileName;
  final String fileUrl;
  final int sizeBytes;
  final String extension;
  final String version; // e.g. 'v1.0', 'v2.0', 'Draft'
  final String uploadedByEmployee; // e.g. 'Aya Ahmed', 'Amro Handousa'
  final DateTime uploadedAt;
  final String storagePath;
  final bool isDeleted;

  static const String ID = 'id';
  static const String DEAL_ID = 'dealId';
  static const String TITLE = 'title';
  static const String FILE_NAME = 'fileName';
  static const String FILE_URL = 'fileUrl';
  static const String SIZE_BYTES = 'sizeBytes';
  static const String EXTENSION = 'extension';
  static const String VERSION = 'version';
  static const String UPLOADED_BY_EMPLOYEE = 'uploadedByEmployee';
  static const String UPLOADED_AT = 'uploadedAt';
  static const String STORAGE_PATH = 'storagePath';
  static const String IS_DELETED = 'isDeleted';

  const CrmDealContractModel({
    required this.id,
    required this.dealId,
    required this.title,
    required this.fileName,
    required this.fileUrl,
    required this.sizeBytes,
    required this.extension,
    required this.version,
    required this.uploadedByEmployee,
    required this.uploadedAt,
    required this.storagePath,
    this.isDeleted = false,
  });

  bool get isPdf {
    final String ext = extension.toLowerCase().replaceAll('.', '');
    return ext == 'pdf';
  }

  String get formattedSize {
    if (sizeBytes <= 0) return '0 KB';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      final double kb = sizeBytes / 1024;
      return '${kb.toStringAsFixed(0)} KB';
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ID: id,
      DEAL_ID: dealId,
      TITLE: title,
      FILE_NAME: fileName,
      FILE_URL: fileUrl,
      SIZE_BYTES: sizeBytes,
      EXTENSION: extension,
      VERSION: version,
      UPLOADED_BY_EMPLOYEE: uploadedByEmployee,
      UPLOADED_AT: uploadedAt.toIso8601String(),
      STORAGE_PATH: storagePath,
      IS_DELETED: isDeleted,
    };
  }

  factory CrmDealContractModel.fromMap(
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

    return CrmDealContractModel(
      id: id ?? map[ID] as String? ?? '',
      dealId: map[DEAL_ID] as String? ?? '',
      title: map[TITLE] as String? ?? 'Contract',
      fileName: map[FILE_NAME] as String? ?? 'Contract.pdf',
      fileUrl: map[FILE_URL] as String? ?? '',
      sizeBytes: (map[SIZE_BYTES] as num?)?.toInt() ?? 0,
      extension: map[EXTENSION] as String? ?? 'pdf',
      version: map[VERSION] as String? ?? 'v1.0',
      uploadedByEmployee: map[UPLOADED_BY_EMPLOYEE] as String? ?? 'Aya Ahmed',
      uploadedAt: parsedDate,
      storagePath: map[STORAGE_PATH] as String? ?? '',
      isDeleted: map[IS_DELETED] as bool? ?? false,
    );
  }

  CrmDealContractModel copyWith({
    String? id,
    String? dealId,
    String? title,
    String? fileName,
    String? fileUrl,
    int? sizeBytes,
    String? extension,
    String? version,
    String? uploadedByEmployee,
    DateTime? uploadedAt,
    String? storagePath,
    bool? isDeleted,
  }) {
    return CrmDealContractModel(
      id: id ?? this.id,
      dealId: dealId ?? this.dealId,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      extension: extension ?? this.extension,
      version: version ?? this.version,
      uploadedByEmployee: uploadedByEmployee ?? this.uploadedByEmployee,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      storagePath: storagePath ?? this.storagePath,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
