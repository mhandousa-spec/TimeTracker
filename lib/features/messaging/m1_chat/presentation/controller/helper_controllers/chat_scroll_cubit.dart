/// Module: messaging / chat / presentation/controller/helper_controllers/chat_scroll_cubit.dart
import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// ************************ FILE INFO ****************************
/// Class Name: ChatScrollCubit
/// Purpose: This class is responsible for handling the chat scroll state
/// Attributes: masterChatCubit

// State class
class ChatScrollState {
  final bool lastIndexVisible;
  final int? highlightedMessageIndex;
  final bool isScrolling;

  ChatScrollState({
    this.lastIndexVisible = true,
    this.highlightedMessageIndex,
    this.isScrolling = false,
  });

  ChatScrollState copyWith({
    bool? lastIndexVisible,
    int? Function()? highlightedMessageIndex,
    bool? isScrolling,
  }) {
    return ChatScrollState(
      lastIndexVisible: lastIndexVisible ?? this.lastIndexVisible,
      highlightedMessageIndex: highlightedMessageIndex != null
          ? highlightedMessageIndex()
          : this.highlightedMessageIndex,
      isScrolling: isScrolling ?? this.isScrolling,
    );
  }
}

// Cubit
class ChatScrollCubit extends Cubit<ChatScrollState> {
  final MasterChatCubit masterChatCubit;

  Timer? _scrollTimer;
  late ItemScrollController scrollController;
  late ItemPositionsListener scrollPositionsListener;

  int initialIndex = 0;

  // ✅ Track retry attempts to avoid infinite loops
  int _retryCount = 0;
  static const int _maxRetries = 10;

  ChatScrollCubit({required this.masterChatCubit}) : super(ChatScrollState()) {
    scrollController = ItemScrollController();
    scrollPositionsListener = ItemPositionsListener.create();
    scrollPositionsListener.itemPositions.addListener(_onItemPositionsChanged);
  }

  /// Method Name: scrollAndHighlight
  /// Purpose: Scroll to a specific message index and optionally highlight it
  Future<void> scrollAndHighlight(int index) async {

    // CHECK 1: Verify scroll controller is attached — retry if not
    if (!scrollController.isAttached) {
      if (_retryCount >= _maxRetries) {
        _retryCount = 0;
        return;
      }
      _retryCount++;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollAndHighlight(index);
      });
      return;
    }

    // Reset retry count on success
    _retryCount = 0;

    // CHECK 2: Validate index is not negative
    if (index < 0) {
      return;
    }

    // CHECK 3: Validate index is within bounds
    final messages = masterChatCubit.state.messages;
    if (messages.isEmpty) {
      return;
    }

    final clampedIndex = index.clamp(0, messages.length - 1);
    if (clampedIndex != index) {
    }

    try {
      emit(state.copyWith(isScrolling: true));

      await scrollController.scrollTo(
        index: clampedIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.decelerate,
      );


      emit(state.copyWith(
        highlightedMessageIndex: () => clampedIndex,
        isScrolling: false,
      ));

      Future.delayed(const Duration(seconds: 1), () {
        if (!isClosed) {
          emit(state.copyWith(highlightedMessageIndex: () => null));
        }
      });
    } catch (e) {
      emit(state.copyWith(isScrolling: false));
    }
  }

  /// Method Name: _onItemPositionsChanged
  /// Purpose: Called when visible items change - updates pinned messages
  void _onItemPositionsChanged() {
    final List<ItemPosition> positions =
    scrollPositionsListener.itemPositions.value.toList();

    final List<int> visibleIndices =
    positions.map((position) => position.index).toList();

    masterChatCubit.pinnedMessageCubit.updatePinMessageRow(visibleIndices);
  }

  /// Method Name: scrollMessagesListener
  /// Purpose: Check if last message is visible and update state
  void scrollMessagesListener() {
    if (!scrollController.isAttached) {
      return;
    }

    if (_scrollTimer?.isActive ?? false) {
      return;
    }

    final messages = masterChatCubit.state.messages;

    _scrollTimer = Timer(
      const Duration(milliseconds: 520),
          () {
        if (messages.isNotEmpty) {
          final lastVisible = checkVisibleIndex(messages.length - 1);
          emit(state.copyWith(lastIndexVisible: lastVisible));
        }
      },
    );
  }

  /// Method Name: checkVisibleIndex
  /// Purpose: Check if a specific index is currently visible
  bool checkVisibleIndex(int index) {
    if (!scrollController.isAttached) {
      return false;
    }

    final positions = scrollPositionsListener.itemPositions.value;
    if (positions.isEmpty) {
      return false;
    }

    return positions.last.index >= index;
  }

  /// Method Name: scrollToLatest
  /// Purpose: Scroll to the latest message if not already visible
  Future<void> scrollToLatest(int index, {int? milliseconds}) async {

    if (!scrollController.isAttached) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollToLatest(index, milliseconds: milliseconds);
      });
      return;
    }

    final messages = masterChatCubit.state.messages;
    if (messages.isEmpty) {
      return;
    }

    final clampedIndex = index.clamp(0, messages.length - 1);

    bool indexVisible = checkVisibleIndex(clampedIndex);

    if (!indexVisible) {
      emit(state.copyWith(isScrolling: true));

      await scrollController.scrollTo(
        index: clampedIndex,
        duration: Duration(milliseconds: milliseconds ?? 400),
        curve: Curves.decelerate,
      );


      emit(state.copyWith(
        isScrolling: false,
        lastIndexVisible: true,
      ));
    }
  }

  /// Method Name: scrollToIndex
  /// Purpose: Scroll to any specific index
  Future<void> scrollToIndex(int index, {int? milliseconds}) async {

    if (!scrollController.isAttached) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollToIndex(index, milliseconds: milliseconds);
      });
      return;
    }

    if (index < 0) {
      return;
    }

    final messages = masterChatCubit.state.messages;
    if (messages.isEmpty) {
      return;
    }

    final clampedIndex = index.clamp(0, messages.length - 1);
    if (clampedIndex != index) {
    }

    emit(state.copyWith(isScrolling: true));

    await scrollController.scrollTo(
      index: clampedIndex,
      duration: Duration(milliseconds: milliseconds ?? 400),
      curve: Curves.decelerate,
    );

    emit(state.copyWith(isScrolling: false));
  }

  /// Method Name: jumpToIndex
  /// Purpose: Jump to index without animation
  void jumpToIndex(int index) {

    if (!scrollController.isAttached) {
      return;
    }

    if (index < 0) {
      return;
    }

    final messages = masterChatCubit.state.messages;
    if (messages.isEmpty) {
      return;
    }

    final clampedIndex = index.clamp(0, messages.length - 1);
    if (clampedIndex != index) {
    }

    scrollController.jumpTo(index: clampedIndex);
  }

  /// Method Name: setInitialIndex
  /// Purpose: Set the initial index for chat scroll
  void setInitialIndex(int index) {
    final messages = masterChatCubit.state.messages;
    final safe = messages.isEmpty ? 0 : index.clamp(0, messages.length - 1);
    initialIndex = safe;
  }

  /// Method Name: resetResources
  /// Purpose: Clean up resources
  void resetResources() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _retryCount = 0;
    scrollPositionsListener.itemPositions
        .removeListener(_onItemPositionsChanged);
  }

  /// Check if message is highlighted
  bool isMessageHighlighted(int index) {
    return state.highlightedMessageIndex == index;
  }

  @override
  Future<void> close() {
    resetResources();
    return super.close();
  }
}