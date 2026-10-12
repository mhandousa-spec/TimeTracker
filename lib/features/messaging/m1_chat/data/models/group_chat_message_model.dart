/// Module: messaging / chat / data/models/group_chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../domain/enum/reacts.dart';
import './group_member_seen_model.dart';
import './message/audio_message_model.dart';
import './message/doc_message_model.dart';
import './message/video_message_model.dart';
import './sub_models/pin_model.dart';

class GroupChatMessageModel {
  /// **********************  MESSAGE INFO ****************************
  // §10 — pure data model: all fields final; edits go through copyWith.

  final String groupId;
  final String messageId;
  final Timestamp sendTime;
  final String senderId;
  final List<GroupMemberSeenModel> seenBy;
  final bool isDeleted;
  final bool isEdited;
  final bool isForwarded;
  final String? forwardFrom;
  final String? repliedMessageId;
  final List<String>? mentionedMembers;
  final PinModel? pinModel;
  final List<String> reacts;

  /// **********************  MESSAGE CONTENT ****************************

  final MessageTypes messageType;
  final String? messageContent;
  final String? mediaLink;
  final VideoMessageModel? video;
  final DocMessageModel? docMessageModel;
  final AudioMessageModel? audio;

  /// *************************** CONSTRUCTOR ***************************

  GroupChatMessageModel(
      {required this.groupId,
        required this.messageId,
        required this.sendTime,
        required this.senderId,
        required this.seenBy,
        required this.isDeleted,
        required this.isEdited,
        required this.isForwarded,
        this.forwardFrom,
        required this.messageType,
        required this.messageContent,
        this.pinModel,
        this.mentionedMembers,
        this.repliedMessageId,
        this.docMessageModel,
        this.mediaLink,
        this.audio,
        this.video,
        this.reacts = const []});

  GroupChatMessageModel copyWith({
    String? groupId,
    String? messageId,
    Timestamp? sendTime,
    String? senderId,
    List<GroupMemberSeenModel>? seenBy,
    bool? isDeleted,
    bool? isEdited,
    bool? isForwarded,
    String? forwardFrom,
    String? repliedMessageId,
    List<String>? mentionedMembers,
    PinModel? pinModel,
    List<String>? reacts,
    MessageTypes? messageType,
    String? messageContent,
    String? mediaLink,
    VideoMessageModel? video,
    DocMessageModel? docMessageModel,
    AudioMessageModel? audio,
  }) {
    return GroupChatMessageModel(
      groupId: groupId ?? this.groupId,
      messageId: messageId ?? this.messageId,
      sendTime: sendTime ?? this.sendTime,
      senderId: senderId ?? this.senderId,
      seenBy: seenBy ?? this.seenBy,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardFrom: forwardFrom ?? this.forwardFrom,
      repliedMessageId: repliedMessageId ?? this.repliedMessageId,
      mentionedMembers: mentionedMembers ?? this.mentionedMembers,
      pinModel: pinModel ?? this.pinModel,
      reacts: reacts ?? this.reacts,
      messageType: messageType ?? this.messageType,
      messageContent: messageContent ?? this.messageContent,
      mediaLink: mediaLink ?? this.mediaLink,
      video: video ?? this.video,
      docMessageModel: docMessageModel ?? this.docMessageModel,
      audio: audio ?? this.audio,
    );
  }

  /// *************************** FIELDS KEY ****************************

  static const String GROUP_ID = 'Group_Id';
  static const String MESSAGE_ID = 'Message_Id';
  static const String SEND_TIME = 'Send_Time';
  static const String SENDER_ID = 'Sender_Id';
  static const String SEEN_BY = 'Seen_By';
  static const String IS_DELETED = 'Is_Deleted';
  static const String IS_EDITED = 'Is_Edited';
  static const String IS_FORWARDED = 'Is_Forwarded';
  static const String FORWARD_FROM = 'Forward_From';
  static const String MESSAGE_TYPE = 'Message_Type';
  static const String MESSAGE_CONTENT = 'Message_Content';
  static const String REPLIED_MESSAGE_ID = 'Replied_Message_Id';
  static const String MEDIA_LINK = 'Media_Link';
  static const String MENTIONED_MEMBERS = 'Mentioned_Members';
  static const String PIN_MODEL = 'Pin_Model';
  static const String REACTS = 'reacts';

  /// ***************************** FUNCTIONS ****************************

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      GROUP_ID: groupId,
      MESSAGE_ID: messageId,
      SEND_TIME: sendTime,
      SENDER_ID: senderId,
      SEEN_BY: seenBy.map((e) => e.toMap()).toList(),
      IS_DELETED: isDeleted,
      IS_EDITED: isEdited,
      IS_FORWARDED: isForwarded,
      FORWARD_FROM: forwardFrom,
      MESSAGE_TYPE: messageType.index,
      MESSAGE_CONTENT: messageContent,
      REPLIED_MESSAGE_ID: repliedMessageId,
      MEDIA_LINK: mediaLink,
      MENTIONED_MEMBERS: mentionedMembers,
      PIN_MODEL: pinModel?.toMap(),
      REACTS: reacts,
    };

    if (docMessageModel != null) {
      map.addAll(docMessageModel!.toMap());
    }
    if (video != null) {
      map.addAll(video!.toMap());
    }
    if (audio != null) {
      map.addAll(audio!.toMap());
    }
    return map;
  }

  factory GroupChatMessageModel.fromMap(Map<String, dynamic> map) {
    MessageTypes messageType = MessageTypes.values[map[MESSAGE_TYPE]];

    // ✅ Parse reacts from Firestore
    List<String> parsedReacts = [];
    if (map[REACTS] != null && map[REACTS] is List) {
      parsedReacts = List<String>.from(map[REACTS]);
    }

    return GroupChatMessageModel(
      groupId: map[GROUP_ID],
      messageId: map[MESSAGE_ID],
      sendTime: map[SEND_TIME],
      senderId: map[SENDER_ID],
      seenBy: (map[SEEN_BY] as List)
          .map((e) => GroupMemberSeenModel.fromMap(e) as GroupMemberSeenModel)
          .toList(),
      isDeleted: map[IS_DELETED],
      mentionedMembers: map[MENTIONED_MEMBERS] != null
          ? List<String>.from(map[MENTIONED_MEMBERS])
          : null,
      isEdited: map[IS_EDITED],
      isForwarded: map[IS_FORWARDED],
      forwardFrom: map[FORWARD_FROM],
      messageType: MessageTypes.values[map[MESSAGE_TYPE]],
      messageContent: map[MESSAGE_CONTENT],
      repliedMessageId: map[REPLIED_MESSAGE_ID],
      mediaLink: map[MEDIA_LINK],
      pinModel:
      map[PIN_MODEL] == null ? null : PinModel.fromMap(map[PIN_MODEL]),
      video: (messageType == MessageTypes.video)
          ? VideoMessageModel.fromMap(map)
          : null,
      audio: (messageType == MessageTypes.audio)
          ? AudioMessageModel.fromMap(map)
          : null,
      docMessageModel: (messageType == MessageTypes.doc)
          ? DocMessageModel.fromMap(map)
          : null,
      reacts: parsedReacts,
    );
  }
}