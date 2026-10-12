/// Module: messaging / chat / presentation/ui/widgets/bubbles/video_bubble.dart
// Date: 4/9/2024
// By: Youssef Ashraf
// Objectives: This file is responsible for providing a widget that represents a Video bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class VideoBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isGroup;
  final int index;

  const VideoBubble({
    super.key,
    required this.message,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = message.isMe;
    var isTablet = ContextExtension(context).isTablett;
    final masterChatCubit = context.read<MasterChatCubit>();

    masterChatCubit.imageMessageCubit
        .videoListener(message.videoMessageModel!, 'videoBubble');

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      bloc: masterChatCubit,
      builder: (context, state) {
        return DefaultBubble(
          index: index,
          isGroup: isGroup,
          messageModel: message,
          hideSeen: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              message.videoMessageModel!.playerController.value.isInitialized
                  ? GestureDetector(
                onTap: () {
                  masterChatCubit.imageMessageCubit
                      .playVideo(message.videoMessageModel!);

                  Get.to(
                    VideoPlayerView(
                      model: message.videoMessageModel!,
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: 'video${message.videoMessageModel!.id}',
                      child: AspectRatio(
                        aspectRatio: message.videoMessageModel!
                            .playerController.value.aspectRatio,
                        child: VideoPlayer(
                          message.videoMessageModel!.playerController,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: AppColors.grey.withOpacity(0.3),
                      child: SvgPicture.asset(AppAssets.play),
                    ),
                    if (message.videoMessageModel!.playerController.value
                        .isInitialized)
                      PositionedDirectional(
                        end: 4.w,
                        start: 4.w,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(AppAssets.video),
                                SizedBox(width: 2.w),
                                Text(message.videoMessageModel!.duration),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (message.isStarred)
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      end: 4.w,
                                      bottom: 2.h,
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      color: !isMe
                                          ? AppColors.primary
                                          : AppColors.moreLightGrey,
                                      size: isTablet ? 18.r : 12.r,
                                    ),
                                  ),
                                Text(
                                  // ToDo: Fix the time format
                                  DateTimeHelper.formatTime(
                                      message.time.toDate()),
                                  style: GoogleFonts.roboto(
                                    color: isMe
                                        ? AppColors.moreLightGrey
                                        : AppColors.darkGrey,
                                    fontSize:
                                    ContextExtension(context).isTablet ? 12.sp : 10.sp,
                                  ),
                                ),
                                horizontalSpace(4),
                                if (isMe)
                                  Icon(
                                    message.isSeen
                                        ? Icons.done_all
                                        : Icons.done,
                                    /*color: message.isRead
                                              ? AppColors.blue
                                              : AppColors.moreLightGrey,*/
                                    size:
                                    ContextExtension(context).isTablet ? 18.sp : 16.sp,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              )
                  : LinearProgressIndicator(
                color: AppColors.base,
                backgroundColor: AppColors.inverseBase,
              ),
              if (message.messageContent != null &&
                  message.messageContent!.isNotEmpty)
                Column(children: [SizedBox(height: 5.h)]),
              Text(
                message.videoMessageModel!.caption ?? '',
                style: isMe
                    ? StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.textButton)
                    : StyleText.fontSize14Weight400,
                softWrap: true,
              ),
            ],
          ),
        );
      },
    );
  }
}