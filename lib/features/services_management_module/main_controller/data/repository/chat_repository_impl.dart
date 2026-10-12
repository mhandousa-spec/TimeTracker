/// Module: services_management_module
/// Description: Data-layer repository implementation for service-request
///              comment threads (load / send / edit / delete comments +
///              upload attachments). Implements the ChatRepository contract
///              from domain/base_repository/chat_repository.dart.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: cloud_firestore, firebase_storage, core/network/get_base_url.dart,
///               core/network/api_constants.dart, domain/base_repository/chat_repository.dart
/// Revision History: Renamed from ChatRepository -> ChatRepositoryImpl and made
///                    to implement the new ChatRepository interface, matching
///                    the GetServiceRepositoryImpl / CreateServicesRepository
///                    pattern used elsewhere in this module (was previously a
///                    bare class with no base_repository interface).

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/chat_repository.dart'
    as base;

/// Plain data holder for a single comment, kept in the data layer so the
/// UI layer never depends on Firestore types directly.
class ChatMessageData {
  final String senderName;
  final String senderTitle;
  final String? text;
  final String? imagePath;
  final DateTime timestamp;
  final String docId;

  ChatMessageData({
    required this.senderName,
    required this.senderTitle,
    required this.text,
    required this.imagePath,
    required this.timestamp,
    required this.docId,
  });
}

class ChatRepositoryImpl implements base.ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ChatRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _comments(String modelId) {
    return firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(modelId)
        .collection('comments');
  }

  @override
  Future<List<ChatMessageData>> loadComments(String modelId) async {
    final querySnapshot = await _comments(modelId).orderBy('timestamp').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return ChatMessageData(
        senderName: data['senderName'] ?? '',
        senderTitle: data['senderTitle'] ?? '',
        text: data['text'],
        imagePath: data['imagePath'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        docId: doc.id,
      );
    }).toList();
  }

  @override
  Future<void> sendComment({
    required String modelId,
    required String senderName,
    required String senderTitle,
    required String text,
    required DateTime timestamp,
  }) async {
    await _comments(modelId).add({
      'senderName': senderName,
      'senderTitle': senderTitle,
      'text': text,
      'timestamp': timestamp,
    });
  }

  @override
  Future<void> editComment({
    required String modelId,
    required String docId,
    required String newText,
  }) async {
    await _comments(modelId).doc(docId).update({'text': newText});
  }

  @override
  Future<void> deleteComment({
    required String modelId,
    required String docId,
  }) async {
    await _comments(modelId).doc(docId).delete();
  }

  /// Uploads a local file to storage and returns its download URL.
  @override
  Future<String> uploadAttachment({
    required String fileName,
    required String filePath,
  }) async {
    final ref = storage.ref(
      '${getBaseUrl(FirestoreCollections.commentsAttachmentsStorage)}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );
    await ref.putFile(File(filePath));
    return ref.getDownloadURL();
  }

  @override
  Future<void> sendAttachmentComment({
    required String modelId,
    required String senderName,
    required String senderTitle,
    required String text,
    required String imagePath,
    required DateTime timestamp,
  }) async {
    await _comments(modelId).add({
      'senderName': senderName,
      'senderTitle': senderTitle,
      'text': text,
      'imagePath': imagePath,
      'timestamp': timestamp,
    });
  }
}
