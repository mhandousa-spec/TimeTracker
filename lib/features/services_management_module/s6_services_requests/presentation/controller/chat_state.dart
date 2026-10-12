/// Module: services_management_module
/// Description: State for ChatCubit — owns the comment-thread list for a
///              single service-request document (loading/loaded/error) plus
///              a busy flag for in-flight send/edit/delete/upload actions.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: equatable, ChatMessageData (data/repository/chat_repository_impl.dart)
/// Revision History: Initial version — extracted from chat.dart (audit fix #2/#3).

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/chat_repository_impl.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessageData> messages;
  final bool isBusy;

  const ChatLoaded({required this.messages, this.isBusy = false});

  ChatLoaded copyWith({
    List<ChatMessageData>? messages,
    bool? isBusy,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  List<Object?> get props => [messages, isBusy];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
