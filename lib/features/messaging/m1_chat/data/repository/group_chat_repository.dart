/// Module: messaging / chat / data/repository/group_chat_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/constants/message_module/api_constants.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../m2_connections/data/models/user_connection_last_message_info_model.dart';
import '../../../m3_groups/data/models/group_last_message_info.dart';
import '../../../m3_groups/data/models/group_members.dart';
import '../../../m3_groups/data/models/group_model.dart';
import '../../../m3_groups/domain/entities/group_entity.dart';
import '../../../m3_groups/domain/entities/member_entity.dart';
import '../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../domain/entity/new_message_content_entity.dart';
import '../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../domain/enum/reacts.dart';
import 'react_writer.dart';
import '../data_source/group_chat_remote_data_source.dart';
import '../models/group_chat_message_model.dart';
import '../models/group_member_seen_model.dart';
import '../models/single_chat_message_model.dart';
import '../models/sub_models/pin_model.dart';

class GroupChatRepository implements BaseChatRepository {
  Timestamp _currentTime = Timestamp.now();
  final GroupChatRemoteDataSource chatRemoteDataSource =
  GroupChatRemoteDataSource();

  @override
  deleteMessage({
    required String messageId,
    required String chatId,
    required String otherId,
    required String currentUserId,
  }) {
    chatRemoteDataSource.deleteMessage(
        messageId: messageId, groupId: chatId, currentUserId: currentUserId);
  }

  @override
  editTextMessage({
    required String newMessageText,
    required String messageId,
    required String chatId,
    required String otherId,
    required String currentUserId,
  }) {
    chatRemoteDataSource.editTextMessage(
        newMessageText: newMessageText,
        messageId: messageId,
        groupId: chatId,
        currentUserId: currentUserId);
  }

  @override
  Stream<Either<Failure, dynamic>> getChatMessages(String chatId) async* {
    Stream<Either<Failure, List<Map<String, dynamic>>>> stream =
    chatRemoteDataSource.getGroupChatMessages(groupId: chatId);
    await for (final data in stream) {
      if (data.isLeft()) {
        yield data;
        return;
      }
      List<Map<String, dynamic>> jsonMessages = data.getOrElse(() => []);
      List<GroupChatMessageModel> messages = [];
      // FIXED 24/9/2026 — realtime: skip a malformed doc instead of throwing,
      // which used to kill the live stream until the app was restarted.
      for (Map<String, dynamic> jsonMessage in jsonMessages) {
        try {
          messages.add(GroupChatMessageModel.fromMap(jsonMessage));
        } catch (e) {
          debugPrint('⚠️ skipped malformed group chat message ($e): $jsonMessage');
        }
      }
      yield Right(messages);
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required SingleChatMessageModel messageModel,
    required UserConnectionLastMessageInfoModel currentUserConnectionModel,
    required UserConnectionLastMessageInfoModel otherUserConnectionModel,
  }) {
    throw UnimplementedError();
  }

  @override
  updateMyNumOfUnreadMessages({
    required String currentUserId,
    required String otherUserId,
    required int newValue,
  }) {
    throw UnimplementedError();
  }

  @override
  sendNewMessage({
    required BaseMessagingInterfaceParameters currentUser,
    required ChatTypeEntity otherConnectionSide,
    required NewMessageContentEntity messageContent,
  }) async {
    GroupEntity groupEntity = otherConnectionSide as GroupEntity;
    _currentTime = Timestamp.now();
    chatRemoteDataSource.startBatch();
    Map<String, dynamic> groupUpdatedData = {};
    _updateGroupLastMessageInfo(
        groupEntity: groupEntity,
        currentUser: currentUser,
        newMessageContent: messageContent,
        groupUpdatedData: groupUpdatedData);
    _updateGroupMembersSeenMessages(
        groupEntity: groupEntity,
        currentUser: currentUser,
        groupedUpdatedData: groupUpdatedData);

    chatRemoteDataSource.updateGroupMessageData(
        groupId: groupEntity.groupId, data: groupUpdatedData);

    GroupChatMessageModel? messageModel = await _createMessageModel(
      newMessageContent: messageContent,
      currentUser: currentUser,
      groupEntity: groupEntity,
    );
    if (messageModel == null) {
      return Left(FirebaseFailure("Failed to create message model"));
    }

    chatRemoteDataSource.sendMessage(messageModel: messageModel);
    return await chatRemoteDataSource.commitBatch();
  }

