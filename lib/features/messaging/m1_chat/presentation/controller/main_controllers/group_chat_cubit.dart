/// Module: messaging / chat / presentation/controller/main_controllers/group_chat_cubit.dart
// Date: 6/8/2024
// Last update: 28/4/2026
// Purpose: Concrete cubit for group chat.
//          Encrypts outgoing text messages and decrypts incoming ones.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/domain/enum/media_type.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/message_action_types.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../../m3_groups/domain/entities/member_entity.dart';
import '../../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../../domain/entity/group_message_entity.dart';
import '../../../domain/entity/message_entity.dart';
import '../../../domain/use_cases/group_chat_use_cases/get_group_chat_message_use_case.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class GroupChatState extends MasterChatState {
  final GroupEntity? selectedGroup;
  final bool showMentionCard;
  final Map<String, MemberEntity> mentionedMembers;

  GroupChatState({
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
    this.selectedGroup,
    this.showMentionCard = false,
    this.mentionedMembers = const {},
  });

  @override
  GroupChatState copyWith({
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
    GroupEntity? selectedGroup,
    bool? showMentionCard,
    Map<String, MemberEntity>? mentionedMembers,
  }) {
    return GroupChatState(
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
      selectedGroup: selectedGroup ?? this.selectedGroup,
      showMentionCard: showMentionCard ?? this.showMentionCard,
      mentionedMembers: mentionedMembers ?? this.mentionedMembers,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

class GroupChatCubit extends MasterChatCubit {
  final GroupsCubit groupsCubit;

  GroupChatCubit({
    required super.chatRepository,
    required this.groupsCubit,
  }) : super(initialState: GroupChatState());

  @override
  GroupChatState get state => super.state as GroupChatState;

  // ─────────────────────────────────────────────────────────────────────────
  // Start chat
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> startChat({
    required ChatTypeEntity otherSideData,
    required BaseMessagingInterfaceParameters currentUserData,
  }) async {
    final groupEntity = otherSideData as GroupEntity;

    emit(GroupChatState(
      otherConnectionSide: groupEntity,
      currentUser: currentUserData,
      selectedGroup: groupEntity,
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
  // Fetch & decrypt messages from Firebase  ✅
  // ─────────────────────────────────────────────────────────────────────────

  // FIXED 24/9/2026 — realtime without restart: see SingleChatCubit. The
  // listener now survives errors / Left / onDone and re-attaches itself to
  // the same group after a short back-off.
  Timer? _resubscribeTimer;
  int _retryAttempt = 0;

  @override
  Future<void> getChatMessages() async {
    emit(state.copyWith(messages: []) as GroupChatState);
    _listenToChatMessages();
  }

  void _listenToChatMessages() {
    _resubscribeTimer?.cancel();
    cancelChatMessagesSubscription();

    final side = state.otherConnectionSide;
    final group = state.selectedGroup;
    final currentUser = state.currentUser;
    if (isClosed || side == null || group == null || currentUser == null) {
      return;
    }

    final String chatId = side.otherSideId;
    bool isStarted = state.messages.isNotEmpty;

    chatMessagesSubscription =
        GetGroupChatMessageUseCase(chatRepository, groupsCubit)
            .execute(
      chatId: chatId,
      groupEntity: group,
      currentUserId: currentUser.userId,
    )
            .listen(
      (event) {
        if (isClosed) return;
        if (event.isLeft()) {
          _scheduleResubscribe(chatId);
          return;
        }
        _retryAttempt = 0;
        try {
          final rawMessages = event.getOrElse(() => []);

          // ✅ Decrypt all text messages before emitting to UI
          final decryptedMessages = decryptMessagesList(rawMessages);

          emit(state.copyWith(messages: []) as GroupChatState);
          emit(state.copyWith(messages: decryptedMessages) as GroupChatState);

          pinnedMessageCubit.updatePinList();
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
      if (isClosed || state.otherConnectionSide?.otherSideId != chatId) return;
      _listenToChatMessages();
    });
  }

  @override
  void cancelChatMessagesSubscription() {
    _resubscribeTimer?.cancel();
    super.cancelChatMessagesSubscription();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Unread messages
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> clearNumOfUnReadMessages({
    required String currentUserId,
    required String otherUserId,
  }) async {}

  @override
  Future<void> updateUnSeenMessages() async {
    final unSeenMessagesIds = <String>[];

    for (final message in state.messages) {
      if (message is GroupMessageEntity) {
        if (!message.messageSeenBy.contains(state.currentUser!.userId)) {
          unSeenMessagesIds.add(message.messageId);
        }
      }
    }

    if (unSeenMessagesIds.isNotEmpty) {
      await chatRepository.updateMessagesAsSeen(
        unSeenMessagesIds: unSeenMessagesIds,
        chatId: state.otherConnectionSide!.otherSideId,
        currentUserId: state.currentUser!.userId,
      );
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
        otherConnectionSide: state.otherConnectionSide!,
        mentionedMembers: state.mentionedMembers,
        repliedMessageId: repliedMessageId,
      );
    } else if (state.newMessageType == MessageTypes.cameraImage ||
        state.newMessageType == MessageTypes.galleryImage) {
      await imageMessageCubit.sendMessage();
    }

    emit(state.copyWith(mentionedMembers: {}) as GroupChatState);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Scroll helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _scrollController(bool isStarted) {
    if (state.messages.isEmpty) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isStarted) {
        chatScrollCubit.scrollAndHighlight(_getInitialIndex());
      }
      if (state.messages.last.isMe) {
        chatScrollCubit.scrollAndHighlight(state.messages.length);
      }
    });
  }

  int _getInitialIndex() {
    for (int i = state.messages.length - 1; i < state.messages.length; i++) {
      bool isSeen = false;
      if (state.messages[i] is GroupMessageEntity) {
        isSeen = (state.messages[i] as GroupMessageEntity)
            .messageSeenBy
            .contains(state.currentUser!.userId);
      }
      if (isSeen || state.messages[i].isMe) return i;
    }
    return 0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mention logic
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void setCurrentMessage(String message) {
    _validateMention();
    _showMentionSection();
    super.setCurrentMessage(message);
  }

  void _showMentionSection() {
    final cursorPosition =
        textMessageEditingController.selection.baseOffset;
    final textBeforeCursor =
    textMessageEditingController.text.substring(0, cursorPosition);

    if (textBeforeCursor.split('@').length > 1) {
      final textAfterLastAt = textBeforeCursor.split('@').last;
      if (textAfterLastAt.contains(' ')) {
        emit(state.copyWith(showMentionCard: false) as GroupChatState);
      } else {
        emit(state.copyWith(showMentionCard: true) as GroupChatState);
      }
    } else {
      emit(state.copyWith(showMentionCard: false) as GroupChatState);
    }
  }

  String getMentionPrefix() {
    final cursorPosition =
        textMessageEditingController.selection.baseOffset;
    final textBeforeCursor =
    textMessageEditingController.text.substring(0, cursorPosition);
    return textBeforeCursor.split('@').last;
  }

  void addMention(MemberEntity member) {
    final cursorPosition =
        textMessageEditingController.selection.baseOffset;
    String previousText =
    textMessageEditingController.text.substring(0, cursorPosition);
    previousText =
        previousText.substring(0, previousText.lastIndexOf('@'));
    previousText =
    '$previousText@${member.memberId.replaceAll('@', '_')} '
        '${textMessageEditingController.text.substring(cursorPosition)}';

    textMessageEditingController.text = previousText;

    final updatedMentions =
    Map<String, MemberEntity>.from(state.mentionedMembers);
    updatedMentions[member.memberId] = member;

    emit(state.copyWith(
      showMentionCard: false,
      mentionedMembers: updatedMentions,
    ) as GroupChatState);
  }

  void _validateMention() {
    final cursorPosition =
        textMessageEditingController.selection.baseOffset;
    final textBeforeCursor =
    textMessageEditingController.text.substring(0, cursorPosition);

    if (state.mentionedMembers.isNotEmpty) {
      final updatedMentions =
      Map<String, MemberEntity>.from(state.mentionedMembers);
      bool needsUpdate = false;

      updatedMentions.forEach((key, member) {
        String mentionText =
            '@${member.memberId.replaceAll('@', '_')}';
        mentionText = mentionText.substring(0, mentionText.length - 1);

        if (textBeforeCursor.contains(mentionText) &&
            textBeforeCursor.endsWith(mentionText)) {
          textMessageEditingController.text =
              textMessageEditingController.text.replaceRange(
                  textBeforeCursor.lastIndexOf('@'), cursorPosition, '');
          updatedMentions.remove(key);
          needsUpdate = true;
        }
      });

      if (needsUpdate) {
        emit(state.copyWith(
          showMentionCard: false,
          mentionedMembers: updatedMentions,
        ) as GroupChatState);
      }
    }
  }

  void preventCursorInMention() {
    final cursorPosition =
        textMessageEditingController.selection.baseOffset;
    final fullText = textMessageEditingController.text;

    for (final member in state.mentionedMembers.values) {
      final mentionText =
          '@${member.memberId.replaceAll('@', '_')}';
      final mentionStart = fullText.indexOf(mentionText);
      final mentionEnd = mentionStart + mentionText.length;

      if (mentionStart != -1 &&
          cursorPosition > mentionStart &&
          cursorPosition < mentionEnd) {
        textMessageEditingController.selection =
            TextSelection.fromPosition(
              TextPosition(offset: mentionEnd),
            );
        break;
      }
    }
  }

  void clearMentions() {
    emit(state.copyWith(mentionedMembers: {}));
  }

  void toggleMentionCard(bool show) {
    emit(state.copyWith(showMentionCard: show));
  }
}