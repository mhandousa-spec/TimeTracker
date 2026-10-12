// ****************** FILE INFO ******************
// File Name: crm_deal_timeline_item_model.dart
// Purpose: Data model for Deals Timeline events (Activities, Stage changes, Meetings, Calls, Quotes)
// Author: Mohand Adel
// Created At: 29/08/2026
// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

class CrmDealTimelineItemModel {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime date;
  final String time;
  final String
      activityType; // 'Call', 'Meeting', 'Task', 'Email', 'Follow Up', 'Stage', 'Quote'
  final String? assignedUserName;
  final String? assignedUserAvatar;
  final String? tag;
  final String? itemNumber;
  final String? duration;
  final String? dealId;
  final Map<String, dynamic>? metadata;

  static const String ID = 'id';
  static const String TITLE = 'title';
  static const String SUBTITLE = 'subtitle';
  static const String DATE = 'date';
  static const String TIME = 'time';
  static const String ACTIVITY_TYPE = 'activityType';
  static const String ASSIGNED_USER_NAME = 'assignedUserName';
  static const String ASSIGNED_USER_AVATAR = 'assignedUserAvatar';
  static const String TAG = 'tag';
  static const String ITEM_NUMBER = 'itemNumber';
  static const String DURATION = 'duration';
  static const String DEAL_ID = 'dealId';
  static const String METADATA = 'metadata';

  const CrmDealTimelineItemModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.date,
    required this.time,
    required this.activityType,
    this.assignedUserName,
    this.assignedUserAvatar,
    this.tag,
    this.itemNumber,
    this.duration,
    this.dealId,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ID: id,
      TITLE: title,
      SUBTITLE: subtitle,
      DATE: date.toIso8601String(),
      TIME: time,
      ACTIVITY_TYPE: activityType,
      ASSIGNED_USER_NAME: assignedUserName,
      ASSIGNED_USER_AVATAR: assignedUserAvatar,
      TAG: tag,
      ITEM_NUMBER: itemNumber,
      DURATION: duration,
      DEAL_ID: dealId,
      METADATA: metadata,
    };
  }

  factory CrmDealTimelineItemModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    DateTime parsedDate;
    final dynamic rawDate = map[DATE];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return CrmDealTimelineItemModel(
      id: id ?? map[ID] as String? ?? '',
      title: map[TITLE] as String? ?? 'Activity',
      subtitle: map[SUBTITLE] as String?,
      date: parsedDate,
      time: map[TIME] as String? ?? DateFormat('hh:mma').format(parsedDate),
      activityType: map[ACTIVITY_TYPE] as String? ?? 'Activity',
      assignedUserName: map[ASSIGNED_USER_NAME] as String?,
      assignedUserAvatar: map[ASSIGNED_USER_AVATAR] as String?,
      tag: map[TAG] as String?,
      itemNumber: map[ITEM_NUMBER] as String?,
      duration: map[DURATION] as String?,
      dealId: map[DEAL_ID] as String?,
      metadata: map[METADATA] as Map<String, dynamic>?,
    );
  }

  CrmDealTimelineItemModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? date,
    String? time,
    String? activityType,
    String? assignedUserName,
    String? assignedUserAvatar,
    String? tag,
    String? itemNumber,
    String? duration,
    String? dealId,
    Map<String, dynamic>? metadata,
  }) {
    return CrmDealTimelineItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      date: date ?? this.date,
      time: time ?? this.time,
      activityType: activityType ?? this.activityType,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      assignedUserAvatar: assignedUserAvatar ?? this.assignedUserAvatar,
      tag: tag ?? this.tag,
      itemNumber: itemNumber ?? this.itemNumber,
      duration: duration ?? this.duration,
      dealId: dealId ?? this.dealId,
      metadata: metadata ?? this.metadata,
    );
  }
}
