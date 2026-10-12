// ****************** FILE INFO ******************
// File Name: crm_timeline_item_model.dart
// Purpose: Data model for CRM client timeline events (Status, Blacklist/Unblacklist, Activities, Relationships)
// Author: Mohand Adel
// Created At: 27/08/2026
// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';

class CrmTimelineItemModel {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime date;
  final String time;
  final String
      activityType; // 'Status', 'Blacklist', 'Unblacklist', 'Call', 'Meeting', 'Task', 'Email', 'Relationship'
  final String? assignedUserName;
  final String? assignedUserAvatar;
  final String? tag;
  final List<String> tags;
  final String? itemNumber;
  final String? duration;
  final CrmClientActivityModel? activityModel;
  final CrmClientRelationshipModel? relationshipModel;
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
  static const String TAGS = 'tags';
  static const String ITEM_NUMBER = 'itemNumber';
  static const String DURATION = 'duration';
  static const String METADATA = 'metadata';

  const CrmTimelineItemModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.date,
    required this.time,
    required this.activityType,
    this.assignedUserName,
    this.assignedUserAvatar,
    this.tag,
    this.tags = const <String>[],
    this.itemNumber,
    this.duration,
    this.activityModel,
    this.relationshipModel,
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
      TAGS: tags,
      ITEM_NUMBER: itemNumber,
      DURATION: duration,
      METADATA: metadata,
    };
  }

  factory CrmTimelineItemModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate;
    if (map[DATE] is String) {
      parsedDate = DateTime.tryParse(map[DATE] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final dynamic rawTags = map[TAGS];
    final List<String> parsedTags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList()
        : <String>[];

    return CrmTimelineItemModel(
      id: id ?? (map[ID] as String? ?? ''),
      title: map[TITLE] as String? ?? 'Activity',
      subtitle: map[SUBTITLE] as String?,
      date: parsedDate,
      time: map[TIME] as String? ?? '11:30am',
      activityType: map[ACTIVITY_TYPE] as String? ?? 'Contact',
      assignedUserName: map[ASSIGNED_USER_NAME] as String?,
      assignedUserAvatar: map[ASSIGNED_USER_AVATAR] as String?,
      tag: map[TAG] as String?,
      tags: parsedTags,
      itemNumber: map[ITEM_NUMBER] as String?,
      duration: map[DURATION] as String?,
      metadata: map[METADATA] as Map<String, dynamic>?,
    );
  }

  /// Constructs a timeline event from an Activity subcollection record
  factory CrmTimelineItemModel.fromActivity(
    CrmClientActivityModel activity, {
    int? index,
  }) {
    final DateTime eventDate = activity.dueAt;
    final String eventTime = DateFormat('hh:mma').format(eventDate);

    final String title = activity.subjectEn.isNotEmpty
        ? activity.subjectEn
        : (activity.subjectAr.isNotEmpty ? activity.subjectAr : 'Activity');

    final String? subtitle = activity.noteEn.isNotEmpty
        ? activity.noteEn
        : (activity.categoryName.isNotEmpty ? activity.categoryName : null);

    final String type =
        activity.typeName.isNotEmpty ? activity.typeName : 'Activity';

    final List<String> resolvedTags = <String>[];
    if (activity.tagNames.isNotEmpty) {
      resolvedTags.addAll(activity.tagNames);
    }
    if (activity.dealLabel != null && activity.dealLabel!.isNotEmpty) {
      if (!resolvedTags.contains(activity.dealLabel)) {
        resolvedTags.add(activity.dealLabel!);
      }
    }

    final String? primaryTag =
        resolvedTags.isNotEmpty ? resolvedTags.first : null;

    return CrmTimelineItemModel(
      id: 'activity_${activity.id}',
      title: title,
      subtitle: subtitle,
      date: eventDate,
      time: eventTime,
      activityType: type,
      assignedUserName: activity.assigneeName,
      tag: primaryTag,
      tags: resolvedTags,
      itemNumber: index?.toString(),
      activityModel: activity,
    );
  }

  /// Constructs a timeline event from a Relationship subcollection record
  factory CrmTimelineItemModel.fromRelationship(
    CrmClientRelationshipModel relationship,
  ) {
    final DateTime eventDate = relationship.startDate ??
        relationship.audit?.createdAt ??
        DateTime.now();
    final String eventTime = DateFormat('hh:mma').format(eventDate);

    final String name = relationship.relatedEntityName.isNotEmpty
        ? relationship.relatedEntityName
        : (relationship.relatedEntityNameAr ?? 'Contact');

    final String role = relationship.relatedEntityRole?.isNotEmpty == true
        ? relationship.relatedEntityRole!
        : (relationship.typeNameEn.isNotEmpty
            ? relationship.typeNameEn
            : relationship.categoryNameEn);

    return CrmTimelineItemModel(
      id: 'relationship_${relationship.id}',
      title: 'Add Relationship: $name',
      subtitle: 'Category: ${relationship.categoryNameEn} • Role: $role',
      date: eventDate,
      time: eventTime,
      activityType: 'Relationship',
      assignedUserName: name,
      assignedUserAvatar: relationship.relatedEntityAvatar,
      tag: null,
      tags: const <String>[],
      relationshipModel: relationship,
    );
  }

  /// Constructs status lifecycle events (Active, Inactive, Blacklist, Unblacklist) from client record
  static List<CrmTimelineItemModel> generateStatusEvents(
      CrmClientRecordModel record) {
    final List<CrmTimelineItemModel> events = <CrmTimelineItemModel>[];

    // 1. Initial Creation / Activation event
    final DateTime createdDate = record.audit.createdAt;
    events.add(
      CrmTimelineItemModel(
        id: 'status_created_${record.id}',
        title: 'Client Created',
        subtitle: 'Initial status: ${record.status.toUpperCase()}',
        date: createdDate,
        time: DateFormat('hh:mma').format(createdDate),
        activityType: 'Status',
        tag: null,
        tags: const <String>[],
        assignedUserName: record.audit.createdBy,
      ),
    );

    // 2. Inactive status event
    if (record.status.toLowerCase() == 'inactive') {
      final DateTime inactiveDate = record.audit.updatedAt;
      events.add(
        CrmTimelineItemModel(
          id: 'status_inactive_${record.id}',
          title: 'Client Deactivated',
          subtitle: 'Status changed to INACTIVE',
          date: inactiveDate,
          time: DateFormat('hh:mma').format(inactiveDate),
          activityType: 'Status',
          tag: null,
          tags: const <String>[],
          assignedUserName: record.audit.updatedBy,
        ),
      );
    }

    // 3. Blacklist event
    final dynamic blacklistDateRaw =
        record.blacklistDetails[CrmClientRecordModel.blacklistRequestedAtKey];

    if (record.isBlacklisted || blacklistDateRaw != null) {
      DateTime blDate = createdDate;
      if (blacklistDateRaw is String) {
        blDate = DateTime.tryParse(blacklistDateRaw) ?? createdDate;
      }
      final String? reason = record
          .blacklistDetails[CrmClientRecordModel.blacklistReasonKey]
          ?.toString();
      final String? requestedBy = record
          .blacklistDetails[CrmClientRecordModel.blacklistRequestedByKey]
          ?.toString();

      events.add(
        CrmTimelineItemModel(
          id: 'status_blacklist_${record.id}',
          title: 'Client Blacklisted',
          subtitle: reason?.isNotEmpty == true
              ? 'Reason: $reason'
              : 'Client restricted on blacklist',
          date: blDate,
          time: DateFormat('hh:mma').format(blDate),
          activityType: 'Blacklist',
          tag: null,
          tags: const <String>[],
          assignedUserName: requestedBy,
        ),
      );
    }

    // 4. Unblacklist / Removal event
    final dynamic removalDateRaw = record
        .blacklistDetails[CrmClientRecordModel.blacklistRemovalRequestedAtKey];
    if (removalDateRaw != null ||
        record.blacklistDetails[
                CrmClientRecordModel.blacklistRemovalReasonKey] !=
            null) {
      DateTime remDate = createdDate;
      if (removalDateRaw is String) {
        remDate = DateTime.tryParse(removalDateRaw) ?? createdDate;
      }
      final String? remReason = record
          .blacklistDetails[CrmClientRecordModel.blacklistRemovalReasonKey]
          ?.toString();
      final String? remBy = record
          .blacklistDetails[CrmClientRecordModel.blacklistRemovalRequestedByKey]
          ?.toString();

      events.add(
        CrmTimelineItemModel(
          id: 'status_unblacklist_${record.id}',
          title: 'Removed from Blacklist',
          subtitle: remReason?.isNotEmpty == true
              ? 'Reason: $remReason'
              : 'Client restored to active status',
          date: remDate,
          time: DateFormat('hh:mma').format(remDate),
          activityType: 'Unblacklist',
          tag: null,
          tags: const <String>[],
          assignedUserName: remBy,
        ),
      );
    }

    return events;
  }
}
