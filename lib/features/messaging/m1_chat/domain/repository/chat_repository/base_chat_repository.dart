/// Module: messaging / chat / domain/repository/chat_repository/base_chat_repository.dart
import 'package:dartz/dartz.dart';
import '../../enum/reacts.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import '../../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../m2_connections/data/models/user_connection_last_message_info_model.dart';
import '../../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../../data/models/single_chat_message_model.dart';
import '../../entity/new_message_content_entity.dart';

abstract interface class BaseChatRepository {
  Future<Either<Failure, void>> sendMessage({
    required SingleChatMessageModel messageModel,
    required UserConnectionLastMessageInfoModel currentUserConnectionModel,
    required UserConnectionLastMessageInfoModel otherUserConnectionModel,
  });

  getChatMessages(String chatId);

  updateMyNumOfUnreadMessages({
    required String currentUserId,
    required String otherUserId,
    required int newValue,
  });

  updateMessagesAsSeen({
    required List<String> unSeenMessagesIds,
    required String chatId,
    String? currentUserId,
  });

  editTextMessage({
    required String newMessageText,
    required String messageId,
    required String chatId,
    required String otherId,
    required String currentUserId,
  });

  deleteMessage({
    required String messageId,
    required String chatId,
    required String otherId,
    required String currentUserId,
  });

  sendNewMessage({
    required BaseMessagingInterfaceParameters currentUser,
    required ChatTypeEntity otherConnectionSide,
    required NewMessageContentEntity messageContent,
  });

  updateMessagePinState({
    required String messageId,
    required chatId,
    required currentUserId,
    required bool state,
  });

  // ✅ Add or toggle a reaction on a message
  Future<Either<Failure, void>> addReact({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required Reacts react,
  });
}