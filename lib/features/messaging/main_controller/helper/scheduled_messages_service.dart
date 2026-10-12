/// Module: messaging / main_controller / helper / scheduled_messages_service.dart
/// ************************* FILE INFO *************************** ///
/// File Name: scheduled_messages_service.dart
/// Purpose: Schedule Message (Figma 6799:16821) and scheduled polls
///          (Figma 6799:5666 → "Scheduled").
/// Author: Knowticed Team
/// Created At: 30/9/2026
///
/// STORAGE
/// -------
///   Messaging_Scheduled_Messages/{autoId}
///     Sender_Id, Chat_Key, Is_Group, Target_Id, Target_Name,
///     Text?, Attachment_Path?, Poll? (PollPayload json),
///     Send_At (Timestamp), Status (pending|sending|sent|failed), Created_At
///
/// DISPATCH
/// --------
/// Messages are sent by the sender's app: [startDispatcher] checks every 30s
/// (and once on start) for due messages and sends them through the normal
/// chat repositories, so they are encrypted and appear exactly like a message
/// typed by hand. A message that became due while the app was closed is sent
/// the next time the app opens. (A server-side Cloud Function would be
/// needed to send while the app is closed.)
library;

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' show Left;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../core/helper/message_module/main_helper/incrption.dart';
import '../../m1_chat/data/models/message/doc_message_model.dart';
import '../../m1_chat/data/repository/group_chat_repository.dart';
import '../../m1_chat/data/repository/single_chat_repository.dart';
import '../../m1_chat/domain/entity/new_message_content_entity.dart';
import '../../m1_chat/domain/repository/chat_repository/base_chat_repository.dart';
import '../../m1_chat/presentation/controller/message_types_controllers/text_message_cubit.dart';
import '../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../m2_connections/presentation/controller/connections_controller.dart';
import '../../m3_groups/domain/entities/group_entity.dart';
import '../../m3_groups/presentation/controller/groups_controller.dart';
import '../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../notifications/messages_notification_service.dart';

class ScheduledMessagesService {
  ScheduledMessagesService._();

  static const String collection = 'Messaging_Scheduled_Messages';

  static const String senderIdKey = 'Sender_Id';
  static const String chatKeyKey = 'Chat_Key';
  static const String isGroupKey = 'Is_Group';
  static const String targetIdKey = 'Target_Id';
  static const String targetNameKey = 'Target_Name';
  static const String textKey = 'Text';
  static const String attachmentPathKey = 'Attachment_Path';
  static const String pollKey = 'Poll';
  static const String sendAtKey = 'Send_At';
  static const String statusKey = 'Status';
  static const String createdAtKey = 'Created_At';

  static const String pending = 'pending';
  static const String sending = 'sending';
  static const String sent = 'sent';
  static const String failed = 'failed';

  static String _norm(String id) => id.trim().toLowerCase();

  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection(collection);

  // ── Create ───────────────────────────────────────────────────────────────

  /// Stores a message to be sent at [sendAt]. At least one of [text],
  /// [attachmentPath] or [poll] must be given. Returns true on success.
  static Future<bool> schedule({
    required String senderId,
    required String chatKey,
    required bool isGroup,
    required String targetId,
    required String targetName,
    required DateTime sendAt,
    String? text,
    String? attachmentPath,
    PollPayload? poll,
  }) async {
    final bool hasText = text != null && text.trim().isNotEmpty;
    final bool hasFile = attachmentPath != null && attachmentPath.isNotEmpty;
    if (!hasText && !hasFile && poll == null) return false;
    try {
      await _col.add(<String, dynamic>{
        senderIdKey: _norm(senderId),
        chatKeyKey: chatKey,
        isGroupKey: isGroup,
        targetIdKey: isGroup ? targetId : _norm(targetId),
        targetNameKey: targetName,
        textKey: hasText ? text.trim() : null,
        attachmentPathKey: hasFile ? attachmentPath : null,
        pollKey: poll?.encode(),
        sendAtKey: Timestamp.fromDate(sendAt),
        statusKey: pending,
        createdAtKey: FieldValue.serverTimestamp(),
      });
      debugPrint('[Scheduled] ✓ scheduled for $chatKey at $sendAt');
      // Something may already be due (a time in the past was picked).
      unawaited(_dispatchDue());
      return true;
    } catch (e) {
      debugPrint('[Scheduled] ✗ schedule failed: $e');
      return false;
    }
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  /// The next pending send time of [senderId]'s messages in [chatKey], or
  /// null when none. Drives the yellow "Scheduled Message: …" banner.
  ///
  /// Only equality filters are used (no composite index needed); the
  /// earliest time is picked on the client.
  static Stream<DateTime?> nextFor(String chatKey, String senderId) {
    return _col
        .where(chatKeyKey, isEqualTo: chatKey)
        .where(senderIdKey, isEqualTo: _norm(senderId))
        .where(statusKey, isEqualTo: pending)
        .snapshots()
        .map((snap) {
      DateTime? next;
      for (final d in snap.docs) {
        final Object? at = d.data()[sendAtKey];
        if (at is! Timestamp) continue;
        final DateTime t = at.toDate();
        if (next == null || t.isBefore(next)) next = t;
      }
      return next;
    }).handleError((Object e) {
      debugPrint('[Scheduled] ✗ nextFor($chatKey) failed: $e');
    });
  }

  // ── Dispatch ─────────────────────────────────────────────────────────────

  static Timer? _timer;
  static String? _dispatchUser;
  static bool _running = false;

  /// Starts sending [userId]'s due messages. Safe to call again (e.g. after
  /// an account switch) — the previous dispatcher is stopped first.
  static void startDispatcher(String userId) {
    stopDispatcher();
    _dispatchUser = _norm(userId);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _dispatchDue());
    unawaited(_dispatchDue());
  }

