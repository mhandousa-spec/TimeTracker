/// Module: messaging / chat / data/models/message/message_model.dart
// By: Nada Mohammed , Youssef Ashraf

import 'dart:io';

import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import '../location_message_model.dart';
import '../../../domain/enum/reacts.dart';
import './audio_message_model.dart';
import './doc_message_model.dart';
import './poll_message_model.dart';
import './video_message_model.dart';

/// §10 — model purity: all data fields are `final`; mutations go through
/// [copyWith] (which is lossless), and (de)serialization uses static-const
/// keys with no inline string literals.
class MessageModel {
  final AudioMessageModel? audioModel;
  final VideoMessageModel? videoModel;
  final PollMessageModel? pollModel;
  final DocMessageModel? docModel;
  final MessageModel? replyMessageModel;
  final int? index;
  final LocationMessageModel? locationModel;
  final String? message;
  final File? image;
  final bool isMeLastMessage;
  final DateTime sentDate;
  late final String sentTime;
  final bool isDelivered;
  final bool isRead;
  final bool isOtherUserTyping;
  final String sentUserID;
  final String? sentUserImage;
  final bool isStarred;
  final bool? isEdited;
  final bool? isDeleted;
  final bool? isForwarded;
  final List<Reacts> reacts;

  // Serialization keys (§10 — no inline string literals in (de)serialization).
  static const String messageKey = 'message';
  static const String isMeLastMessageKey = 'isMeLastMessage';
  static const String sentTimeKey = 'sentTime';
  static const String sentDateKey = 'sentDate';
  static const String sentUserIDKey = 'sentUserID';
  static const String isDeliveredKey = 'isDelivered';
  static const String isReadKey = 'isRead';

//Backend: Add Member id
  MessageModel({
    this.message,
    required this.isMeLastMessage, // for coloring and styling the message bubble
    required this.sentUserID,
    required this.sentDate,
    this.isOtherUserTyping = false,
    this.isDelivered = false,
    this.isRead = false,
    this.image,
    this.audioModel,
    this.docModel,
    this.pollModel,
    this.videoModel,
    this.sentUserImage,
    this.locationModel,
    this.replyMessageModel,
    this.reacts = const [Reacts.clap, Reacts.love],
    this.isStarred = false,
    this.index,
    this.isEdited,
    this.isDeleted,
    this.isForwarded,
  }) {
    sentTime = DateTimeHelper.formatTime(sentDate);
  }

  /// Lossless copy — every field is carried over unless explicitly overridden,
  /// so routing in-place mutations through [copyWith] never drops data.
  MessageModel copyWith({
    String? message,
    bool? isMeLastMessage,
    bool? isDelivered,
    bool? isRead,
    bool? isOtherUserTyping,
    String? sentUserID,
    String? sentUserImage,
    bool? isStarred,
    File? image,
    AudioMessageModel? audioModel,
    VideoMessageModel? videoModel,
    PollMessageModel? pollModel,
    DocMessageModel? docModel,
    LocationMessageModel? locationModel,
    MessageModel? replyMessageModel,
    DateTime? sentDate,
    int? index,
    bool? isEdited,
    bool? isDeleted,
    bool? isForwarded,
    List<Reacts>? reacts,
  }) {
    return MessageModel(
      message: message ?? this.message,
      sentDate: sentDate ?? this.sentDate,
      isMeLastMessage: isMeLastMessage ?? this.isMeLastMessage,
      isDelivered: isDelivered ?? this.isDelivered,
      isRead: isRead ?? this.isRead,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
      sentUserID: sentUserID ?? this.sentUserID,
      sentUserImage: sentUserImage ?? this.sentUserImage,
      isStarred: isStarred ?? this.isStarred,
      image: image ?? this.image,
      audioModel: audioModel ?? this.audioModel,
      videoModel: videoModel ?? this.videoModel,
      pollModel: pollModel ?? this.pollModel,
      docModel: docModel ?? this.docModel,
      locationModel: locationModel ?? this.locationModel,
      replyMessageModel: replyMessageModel ?? this.replyMessageModel,
      index: index ?? this.index,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isForwarded: isForwarded ?? this.isForwarded,
      reacts: reacts ?? this.reacts,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      messageKey: message,
      isMeLastMessageKey: isMeLastMessage,
      sentTimeKey: sentTime,
      isDeliveredKey: isDelivered,
      isReadKey: isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      sentUserID: map[sentUserIDKey] as String,
      message: map[messageKey] as String,
      sentDate: map[sentDateKey] as DateTime,
      isMeLastMessage: map[isMeLastMessageKey] as bool,
      isDelivered: map[isDeliveredKey] as bool,
      isRead: map[isReadKey] as bool,
    );
  }
}
