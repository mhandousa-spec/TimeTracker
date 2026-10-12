/// Module: messaging / chat / domain/use_cases/single_connection_usecases/send_text_message_use_case.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../../core/helper/message_module/interface/controller/messaging_init_controller.dart';
import '../../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../m2_connections/data/models/user_connection_last_message_info_model.dart';
import '../../../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../../data/models/single_chat_message_model.dart';
import '../../repository/chat_repository/base_chat_repository.dart';

class SendTextMessageUseCase {
  final BaseChatRepository chatRepository;

  SendTextMessageUseCase(this.chatRepository);

  Timestamp messageTime = Timestamp.now();

  Future<Either<Failure, void>> execute(
      {required String messageText,
        required BaseMessagingInterfaceParameters currentUser,
        required ChatTypeEntity otherUser,
        String? repliedMessageId,
        String? previewText}) async {
    messageTime = Timestamp.now();
    otherUser as SingleConnectionEntity;

    // ✅ Use previewText (plain) for last message info, messageText (encrypted) for message content
    final displayText = previewText ?? messageText;

    SingleChatMessageModel message = createMessageModel(otherUser.connectionId,
        messageText, currentUser, otherUser, repliedMessageId);
    UserConnectionLastMessageInfoModel senderConnectionInfo =
    createSenderConnectionModel(
        otherUser: otherUser,
        message: displayText,
        otherUnreadMessagesCount: otherUser.otherNumUnreadMessage ?? 0,
        messageId: message.messageId);
    UserConnectionLastMessageInfoModel receiverConnectionInfo =
    createReceiverConnectionModel(
        messageId: message.messageId,
        currentUser: currentUser,
        message: displayText,
        unreadMessagesCount: otherUser.otherNumUnreadMessage ?? 0);
    Either<Failure, dynamic> response = await chatRepository.sendMessage(
        messageModel: message,
        currentUserConnectionModel: senderConnectionInfo,
        otherUserConnectionModel: receiverConnectionInfo);
    if (response.isLeft()) return response;
    Get.find<MessagingInitController>()
        .messagingConfigurations
        .sendNotification
        .call(
        targetAudienceIds: [otherUser.userId],
        englishBody:
        '${currentUser.primaryLanguageName} sends you a ${message.messageType.messagePrimaryLanguageName}',
        englishTitle: 'New Message',
        arabicBody:
        '${currentUser.secondaryLanguageName} أرسل لك ${message.messageType.messageArabicName}',
        arabicTitle: 'رسالة جديدة',
        payload: <String, String>{
          "Chat_Id": otherUser.connectionId,
          "Sender_Id": currentUser.userId,
          "Receiver_Id": otherUser.userId,
        });

    return response;
  }

  createMessageModel(
      String connectionId,
      String messageText,
      BaseMessagingInterfaceParameters currentUser,
      SingleConnectionEntity otherUser,
      String? repliedMessageId) {
    return SingleChatMessageModel(
      chatId: connectionId,
      messageId: "${currentUser.userId} . $messageTime",
      messageContent: messageText,
      messageType: MessageTypes.text,
      senderId: currentUser.userId,
      receiverId: otherUser.userId,
      sendTime: messageTime,
      isSeen: false,
      isDeleted: false,
      isEdited: false,
      isForwarded: false,
      repliedMessageId: repliedMessageId,
    );
  }

  UserConnectionLastMessageInfoModel createSenderConnectionModel({
    required SingleConnectionEntity otherUser,
    required String message,
    required int otherUnreadMessagesCount,
    required String messageId,
  }) {
    return UserConnectionLastMessageInfoModel(
      myUnreadMessagesCount: 0,
      otherUnreadMessagesCount: otherUnreadMessagesCount + 1,
      messageType: MessageTypes.text,
      textMessage: message,
      lastMessageTime: messageTime,
      isLastMessageSenderCurrentUser: true,
      messageId: messageId,
    );
  }

  UserConnectionLastMessageInfoModel createReceiverConnectionModel({
    required BaseMessagingInterfaceParameters currentUser,
    required String message,
    required int unreadMessagesCount,
    required String messageId,
  }) {
    return UserConnectionLastMessageInfoModel(
      myUnreadMessagesCount: unreadMessagesCount + 1,
      otherUnreadMessagesCount: 0,
      messageType: MessageTypes.text,
      textMessage: message,
      lastMessageTime: messageTime,
      isLastMessageSenderCurrentUser: false,
      messageId: messageId,
    );
  }
}