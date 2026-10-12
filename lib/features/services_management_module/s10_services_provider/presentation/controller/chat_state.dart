/// Module: services_management_module
/// Description: State for s10's ChatCubit — owns the comment-thread list for
///              a single employee-action request document (loading / loaded /
///              error) plus a busy flag for in-flight send/edit/delete/upload
///              actions. Distinct from s6's ChatState (different screen,
///              different request-lookup scoping by employeeFunctionHelper).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: equatable
/// Revision History: Initial version — extracted from
///                    s10_services_provider/ui/widgets/chat.dart (audit fix 1a).
library;

import 'package:equatable/equatable.dart';

/// Plain data holder for a single comment/attachment message, kept here so
/// the UI never touches Firestore document snapshots directly.
class ChatMessageModel extends Equatable {
  final String senderName;
  final String senderTitle;
  final String avatarPath;
  final String? text;
  final String? imagePath;
  final DateTime timestamp;
  final String? docId;

  const ChatMessageModel({
    required this.senderName,
    required this.senderTitle,
    required this.avatarPath,
    this.text,
    this.imagePath,
    required this.timestamp,
    this.docId,
  });

  @override
  List<Object?> get props =>
      [senderName, senderTitle, avatarPath, text, imagePath, timestamp, docId];
}

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
  final List<ChatMessageModel> messages;
  final bool isBusy;

  const ChatLoaded({required this.messages, this.isBusy = false});

  ChatLoaded copyWith({
    List<ChatMessageModel>? messages,
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
