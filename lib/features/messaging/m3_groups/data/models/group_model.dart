/// Module: messaging / groups / data/models/group_model.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_model.dart
/// Purpose: Group model — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/helper/main_helper/single_value_tracking_model.dart';
import './group_admin_model.dart';
import './group_last_message_info.dart';
import './group_members.dart';

class GroupModel {
  String groupId;
  String createdBy;
  SingleValueTrackingModel<String> groupName;
  SingleValueTrackingModel<String>? groupNameAr;
  SingleValueTrackingModel<String> groupDescription;
  SingleValueTrackingModel<String>? groupDescriptionAr;
  SingleValueTrackingModel<String> groupImage;
  Timestamp creationTime;
  SingleValueTrackingModel<bool> isPublic;
  SingleValueTrackingModel<bool> isOnlyAdminsCanSend;
  SingleValueTrackingModel<bool> isDisappearingMessages;
  List<String> currentExistingMembers = [];
  bool isDeleted;
  Timestamp? deletedTime;
  SingleValueTrackingModel<bool> isUnMuted;
  GroupMembers groupMembers;
  GroupAdminsModel groupAdmins;
  GroupLastMessageInfo? groupLastMessageInfo;
  List<String>? mentionedMembers;
  String? pinnedMessageId; // ✅ Pinned message ID

  GroupModel({
    required this.groupId,
    required this.createdBy,
    required this.groupName,
    this.groupNameAr,
    required this.groupDescription,
    this.groupDescriptionAr,
    required this.groupImage,
    required this.creationTime,
    required this.isPublic,
    required this.isOnlyAdminsCanSend,
    required this.isDeleted,
    required this.deletedTime,
    required this.isUnMuted,
    required this.groupMembers,
    required this.groupAdmins,
    required this.isDisappearingMessages,
    required this.currentExistingMembers,
    this.mentionedMembers,
    this.groupLastMessageInfo,
    this.pinnedMessageId, // ✅
  });

  static const String GROUP_ID = 'Group_Id';
  static const String CREATED_BY = 'Created_By';
  static const String GROUP_NAME = 'Group_Name';
  static const String GROUP_NAME_AR = 'Group_Name_Ar';
  static const String GROUP_DESCRIPTION = 'Group_Description';
  static const String GROUP_DESCRIPTION_AR = 'Group_Description_Ar';
  static const String GROUP_IMAGE = 'Group_Image';
  static const String CREATION_TIME = 'Creation_Time';
  static const String IS_PUBLIC = 'Is_Public';
  static const String IS_ONLY_ADMINS_CAN_SEND = 'Is_Only_Admins_Can_Send';
  static const String IS_DELETED = 'Is_Deleted';
  static const String DELETED_TIME = 'Deleted_Time';
  static const String IS_UN_MUTED = 'Is_Un_Muted';
  static const String IS_DISAPPEARING_MESSAGES = 'Is_Disappearing_Messages';
  static const String GROUP_ADMINS = 'Group_Admins';
  static const String GROUP_LAST_MESSAGE_INFO = 'Group_Last_Message_Info';
  static const String CURRENT_EXISTING_MEMBERS = 'Current_Existing_Members';
  static const String MENTIONED_MEMBERS = 'Mentioned_Members';
  static const String PINNED_MESSAGE_ID = 'Pinned_Message_Id'; // ✅

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      GROUP_ID: groupId,
      CREATED_BY: createdBy,
      CURRENT_EXISTING_MEMBERS: currentExistingMembers,
      GROUP_NAME: groupName.toMap(),
      if (groupNameAr != null) GROUP_NAME_AR: groupNameAr!.toMap(),
      GROUP_DESCRIPTION: groupDescription.toMap(),
      if (groupDescriptionAr != null)
        GROUP_DESCRIPTION_AR: groupDescriptionAr!.toMap(),
      GROUP_IMAGE: groupImage.toMap(),
      CREATION_TIME: creationTime,
      IS_PUBLIC: isPublic.toMap(),
      IS_ONLY_ADMINS_CAN_SEND: isOnlyAdminsCanSend.toMap(),
      IS_DELETED: isDeleted,
      DELETED_TIME: deletedTime,
      IS_UN_MUTED: isUnMuted.toMap(),
      GROUP_ADMINS: groupAdmins.toMap(),
      IS_DISAPPEARING_MESSAGES: isDisappearingMessages.toMap(),
      GROUP_LAST_MESSAGE_INFO: groupLastMessageInfo?.toMap(),
      MENTIONED_MEMBERS: mentionedMembers,
      if (pinnedMessageId != null) PINNED_MESSAGE_ID: pinnedMessageId, // ✅
    };
    map.addAll(groupMembers.toMap());
    return map;
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map[GROUP_ID] as String,
      currentExistingMembers: List<String>.from(map[CURRENT_EXISTING_MEMBERS]),
      createdBy: map[CREATED_BY] as String,
      groupName: SingleValueTrackingModel<String>.fromMap(
          map[GROUP_NAME] as Map<String, dynamic>),
      groupNameAr: map[GROUP_NAME_AR] != null
          ? SingleValueTrackingModel<String>.fromMap(
          map[GROUP_NAME_AR] as Map<String, dynamic>)
          : null,
      groupDescription: SingleValueTrackingModel<String>.fromMap(
          map[GROUP_DESCRIPTION] as Map<String, dynamic>),
      groupDescriptionAr: map[GROUP_DESCRIPTION_AR] != null
          ? SingleValueTrackingModel<String>.fromMap(
          map[GROUP_DESCRIPTION_AR] as Map<String, dynamic>)
          : null,
      groupImage: SingleValueTrackingModel<String>.fromMap(
          map[GROUP_IMAGE] as Map<String, dynamic>),
      creationTime: map[CREATION_TIME] as Timestamp,
      isPublic: SingleValueTrackingModel<bool>.fromMap(
          map[IS_PUBLIC] as Map<String, dynamic>),
      isOnlyAdminsCanSend: SingleValueTrackingModel<bool>.fromMap(
          map[IS_ONLY_ADMINS_CAN_SEND] as Map<String, dynamic>),
      isDeleted: map[IS_DELETED] as bool,
      deletedTime: map[DELETED_TIME] as Timestamp?,
      isUnMuted: SingleValueTrackingModel<bool>.fromMap(
          map[IS_UN_MUTED] as Map<String, dynamic>),
      groupMembers: GroupMembers.fromMap(map),
      groupAdmins: GroupAdminsModel.fromMap(
          map[GROUP_ADMINS] as Map<String, dynamic>),
      groupLastMessageInfo: map[GROUP_LAST_MESSAGE_INFO] == null
          ? null
          : GroupLastMessageInfo.fromMap(
          map[GROUP_LAST_MESSAGE_INFO] as Map<String, dynamic>),
      isDisappearingMessages: SingleValueTrackingModel<bool>.fromMap(
          map[IS_DISAPPEARING_MESSAGES] as Map<String, dynamic>),
      mentionedMembers: map[MENTIONED_MEMBERS] == null
          ? null
          : List<String>.from(map[MENTIONED_MEMBERS]),
      pinnedMessageId: map[PINNED_MESSAGE_ID] as String?, // ✅
    );
  }
}