/// Module: messaging / chat / presentation/ui/widgets/message_list_view.dart
// Date: 6/8/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 18/2/2026
// Objectives: This file is responsible for providing a widget that represents a message list view in the direct messaging view.

part of '../pages/chat_mobile_view.dart';

class MessageListView extends StatelessWidget {
  final bool isGroup;

  const MessageListView({super.key, required this.isGroup});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        final cubit = context.read<MasterChatCubit>();

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ScrollablePositionedList.builder(
              itemScrollController: cubit.chatScrollCubit.scrollController,
              itemPositionsListener:
              cubit.chatScrollCubit.scrollPositionsListener,
              itemCount: state.messages.length,
              // ✅ Clamp initialScrollIndex to valid range on chat switch
              initialScrollIndex: state.messages.isEmpty
                  ? 0
                  : cubit.chatScrollCubit.initialIndex
                  .clamp(0, state.messages.length - 1),
              itemBuilder: (context, index) {
                // ✅ Guard against stale index during chat switch
                if (index < 0 || index >= state.messages.length) {
                  return const SizedBox.shrink();
                }

                final message = state.messages[index];

                if (message.isDeleted) {
                  return DeletedBubble(
                    index: index,
                    messageModel: message,
                    isGroup: isGroup,
                  );
                }
                if (message.audio != null) {
                  return AudioBubble(
                    index: index,
                    messageModel: message,
                    isGroup: isGroup,
                  );
                }
                if (message.messageType == MessageTypes.video) {
                  return VideoBubble(
                    index: index,
                    message: message,
                    isGroup: isGroup,
                  );
                }
                if (message.messageType == MessageTypes.cameraImage) {
                  return ImageBubble(
                    index: index,
                    messageModel: message,
                    isGroup: isGroup,
                    masterChatCubit: cubit,
                  );
                }
                if (message.messageType == MessageTypes.doc) {
                  return DocBubble(
                    index: index,
                    messageModel: message,
                    isGroup: isGroup,
                  );
                }
                // Bug report #23 — shared location / contact cards.
                if (message.messageType == MessageTypes.location) {
                  return SharedLocationBubble(
                    index: index,
                    messageModel: message,
                    isGroup: isGroup,
                  );
                }
                // Figma 6799:5666 — polls sent from the Poll dialog.
                if (message.messageType == MessageTypes.poll) {
                  return LivePollBubble(
                    index: index,
                    messageModel: message,
                    isGroup: isGroup,
                  );
                }
                if (message.messageType == MessageTypes.contact) {
                  return SharedContactBubble(
                    index: index,
                    messageModel: message,
                    isGroup: isGroup,
                  );
                }
                if (message.messageContent != null) {
                  return MessageBubble(
                    index: index,
                    messageModel: message,
                    isGroup: isGroup,
                  );
                }

                return const SizedBox();
              },
            ),
            Positioned.directional(
              bottom: 20.h,
              end: 0,
              textDirection: Directionality.of(context),
              child: BlocBuilder<ChatScrollCubit, ChatScrollState>(
                bloc: cubit.chatScrollCubit,
                builder: (context, scrollState) {
                  return Visibility(
                    visible: !scrollState.lastIndexVisible &&
                        state.messages.isNotEmpty,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        cubit.chatScrollCubit.scrollToLatest(
                          state.messages.length - 1,
                        );
                      },
                      child: Container(
                        height: 28.h,
                        width: 28.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: SvgPicture.asset(
                          AppAssets.scroll,
                          height: 16.h,
                          width: 16.w,
                          color: AppColors.icon,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}