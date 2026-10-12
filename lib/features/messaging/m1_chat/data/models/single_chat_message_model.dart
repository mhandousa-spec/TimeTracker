/// Module: messaging / chat / data/models/single_chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../domain/entity/message_entity.dart';
import '../../domain/enum/reacts.dart';
import './message/audio_message_model.dart';
import './message/doc_message_model.dart';
import './message/video_message_model.dart';
import './sub_models/pin_model.dart';

class SingleChatMessageModel {
  /************************  MESSAGE INFO *****************************/
  // §10 — pure data model: all fields final; edits go through copyWith.
  final String chatId;
  final String messageId;
  final Timestamp sendTime;
  final String senderId;
  final String receiverId;
  final bool isSeen;
  final bool isDeleted;
  final bool isEdited;
  final bool isForwarded;
  final String? forwardFrom;
  final String? repliedMessageId;
  final PinModel? pinModel;
  final List<Reacts> reacts;
  /************************  MESSAGE CONTENT *****************************/

  final MessageTypes messageType;
  final String? messageContent;
  final String? mediaLink;
  final DocMessageModel? docMessageModel;
  final VideoMessageModel? videoMessageModel;
  final AudioMessageModel? audioMessageModel;

  /***************************** CONSTRUCTOR ****************************/

  SingleChatMessageModel({
    required this.chatId,
    required this.messageId,
    required this.sendTime,
    required this.senderId,
    required this.receiverId,
    required this.isSeen,
    required this.isDeleted,
    required this.isEdited,
    required this.isForwarded,
    this.forwardFrom,
    required this.messageType,
    required this.messageContent,
    this.docMessageModel,
    this.repliedMessageId,
    this.mediaLink,
    this.audioMessageModel,
    this.videoMessageModel,
    this.pinModel,
    this.reacts = const [],
  });

  SingleChatMessageModel copyWith({
    String? chatId,
    String? messageId,
    Timestamp? sendTime,
    String? senderId,
    String? receiverId,
    bool? isSeen,
    bool? isDeleted,
    bool? isEdited,
    bool? isForwarded,
    String? forwardFrom,
    String? repliedMessageId,
    PinModel? pinModel,
    List<Reacts>? reacts,
    MessageTypes? messageType,
    String? messageContent,
    String? mediaLink,
    DocMessageModel? docMessageModel,
    VideoMessageModel? videoMessageModel,
    AudioMessageModel? audioMessageModel,
  }) {
    return SingleChatMessageModel(
      chatId: chatId ?? this.chatId,
      messageId: messageId ?? this.messageId,
      sendTime: sendTime ?? this.sendTime,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      isSeen: isSeen ?? this.isSeen,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardFrom: forwardFrom ?? this.forwardFrom,
      repliedMessageId: repliedMessageId ?? this.repliedMessageId,
      pinModel: pinModel ?? this.pinModel,
      reacts: reacts ?? this.reacts,
      messageType: messageType ?? this.messageType,
      messageContent: messageContent ?? this.messageContent,
      mediaLink: mediaLink ?? this.mediaLink,
      docMessageModel: docMessageModel ?? this.docMessageModel,
      videoMessageModel: videoMessageModel ?? this.videoMessageModel,
      audioMessageModel: audioMessageModel ?? this.audioMessageModel,
    );
  }

  /***************************** FIELDS KEY *****************************/
  static const String CHAT_ID = 'Chat_Id';
  static const String MESSAGE_ID = 'Message_Id';
  static const String SEND_TIME = 'Send_Time';
  static const String SENDER_ID = 'Sender_Id';
  static const String RECIEVER_ID = 'Reciever_Id';
  static const String IS_SEEN = 'Is_Seen';
  static const String IS_DELETED = 'Is_Deleted';
  static const String IS_EDITED = 'Is_Edited';
  static const String IS_FORWARDED = 'Is_Forwarded';
  static const String FORWARD_FROM = 'Forward_From';
  static const String MESSAGE_TYPE = 'Message_Type';
  static const String MESSAGE_CONTENT = 'Message_Content';
  static const String REPLIED_MESSAGE_ID = 'Replied_Message_Id';
  static const String MEDIA_LINK = 'Media_Link';
  static const String PIN_MODEL = 'Pin_Model';
  static const String REACTS = 'reacts';

