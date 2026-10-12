/// Module: messaging / chat / data/repository/single_chat_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/constants/message_module/api_constants.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../m2_connections/data/models/user_connection_last_message_info_model.dart';
import '../../../m2_connections/data/models/users_connection_model.dart';
import '../../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../domain/entity/new_message_content_entity.dart';
import '../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../domain/enum/reacts.dart';
import 'react_writer.dart';
import '../data_source/single_chat_remote_data_source.dart';
import '../models/single_chat_message_model.dart';
import '../models/sub_models/pin_model.dart';

class SingleChatRepository implements BaseChatRepository {
  final SingleChatRemoteDataSource chatRemoteDataSource =
  SingleChatRemoteDataSource();

  Timestamp _messageTime = Timestamp.now();

  @override
  Future<Either<Failure, void>> sendMessage({
    required SingleChatMessageModel messageModel,
    required UserConnectionLastMessageInfoModel currentUserConnectionModel,
    required UserConnectionLastMessageInfoModel otherUserConnectionModel,
  }) async {
    return await chatRemoteDataSource.sendSingleChatMessage(
      chatId: messageModel.chatId,
      messageId: messageModel.messageId,
      messageData: messageModel,
      currentUserConnectionModel: currentUserConnectionModel,
      otherUserConnectionModel: otherUserConnectionModel,
    );
  }

  @override
  Stream<Either<Failure, dynamic>> getChatMessages(String chatId) async* {
    Stream<Either<Failure, List<Map<String, dynamic>>>> stream =
    chatRemoteDataSource.getChatMessages(chatId: chatId);
    await for (final chatMessage in stream) {
      if (chatMessage.isLeft()) {
        yield chatMessage;
        return;
      }
      List<Map<String, dynamic>> messages = chatMessage.getOrElse(() => []);
      List<SingleChatMessageModel> messageEntities = [];
      // FIXED 24/9/2026 — realtime: one malformed/half-written message doc
      // used to throw here, which terminated this async* stream, so the chat
      // stopped receiving new messages until the app was restarted. Bad docs
      // are now skipped and the live listener keeps running.
      for (var message in messages) {
        try {
          messageEntities.add(SingleChatMessageModel.fromMap(message));
        } catch (e) {
          debugPrint('⚠️ skipped malformed single chat message ($e): $message');
        }
      }
      yield Right(messageEntities);
    }
  }

  @override
  updateMyNumOfUnreadMessages({
    required String currentUserId,
    required String otherUserId,
    required int newValue,
  }) async {
    return await chatRemoteDataSource.updateMyNumOfUnreadMessages(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        newValue: newValue);
  }

  @override
  updateMessagesAsSeen({
    required List<String> unSeenMessagesIds,
    required String chatId,
    String? currentUserId,
  }) async {
    return await chatRemoteDataSource.updateMessagesAsSeen(
        unSeenMessagesIds: unSeenMessagesIds, chatId: chatId);
  }

  @override
  editTextMessage({
    required String newMessageText,
    required String messageId,
    required String chatId,
    required String otherId,
    required String currentUserId,
  }) async {
    return await chatRemoteDataSource.editTextMessage(
      newMessageText: newMessageText,
      messageId: messageId,
      chatId: chatId,
      otherId: otherId,
      currentUserId: currentUserId,
    );
  }

  @override
  deleteMessage({
    required String messageId,
    required String chatId,
    required String otherId,
    required String currentUserId,
  }) async {
    return await chatRemoteDataSource.deleteMessage(
      messageId: messageId,
      chatId: chatId,
      otherId: otherId,
      currentUserId: currentUserId,
    );
  }

  @override
  sendNewMessage({
    required BaseMessagingInterfaceParameters currentUser,
    required ChatTypeEntity otherConnectionSide,
    required NewMessageContentEntity messageContent,
  }) async {
    otherConnectionSide as SingleConnectionEntity;
    _messageTime = Timestamp.now();

    SingleChatMessageModel messageModel = await _createMessageModel(
        otherUser: otherConnectionSide,
        messageContent: messageContent,
        currentUser: currentUser);

    UserConnectionLastMessageInfoModel senderConnectionModel =
    _createSenderConnectionModel(
      otherUser: otherConnectionSide,
      messageContent: messageContent,
      otherUnreadMessagesCount: otherConnectionSide.otherNumUnreadMessage,
      messageId: messageModel.messageId,
    );

    UserConnectionLastMessageInfoModel receiverConnectionModel =
    _createReceiverConnectionModel(
        currentUser: currentUser,
        messageContent: messageContent,
        unreadMessagesCount: otherConnectionSide.otherNumUnreadMessage,
        messageId: messageModel.messageId);

    return await sendMessage(
      messageModel: messageModel,
      currentUserConnectionModel: senderConnectionModel,
      otherUserConnectionModel: receiverConnectionModel,
    );
  }

  @override
  updateMessagePinState({
    required String messageId,
    required chatId,
    required currentUserId,
    required bool state,
  }) async {
    final dynamic result = await chatRemoteDataSource.getMessage(
      messageId,
      chatId,
    );

    if (result is Left) {
      return;
    }

    final raw = (result as Either).getOrElse(() => null);

    if (raw == null) {
      return;
    }

    SingleChatMessageModel messageModel =
    SingleChatMessageModel.fromMap(raw as Map<String, dynamic>);

    // §10 — pinModel is final; seed it via copyWith when absent, then mutate
    // the PinModel's own lists (that's the PinModel's state, not this model's).
    if (messageModel.pinModel == null) {
      messageModel = messageModel.copyWith(
          pinModel: PinModel(isPinned: [], userId: [], pinnedAt: []));
    }
    messageModel.pinModel!.isPinned.add(state);
    messageModel.pinModel!.userId.add(currentUserId);
    messageModel.pinModel!.pinnedAt.add(Timestamp.now());

    await chatRemoteDataSource.updateMessage(messageId, chatId, messageModel);
  }

