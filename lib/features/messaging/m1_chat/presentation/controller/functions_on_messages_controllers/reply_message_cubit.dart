/// Module: messaging / chat / presentation/controller/functions_on_messages_controllers/reply_message_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';

import '../../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../../../../../core/helper/message_module/main_helper/message_action_types.dart';

/// ******************************** FILE INFO *****************************
/// Class Name: ReplyMessageCubit
/// Purpose: This file contains the cubit for reply message functionality
/// Attributes:
///            masterChatCubit: MasterChatCubit, to access values and trigger actions
///            chatRepository: BaseChatRepository, to call sendNewMessage function
/// Author: Mohamed Elrashidy

// State class
class ReplyMessageState {
  final bool isReplying;
  final String? replyingToMessageId;

  ReplyMessageState({
    this.isReplying = false,
    this.replyingToMessageId,
  });

  ReplyMessageState copyWith({
    bool? isReplying,
    String? Function()? replyingToMessageId,
  }) {
    return ReplyMessageState(
      isReplying: isReplying ?? this.isReplying,
      replyingToMessageId: replyingToMessageId != null
          ? replyingToMessageId()
          : this.replyingToMessageId,
    );
  }
}

// Cubit
class ReplyMessageCubit extends Cubit<ReplyMessageState> {
  final MasterChatCubit masterChatCubit;
  final BaseChatRepository chatRepository;

  ReplyMessageCubit({
    required this.masterChatCubit,
    required this.chatRepository,
  }) : super(ReplyMessageState());

  /// Function Name : cancelReply
  /// Purpose: function to cancel reply message and set state to default
  void cancelReply(BuildContext context) {
    emit(ReplyMessageState());

    // Update master chat cubit to reset message action type
    masterChatCubit.selectMessageToMakeAction(
      context: context,
      message: null,
      actionType: MessageActionTypes.newMessage,
      newMessageType: null,
    );
  }

  /// Function Name : setReplyMessage
  /// Purpose: function to update state to show reply message UI
  void setReplyMessage() {
    final selectedMessage = masterChatCubit.state.selectedMessage;

    if (selectedMessage != null) {
      emit(state.copyWith(
        isReplying: true,
        replyingToMessageId: () => selectedMessage.messageId,
      ));

      // Request focus on message input
      // masterChatCubit.messageFocusNode.requestFocus();
    }
  }

  /// Function Name : submitMessageReply
  /// Purpose: function to submit message reply by calling sendNewMessage with replied message id
  Future<void> submitMessageReply(BuildContext context) async {

    final selectedMessage = masterChatCubit.state.selectedMessage;
    if (selectedMessage != null) {
      await masterChatCubit.sendNewMessage(
        repliedMessageId: selectedMessage.messageId,
      );
      cancelReply(context);
    }
  }

  /// Check if currently replying to a message
  bool get isReplyingToMessage => state.isReplying;

  /// Get the message ID being replied to
  String? get replyingMessageId => state.replyingToMessageId;
}