  /******************************* FUNCTIONS *****************************/

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      CHAT_ID: chatId,
      MESSAGE_ID: messageId,
      SEND_TIME: sendTime,
      SENDER_ID: senderId,
      RECIEVER_ID: receiverId,
      IS_SEEN: isSeen,
      IS_DELETED: isDeleted,
      IS_EDITED: isEdited,
      IS_FORWARDED: isForwarded,
      FORWARD_FROM: forwardFrom,
      MESSAGE_TYPE: messageType.index,
      MESSAGE_CONTENT: messageContent,
      REPLIED_MESSAGE_ID: repliedMessageId,
      MEDIA_LINK: mediaLink,
      PIN_MODEL: pinModel?.toMap(),
      REACTS: reacts.map((e) => e.name).toList(),
    };
    if (messageType == MessageTypes.doc) {
      map.addAll(docMessageModel!.toMap());
    }
    if (messageType == MessageTypes.video) {
      map.addAll(videoMessageModel!.toMap());
    }
    if (messageType == MessageTypes.audio) {
      map.addAll(audioMessageModel!.toMap());
    }
    return map;
  }

  /// Helper to convert a react name string back to Reacts enum
  static Reacts? _reactFromName(String name) {
    for (final r in Reacts.values) {
      if (r.name == name) return r;
    }
    return null;
  }

  factory SingleChatMessageModel.fromMap(Map<String, dynamic> map) {
    MessageTypes messageType = MessageTypes.values[map[MESSAGE_TYPE]];

    // ✅ Parse reacts from Firestore string list back to Reacts enum list
    List<Reacts> parsedReacts = [];
    if (map[REACTS] != null && map[REACTS] is List) {
      for (final reactName in map[REACTS]) {
        final r = _reactFromName(reactName.toString());
        if (r != null) parsedReacts.add(r);
      }
    }

    return SingleChatMessageModel(
      chatId: map[CHAT_ID],
      messageId: map[MESSAGE_ID],
      sendTime: map[SEND_TIME],
      senderId: map[SENDER_ID],
      receiverId: map[RECIEVER_ID],
      isSeen: map[IS_SEEN],
      isDeleted: map[IS_DELETED],
      isEdited: map[IS_EDITED],
      isForwarded: map[IS_FORWARDED],
      forwardFrom: map[FORWARD_FROM],
      messageType: MessageTypes.values[map[MESSAGE_TYPE]],
      messageContent: map[MESSAGE_CONTENT],
      mediaLink: map[MEDIA_LINK],
      audioMessageModel: (messageType == MessageTypes.audio)
          ? AudioMessageModel.fromMap(map)
          : null,
      videoMessageModel: (messageType == MessageTypes.video)
          ? VideoMessageModel.fromMap(map)
          : null,
      docMessageModel: (messageType == MessageTypes.doc)
          ? DocMessageModel.fromMap(map)
          : null,
      repliedMessageId: map[REPLIED_MESSAGE_ID],
      pinModel:
      map[PIN_MODEL] != null ? PinModel.fromMap(map[PIN_MODEL]) : null,
      reacts: parsedReacts,
    );
  }

  // ✅ FIX: currentUserId passed as parameter — no more Get.find<ConnectionsCubit>()
  MessageEntity toMessageEntity(
      String connectionId,
      Map<String, MessageEntity> messages,
      String currentUserId,
      ) {
    MessageEntity? repliedMessage;
    if (repliedMessageId != null) {
      repliedMessage = messages[repliedMessageId];
    }
    return MessageEntity(
      isGroup: false,
      channelId: connectionId,
      messageId: messageId,
      time: sendTime,
      isMe: senderId == currentUserId,
      mediaLink: mediaLink,
      isSeen: isSeen,
      isDeleted: isDeleted,
      isEdited: isEdited,
      isPinned: pinModel != null ? pinModel!.isPinned.last : false,
      isForwarded: isForwarded,
      forwardFrom: forwardFrom,
      messageType: messageType,
      messageContent: messageContent,
      audio: audioMessageModel,
      docMessageModel: docMessageModel,
      videoMessageModel: videoMessageModel,
      repliedMessage: repliedMessage,
      index: (messages.containsKey(messageId))
          ? messages.length - 1
          : messages.length,
      reacts: reacts,
    );
  }
}