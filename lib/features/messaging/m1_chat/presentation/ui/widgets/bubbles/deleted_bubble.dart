/// Module: messaging / chat / presentation/ui/widgets/bubbles/deleted_bubble.dart
// By: Youssef Ashraf
// Last update: 18/9/2024
// Objectives: This file is responsible for providing a widget that represents a deleted bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class DeletedBubble extends StatelessWidget {
  final bool isGroup;
  final int index;
  final MessageEntity messageModel;

  const DeletedBubble({
    super.key,
    required this.isGroup,
    required this.index,
    required this.messageModel,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = messageModel.isMe;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        /*      if (!isMe && isGroup)
          Row(
            children: [
              AvatarChat(imageUrl: messageModel.sentUserImage),
              horizontalSpace(4),
            ],
          ),*/
        Container(
          constraints: BoxConstraints(
            minHeight: 41.h,
            maxWidth: 186.w,
            minWidth: 186.w,
          ),
          padding: EdgeInsetsDirectional.only(
            start: 8.w,
            end: 8.w,
            top: 4.h,
            bottom: 4.h,
          ),
          margin: EdgeInsets.only(
            bottom: ContextExtension(context).isPhone ? 24.h : 16.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              4.r,
            ),
            color: const Color(0xffd7d7d7),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).youDeletedThisMessage,
                style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryBlack),
                softWrap: true,
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(
                      DateTimeHelper.formatTime(messageModel.time.toDate()),
                      style: StyleText.fontSize8Weight500.copyWith(color: AppColors.secondaryBlack),
                    ),
                    horizontalSpace(4),
                    if (isMe)
                      Icon(
                        /*  messageModel.isDelivered //Todo */ true
                            ? Icons.done_all
                            : Icons.done,
                        color: messageModel.isSeen
                            ? AppColors.blue
                            : AppColors.secondaryBlack,
                        size: ContextExtension(context).isTablet ? 18.sp : 16.sp,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        /*     if (isMe && isGroup)
          Row(
            children: [
              horizontalSpace(4),
              AvatarChat(imageUrl: messageModel.sentUserImage),
            ],
          ),*/
      ],
    );
  }
}