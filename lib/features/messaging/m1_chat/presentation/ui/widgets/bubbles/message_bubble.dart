/// Module: messaging / chat / presentation/ui/widgets/bubbles/message_bubble.dart
// Date: 6/8/2024
// By: Nada Mohammed
// Last update: 28/8/2024
// Objectives: This file is responsible for providing a widget that represents a message bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const MessageBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;

    return DefaultBubble(
      index: index,
      isGroup: isGroup,
      messageModel: messageModel,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: 8.h,
            ),
            child: Text(
              messageModel.messageContent!,
              style: (isMe
                      ? StyleText.fontSize14Weight400.copyWith(
                          color: AppColors.textButton,
                        )
                      : StyleText.fontSize14Weight400)
                  .copyWith(height: 1.3),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}