/// Module: services_management_module
/// Description: Abstract repository contract for service-request comment
///              threads (load / send / edit / delete comments + upload
///              attachments). Implemented by data/repository/chat_repository_impl.dart.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: dart:io (File), ChatMessageData (data/repository/chat_repository_impl.dart)
/// Revision History: Initial version — extracted so ChatRepositoryImpl has a
///                    base_repository interface like the other repos in this module.

import 'dart:io';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/chat_repository_impl.dart';

abstract class ChatRepository {
  Future<List<ChatMessageData>> loadComments(String modelId);

  Future<void> sendComment({
    required String modelId,
    required String senderName,
    required String senderTitle,
    required String text,
    required DateTime timestamp,
  });

  Future<void> editComment({
    required String modelId,
    required String docId,
    required String newText,
  });

  Future<void> deleteComment({
    required String modelId,
    required String docId,
  });

  /// Uploads a local file to storage and returns its download URL.
  Future<String> uploadAttachment({
    required String fileName,
    required String filePath,
  });

  Future<void> sendAttachmentComment({
    required String modelId,
    required String senderName,
    required String senderTitle,
    required String text,
    required String imagePath,
    required DateTime timestamp,
  });
}
