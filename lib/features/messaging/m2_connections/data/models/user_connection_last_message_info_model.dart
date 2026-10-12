/// Module: messaging / connections / data/models/user_connection_last_message_info_model.dart
/// ************************* FILE INFO *************************** ///
/// File Name: user_connection_last_message_info_model.dart
/// Purpose: User connection last message info model — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';

class UserConnectionLastMessageInfoModel{
  MessageTypes messageType;
  bool? isLastMessageSenderCurrentUser;
  String? textMessage;
  int? myUnreadMessagesCount;
  int otherUnreadMessagesCount;
  Timestamp? lastMessageTime;
  String? messageId;


  UserConnectionLastMessageInfoModel({
    required this.messageType,
    this.isLastMessageSenderCurrentUser,
    this.textMessage,
    required this.myUnreadMessagesCount,
    required this.otherUnreadMessagesCount,
    this.lastMessageTime,
    this.messageId,
  });


  static const String MESSAGE_TYPE = 'Message_Type';
  static const String IS_LAST_MESSAGE_SENDER_CURRENT_USER =
      'Is_Last_Message_Sender_Current_User';
  static const String TEXT_MESSAGE = 'Text_Message';
  static const String MY_UNREAD_MESSAGES_COUNT = 'My_Unread_Messages_Count';
  static const String OTHER_UNREAD_MESSAGES_COUNT = 'Other_Unread_Messages_Count';
  static const String LAST_MESSAGE_TIME = 'Last_Message_Time';
  static const String MESSAGE_ID = 'Message_Id';




  Map<String, dynamic> toMap() {
    return {
      MESSAGE_TYPE: messageType.index,
      IS_LAST_MESSAGE_SENDER_CURRENT_USER: isLastMessageSenderCurrentUser,
      TEXT_MESSAGE: textMessage,
      MY_UNREAD_MESSAGES_COUNT: myUnreadMessagesCount,
      LAST_MESSAGE_TIME: lastMessageTime,
      OTHER_UNREAD_MESSAGES_COUNT: otherUnreadMessagesCount,
      MESSAGE_ID: messageId ,
    };
  }

  factory UserConnectionLastMessageInfoModel.fromMap(Map<String, dynamic> map) {
    return UserConnectionLastMessageInfoModel(
      messageType: MessageTypes.values[map[MESSAGE_TYPE]],
      isLastMessageSenderCurrentUser: map[IS_LAST_MESSAGE_SENDER_CURRENT_USER],
      textMessage: map[TEXT_MESSAGE],
      myUnreadMessagesCount: map[MY_UNREAD_MESSAGES_COUNT],
      otherUnreadMessagesCount: map[OTHER_UNREAD_MESSAGES_COUNT],
      lastMessageTime: map[LAST_MESSAGE_TIME],
      messageId: map[MESSAGE_ID],
    );
  }
}