  // ✅ FIXED: use correct Firestore path from ApiConstants
  @override
  Future<Either<Failure, void>> addReact({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required Reacts react,
  }) async {
    try {
      final collectionPath =
          "${ApiConstants.singleChatMessages}/$chatId/${ApiConstants.messages}";

      // One reaction per user; changing it replaces the old one
      // (bug report #24). See ReactWriter.
      await ReactWriter.setReact(
        messageRef: FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(messageId),
        userId: currentUserId,
        react: react,
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  UserConnectionLastMessageInfoModel _createSenderConnectionModel({
    required SingleConnectionEntity otherUser,
    required NewMessageContentEntity messageContent,
    required int otherUnreadMessagesCount,
    required String messageId,
  }) {
    return UserConnectionLastMessageInfoModel(
      myUnreadMessagesCount: 0,
      otherUnreadMessagesCount: otherUnreadMessagesCount + 1,
      messageType: messageContent.messageType,
      textMessage: messageContent.messageType == MessageTypes.text
          ? (messageContent as TextMessageContentEntity).messageContent
          : null,
      lastMessageTime: _messageTime,
      isLastMessageSenderCurrentUser: true,
      messageId: messageId,
    );
  }

  UserConnectionLastMessageInfoModel _createReceiverConnectionModel({
    required BaseMessagingInterfaceParameters currentUser,
    required NewMessageContentEntity messageContent,
    required int unreadMessagesCount,
    required String messageId,
  }) {
    return UserConnectionLastMessageInfoModel(
      myUnreadMessagesCount: unreadMessagesCount + 1,
      otherUnreadMessagesCount: 0,
      messageType: messageContent.messageType,
      textMessage: messageContent.messageType == MessageTypes.text
          ? (messageContent as TextMessageContentEntity).messageContent
          : null,
      lastMessageTime: _messageTime,
      isLastMessageSenderCurrentUser: false,
      messageId: messageId,
    );
  }

  _createMessageModel({
    required SingleConnectionEntity otherUser,
    required NewMessageContentEntity messageContent,
    required BaseMessagingInterfaceParameters currentUser,
  }) async {
    String? mediaLink;

    if (messageContent.messageType == MessageTypes.cameraImage) {
      messageContent as ImageMessageContentEntity;
      Either<Failure, String> uploadImageResult =
      await chatRemoteDataSource.uploadImage(
          documentName: messageContent.filePath.split('/').last,
          filePath: messageContent.filePath);
      if (uploadImageResult.isLeft()) return null;
      mediaLink = uploadImageResult.getOrElse(() => '');
    }
    if (messageContent.messageType == MessageTypes.doc) {
      messageContent as DocumentMessageContentEntity;
      Either<Failure, String> uploadDocResult = await chatRemoteDataSource
          .uploadMedia(filePath: messageContent.documentMessageModel.docPath);
      if (uploadDocResult.isLeft()) return null;
      mediaLink = uploadDocResult.getOrElse(() => '');
      messageContent.documentMessageModel.docPath = mediaLink;
    }
    if (messageContent.messageType == MessageTypes.audio) {
      messageContent as AudioMessageContentEntity;
      Either<Failure, String> uploadDocResult = await chatRemoteDataSource
          .uploadMedia(filePath: messageContent.audio.audioPath);
      if (uploadDocResult.isLeft()) return null;
      mediaLink = uploadDocResult.getOrElse(() => '');
      messageContent.audio.audioPath = mediaLink;
    }
    if (messageContent.messageType == MessageTypes.video) {
      messageContent as VideoMessageContentEntity;
      Either<Failure, String> uploadDocResult = await chatRemoteDataSource
          .uploadMedia(filePath: messageContent.video.videoFilePath);
      if (uploadDocResult.isLeft()) return null;
      mediaLink = uploadDocResult.getOrElse(() => '');
      messageContent.video.videoFilePath = mediaLink;
    }

    return SingleChatMessageModel(
      chatId: otherUser.connectionId,
      messageId: "${currentUser.userId} . $_messageTime",
      mediaLink: mediaLink,
      messageContent: _getMessageTextContent(content: messageContent),
      messageType: messageContent.messageType,
      senderId: currentUser.userId,
      receiverId: otherUser.userId,
      sendTime: _messageTime,
      audioMessageModel: (messageContent.messageType == MessageTypes.audio)
          ? (messageContent as AudioMessageContentEntity).audio
          : null,
      videoMessageModel: (messageContent.messageType == MessageTypes.video)
          ? (messageContent as VideoMessageContentEntity).video
          : null,
      docMessageModel: (messageContent.messageType == MessageTypes.doc)
          ? (messageContent as DocumentMessageContentEntity).documentMessageModel
          : null,
      isSeen: false,
      isDeleted: false,
      isEdited: false,
      isForwarded: false,
      repliedMessageId: messageContent.repliedMessageId,
    );
  }

  _getMessageTextContent({required NewMessageContentEntity content}) {
    if (content.messageType == MessageTypes.text) {
      content as TextMessageContentEntity;
      return content.messageContent;
    }
    if (content.messageType == MessageTypes.cameraImage) {
      content as ImageMessageContentEntity;
      return content.caption;
    }
    // Bug report #23 — location / contact travel as JSON in the content.
    if (content is LocationMessageContentEntity) {
      return content.location.encode();
    }
    if (content is ContactMessageContentEntity) {
      return content.contact.encode();
    }
    // Poll (Figma 6799:5666) — JSON in the content, like location / contact.
    if (content is PollMessageContentEntity) {
      return content.poll.encode();
    }
    return null;
  }
}