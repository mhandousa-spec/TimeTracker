/// Module: messaging / chat / presentation/controller/functions_on_messages_controllers/forward_message_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/message/message_model.dart';

// State class
class ForwardMessageState {
  final bool selectMessages;
  final List<MessageModel> selectedForwardMessages;

  ForwardMessageState({
    this.selectMessages = false,
    this.selectedForwardMessages = const [],
  });

  ForwardMessageState copyWith({
    bool? selectMessages,
    List<MessageModel>? selectedForwardMessages,
  }) {
    return ForwardMessageState(
      selectMessages: selectMessages ?? this.selectMessages,
      selectedForwardMessages: selectedForwardMessages ?? this.selectedForwardMessages,
    );
  }
}

// Cubit
class ForwardMessageCubit extends Cubit<ForwardMessageState> {
  ForwardMessageCubit() : super(ForwardMessageState());

  void toggleSelectMessages(bool value) {
    emit(state.copyWith(selectMessages: value));
  }

  void addMessageToForward(MessageModel message) {
    final updatedList = List<MessageModel>.from(state.selectedForwardMessages)
      ..add(message);
    emit(state.copyWith(selectedForwardMessages: updatedList));
  }

  void removeMessageFromForward(MessageModel message) {
    final updatedList = List<MessageModel>.from(state.selectedForwardMessages)
      ..remove(message);
    emit(state.copyWith(selectedForwardMessages: updatedList));
  }

  void toggleMessageSelection(MessageModel message) {
    final isSelected = state.selectedForwardMessages.contains(message);
    if (isSelected) {
      removeMessageFromForward(message);
    } else {
      addMessageToForward(message);
    }
  }

  void clearSelectedMessages() {
    emit(state.copyWith(selectedForwardMessages: []));
  }

  bool isMessageSelected(MessageModel message) {
    return state.selectedForwardMessages.contains(message);
  }

  void generateForwardCheckboxes(int index) {
    // If you need to generate checkboxes, you can handle it here
    // This might not be needed in Cubit pattern as you can derive state
  }

  void resetForwardState() {
    emit(ForwardMessageState());
  }
}