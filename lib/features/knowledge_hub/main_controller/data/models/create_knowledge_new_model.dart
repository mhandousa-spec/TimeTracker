/// Module: knowledge_hub / core/data/models/create_knowledge_new_model.dart
import 'dart:developer';
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_new_model.dart
/// Purpose: Contains the model class to create new knowledge.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
/// Updated: Added startTime and endTime fields

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateKnowledgeModel {
  // ✅ The actual Firestore document ID
  final String? firestoreDocumentId;

  // ✅ SHARED timestamps for ALL fields
  final List<int> timestamps;

  // Core fields - Direct lists!
  final List<String> knowledgeId;
  final List<String>? knowledgeImage;
  final List<String> nameEnglish;
  final List<String> nameArabic;
  final List<String> descriptionEnglish;
  final List<String> descriptionArabic;
  final List<String> knowledgeDocumentType;
  final List<String> owningDepartment;
  final List<String> limitedDepartments; // JSON encoded list
  final List<bool> schedulePublishing;
  final List<Timestamp> startDateTime;
  final List<Timestamp> endDateTime;
  final List<String> startTime; // ✅ NEW: Store time as "HH:mm" format
  final List<String> endTime;   // ✅ NEW: Store time as "HH:mm" format
  final List<String>? imageUrl;
  final List<String> documentUrl;
  final List<String> documentFileName;
  final List<String> documentExtension;
  final List<int> documentSize;
  final List<String> createdByEmail;
  final List<String> timeStamp;
  final List<String> status;

  /// Why the matching entry in [status] happened, in the author's words.
  ///
  /// ADDED 22/9/2026. A reason had nowhere to live, so
  /// `removeKnowledgeWithReason` appended the removal justification to
  /// [descriptionEnglish] and [descriptionArabic] — and because
  /// `currentDescriptionEnglish` reads `.last`, removing a document REPLACED
  /// its description with the reason it was removed. The document's own
  /// description was lost from every screen that shows it.
  ///
  /// This array is parallel to [status]: one entry per status change, `''`
  /// where a change carried no reason. Old documents have no `statusReason`
  /// key at all, which parses to an empty list — hence [reasonForStatusAt],
  /// which is index-safe rather than assuming the two arrays line up.
  final List<String> statusReason;

  CreateKnowledgeModel({
    this.firestoreDocumentId,
    required this.timestamps,
    required this.knowledgeId,
    this.knowledgeImage,
    required this.nameEnglish,
    required this.nameArabic,
    required this.descriptionEnglish,
    required this.descriptionArabic,
    required this.knowledgeDocumentType,
    required this.owningDepartment,
    required this.limitedDepartments,
    required this.schedulePublishing,
    required this.startDateTime,
    required this.endDateTime,
    required this.startTime, // ✅ NEW
    required this.endTime,   // ✅ NEW
    this.imageUrl,
    required this.documentUrl,
    required this.documentFileName,
    required this.timeStamp,
    required this.documentExtension,
    required this.documentSize,
    required this.status,
    required this.createdByEmail,
    this.statusReason = const [],
  });

  // ✅ Helper getters for current (latest) values
  String get currentKnowledgeId => knowledgeId.isNotEmpty ? knowledgeId.last : '';

  /// The reason given for the CURRENT status, or `''` when there was none
  /// (including every document written before `statusReason` existed).
  String get currentStatusReason => reasonForStatusAt(status.length - 1);

  /// The reason recorded alongside the status at [index].
  ///
  /// Index-safe on purpose: [statusReason] is shorter than [status] on any
  /// document that predates it, and on any status change that carried no
  /// reason, so a plain `statusReason[index]` would throw on exactly the
  /// documents most likely to be opened.
  String reasonForStatusAt(int index) {
    if (index < 0 || index >= statusReason.length) return '';
    return statusReason[index];
  }
  String get currentKnowledgeImage => knowledgeImage != null && knowledgeImage!.isNotEmpty ? knowledgeImage!.last : '';
  String get currentNameEnglish => nameEnglish.isNotEmpty ? nameEnglish.last : '';
  String get currentNameArabic => nameArabic.isNotEmpty ? nameArabic.last : '';
  String get currentDescriptionEnglish => descriptionEnglish.isNotEmpty ? descriptionEnglish.last : '';
  String get currentDescriptionArabic => descriptionArabic.isNotEmpty ? descriptionArabic.last : '';
  String get currentKnowledgeDocumentType => knowledgeDocumentType.isNotEmpty ? knowledgeDocumentType.last : '';
  String get currentOwningDepartment => owningDepartment.isNotEmpty ? owningDepartment.last : '';
  String get currentLimitedDepartments => limitedDepartments.isNotEmpty ? limitedDepartments.last : '[]';
  bool get currentSchedulePublishing => schedulePublishing.isNotEmpty ? schedulePublishing.last : false;
  Timestamp? get currentStartDateTime => startDateTime.isNotEmpty ? startDateTime.last : null;
  Timestamp? get currentEndDateTime => endDateTime.isNotEmpty ? endDateTime.last : null;
  String get currentStartTime => startTime.isNotEmpty ? startTime.last : ''; // ✅ NEW
  String get currentEndTime => endTime.isNotEmpty ? endTime.last : '';       // ✅ NEW
  String get currentImageUrl => imageUrl != null && imageUrl!.isNotEmpty ? imageUrl!.last : '';
  String get currentDocumentUrl => documentUrl.isNotEmpty ? documentUrl.last : '';
  String get currentDocumentFileName => documentFileName.isNotEmpty ? documentFileName.last : '';
  String get currentTimeStamp => timeStamp.isNotEmpty ? timeStamp.last : '';
  String get currentDocumentExtension => documentExtension.isNotEmpty ? documentExtension.last : '';
  int get currentDocumentSize => documentSize.isNotEmpty ? documentSize.last : 0;
  String get currentStatus => status.isNotEmpty ? status.last : '';
  String get currentCreatedByEmail => createdByEmail.isNotEmpty ? createdByEmail.last : '';

  // ✅ Get timestamp at specific index
  int? getTimestampAt(int index) => index < timestamps.length ? timestamps[index] : null;

  // ✅ Get current (latest) timestamp
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  /// ADDED 28/8/2026 — the document's PUBLISH date, or null if it was never
  /// published.
  ///
  /// [status] and [timestamps] are parallel histories: entry i of one describes
  /// the same edit as entry i of the other. The publish date is therefore the
  /// timestamp sitting at the FIRST index whose status is `published` — first,
  /// not last, because a document that is republished after an edit keeps the
  /// date it originally went live.
  ///
  /// This is the same walk view_knowledge_hub already does inline to render the
  /// date on each card; it lives here so the card, the details page and the
  /// publish-date filter cannot drift into three different answers.
  DateTime? get publishedAt {
    for (int i = 0; i < status.length; i++) {
      if (status[i].trim().toLowerCase() == 'published') {
        if (i < timestamps.length) {
          return DateTime.fromMillisecondsSinceEpoch(timestamps[i]);
        }
        return null;
      }
    }
    return null;
  }

  // Helper to get decoded limited departments list
  List<String> get currentLimitedDepartmentsList {
    try {
      final jsonStr = limitedDepartments.isNotEmpty ? limitedDepartments.last : '[]';
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      log('❌ ERROR in currentLimitedDepartmentsList: $e');
      return [];
    }
  }

  // ✅ NEW: Helper to format time for display (e.g., "14:30" -> "02:30 PM")
  String formatTimeForDisplay(String time24) {
    if (time24.isEmpty) return '';
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  // Factory: Create from JSON
  factory CreateKnowledgeModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    try {
      // ✅ Parse shared timestamps first
      final List<int> sharedTimestamps = (json['timestamps'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [DateTime.now().millisecondsSinceEpoch];

      return CreateKnowledgeModel(
        firestoreDocumentId: docId,
        timestamps: sharedTimestamps,
        knowledgeId: _parseList<String>(json['knowledgeId'], (v) => v as String? ?? ''),
        knowledgeImage: _parseList<String>(json['knowledgeImage'], (v) => v as String? ?? ''),
        nameEnglish: _parseList<String>(json['nameEnglish'], (v) => v as String? ?? ''),
        nameArabic: _parseList<String>(json['nameArabic'], (v) => v as String? ?? ''),
        descriptionEnglish: _parseList<String>(json['descriptionEnglish'], (v) => v as String? ?? ''),
        descriptionArabic: _parseList<String>(json['descriptionArabic'], (v) => v as String? ?? ''),
        knowledgeDocumentType: _parseList<String>(json['knowledgeDocumentType'], (v) => v as String? ?? ''),
        owningDepartment: _parseList<String>(json['owningDepartment'], (v) => v as String? ?? ''),
        limitedDepartments: _parseList<String>(json['limitedDepartments'], (v) => _parseJsonArray(v)),
        schedulePublishing: _parseList<bool>(json['schedulePublishing'], (v) => v as bool? ?? false),
        startDateTime: _parseList<Timestamp>(json['startDateTime'], (v) => _parseTimestamp(v)),
        endDateTime: _parseList<Timestamp>(json['endDateTime'], (v) => _parseTimestamp(v)),
        startTime: _parseList<String>(json['startTime'], (v) => v as String? ?? ''), // ✅ NEW
        endTime: _parseList<String>(json['endTime'], (v) => v as String? ?? ''),     // ✅ NEW
        imageUrl: _parseList<String>(json['imageUrl'], (v) => v as String? ?? ''),
        documentUrl: _parseList<String>(json['documentUrl'], (v) => v as String? ?? ''),
        documentFileName: _parseList<String>(json['documentFileName'], (v) => v as String? ?? ''),
        timeStamp: _parseList<String>(json['timeStamp'], (v) => v as String? ?? ''),
        documentExtension: _parseList<String>(json['documentExtension'], (v) => v as String? ?? ''),
        documentSize: _parseList<int>(json['documentSize'], (v) => v as int? ?? 0),
        status: _parseList<String>(json['status'], (v) => v as String? ?? ''),
        createdByEmail: _parseList<String>(json['createdByEmail'], (v) => v as String? ?? ''),
        statusReason: _parseList<String>(json['statusReason'], (v) => v as String? ?? ''),
      );
    } catch (e, stack) {
      log("❌ Error parsing CreateKnowledgeModel from doc '${docId ?? 'unknown'}': $e");
      log("📄 JSON: $json");
      log("🧱 Stacktrace:\n$stack");
      rethrow;
    }
  }

  // Helper: Parse list (handles multiple legacy formats)
  static List<T> _parseList<T>(dynamic value, T Function(dynamic) deserializer) {
    if (value == null) return [];

    if (value is List) {
      try {
        return value.map((e) => deserializer(e)).toList();
      } catch (e) {
        log('❌ Error parsing list: $e');
        return [];
      }
    }

    // Legacy format with FieldHistory: {timestamps: [...], values: [...]}
    if (value is Map<String, dynamic> && value.containsKey('values')) {
      final values = value['values'];
      if (values is List) {
        return values.map((e) => deserializer(e)).toList();
      }
    }

    // Legacy format: {value: ..., timestamp: ...}
    if (value is Map<String, dynamic> && value.containsKey('value')) {
      return [deserializer(value['value'])];
    }

    // Single value - wrap in list
    return [deserializer(value)];
  }

  // Helper: Convert arrays to JSON string
  static String _parseJsonArray(dynamic value) {
    if (value == null) return '[]';
    if (value is String) return value;
    if (value is List) return jsonEncode(value);
    return '[]';
  }

  // Helper: Parse Timestamp
  static Timestamp _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    if (value is int) return Timestamp.fromMillisecondsSinceEpoch(value);
    if (value is String) return Timestamp.fromDate(DateTime.parse(value));
    if (value is DateTime) return Timestamp.fromDate(value);
    return Timestamp.now();
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamps': timestamps,
      'knowledgeId': knowledgeId,
      'knowledgeImage': knowledgeImage,
      'nameEnglish': nameEnglish,
      'nameArabic': nameArabic,
      'descriptionEnglish': descriptionEnglish,
      'descriptionArabic': descriptionArabic,
      'knowledgeDocumentType': knowledgeDocumentType,
      'owningDepartment': owningDepartment,
      'limitedDepartments': limitedDepartments,
      'schedulePublishing': schedulePublishing,
      'startDateTime': startDateTime.map((v) => v.millisecondsSinceEpoch).toList(),
      'endDateTime': endDateTime.map((v) => v.millisecondsSinceEpoch).toList(),
      'startTime': startTime, // ✅ NEW
      'endTime': endTime,     // ✅ NEW
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'documentFileName': documentFileName,
      'timeStamp': timeStamp,
      'documentExtension': documentExtension,
      'documentSize': documentSize,
      'createdByEmail': createdByEmail,
      'status': status,
      'statusReason': statusReason,
    };
  }

  // Factory: Create with initial values
  factory CreateKnowledgeModel.createNew({
    String? firestoreDocumentId,
    required String knowledgeId,
    String? knowledgeImage,
    required String nameEnglish,
    required String nameArabic,
    required String descriptionEnglish,
    required String descriptionArabic,
    required String knowledgeDocumentType,
    required String owningDepartment,
    List<String>? limitedDepartments,
    bool? schedulePublishing,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? startTime, // ✅ NEW: Format "HH:mm" (24-hour)
    String? endTime,   // ✅ NEW: Format "HH:mm" (24-hour)
    String? imageUrl,
    required String documentUrl,
    required String documentFileName,
    required String documentExtension,
    required int documentSize,
    required String createdByEmail,
    required String timeStamp,
    required String status,
    String statusReason = '',
  }) {
    List<Timestamp> startDateTimeList = [];
    List<Timestamp> endDateTimeList = [];

    if (startDateTime != null) {
      startDateTimeList.add(Timestamp.fromDate(startDateTime));
    }
    if (endDateTime != null) {
      endDateTimeList.add(Timestamp.fromDate(endDateTime));
    }

    return CreateKnowledgeModel(
      firestoreDocumentId: firestoreDocumentId,
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      knowledgeId: [knowledgeId],
      knowledgeImage: [knowledgeImage ?? ''],
      nameEnglish: [nameEnglish],
      nameArabic: [nameArabic],
      descriptionEnglish: [descriptionEnglish],
      descriptionArabic: [descriptionArabic],
      knowledgeDocumentType: [knowledgeDocumentType],
      owningDepartment: [owningDepartment],
      limitedDepartments: [jsonEncode(limitedDepartments ?? [])],
      schedulePublishing: [schedulePublishing ?? false],
      startDateTime: startDateTimeList,
      endDateTime: endDateTimeList,
      startTime: [startTime ?? ''], // ✅ NEW
      endTime: [endTime ?? ''],     // ✅ NEW
      imageUrl: [imageUrl ?? ''],
      documentUrl: [documentUrl],
      documentFileName: [documentFileName],
      timeStamp: [timeStamp],
      documentExtension: [documentExtension],
      documentSize: [documentSize],
      createdByEmail: [createdByEmail],
      status: [status],
      statusReason: [statusReason],
    );
  }

  // copyWith method - adds new timestamp and new values
  CreateKnowledgeModel copyWith({
    String? firestoreDocumentId,
    String? knowledgeId,
    String? knowledgeImage,
    String? nameEnglish,
    String? nameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? knowledgeDocumentType,
    String? owningDepartment,
    List<String>? limitedDepartments,
    bool? schedulePublishing,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? startTime, // ✅ NEW
    String? endTime,   // ✅ NEW
    String? imageUrl,
    String? documentUrl,
    String? documentFileName,
    String? documentExtension,
    int? documentSize,
    String? createdByEmail,
    String? timeStamp,
    String? status,
    String? statusReason,
  }) {
    final newTimestamps = List<int>.from(timestamps)..add(DateTime.now().millisecondsSinceEpoch);

    List<Timestamp> newStartDateTime = List<Timestamp>.from(this.startDateTime);
    List<Timestamp> newEndDateTime = List<Timestamp>.from(this.endDateTime);

    if (startDateTime != null) {
      newStartDateTime = [Timestamp.fromDate(startDateTime)];
    }
    if (endDateTime != null) {
      newEndDateTime = [Timestamp.fromDate(endDateTime)];
    }

    return CreateKnowledgeModel(
      firestoreDocumentId: firestoreDocumentId ?? this.firestoreDocumentId,
      timestamps: newTimestamps,
      knowledgeId: knowledgeId != null ? [knowledgeId] : this.knowledgeId,
      knowledgeImage: knowledgeImage != null ? [knowledgeImage] : this.knowledgeImage,
      nameEnglish: nameEnglish != null ? [nameEnglish] : this.nameEnglish,
      nameArabic: nameArabic != null ? [nameArabic] : this.nameArabic,
      descriptionEnglish: descriptionEnglish != null ? [descriptionEnglish] : this.descriptionEnglish,
      descriptionArabic: descriptionArabic != null ? [descriptionArabic] : this.descriptionArabic,
      knowledgeDocumentType: knowledgeDocumentType != null ? [knowledgeDocumentType] : this.knowledgeDocumentType,
      owningDepartment: owningDepartment != null ? [owningDepartment] : this.owningDepartment,
      limitedDepartments: limitedDepartments != null ? limitedDepartments : this.limitedDepartments,
      schedulePublishing: schedulePublishing != null ? [schedulePublishing] : this.schedulePublishing,
      startDateTime: newStartDateTime,
      endDateTime: newEndDateTime,
      startTime: startTime != null ? [startTime] : this.startTime, // ✅ NEW
      endTime: endTime != null ? [endTime] : this.endTime,         // ✅ NEW
      imageUrl: imageUrl != null ? [imageUrl] : this.imageUrl,
      documentUrl: documentUrl != null ? [documentUrl] : this.documentUrl,
      documentFileName: documentFileName != null ? [documentFileName] : this.documentFileName,
      timeStamp: timeStamp != null ? [timeStamp] : this.timeStamp,
      documentExtension: documentExtension != null ? [documentExtension] : this.documentExtension,
      documentSize: documentSize != null ? [documentSize] : this.documentSize,
      createdByEmail: createdByEmail != null ? [createdByEmail] : this.createdByEmail,
      status: status != null ? [status] : this.status,
      statusReason: statusReason != null ? [statusReason] : this.statusReason,
    );
  }

  // Update methods - add new values to lists
  void updateKnowledgeName(String englishName, String arabicName) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    nameEnglish.add(englishName);
    nameArabic.add(arabicName);
  }

  void updateKnowledgeDescription(String englishDesc, String arabicDesc) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    descriptionEnglish.add(englishDesc);
    descriptionArabic.add(arabicDesc);
  }

  void updateLimitedDepartments(List<String> departments) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    limitedDepartments.add(jsonEncode(departments));
  }

  // ✅ UPDATED: Now includes time parameters
  void updateSchedulePublishing(
      bool schedule,
      DateTime? start,
      DateTime? end, {
        String? startTimeStr, // ✅ NEW: Format "HH:mm"
        String? endTimeStr,   // ✅ NEW: Format "HH:mm"
      }) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    schedulePublishing.add(schedule);
    if (start != null) startDateTime.add(Timestamp.fromDate(start));
    if (end != null) endDateTime.add(Timestamp.fromDate(end));
    if (startTimeStr != null) startTime.add(startTimeStr); // ✅ NEW
    if (endTimeStr != null) endTime.add(endTimeStr);       // ✅ NEW
  }

  void updateDocumentInfo({
    String? url,
    String? fileName,
    String? icon,
    String? extension,
    int? size,
    DateTime? uploadedDate,
  }) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    if (url != null) documentUrl.add(url);
    if (fileName != null) documentFileName.add(fileName);
    if (extension != null) documentExtension.add(extension);
    if (size != null) documentSize.add(size);
  }
}