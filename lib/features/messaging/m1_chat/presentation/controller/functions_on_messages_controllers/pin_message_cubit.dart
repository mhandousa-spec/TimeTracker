/// Module: messaging / chat / presentation/controller/functions_on_messages_controllers/pin_message_cubit.dart
import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import '../../../domain/entity/message_entity.dart';
import '../../../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../data/repository/group_chat_repository.dart';

// State class
class PinMessageState {
  final SplayTreeSet<int> pinnedMessagesInRow;
  final SplayTreeSet<int> allPinnedMessages;

  PinMessageState({
    required this.pinnedMessagesInRow,
    required this.allPinnedMessages,
  });

  PinMessageState copyWith({
    SplayTreeSet<int>? pinnedMessagesInRow,
    SplayTreeSet<int>? allPinnedMessages,
  }) {
    return PinMessageState(
      pinnedMessagesInRow: pinnedMessagesInRow ?? this.pinnedMessagesInRow,
      allPinnedMessages: allPinnedMessages ?? this.allPinnedMessages,
    );
  }
}

// Cubit
class PinMessageCubit extends Cubit<PinMessageState> {
  final MasterChatCubit masterChatCubit;

  PinMessageCubit({required this.masterChatCubit})
      : super(PinMessageState(
    pinnedMessagesInRow:
    SplayTreeSet<int>((a, b) => b.compareTo(a))..add(0),
    allPinnedMessages: SplayTreeSet<int>((a, b) => a.compareTo(b)),
  ));

  MessageEntity? get message {
    if (state.pinnedMessagesInRow.isEmpty) return null;
    final messages = masterChatCubit.state.messages;
    final firstIndex = state.pinnedMessagesInRow.first;
    return firstIndex < messages.length ? messages[firstIndex] : null;
  }

  void updatePinMessageRow(List<int> messageIndexs) {
    if (messageIndexs.isEmpty) return;

    final newPinnedInRow = SplayTreeSet<int>((a, b) => b.compareTo(a))
      ..addAll(state.pinnedMessagesInRow);

    for (int index in messageIndexs) {
      newPinnedInRow.remove(index);
    }

    for (int index in state.allPinnedMessages) {
      if (index > messageIndexs[0]) break;
      newPinnedInRow.add(index);
    }

    emit(state.copyWith(pinnedMessagesInRow: newPinnedInRow));
  }

  void updatePinList() {
    final newPinnedInRow = SplayTreeSet<int>((a, b) => b.compareTo(a));
    final newAllPinned = SplayTreeSet<int>((a, b) => a.compareTo(b));

    final messages = masterChatCubit.state.messages;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].isPinned) {
        newPinnedInRow.add(i);
        newAllPinned.add(i);
      }
    }


    emit(state.copyWith(
      pinnedMessagesInRow: newPinnedInRow,
      allPinnedMessages: newAllPinned,
    ));
  }

  Future<void> updatePinMessage(MessageEntity message) async {
    final currentUser = masterChatCubit.state.currentUser;
    final otherConnectionSide = masterChatCubit.state.otherConnectionSide;

    if (currentUser == null || otherConnectionSide == null) {
      return;
    }

    final chatId = otherConnectionSide is SingleConnectionEntity
        ? otherConnectionSide.connectionId
        : otherConnectionSide.otherSideId;

    final newPinState = !message.isPinned;

    try {
      await masterChatCubit.chatRepository.updateMessagePinState(
        messageId: message.messageId,
        chatId: chatId,
        currentUserId: currentUser.userId,
        state: newPinState,
      );

      // ✅ Update group document BEFORE updatePinList
      if (otherConnectionSide is GroupEntity) {
        await _updateGroupPinnedState(
          groupId: otherConnectionSide.groupId,
          messageId: message.messageId,
          isPinning: newPinState,
        );
      }

      // ✅ Update single connection pin state locally
      if (otherConnectionSide is SingleConnectionEntity) {
        otherConnectionSide.hasPinnedMessage = newPinState ||
            masterChatCubit.state.messages.any(
                  (m) => m.isPinned && m.messageId != message.messageId,
            );
      }

      // ✅ Now update local pin list
      updatePinList();

      // ✅ Force ConnectionsCubit to re-emit so ConnectionTile rebuilds
      if (otherConnectionSide is SingleConnectionEntity) {
        try {
          final connectionsCubit = Get.find<ConnectionsCubit>();
          connectionsCubit.filteredSingleConnections();
        } catch (e) {
        }
      }
    } catch (e) {
    }
  }

  // ✅ Sync pin state to group document for GroupsTile pin icon
// ✅ Sync pin state to group document for GroupsTile pin icon
  Future<void> _updateGroupPinnedState({
    required String groupId,
    required String messageId,
    required bool isPinning,
  }) async {
    try {
      final repo = masterChatCubit.chatRepository;
      if (repo is! GroupChatRepository) return;

      if (isPinning) {
        await repo.updateGroupPinnedMessageId(
          groupId: groupId,
          pinnedMessageId: messageId,
        );

        final otherSide = masterChatCubit.state.otherConnectionSide;
        if (otherSide is GroupEntity) {
          otherSide.hasPinnedMessage = true;
        }
      } else {
        // ✅ Check if OTHER messages are still pinned (exclude current one)
        final messages = masterChatCubit.state.messages;
        MessageEntity? otherPinned;
        for (final m in messages) {
          if (m.isPinned && m.messageId != messageId) {
            otherPinned = m;
            break;
          }
        }

        if (otherPinned != null) {
          await repo.updateGroupPinnedMessageId(
            groupId: groupId,
            pinnedMessageId: otherPinned.messageId,
          );
        } else {
          await repo.updateGroupPinnedMessageId(
            groupId: groupId,
            pinnedMessageId: null,
          );

          final otherSide = masterChatCubit.state.otherConnectionSide;
          if (otherSide is GroupEntity) {
            otherSide.hasPinnedMessage = false;
          }
        }
      }
    } catch (e) {
    }
  }

  List<int> get allPinnedIndices => state.allPinnedMessages.toList();
  List<int> get visiblePinnedIndices => state.pinnedMessagesInRow.toList();
  bool isMessagePinned(int index) => state.allPinnedMessages.contains(index);
  int get pinnedMessageCount => state.allPinnedMessages.length;
}