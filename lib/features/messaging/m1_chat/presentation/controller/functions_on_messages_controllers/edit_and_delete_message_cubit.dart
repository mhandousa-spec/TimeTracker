/// Module: messaging / chat / presentation/controller/functions_on_messages_controllers/edit_and_delete_message_cubit.dart
// Date: 6/8/2024
// Last update: 2/3/2026
// Author: Mohamed Elrashidy
// Purpose: Handles editing and deleting messages.
//          Re-encrypts the edited text before persisting to Firebase.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';

import '../../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../../../../../core/helper/message_module/main_helper/message_action_types.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class EditAndDeleteMessageState {
  final bool isEditing;
  final String? editingMessageId;

  const EditAndDeleteMessageState({
    this.isEditing = false,
    this.editingMessageId,
  });

  EditAndDeleteMessageState copyWith({
    bool? isEditing,
    String? Function()? editingMessageId,
  }) {
    return EditAndDeleteMessageState(
      isEditing: isEditing ?? this.isEditing,
      editingMessageId: editingMessageId != null
          ? editingMessageId()
          : this.editingMessageId,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

class EditAndDeleteMessageCubit extends Cubit<EditAndDeleteMessageState> {
  final BaseChatRepository chatRepository;
  final MasterChatCubit masterChatCubit;

  EditAndDeleteMessageCubit({
    required this.chatRepository,
    required this.masterChatCubit,
  }) : super(const EditAndDeleteMessageState());

  // ─────────────────────────────────────────────────────────────────────────
  // Set edit mode
  // ─────────────────────────────────────────────────────────────────────────

  /// Called when the user taps "Edit" on a message.
  /// The master cubit already decrypts the content and puts it in the text
  /// field (see [MasterChatCubit.selectMessageToMakeAction]), so here we only
  /// update the editing state.
  void setEditMessage() {
    final selectedMessage = masterChatCubit.state.selectedMessage;

    if (selectedMessage != null) {
      emit(state.copyWith(
        isEditing: true,
        editingMessageId: () => selectedMessage.messageId,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Submit edit  ✅ re-encrypt before saving
  // ─────────────────────────────────────────────────────────────────────────

  /// Reads the plain text from the controller, re-encrypts it, then persists.
  Future<void> submitEditMessage(BuildContext context) async {
    final selectedMessage = masterChatCubit.state.selectedMessage;
    final currentUser = masterChatCubit.state.currentUser;
    final otherConnectionSide = masterChatCubit.state.otherConnectionSide;

    if (selectedMessage == null ||
        currentUser == null ||
        otherConnectionSide == null) {
      return;
    }

    final plainText =
    masterChatCubit.textMessageEditingController.text.trim();
    if (plainText.isEmpty) return;

    // ✅ Re-encrypt the edited content before writing to Firebase
    final encryptedText = masterChatCubit.encryptMessage(plainText);

    await chatRepository.editTextMessage(
      newMessageText: encryptedText,           // 🔒 encrypted
      messageId: selectedMessage.messageId,
      chatId: selectedMessage.channelId,
      otherId: otherConnectionSide.otherSideId,
      currentUserId: currentUser.userId,
    );

    cancelEdit(context);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delete
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> deleteMessage() async {
    final selectedMessage = masterChatCubit.state.selectedMessage;
    final currentUser = masterChatCubit.state.currentUser;
    final otherConnectionSide = masterChatCubit.state.otherConnectionSide;

    if (selectedMessage == null ||
        currentUser == null ||
        otherConnectionSide == null) {
      return;
    }

    await chatRepository.deleteMessage(
      messageId: selectedMessage.messageId,
      chatId: selectedMessage.channelId,
      otherId: otherConnectionSide.otherSideId,
      currentUserId: currentUser.userId,
    );

    emit(const EditAndDeleteMessageState());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cancel
  // ─────────────────────────────────────────────────────────────────────────

  void cancelEdit(BuildContext context) {
    emit(const EditAndDeleteMessageState());

    masterChatCubit.selectMessageToMakeAction(
      context: context,
      message: null,
      actionType: MessageActionTypes.newMessage,
      newMessageType: null,
    );

    masterChatCubit.textMessageEditingController.clear();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  bool get isEditingMessage => state.isEditing;
  String? get editingMessageId => state.editingMessageId;
}