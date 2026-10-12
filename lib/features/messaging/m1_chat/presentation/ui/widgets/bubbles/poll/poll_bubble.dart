/// Module: messaging / chat / presentation/ui/widgets/bubbles/poll/poll_bubble.dart
// By: Youssef Ashraf
// Date: 8/9/2024
// Objectives: This file is responsible for providing a widget that represents a poll bubble in the direct messaging view.

part of '../../../pages/chat_mobile_view.dart';

class PollBubble extends StatelessWidget {
  final MessageModel messageModel;
  final bool isGroup;
  final int index;

  const PollBubble({
    super.key,
    required this.messageModel,
    required this.index,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMeLastMessage;

    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        return /*DefaultBubble(
          index: index,
          isGroup: isGroup,
          messageModel: messageModel,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageModel.pollModel!.question,
                style: StyleText.fontSize14Weight400.copyWith(
                      color: isMe ? AppColors.textButton : AppColors.text,
                    ),
                softWrap: true,
              ),
              horizontalSpace(2),
              Text(
                messageModel.pollModel!.isMultible
                    ? 'Select one or more choice'.tr
                    : 'Select one choice'.tr,
                style: StyleText.fontSize14Weight400.copyWith(
                      fontSize: 10.sp,
                      color: AppTheme.contrastGreyColor(),
                    ),
              ),
              verticalSpace(2),
              ...List.generate(
                messageModel.pollModel!.options.length,
                (index) {
                  return Column(
                    children: [
                      messageModel.pollModel!.isMultible
                          ? PollCheckbox(
                              messageModel: messageModel,
                              index: index,
                            )
                          : PollRadio(messageModel: messageModel, index: index),
                      AnimatedVotesBar(
                        messageModel: messageModel,
                        voteIndex: index,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: 14.h,
              ),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.pollDetails,
                      arguments: {
                        'pollModel': messageModel.pollModel!,
                      },
                    );
                  },
                  child: Text(
                    'View Votes'.tr,
                    style: StyleText.fontSize14Weight400.copyWith(
                          color: isMe ? AppColors.textButton : AppColors.text,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );*/
          Container();
      },
    );
  }
}