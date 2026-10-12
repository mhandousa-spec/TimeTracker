/// Module: messaging / chat / domain/use_cases/single_connection_usecases/get_single_chat_messages_use_case.dart
import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/file_handler.dart';
import '../../../data/models/message/video_message_model.dart';
import '../../entity/message_entity.dart';
import '../../repository/chat_repository/base_chat_repository.dart';

class GetSingleChatMessages {
  final BaseChatRepository repository;
  GetSingleChatMessages({required this.repository});

  // ✅ FIX: added currentUserId parameter
  execute(String chatId, {required String currentUserId}) async* {
    Stream<Either<Failure, dynamic>> chatMessages =
    repository.getChatMessages(chatId);
    await for (final chatMessage in chatMessages) {
      Either<Failure, List<MessageEntity>> messages;
      if (chatMessage.isLeft()) {
        Failure? failure = chatMessage.fold((l) => l, (r) => null);
        messages = Left(failure!);
        yield messages;
        return;
      }
      yield* _getMessageEntities(
        fetchedMessages: chatMessage.getOrElse(() => []),
        chatId: chatId,
        currentUserId: currentUserId, // ✅ pass through
      );
    }
  }

  _getMessageEntities({
    required fetchedMessages,
    required String chatId,
    required String currentUserId, // ✅ added
  }) async* {
    Either<Failure, List<MessageEntity>> result;
    List<MessageEntity> messageEntities = [];
    Map<String, MessageEntity> messages = {};
    for (var message in fetchedMessages) {
      // FIXED 24/9/2026 — realtime. Any throw in here (a bad doc, a media
      // download that fails) used to end the whole async* stream, and a
      // download that never answered blocked it forever — either way the
      // receiver stopped seeing new messages until the app was restarted.
      // A failing message is now skipped / shown without its local file, and
      // the live listener keeps running.
      MessageEntity? entity;
      try {
        // ✅ FIX: pass currentUserId as third argument
        entity = message.toMessageEntity(chatId, messages, currentUserId);
      } catch (e) {
        entity = null;
      }
      if (entity == null) continue;
      messages[message.messageId] = entity;
      await _safeHandleMediaMessage(entity);
      messageEntities.add(entity);
    }
    result = Right(messageEntities);
    yield result;
  }

  /// Media download must never block or break the live message stream.
  Future<void> _safeHandleMediaMessage(MessageEntity message) async {
    try {
      await handleMediaMessage(message: message)
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      // Keep the remote link; the bubble can still show / retry it.
    }
  }

  Future<void> handleMediaMessage({required MessageEntity message}) async {
    if (message.messageType == MessageTypes.audio) {
      File file = await FileHandler().downloadFile(
          message.audio!.audioPath,
          message.time.toString() +
              '.' +
              message.audio!.audioPath.split('.').last.split('?').first);
      message.audio!.audioPath = file.path;
      message.mediaLink = message.audio!.audioPath;
    }
    if (message.messageType == MessageTypes.doc) {
      File file = await FileHandler().downloadFile(
          message.docMessageModel!.docPath,
          message.time.toString() + message.docMessageModel!.fileName!);

      message.docMessageModel!.docPath = file.path;
      message.mediaLink = message.docMessageModel!.docPath;
    }
    if (message.messageType == MessageTypes.video) {
      File file = await FileHandler().downloadFile(
          message.videoMessageModel!.videoFilePath,
          message.time.toString() +
              '.' +
              message.videoMessageModel!.videoFilePath
                  .split('.')
                  .last
                  .split('?')
                  .first);
      message.videoMessageModel!.videoFilePath = file.path;
      VideoMessageModel videoMessageModel = VideoMessageModel(
          videoFilePath: message.videoMessageModel!.videoFilePath);
      message.mediaLink = message.videoMessageModel!.videoFilePath;
      message.videoMessageModel = videoMessageModel;
    }
  }
}