  @override
  updateMessagesAsSeen({
    required List<String> unSeenMessagesIds,
    required String chatId,
    String? currentUserId,
  }) async {
    chatRemoteDataSource.startBatch();
    chatRemoteDataSource.updateUserSeenMessages(
        chatId: chatId,
        messageId: unSeenMessagesIds,
        userId: currentUserId!,
        seenTime: Timestamp.now());
    chatRemoteDataSource.updateUserNumOfUnreadMessages(
        groupId: chatId, userId: currentUserId!, numOfUnreadMessages: 0);
    return await chatRemoteDataSource.commitBatch();
  }

  @override
  updateMessagePinState({
    required String messageId,
    required chatId,
    required currentUserId,
    required bool state,
  }) async {
    Either<Failure, void> result = await chatRemoteDataSource.getMessage(
      messageId,
      chatId,
    );
    if (result.isLeft()) {
      return result;
    }
    GroupChatMessageModel messageModel = GroupChatMessageModel.fromMap(
        result.getOrElse(() => {}) as Map<String, dynamic>);
    // §10 — pinModel is final; seed it via copyWith when absent, then mutate
    // the PinModel's own lists (that's the PinModel's state, not this model's).
    if (messageModel.pinModel == null) {
      messageModel = messageModel.copyWith(
          pinModel: PinModel(isPinned: [], userId: [], pinnedAt: []));
    }
    messageModel.pinModel!.isPinned.add(state);
    messageModel.pinModel!.userId.add(currentUserId);
    messageModel.pinModel!.pinnedAt.add(Timestamp.now());
    chatRemoteDataSource.updateMessage(messageId, chatId, messageModel.toMap());
  }


  Future<Either<Failure, void>> updateGroupPinnedMessageId({
    required String groupId,
    required String? pinnedMessageId,
  }) async {
    return await chatRemoteDataSource.updateGroupPinnedMessageId(
      groupId: groupId,
      pinnedMessageId: pinnedMessageId,
    );
  }

