/// Module: messaging / chat / domain/use_cases/single_connection_usecases/clear_connection_num_of_unread_messages_use_case.dart
import '../../repository/chat_repository/base_chat_repository.dart';

class ClearConnectionNumOfUnreadMessagesUseCase {
  final BaseChatRepository repository;

  ClearConnectionNumOfUnreadMessagesUseCase({required this.repository});

  execute({required String currentUserId, required String otherUserId}) async {
    return await repository.updateMyNumOfUnreadMessages(
        currentUserId: currentUserId, otherUserId: otherUserId,newValue: 0);
  }
}