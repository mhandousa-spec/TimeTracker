/// Module: messaging / chat / presentation/controller/main_controllers/single_chat_cubit.dart
// Date: 6/8/2024
// Last update: 28/4/2026
// Purpose: Concrete cubit for 1-to-1 (single) chat.
//          Encrypts outgoing text messages and decrypts incoming ones.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
// ADDED 2/9/2026 — spec section 2.4.
import 'package:knowticed_plus/features/messaging/main_controller/notifications/messages_notification_service.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/domain/enum/media_type.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/message_action_types.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../../domain/entity/message_entity.dart';
import '../../../domain/use_cases/single_connection_usecases/clear_connection_num_of_unread_messages_use_case.dart';
import '../../../domain/use_cases/single_connection_usecases/get_single_chat_messages_use_case.dart';
import './master_chat_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatState extends MasterChatState {
  final SingleConnectionEntity? otherUser;

  SingleChatState({
    super.otherConnectionSide,
    super.isShowMedia,
    super.isShowContactInfo,       // ✅ added
    super.isExpansionTabletChat,
    super.mediaMessages,
    super.messages,
    super.selectMessages,
    super.messageActionType,
    super.selectedMessage,
    super.newMessageType,
    super.firstUnreadIndex,
    super.swiperIndex,
    super.currentUser,
    super.isSending,
    super.selectedMediaPaths,
    super.selectedDocPaths,
    super.chatPinnedMessage,
    this.otherUser,
  });

  @override
  SingleChatState copyWith({
    ChatTypeEntity? otherConnectionSide,
    bool? isShowMedia,
    bool? isShowContactInfo,       // ✅ added
    bool? isExpansionTabletChat,
    Map<MediaType, Map<String, List<MessageEntity>>>? mediaMessages,
    List<MessageEntity>? messages,
    bool? selectMessages,
    MessageActionTypes? messageActionType,
    MessageEntity? Function()? selectedMessage,
    MessageTypes? newMessageType,
    int? Function()? firstUnreadIndex,
    int? swiperIndex,
    BaseMessagingInterfaceParameters? currentUser,
    bool? isSending,
    List<String>? selectedMediaPaths,
    List<String>? selectedDocPaths,
    MessageEntity? Function()? chatPinnedMessage,
    SingleConnectionEntity? otherUser,
  }) {
    return SingleChatState(
      otherConnectionSide: otherConnectionSide ?? this.otherConnectionSide,
      isShowMedia: isShowMedia ?? this.isShowMedia,
      isShowContactInfo: isShowContactInfo ?? this.isShowContactInfo,  // ✅ added
      isExpansionTabletChat: isExpansionTabletChat ?? this.isExpansionTabletChat,
      mediaMessages: mediaMessages ?? this.mediaMessages,
      messages: messages ?? this.messages,
      selectMessages: selectMessages ?? this.selectMessages,
      messageActionType: messageActionType ?? this.messageActionType,
      selectedMessage: selectedMessage != null ? selectedMessage() : this.selectedMessage,
      newMessageType: newMessageType ?? this.newMessageType,
      firstUnreadIndex: firstUnreadIndex != null ? firstUnreadIndex() : this.firstUnreadIndex,
      swiperIndex: swiperIndex ?? this.swiperIndex,
      currentUser: currentUser ?? this.currentUser,
      isSending: isSending ?? this.isSending,
      selectedMediaPaths: selectedMediaPaths ?? this.selectedMediaPaths,
      selectedDocPaths: selectedDocPaths ?? this.selectedDocPaths,
      chatPinnedMessage: chatPinnedMessage != null
          ? chatPinnedMessage()
          : this.chatPinnedMessage,
      otherUser: otherUser ?? this.otherUser,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

class SingleChatCubit extends MasterChatCubit {
  SingleChatCubit({required super.chatRepository})
      : super(initialState: SingleChatState());

  @override
  SingleChatState get state => super.state as SingleChatState;

  // ─────────────────────────────────────────────────────────────────────────
  // Start chat
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> startChat({
    required ChatTypeEntity otherSideData,
    required BaseMessagingInterfaceParameters currentUserData,
  }) async {
    final singleConnection = otherSideData as SingleConnectionEntity;

    emit(SingleChatState(
      otherConnectionSide: singleConnection,
      currentUser: currentUserData,
      otherUser: singleConnection,
    ));

    try {
      chatScrollCubit.scrollPositionsListener.itemPositions.addListener(
        chatScrollCubit.scrollMessagesListener,
      );
    } catch (e) {
    }

    await getChatMessages();
    // Pin / mute / disappearing settings for this chat (bug report #19–22).
    unawaited(loadChatSettings());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch & decrypt messages from Firebase
  // ─────────────────────────────────────────────────────────────────────────

  // FIXED 24/9/2026 — messages must arrive in realtime, without restarting.
  //
  // The live Firestore listener used to die silently: an error inside the
  // pipeline (bad doc, failed media download, a Firestore error) ended the
  // stream, `event.isLeft()` was simply ignored and there was no onError /
  // onDone — so the receiver never saw another message until the app was
  // restarted. Now:
  //   • the listener handles onError / onDone / Left,
  //   • and re-attaches itself automatically (same chat only) after a short
  //     delay, keeping the messages already on screen.
  Timer? _resubscribeTimer;
  int _retryAttempt = 0;

  @override
  Future<void> getChatMessages() async {
    emit(state.copyWith(messages: []) as SingleChatState);
    _listenToChatMessages();
  }

  void _listenToChatMessages() {
    _resubscribeTimer?.cancel();
    cancelChatMessagesSubscription();

    final otherUser = state.otherUser;
    final currentUser = state.currentUser;
    if (isClosed || otherUser == null || currentUser == null) return;

    final String chatId = otherUser.connectionId;
    bool isStarted = state.messages.isNotEmpty;

    chatMessagesSubscription = GetSingleChatMessages(repository: chatRepository)
        .execute(chatId, currentUserId: currentUser.userId)
        .listen(
      (event) {
        if (isClosed) return;
        if (event.isLeft()) {
          _scheduleResubscribe(chatId);
          return;
        }
        _retryAttempt = 0;
        try {
          final rawMessages = event.getOrElse(() => <MessageEntity>[]);

          // ✅ Decrypt all text messages before updating the state
          final decryptedMessages = decryptMessagesList(rawMessages);

          emit(state.copyWith(messages: decryptedMessages) as SingleChatState);

          getFirstUnreadIndex();
          updateUnSeenMessages();
          _scrollController(isStarted);
          isStarted = true;
        } catch (_) {
          // Never let one bad snapshot stop the realtime updates.
        }
      },
      onError: (Object _, StackTrace __) => _scheduleResubscribe(chatId),
      onDone: () => _scheduleResubscribe(chatId),
      cancelOnError: false,
    );
  }

  void _scheduleResubscribe(String chatId) {
    if (isClosed) return;
    _resubscribeTimer?.cancel();
    final int seconds = 1 << (_retryAttempt < 4 ? _retryAttempt : 4); // 1..16s
    _retryAttempt++;
    _resubscribeTimer = Timer(Duration(seconds: seconds), () {
      // Only if the user is still on the same conversation.
      if (isClosed || state.otherUser?.connectionId != chatId) return;
      _listenToChatMessages();
    });
  }

  @override
  void cancelChatMessagesSubscription() {
    _resubscribeTimer?.cancel();
    super.cancelChatMessagesSubscription();
  }

  /// Closes the open conversation and forgets its messages.
  ///
  /// ADDED 30/9/2026 (Messages QA p.1): this cubit is permanent, so after a
  /// sign-out / sign-in the chat panel kept showing the previous user's
  /// conversation. Called on every sign-in.
  void resetChat() {
    cancelChatMessagesSubscription();
    if (!isClosed) emit(SingleChatState());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Scroll helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _scrollController(bool isStarted) {
    if (state.messages.isEmpty) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!chatScrollCubit.scrollController.isAttached) {
        return;
      }

      if (!isStarted) {
        chatScrollCubit.scrollAndHighlight(_getInitialIndex());
      }
      if (state.messages.isNotEmpty && state.messages.last.isMe) {
        chatScrollCubit.scrollAndHighlight(state.messages.length - 1);
      }
    });
  }

  int _getInitialIndex() {
    for (int i = state.messages.length - 1; i >= 0; i--) {
      if (state.messages[i].isSeen || state.messages[i].isMe) {
        return i;
      }
    }
    return 0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Unread messages
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> clearNumOfUnReadMessages({
    required String currentUserId,
    required String otherUserId,
  }) async {
    await ClearConnectionNumOfUnreadMessagesUseCase(repository: chatRepository)
        .execute(currentUserId: currentUserId, otherUserId: otherUserId);
  }

  @override
  Future<void> updateUnSeenMessages() async {
    final unSeenMessagesIds = state.messages
        .where((m) => !m.isMe && !m.isSeen)
        .map((m) => m.messageId)
        .toList();


    if (unSeenMessagesIds.isNotEmpty) {
      await chatRepository.updateMessagesAsSeen(
        unSeenMessagesIds: unSeenMessagesIds,
        chatId: state.otherUser!.connectionId,
      );

      try {
        await clearNumOfUnReadMessages(
          currentUserId: state.currentUser!.userId,
          otherUserId: state.otherUser!.userId,
        );
      } catch (e) {
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Send message  ✅ Encrypt text before sending to Firebase
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> sendNewMessage({String? repliedMessageId}) async {
    if (state.newMessageType == MessageTypes.text) {
      final plainText = textMessageEditingController.text.trim();
      if (plainText.isEmpty) return;

      // ✅ Encrypt the text before handing off to the repository
      final encryptedText = encryptMessage(plainText);

      await textMessageCubit.sendMessage(
        message: encryptedText,              // 🔒 encrypted for message content
        previewText: plainText,              // 📝 plain for last message preview
        currentUser: state.currentUser!,
        otherConnectionSide: state.otherUser!,
        repliedMessageId: repliedMessageId,
      );

      // ADDED 2/9/2026 — spec section 2.4, "Text Message Received". Messaging
      // raised no notifications at all before this.
      //
      // AFTER the send, never before: a notification about a message that
      // failed to write is a lie. Not awaited and cannot throw — see the
      // fire-and-forget note on MessagesNotificationService.
      //
      // `plainText`, not `encryptedText`. The preview is for a human to read,
      // and the service truncates it to 50 characters before it reaches a push
      // payload so a private message does not land whole on a lock screen.
      unawaited(
        MessagesNotificationService.notifyDirectMessage(
          recipientUserId: state.otherUser!.userId,
          senderName: state.currentUser!.fullName,
          body: plainText,
          // Skipped when the recipient muted this chat (bug report #20).
          chatKey: chatSettingsKey,
        ),
      );
    } else if (state.newMessageType == MessageTypes.cameraImage ||
        state.newMessageType == MessageTypes.galleryImage) {
      await imageMessageCubit.sendMessage();

      // ⚠️ NOT NOTIFIED YET, deliberately. The spec's "File Attachment
      // Received" event requires {{fileName}}, and `imageMessageCubit
      // .sendMessage()` returns void — the uploaded name is not visible from
      // here. Firing the event without it renders "sent you a file: null",
      // which is worse than staying silent.
      //
      // TO FINISH: have `ImageMessageCubit.sendMessage()` return the stored
      // file name, then:
      //   unawaited(MessagesNotificationService.notifyDirectMessage(
      //     recipientUserId: state.otherUser!.userId,
      //     senderName: state.currentUser!.fullName,
      //     fileName: <the returned name>,
      //   ));
      // The same applies to the voice path in RecordAndAudioCubit, which
      // passes `isVoice: true` instead of a file name.
    }
  }
}