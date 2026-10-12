/// Module: messaging / chat / domain/entity/message_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../data/models/message/audio_message_model.dart';
import '../../data/models/message/doc_message_model.dart';
import '../../data/models/message/video_message_model.dart';
import '../enum/reacts.dart';

class MessageEntity {
  String channelId;
  String messageId;
  Timestamp time;
  bool isMe;
  bool isSeen;
  bool isDeleted;
  bool isEdited;
  bool isForwarded;
  String? forwardFrom;
  MessageTypes messageType;
  String? messageContent;
  bool isGroup;
  int? indexOfRepliedMessage;
  int index;
  bool isStarred;
  MessageEntity? repliedMessage;
  String? mediaLink;
  List<Reacts> reacts;
  DocMessageModel? docMessageModel;
  VideoMessageModel? videoMessageModel;
  AudioMessageModel? audio;
  bool isPinned;

  MessageEntity({
    required this.messageId,
    required this.time,
    required this.isMe,
    required this.isSeen,
    required this.isDeleted,
    required this.isEdited,
    required this.isForwarded,
    this.forwardFrom,
    this.isStarred = false,
    required this.messageType,
    required this.messageContent,
    required this.channelId,
    required this.isGroup,
    this.repliedMessage,
    this.indexOfRepliedMessage,
    required this.index,
    required this.isPinned,
    this.mediaLink,
    this.docMessageModel,
    this.audio,
    required this.videoMessageModel,
    this.reacts = const [],
  });

  MessageEntity copyWith({
    String? channelId,
    String? messageId,
    Timestamp? time,
    bool? isMe,
    bool? isSeen,
    bool? isDeleted,
    bool? isEdited,
    bool? isForwarded,
    String? Function()? forwardFrom,
    bool? isStarred,
    MessageTypes? messageType,
    String? Function()? messageContent,
    bool? isGroup,
    int? Function()? indexOfRepliedMessage,
    int? index,
    bool? isPinned,
    MessageEntity? Function()? repliedMessage,
    String? Function()? mediaLink,
    List<Reacts>? reacts,
    DocMessageModel? Function()? docMessageModel,
    VideoMessageModel? Function()? videoMessageModel,
    AudioMessageModel? Function()? audio,
  }) {
    return MessageEntity(
      channelId: channelId ?? this.channelId,
      messageId: messageId ?? this.messageId,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      isSeen: isSeen ?? this.isSeen,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardFrom: forwardFrom != null ? forwardFrom() : this.forwardFrom,
      isStarred: isStarred ?? this.isStarred,
      messageType: messageType ?? this.messageType,
      messageContent:
      messageContent != null ? messageContent() : this.messageContent,
      isGroup: isGroup ?? this.isGroup,
      indexOfRepliedMessage: indexOfRepliedMessage != null
          ? indexOfRepliedMessage()
          : this.indexOfRepliedMessage,
      index: index ?? this.index,
      isPinned: isPinned ?? this.isPinned,
      repliedMessage:
      repliedMessage != null ? repliedMessage() : this.repliedMessage,
      mediaLink: mediaLink != null ? mediaLink() : this.mediaLink,
      reacts: reacts ?? this.reacts,
      docMessageModel:
      docMessageModel != null ? docMessageModel() : this.docMessageModel,
      videoMessageModel: videoMessageModel != null
          ? videoMessageModel()
          : this.videoMessageModel,
      audio: audio != null ? audio() : this.audio,
    );
  }
}