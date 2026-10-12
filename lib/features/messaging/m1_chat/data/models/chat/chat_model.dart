// Date: 2/9/2024
// By: Youssef Ashraf ,Nada Mohamed
// Last update: 2/9/2024
// Objectives: This file is responsible for providing a general chat model which contains messages,media and receiver.


import '../message/message_model.dart';
import '../../../../m2_connections/data/models/member_model.dart';
import '../../../../m3_groups/data/models/legacy_group_model.dart';
import '../media/media_model.dart';

class ChatModel {
  List<MessageModel> messages;
  MediaModel mediaModel;
  // users
  Member? otherUser;
  GroupModel? groupModel;
  DateTime? createdAt;

  ChatModel({
    required this.messages,
    required this.mediaModel,
    this.otherUser,
    this.groupModel,
    this.createdAt,
  });

  ChatModel copyWith({
    List<MessageModel>? messages,
  }) {
    return ChatModel(
      messages: messages ?? this.messages,
      mediaModel: mediaModel,
    );
  }

  bool get isAllRead => messages.every((element) => element.isRead);
  bool get isDeliveredToAll => messages.every((element) => element.isDelivered);

  int get unReadMessages => messages.where((element) => !element.isRead).length;
  int get starredMessagesCount =>
      messages.where((element) => element.isStarred).length;
}
