/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_model_core.dart
/// Purpose: The shell-level notification model.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String titleEnglish;
  final String titleArabic;
  final String bodyEnglish;
  final String bodyArabic;
  final String type;
  final bool seen;
  final Timestamp timestamp;
  final String notificationId;
  final Map<String, dynamic> payLoad;

  NotificationModel({
    required this.notificationId,
    required this.titleEnglish,
    required this.titleArabic,
    required this.bodyEnglish,
    required this.bodyArabic,
    required this.type,
    required this.seen,
    required this.timestamp,
    required this.payLoad,
  });

  static const String titleEnglishKey = 'Title_English';
  static const String titleArabicKey = 'Title_Arabic';
  static const String bodyEnglishKey = 'Body_English';
  static const String bodyArabicKey = 'Body_Arabic';
  static const String typeKey = 'Type';
  static const String seenKey = 'Seen';
  static const String timestampKey = 'Timestamp';
  static const String payLoadKey = 'PayLoad';
  static const String notificationIdKey = 'Notification_Id';

  Map<String, dynamic> toMap() {
    return {
      notificationIdKey: notificationId,
      titleEnglishKey: titleEnglish,
      titleArabicKey: titleArabic,
      bodyEnglishKey: bodyEnglish,
      bodyArabicKey: bodyArabic,
      typeKey: type,
      seenKey: seen,
      timestampKey: timestamp,
      payLoadKey: payLoad,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map[notificationIdKey] ?? '',
      titleEnglish: map[titleEnglishKey] ?? '',
      titleArabic: map[titleArabicKey] ?? '',
      bodyEnglish: map[bodyEnglishKey] ?? '',
      bodyArabic: map[bodyArabicKey] ?? '',
      type: map[typeKey] ?? '',
      seen: map[seenKey] ?? false,
      timestamp: map[timestampKey] ?? Timestamp.now(),
      payLoad: Map<String, dynamic>.from(map[payLoadKey] ?? {}),
    );
  }
}
