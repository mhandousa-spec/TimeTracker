/// Module: messaging / chat / presentation/controller/message_types_controllers/text_message_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../m3_groups/domain/entities/member_entity.dart';
import '../../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../../data/repository/group_chat_repository.dart';
import '../../../data/repository/single_chat_repository.dart';
import '../../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../../domain/use_cases/group_chat_use_cases/send_text_message_use_case.dart';
import '../../../domain/use_cases/single_connection_usecases/send_text_message_use_case.dart';

/// ******************************** FILE INFO *****************************
/// Class Name: TextMessageCubit
/// Purpose: This file contains the cubit for sending text messages
/// Attributes: chatRepository - abstract class for chat repository
/// Author: Mohamed Elrashidy

// State class
class TextMessageState {
  final bool isSending;
  final bool messageSent;
  final String? error;

  TextMessageState({
    this.isSending = false,
    this.messageSent = false,
    this.error,
  });

  TextMessageState copyWith({
    bool? isSending,
    bool? messageSent,
    String? Function()? error,
  }) {
    return TextMessageState(
      isSending: isSending ?? this.isSending,
      messageSent: messageSent ?? this.messageSent,
      error: error != null ? error() : this.error,
    );
  }
}

// Cubit
class TextMessageCubit extends Cubit<TextMessageState> {
  final BaseChatRepository chatRepository;

  TextMessageCubit({required this.chatRepository}) : super(TextMessageState());

  /// Method Name: sendMessage
  /// Purpose: Main method to handle which use case to call to send text message
  Future<void> sendMessage({
    required String message,
    required BaseMessagingInterfaceParameters currentUser,
    required ChatTypeEntity otherConnectionSide,
    Map<String, MemberEntity>? mentionedMembers,
    String? repliedMessageId,
    String? previewText,
  }) async {
    if (message.trim().isEmpty) {
      emit(state.copyWith(error: () => 'Message cannot be empty'));
      return;
    }

    // Set sending state
    emit(state.copyWith(
      isSending: true,
      messageSent: false,
      error: () => null,
    ));

    try {

      if (chatRepository is SingleChatRepository) {
        await SendTextMessageUseCase(chatRepository).execute(
          messageText: message,
          currentUser: currentUser,
          otherUser: otherConnectionSide,
          repliedMessageId: repliedMessageId,
          previewText: previewText,
        );
      } else if (chatRepository is GroupChatRepository) {
        await GroupSendTextMessageUseCase(
          chatRepository: chatRepository,
        ).execute(
          messageText: message,
          currentUser: currentUser,
          otherConnectionSide: otherConnectionSide,
          repliedMessageId: repliedMessageId,
          mentionedMembers: mentionedMembers,
          previewText: previewText,
        );
      } else {
        emit(state.copyWith(
          isSending: false,
          error: () => 'Unhandled repository type error',
        ));
        return;
      }

      // Message sent successfully
      emit(state.copyWith(
        isSending: false,
        messageSent: true,
        error: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        messageSent: false,
        error: () => 'Failed to send message. Please try again.',
      ));
    }
  }

  /// Clear error state
  void clearError() {
    emit(state.copyWith(error: () => null));
  }

  /// Reset state
  void reset() {
    emit(TextMessageState());
  }

  /// Check if currently sending a message
  bool get isSendingMessage => state.isSending;

  /// Get last error
  String? get lastError => state.error;
}