/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_model.dart
/// Purpose: A notification as rendered in the inbox.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationTemplateModel {
  final String id;
  final String module; // 'services', 'qiyas', 'inventory', etc.
  final String eventType; // 'request_submitted', 'request_approved', etc.
  final bool isEnabled;
  final List<String> selectedNotificationTypes; // ["email", "push"] - stores which types are selected
  final String subjectEnglish;
  final String subjectArabic;
  final String bodyEnglish;
  final String bodyArabic;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationTemplateModel({
    required this.id,
    required this.module,
    required this.eventType,
    required this.isEnabled,
    required this.selectedNotificationTypes,
    required this.subjectEnglish,
    required this.subjectArabic,
    required this.bodyEnglish,
    required this.bodyArabic,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods to check notification types
  bool get hasEmail => selectedNotificationTypes.contains('email');
  bool get hasPush => selectedNotificationTypes.contains('push');

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'module': module,
      'eventType': eventType,
      'isEnabled': isEnabled,
      'selectedNotificationTypes': selectedNotificationTypes,
      'subjectEnglish': subjectEnglish,
      'subjectArabic': subjectArabic,
      'bodyEnglish': bodyEnglish,
      'bodyArabic': bodyArabic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore
  factory NotificationTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationTemplateModel(
      id: data['id'] ?? doc.id,
      module: data['module'] ?? '',
      eventType: data['eventType'] ?? '',
      isEnabled: data['isEnabled'] ?? true,
      selectedNotificationTypes: List<String>.from(data['selectedNotificationTypes'] ?? []),
      subjectEnglish: data['subjectEnglish'] ?? '',
      subjectArabic: data['subjectArabic'] ?? '',
      bodyEnglish: data['bodyEnglish'] ?? '',
      bodyArabic: data['bodyArabic'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create default template
  factory NotificationTemplateModel.createDefault({
    required String module,
    required String eventType,
    List<String>? selectedNotificationTypes,
  }) {
    return NotificationTemplateModel(
      id: '${module}_$eventType',
      module: module,
      eventType: eventType,
      isEnabled: true,
      selectedNotificationTypes: selectedNotificationTypes ?? [],
      subjectEnglish: '',
      subjectArabic: '',
      bodyEnglish: '',
      bodyArabic: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  NotificationTemplateModel copyWith({
    String? id,
    String? module,
    String? eventType,
    bool? isEnabled,
    List<String>? selectedNotificationTypes,
    String? subjectEnglish,
    String? subjectArabic,
    String? bodyEnglish,
    String? bodyArabic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationTemplateModel(
      id: id ?? this.id,
      module: module ?? this.module,
      eventType: eventType ?? this.eventType,
      isEnabled: isEnabled ?? this.isEnabled,
      selectedNotificationTypes: selectedNotificationTypes ?? this.selectedNotificationTypes,
      subjectEnglish: subjectEnglish ?? this.subjectEnglish,
      subjectArabic: subjectArabic ?? this.subjectArabic,
      bodyEnglish: bodyEnglish ?? this.bodyEnglish,
      bodyArabic: bodyArabic ?? this.bodyArabic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}