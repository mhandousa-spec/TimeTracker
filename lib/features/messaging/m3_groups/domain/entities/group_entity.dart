/// Module: messaging / groups / domain/entity/group_entity.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_entity.dart
/// Purpose: Group entity — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../data/models/group_members.dart';
import '../../data/models/group_model.dart';
import './member_entity.dart';

class GroupEntity extends ChatTypeEntity {
  String groupId;
  String createdBy;
  String? groupImage;
  String groupDescription;
  String? groupDescriptionAr;
  bool isOnlyAdminsCanSend;
  bool isDisappearingMessages;
  Timestamp createdAt;
  bool isUnMuted;
  String? senderPrimaryLanguageName;
  String? senderSecondaryLanguageName;
  List<MemberEntity> members;
  bool hasMention;
  bool isPublic;
  String? groupNameAr;
  bool hasPinnedMessage; // ✅ Pin indicator for group tile

  GroupEntity({
    required this.groupId,
    required this.createdBy,
    required super.imageUri,
    required this.isPublic,
    required super.primaryLanguageName,
    required this.groupDescription,
    required this.isOnlyAdminsCanSend,
    required this.isDisappearingMessages,
    required this.isUnMuted,
    required super.isSeen,
    required super.otherSideId,
    required super.messageType,
    required super.messageContent,
    required super.lastMessageTime,
    required super.myNumUnreadMessage,
    required super.isLastMessageSenderIsCurrentUser,
    required this.hasMention,
    required this.senderPrimaryLanguageName,
    required this.senderSecondaryLanguageName,
    required this.members,
    required this.groupImage,
    required this.createdAt,
    required this.hasPinnedMessage, // ✅
    this.groupNameAr,
    this.groupDescriptionAr,
  });

  static GroupEntity fromModel(
    GroupModel group,
    String userId, {
    List<UserCategory>? categories,
  }) {
    MemberEntity? sender;
    late MemberEntity me;
    List<MemberEntity> members = [];
    for (GroupMember member in group.groupMembers.members.values) {
      bool isAdmin = false;
      if (group.groupAdmins.adminData.containsKey(member.memberId)) {
        isAdmin = group.groupAdmins.adminData[member.memberId]!.isAdmin.last;
      }
      if (member.isMember.last) {
        members.add(
            MemberEntity.fromModel(member, isAdmin, categories: categories));
      }
      if (member.memberId == group.groupLastMessageInfo?.senderId) {
        sender =
            MemberEntity.fromModel(member, isAdmin, categories: categories);
      }
      if (member.memberId == userId) {
        me = MemberEntity.fromModel(member, isAdmin, categories: categories);
      }
    }

    bool isSeen = true;
    for (MemberEntity member in members) {
      if (member.numOfUnreadMessages != 0) {
        isSeen = false;
        break;
      }
    }

    bool isMe = false;
    MessageTypes messageType = MessageTypes.none;

    if (group.groupLastMessageInfo?.senderId == userId) {
      isMe = true;
    }
    if (group.groupLastMessageInfo != null) {
      messageType = group.groupLastMessageInfo!.messageType;
    }

    return GroupEntity(
      isPublic: group.isPublic.values.last,
      imageUri: group.groupImage.values.isNotEmpty
          ? group.groupImage.values.last
          : "assets/png_assets/groupProfile.png",
      groupId: group.groupId,
      createdBy: group.createdBy,
      primaryLanguageName: group.groupName.values.last,
      groupNameAr: group.groupNameAr?.values.isNotEmpty == true
          ? group.groupNameAr!.values.last
          : null,
      groupDescription: group.groupDescription.values.last,
      groupDescriptionAr:
      group.groupDescriptionAr?.values.isNotEmpty == true
          ? group.groupDescriptionAr!.values.last
          : null,
      isOnlyAdminsCanSend: group.isOnlyAdminsCanSend.values.last,
      isDisappearingMessages: group.isDisappearingMessages.values.last,
      isUnMuted: group.isUnMuted.values.last,
      isSeen: isSeen,
      hasMention: group.mentionedMembers?.contains(userId) ?? false,
      messageType: messageType,
      messageContent: group.groupLastMessageInfo?.textMessage,
      lastMessageTime: group.groupLastMessageInfo?.lastMessageTime,
      isLastMessageSenderIsCurrentUser: isMe,
      senderPrimaryLanguageName: sender?.primaryLanguageName,
      senderSecondaryLanguageName: sender?.secondaryLanguageName,
      members: members,
      otherSideId: group.groupId,
      createdAt: group.creationTime,
      groupImage: (group.groupImage.values.isNotEmpty)
          ? group.groupImage.values.last
          : null,
      myNumUnreadMessage: me.numOfUnreadMessages,
      hasPinnedMessage: group.pinnedMessageId != null && group.pinnedMessageId!.isNotEmpty,
    );
  }
}