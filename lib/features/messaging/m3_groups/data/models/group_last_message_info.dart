/// Module: messaging / groups / data/models/group_last_message_info.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_last_message_info.dart
/// Purpose: Group last message info — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';

class GroupLastMessageInfo{
  MessageTypes messageType;
  String? textMessage;
  Timestamp? lastMessageTime;
  String? messageId;
  String? senderId;


  GroupLastMessageInfo({
    required this.messageType,
    this.textMessage,
    this.lastMessageTime,
    this.messageId,
    this.senderId
  });


  static const String MESSAGE_TYPE = 'Message_Type';
  static const String TEXT_MESSAGE = 'Text_Message';
  static const String LAST_MESSAGE_TIME = 'Last_Message_Time';
  static const String MESSAGE_ID = 'Message_Id';
  static const String SENDER_ID = 'Sender_Id';




  Map<String, dynamic> toMap() {
    return {
      MESSAGE_TYPE: messageType.index,
      TEXT_MESSAGE: textMessage,
      LAST_MESSAGE_TIME: lastMessageTime,
      MESSAGE_ID: messageId ,
      SENDER_ID: senderId
    };
  }

  factory GroupLastMessageInfo.fromMap(Map<String, dynamic> map) {
    return GroupLastMessageInfo(
      messageType: MessageTypes.values[map[MESSAGE_TYPE]],
      textMessage: map[TEXT_MESSAGE],
      lastMessageTime: map[LAST_MESSAGE_TIME],
      messageId: map[MESSAGE_ID],
      senderId: map[SENDER_ID]
    );
  }

}