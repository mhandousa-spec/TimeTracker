/// Module: messaging / home / domain/entity/chat_type_entity.dart
/// ************************* FILE INFO *************************** ///
/// File Name: chat_type_entity.dart
/// Purpose: Chat type entity — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';

class ChatTypeEntity{
  String imageUri;
  String primaryLanguageName;
  String? secondaryLanguageName;
  int myNumUnreadMessage;
  bool isLastMessageSenderIsCurrentUser;
  bool isSeen;
  Timestamp? lastMessageTime;
  MessageTypes messageType;
  String? messageContent;
  String otherSideId;


  ChatTypeEntity({
    required this.myNumUnreadMessage,
    required this.isLastMessageSenderIsCurrentUser,
    required this.isSeen,
    required this.lastMessageTime,
    required this.messageType,
    required this.messageContent,
    required this.otherSideId,
    required this.imageUri,
    required this.primaryLanguageName,
    this.secondaryLanguageName


  });

}
