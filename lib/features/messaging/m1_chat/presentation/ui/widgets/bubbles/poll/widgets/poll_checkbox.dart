/// Module: messaging / chat / presentation/ui/widgets/bubbles/poll/widgets/poll_checkbox.dart
part of '../../../../pages/chat_mobile_view.dart';

class PollCheckbox extends StatelessWidget {
  const PollCheckbox({
    super.key,
    required this.messageModel,
    required this.index,
  });

  final MessageModel messageModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMeLastMessage;

    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        final cubit = context.read<MessageCubit>();

        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          checkboxShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
          checkColor: AppColors.white,
          activeColor: AppColors.secondaryPrimary,
          value: messageModel.pollModel!.pollValues[index],
          onChanged: (value) {
            cubit.updatePollOption(
              option: value,
              index: index,
              model: messageModel.pollModel!,
            );
          },
          title: Row(
            children: [
              Expanded(
                child: Text(
                  messageModel.pollModel!.options[index],
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: isMe ? AppColors.textButton : AppColors.text,
                  ),
                ),
              ),
              if (messageModel.pollModel!.votes[index] != 0)
                Row(
                  children: [
                    StackedAvatars(
                      height: 20.h,
                      avatarColor: AppColors.field,
                      avatarTextColor: AppColors.inverseBase,
                      width: 40.w,
                      images: messageModel.pollModel!
                          .voters[messageModel.pollModel!.options[index]]!
                          .map(
                            (e) {
                          return e.avatarUrl;
                        },
                      ).toList(),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      messageModel.pollModel!.votes[index].toString(),
                      style: StyleText.fontSize14Weight400.copyWith(
                          fontSize: 8.sp, color: AppTheme.contrastGreyColor()),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}