  static void stopDispatcher() {
    _timer?.cancel();
    _timer = null;
    _dispatchUser = null;
  }

  static Future<void> _dispatchDue() async {
    final String? me = _dispatchUser;
    if (me == null || _running) return;
    _running = true;
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _col
          .where(senderIdKey, isEqualTo: me)
          .where(statusKey, isEqualTo: pending)
          .get();
      final DateTime now = DateTime.now();
      for (final doc in snap.docs) {
        if (_dispatchUser != me) break; // account switched meanwhile
        final Object? at = doc.data()[sendAtKey];
        if (at is! Timestamp || at.toDate().isAfter(now)) continue;
        if (!await _claim(doc.reference)) continue;
        final bool ok = await _send(doc.data());
        await doc.reference
            .update(<String, dynamic>{statusKey: ok ? sent : failed});
        if (ok) {
          unawaited(MessagesNotificationService.notifyScheduledMessageSent(
            recipientName: (doc.data()[targetNameKey] ?? '').toString(),
          ));
        }
      }
    } catch (e) {
      debugPrint('[Scheduled] ✗ dispatch failed: $e');
    } finally {
      _running = false;
    }
  }

  /// pending → sending, so two devices of the same user never both send it.
  static Future<bool> _claim(DocumentReference<Map<String, dynamic>> ref) {
    return FirebaseFirestore.instance.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      if (snap.data()?[statusKey] != pending) return false;
      tx.update(ref, <String, dynamic>{statusKey: sending});
      return true;
    }).catchError((Object e) {
      debugPrint('[Scheduled] ✗ claim failed: $e');
      return false;
    });
  }

  static Future<bool> _send(Map<String, dynamic> data) async {
    if (!Get.isRegistered<ConnectionsCubit>()) return false;
    final ConnectionsCubit connections = Get.find<ConnectionsCubit>();
    if (!connections.isCurrentUserInitialized) return false;

    final bool isGroup = data[isGroupKey] == true;
    final String targetId = (data[targetIdKey] ?? '').toString();

    ChatTypeEntity side;
    String chatId = '';
    BaseChatRepository repo;
    if (isGroup) {
      if (!Get.isRegistered<GroupsCubit>()) return false;
      final GroupEntity? group = Get.find<GroupsCubit>()
          .allGroups
          .firstWhereOrNull((g) => g.groupId == targetId);
      if (group == null) return false;
      side = group;
      chatId = group.groupId;
      repo = GroupChatRepository();
    } else {
      final SingleConnectionEntity? conn = connections.connections
          .firstWhereOrNull((c) => _norm(c.userId) == targetId);
      if (conn == null) return false;
      side = conn;
      chatId = conn.connectionId;
      repo = Get.isRegistered<SingleChatRepository>()
          ? Get.find<SingleChatRepository>()
          : SingleChatRepository();
    }
    final currentUser = connections.currentUser;

    bool allOk = true;

    // 1) Text — through the same use cases as the input field.
    final String? text = data[textKey] as String?;
    if (text != null && text.trim().isNotEmpty) {
      final TextMessageCubit cubit = TextMessageCubit(chatRepository: repo);
      await cubit.sendMessage(
        message: MessageEncryptionService().encrypt(text, chatId: chatId),
        previewText: text,
        currentUser: currentUser,
        otherConnectionSide: side,
      );
      allOk = cubit.state.messageSent && cubit.state.error == null;
      await cubit.close();
    }

    // 2) Attachment — only while the picked file is still on this device.
    final String? path = data[attachmentPathKey] as String?;
    if (path != null && path.isNotEmpty) {
      if (File(path).existsSync()) {
        allOk = await _sendContent(
                repo,
                currentUser,
                side,
                DocumentMessageContentEntity(
                    documentMessageModel: DocMessageModel(docPath: path))) &&
            allOk;
      } else {
        debugPrint('[Scheduled] ✗ attachment missing: $path');
        allOk = false;
      }
    }

    // 3) Poll.
    final PollPayload? poll = PollPayload.tryDecode(data[pollKey] as String?);
    if (poll != null) {
      allOk = await _sendContent(
              repo, currentUser, side, PollMessageContentEntity(poll: poll)) &&
          allOk;
    }
    return allOk;
  }

  static Future<bool> _sendContent(
    BaseChatRepository repo,
    BaseMessagingInterfaceParameters currentUser,
    ChatTypeEntity side,
    NewMessageContentEntity content,
  ) async {
    try {
      final result = await repo.sendNewMessage(
        currentUser: currentUser,
        otherConnectionSide: side,
        messageContent: content,
      );
      return result is! Left;
    } catch (e) {
      debugPrint('[Scheduled] ✗ send ${content.messageType.name}: $e');
      return false;
    }
  }
}
