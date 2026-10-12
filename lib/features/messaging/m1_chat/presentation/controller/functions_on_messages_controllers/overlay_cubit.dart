/// Module: messaging / chat / presentation/controller/functions_on_messages_controllers/overlay_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entity/message_entity.dart';
import '../main_controllers/master_chat_cubit.dart';
import '../../ui/pages/chat_mobile_view.dart';

class OverlayState {
  final OverlayEntry? overlayEntry;
  final bool isOverlayVisible;

  OverlayState({
    this.overlayEntry,
    this.isOverlayVisible = false,
  });

  OverlayState copyWith({
    OverlayEntry? Function()? overlayEntry,
    bool? isOverlayVisible,
  }) {
    return OverlayState(
      overlayEntry: overlayEntry != null ? overlayEntry() : this.overlayEntry,
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
    );
  }
}

class OverlayCubit extends Cubit<OverlayState> {
  OverlayCubit() : super(OverlayState());

  OverlayEntry? get overlayEntry => state.overlayEntry;

  void showMessageOverlay({
    required Widget content,
    required BuildContext context,
    required int index,
    required bool isGroup,
    required MessageEntity messageModel,
  }) {

    if (messageModel.isDeleted) return;

    // ✅ Safe remove — guard against stale entries
    _safeRemoveCurrentOverlay();

    final RenderBox bubbleBox = context.findRenderObject() as RenderBox;
    final Offset position = bubbleBox.localToGlobal(Offset.zero);

    // ✅ Capture MasterChatCubit BEFORE entering overlay context
    final masterChatCubit = context.read<MasterChatCubit>();

    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (overlayContext) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => removeOverlay(),
        child: MessageOverlay(
          index: index,
          messageModel: messageModel,
          bubbleBoxHeight: bubbleBox.size.height,
          overlayEntry: overlayEntry,
          bubbleBox: DefaultBubble(
            index: index,
            content: content,
            messageModel: messageModel,
            isGroup: isGroup,
            noMargin: true,
            isOverlay: true,
          ),
          position: position,
          masterChatCubit: masterChatCubit,
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    emit(state.copyWith(
      overlayEntry: () => overlayEntry,
      isOverlayVisible: true,
    ));
  }

  void removeOverlay() {
    _safeRemoveCurrentOverlay();
    emit(state.copyWith(
      overlayEntry: () => null,
      isOverlayVisible: false,
    ));
  }

  // ✅ Safe helper — won't crash if overlay was already removed
  void _safeRemoveCurrentOverlay() {
    if (state.overlayEntry != null) {
      try {
        state.overlayEntry!.remove();
        state.overlayEntry!.dispose();
      } catch (e) {
      }
    }
  }

  bool get isVisible => state.isOverlayVisible;

  @override
  Future<void> close() {
    _safeRemoveCurrentOverlay();
    return super.close();
  }
}