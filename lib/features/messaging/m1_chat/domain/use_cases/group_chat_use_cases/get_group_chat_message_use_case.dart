/// Module: messaging / chat / domain/use_cases/group_chat_use_cases/get_group_chat_message_use_case.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/file_handler.dart';
import '../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../../m3_groups/domain/entities/member_entity.dart';
import '../../../../m3_groups/presentation/controller/groups_controller.dart';
import '../../../data/models/group_chat_message_model.dart';
import '../../../data/models/group_member_seen_model.dart';
import '../../../data/models/message/video_message_model.dart';
import '../../enum/reacts.dart';
import '../../entity/group_message_entity.dart';
import '../../repository/chat_repository/base_chat_repository.dart';

class GetGroupChatMessageUseCase {
  final BaseChatRepository chatRepository;
  // ✅ Accept GroupsCubit instead of using Get.find
  final GroupsCubit groupsCubit;

  GetGroupChatMessageUseCase(this.chatRepository, this.groupsCubit);

  Stream<Either<Failure, List<GroupMessageEntity>>> execute(
      {required String chatId,
        required GroupEntity groupEntity,
        required String currentUserId}) async* {
    Stream<Either<Failure, dynamic>> chatMessages =
    chatRepository.getChatMessages(chatId);

    await for (final chatMessage in chatMessages) {
      Either<Failure, List<GroupMessageEntity>> messages;
      if (chatMessage.isLeft()) {
        Failure? failure = chatMessage.fold((l) => l, (r) => null);
        messages = Left(failure!);
        yield messages;
        return;
      }
      yield* _getMessageEntities(
          messages: chatMessage.getOrElse(() => []),
          group: groupEntity,
          currentUserId: currentUserId);
    }
  }

  /// Helper to convert a react name string back to Reacts enum
  static Reacts? _reactFromName(String name) {
    for (final r in Reacts.values) {
      if (r.name == name) return r;
    }
    return null;
  }

  Stream<Either<Failure, List<GroupMessageEntity>>> _getMessageEntities(
      {required List<GroupChatMessageModel> messages,
        required GroupEntity group,
        required String currentUserId}) async* {
    Either<Failure, List<GroupMessageEntity>> result;
    List<GroupMessageEntity> messageEntities = [];
    Map<String, GroupMessageEntity> messageEntitiesMap = {};

    for (int i = 0; i < messages.length; i++) {
      GroupChatMessageModel message = messages[i];
      Set<String> seenBy = _getSeenBy(message);

      // ✅ FIXED: null-safe lookup — don't crash if replied message not in map
      GroupMessageEntity? repliedMessage;
      if (message.repliedMessageId != null) {
        repliedMessage = messageEntitiesMap[message.repliedMessageId];
      }

      bool isSeen = _checkIfMessageIsSeen(
          message.seenBy, group.members, message.sendTime);

      // ✅ Convert react name strings to Reacts enum list
      List<Reacts> parsedReacts = [];
      for (final reactName in message.reacts) {
        final r = _reactFromName(reactName);
        if (r != null) parsedReacts.add(r);
      }

      GroupMessageEntity messageEntity = GroupMessageEntity(
        messageId: message.messageId,
        videoMessageModel: message.video,
        time: message.sendTime,
        isPinned: message.pinModel != null
            ? message.pinModel!.isPinned.last
            : false,
        docMessageModel: message.docMessageModel,
        senderImage: group.members
            .firstWhere(
              (element) => element.memberId == message.senderId,
          orElse: () => group.members.first, // ✅ safe fallback
        )
            .memberImage,
        isMe: message.senderId == currentUserId,
        isSeen: isSeen,
        audio: message.audio,
        repliedMessage: repliedMessage,
        indexOfRepliedMessage: repliedMessage?.index,
        isDeleted: message.isDeleted,
        isEdited: message.isEdited,
        isForwarded: message.isForwarded,
        messageType: message.messageType,
        messageContent: message.messageContent ?? "",
        channelId: message.groupId,
        isGroup: true,
        mediaLink: message.mediaLink,
        index: i,
        messageSeenBy: seenBy,
        reacts: parsedReacts,
      );

      if (messageEntity.messageType == MessageTypes.text) {

        // ✅ FIXED: use injected groupsCubit instead of Get.find<GroupsCubit>()
        final selectedGroup = groupsCubit.selectedGroup;
        if (selectedGroup != null) {
          for (MemberEntity member in selectedGroup.members) {
            if (message.mentionedMembers != null &&
                message.mentionedMembers!.contains(member.memberId)) {
              messageEntity.messageContent =
                  messageEntity.messageContent!.replaceAll(
                    '@${member.memberId.replaceAll('@', '_')}',
                    '@${member.primaryLanguageName} ',
                  );
            }
          }
        }
      }

      messageEntities.add(messageEntity);
      // FIXED 24/9/2026 — realtime: a failing/hanging media download used to
      // end or block the live stream until the app was restarted.
      try {
        await handleMediaMessage(message: messageEntity)
            .timeout(const Duration(seconds: 20));
      } catch (_) {}
      messageEntitiesMap[message.messageId] = messageEntity;
    }
    yield result = Right(messageEntities);
  }

  bool _checkIfMessageIsSeen(List<GroupMemberSeenModel> seenBy,
      List<MemberEntity> members, Timestamp messageTime) {
    int i = 0;
    bool isSeen = true;
    for (MemberEntity member in members) {
      i++;
      if (!seenBy.any((element) => element.memberId == member.memberId)) {
        // ✅ FIXED: null-safe addedTime check
        final addedTime = member.addedTime;
        if (addedTime != null &&
            messageTime.toDate().isAfter(addedTime.toDate())) {
          isSeen = false;
          break;
        }
      }
    }
    return isSeen;
  }

  Set<String> _getSeenBy(message) {
    Set<String> seenBy = {};
    for (GroupMemberSeenModel seen in message.seenBy) {
      seenBy.add(seen.memberId);
    }
    return seenBy;
  }

  Future<void> handleMediaMessage({required GroupMessageEntity message}) async {
    if (message.messageType == MessageTypes.audio) {
      File file = await FileHandler().downloadFile(
          message.audio!.audioPath,
          '${message.time}.${message.audio!.audioPath.split('.').last.split('?').first}');
      message.audio!.audioPath = file.path;
      message.mediaLink = message.audio!.audioPath;
    }
    if (message.messageType == MessageTypes.doc) {
      File file = await FileHandler().downloadFile(
          message.docMessageModel!.docPath,
          message.time.toString() + message.docMessageModel!.fileName!);
      message.docMessageModel!.docPath = file.path;
      message.mediaLink = message.docMessageModel!.docPath;
    }
    if (message.messageType == MessageTypes.video) {
      File file = await FileHandler().downloadFile(
          message.videoMessageModel!.videoFilePath,
          '${message.time}.${message.videoMessageModel!.videoFilePath.split('.').last.split('?').first}');
      message.videoMessageModel!.videoFilePath = file.path;
      VideoMessageModel videoMessageModel = VideoMessageModel(
          videoFilePath: message.videoMessageModel!.videoFilePath);
      message.mediaLink = message.videoMessageModel!.videoFilePath;
      message.videoMessageModel = videoMessageModel;
    }
  }
}