  // ✅ FIXED: use correct Firestore path from ApiConstants
  @override
  Future<Either<Failure, void>> addReact({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required Reacts react,
  }) async {
    try {
      final collectionPath =
          "${ApiConstants.groupsChat}/$chatId/${ApiConstants.messages}";

      // One reaction per user; changing it replaces the old one
      // (bug report #24). See ReactWriter.
      await ReactWriter.setReact(
        messageRef: FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(messageId),
        userId: currentUserId,
        react: react,
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<GroupChatMessageModel?> _createMessageModel({
    required BaseMessagingInterfaceParameters currentUser,
    required GroupEntity groupEntity,
    required NewMessageContentEntity newMessageContent,
  }) async {
    if (newMessageContent.messageType == MessageTypes.text) {
      newMessageContent as TextMessageContentEntity;
      return GroupChatMessageModel(
          groupId: groupEntity.groupId,
          messageId:
          "${currentUser.userId} . ${_currentTime.microsecondsSinceEpoch}",
          messageContent: newMessageContent.messageContent,
          messageType: newMessageContent.messageType,
          senderId: currentUser.userId,
          sendTime: _currentTime,
          isDeleted: false,
          isEdited: false,
          isForwarded: false,
          repliedMessageId: newMessageContent.repliedMessageId,
          mentionedMembers: newMessageContent.messageType == MessageTypes.text
              ? newMessageContent.mentionedMembers?.keys.toList()
              : null,
          seenBy: [
            GroupMemberSeenModel(
                memberId: currentUser.userId, seenTime: _currentTime)
          ]);
    } else if (newMessageContent.messageType == MessageTypes.cameraImage) {
      newMessageContent as ImageMessageContentEntity;
      Either<Failure, String> mediaLink = await chatRemoteDataSource
          .uploadMedia(filePath: newMessageContent.filePath);
      if (mediaLink.isLeft()) return null;
      String mediaLinkString = mediaLink.getOrElse(() => "");
      return GroupChatMessageModel(
          groupId: groupEntity.groupId,
          messageContent: newMessageContent.caption,
          messageId: "${currentUser.userId} . $_currentTime",
          mediaLink: mediaLinkString,
          messageType: newMessageContent.messageType,
          senderId: currentUser.userId,
          sendTime: _currentTime,
          isDeleted: false,
          isEdited: false,
          isForwarded: false,
          repliedMessageId: newMessageContent.repliedMessageId,
          seenBy: [
            GroupMemberSeenModel(
                memberId: currentUser.userId, seenTime: _currentTime)
          ]);
    } else if (newMessageContent.messageType == MessageTypes.video) {
      newMessageContent as VideoMessageContentEntity;
      Either<Failure, String> mediaLink = await chatRemoteDataSource
          .uploadMedia(filePath: newMessageContent.video.videoFilePath);
      if (mediaLink.isLeft()) return null;
      String mediaLinkString = mediaLink.getOrElse(() => "");
      newMessageContent.video.videoFilePath = mediaLinkString;
      return GroupChatMessageModel(
          groupId: groupEntity.groupId,
          messageContent: newMessageContent.caption,
          messageId: "${currentUser.userId} . $_currentTime",
          mediaLink: mediaLinkString,
          messageType: newMessageContent.messageType,
          senderId: currentUser.userId,
          sendTime: _currentTime,
          isDeleted: false,
          isEdited: false,
          isForwarded: false,
          repliedMessageId: newMessageContent.repliedMessageId,
          video: newMessageContent.video,
          seenBy: [
            GroupMemberSeenModel(
                memberId: currentUser.userId, seenTime: _currentTime)
          ]);
    } else if (newMessageContent.messageType == MessageTypes.doc) {
      newMessageContent as DocumentMessageContentEntity;
      Either<Failure, String> mediaLink = await chatRemoteDataSource
          .uploadMedia(
          filePath: newMessageContent.documentMessageModel.docPath);
      if (mediaLink.isLeft()) return null;
      String docLink = mediaLink.getOrElse(() => "");
      newMessageContent.documentMessageModel.docPath = docLink;
      return GroupChatMessageModel(
          groupId: groupEntity.groupId,
          messageContent: null,
          messageId: "${currentUser.userId} . $_currentTime",
          mediaLink: docLink,
          messageType: newMessageContent.messageType,
          senderId: currentUser.userId,
          sendTime: _currentTime,
          isDeleted: false,
          isEdited: false,
          isForwarded: false,
          repliedMessageId: newMessageContent.repliedMessageId,
          docMessageModel: newMessageContent.documentMessageModel,
          seenBy: [
            GroupMemberSeenModel(
                memberId: currentUser.userId, seenTime: _currentTime)
          ]);
    } else if (newMessageContent.messageType == MessageTypes.audio) {
      newMessageContent as AudioMessageContentEntity;
      Either<Failure, String> mediaLink = await chatRemoteDataSource
          .uploadMedia(filePath: newMessageContent.audio.audioPath);
      if (mediaLink.isLeft()) return null;
      String audioLink = mediaLink.getOrElse(() => "");
      newMessageContent.audio.audioPath = audioLink;
      return GroupChatMessageModel(
          groupId: groupEntity.groupId,
          messageContent: null,
          messageId: "${currentUser.userId} . $_currentTime",
          mediaLink: audioLink,
          messageType: newMessageContent.messageType,
          senderId: currentUser.userId,
          sendTime: _currentTime,
          isDeleted: false,
          isEdited: false,
          isForwarded: false,
          audio: newMessageContent.audio,
          repliedMessageId: newMessageContent.repliedMessageId,
          seenBy: [
            GroupMemberSeenModel(
                memberId: currentUser.userId, seenTime: _currentTime)
          ]);
    } else if (newMessageContent is LocationMessageContentEntity ||
        newMessageContent is ContactMessageContentEntity ||
        newMessageContent is PollMessageContentEntity) {
      // Bug report #23 — location / contact: nothing to upload, the payload
      // travels as JSON in Message_Content. Polls (30/9/2026) do the same.
      final String payload = newMessageContent is LocationMessageContentEntity
          ? newMessageContent.location.encode()
          : newMessageContent is PollMessageContentEntity
              ? newMessageContent.poll.encode()
              : (newMessageContent as ContactMessageContentEntity)
                  .contact
                  .encode();
      return GroupChatMessageModel(
          groupId: groupEntity.groupId,
          messageContent: payload,
          messageId: "${currentUser.userId} . $_currentTime",
          messageType: newMessageContent.messageType,
          senderId: currentUser.userId,
          sendTime: _currentTime,
          isDeleted: false,
          isEdited: false,
          isForwarded: false,
          repliedMessageId: newMessageContent.repliedMessageId,
          seenBy: [
            GroupMemberSeenModel(
                memberId: currentUser.userId, seenTime: _currentTime)
          ]);
    }
    return null;
  }

  // ✅ FIXED: use previewContent (plain text) for last message info instead of encrypted messageContent
  _updateGroupLastMessageInfo({
    required GroupEntity groupEntity,
    required BaseMessagingInterfaceParameters currentUser,
    required Map<String, dynamic> groupUpdatedData,
    required NewMessageContentEntity newMessageContent,
  }) {
    GroupLastMessageInfo? lastMessageInfo;
    if (newMessageContent.messageType == MessageTypes.text) {
      newMessageContent as TextMessageContentEntity;
      // ✅ Use previewContent (plain text) for the tile preview, fall back to messageContent
      final displayText = newMessageContent.previewContent ?? newMessageContent.messageContent;
      lastMessageInfo = GroupLastMessageInfo(
          messageType: newMessageContent.messageType,
          messageId: "${currentUser.userId} . $_currentTime",
          textMessage: displayText,
          senderId: currentUser.userId,
          lastMessageTime: _currentTime);
      if (newMessageContent.mentionedMembers != null) {
        _updateMentionList(
            gorupId: groupEntity,
            mentions: newMessageContent.mentionedMembers!);
      }
    }
    if (newMessageContent.messageType == MessageTypes.cameraImage) {
      newMessageContent as ImageMessageContentEntity;
      lastMessageInfo = GroupLastMessageInfo(
          messageType: newMessageContent.messageType,
          messageId: "${currentUser.userId} . $_currentTime",
          textMessage: newMessageContent.caption,
          senderId: currentUser.userId,
          lastMessageTime: _currentTime);
    }
    if (newMessageContent.messageType == MessageTypes.video) {
      newMessageContent as VideoMessageContentEntity;
      lastMessageInfo = GroupLastMessageInfo(
          messageType: newMessageContent.messageType,
          messageId: "${currentUser.userId} . $_currentTime",
          textMessage: newMessageContent.caption,
          senderId: currentUser.userId,
          lastMessageTime: _currentTime);
    }
    if (newMessageContent.messageType == MessageTypes.doc ||
        newMessageContent.messageType == MessageTypes.audio) {
      lastMessageInfo = GroupLastMessageInfo(
          messageType: newMessageContent.messageType,
          messageId: "${currentUser.userId} . $_currentTime",
          textMessage: null,
          senderId: currentUser.userId,
          lastMessageTime: _currentTime);
      groupUpdatedData.addAll(
          {GroupModel.GROUP_LAST_MESSAGE_INFO: lastMessageInfo.toMap()});
    }
    // Bug report #4: location / contact / poll / gallery-image messages used
    // to leave the group's last-message info untouched, so the group card
    // kept saying "You created this group" after messages were sent. Every
    // other type now records a type-only preview.
    lastMessageInfo ??= GroupLastMessageInfo(
        messageType: newMessageContent.messageType,
        messageId: "${currentUser.userId} . $_currentTime",
        textMessage: null,
        senderId: currentUser.userId,
        lastMessageTime: _currentTime);
    groupUpdatedData.addAll(
        {GroupModel.GROUP_LAST_MESSAGE_INFO: lastMessageInfo.toMap()});
  }

  _updateGroupMembersSeenMessages({
    required GroupEntity groupEntity,
    required BaseMessagingInterfaceParameters currentUser,
    required Map<String, dynamic> groupedUpdatedData,
  }) {
    Map<String, dynamic> updateSeenQueries = {};
    for (MemberEntity member in groupEntity.members) {
      if (member.memberId != currentUser.userId) {
        updateSeenQueries.addAll({
          "${GroupMembers.membersKey}.${member.memberId.replaceAll(".", "---")}.${GroupMember.numOfUnreadMessagesKey}":
          FieldValue.increment(1)
        });
      } else {
        updateSeenQueries.addAll({
          "${GroupMembers.membersKey}.${member.memberId.replaceAll(".", "---")}.${GroupMember.numOfUnreadMessagesKey}":
          0
        });
      }
    }
    groupedUpdatedData.addAll(updateSeenQueries);
  }

  void _updateMentionList({
    required GroupEntity gorupId,
    required Map<String, dynamic> mentions,
  }) {
    chatRemoteDataSource.updateGroupMentionList(
        groupId: gorupId.groupId, mentions: mentions.keys.toList());
  }
}