/// Module: messaging / chat / presentation/ui/widgets/bubbles/poll/live_poll_bubble.dart
/// Purpose: Bubble for poll messages created from the Poll dialog
///          (Figma 6799:5666). The poll travels as JSON in Message_Content
///          (PollPayload); votes are live from PollVotesService, so everyone
///          in the chat sees the counts move as people vote.
///
///   • Single answer: radio — picking another option moves the vote,
///     picking the same one again removes it.
///   • Allow Multiple Answers: checkboxes, each toggled on its own.
///   • Hide Voters: counts only; otherwise voter names show under each option.
/// Created At: 30/9/2026

part of '../../../pages/chat_mobile_view.dart';

class LivePollBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const LivePollBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final PollPayload? poll = PollPayload.tryDecode(messageModel.messageContent);
    final bool isMe = messageModel.isMe;
    final bool isAr = context.isArabic;
    final Color textColor = isMe ? AppColors.textButton : AppColors.text;

    if (poll == null) {
      return DefaultBubble(
        index: index,
        isGroup: isGroup,
        messageModel: messageModel,
        content: Text(isAr ? 'استطلاع غير صالح' : 'Invalid poll',
            style: StyleText.fontSize14Weight400.copyWith(color: textColor)),
      );
    }

    final String me =
        (context.read<MasterChatCubit>().state.currentUser?.userId ?? '')
            .trim()
            .toLowerCase();

    return DefaultBubble(
      index: index,
      isGroup: isGroup,
      messageModel: messageModel,
      content: StreamBuilder<Map<String, List<int>>>(
        stream: PollVotesService.watch(messageModel.messageId),
        builder: (context, snap) {
          final Map<String, List<int>> votes =
              snap.data ?? const <String, List<int>>{};
          final List<int> mine = votes[me] ?? const <int>[];
          final int voters = votes.values.where((v) => v.isNotEmpty).length;

          return ConstrainedBox(
            constraints: BoxConstraints(minWidth: 220.w, maxWidth: 300.w),
            child: Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CustomSvgImage(
                        assetPath:
                            'assets/icons_assets/messaging_assets/poll_bars.svg',
                        width: 16.r,
                        height: 16.r,
                        fit: BoxFit.contain,
                        color: textColor,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(poll.question,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: textColor)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    poll.allowMultiple
                        ? (isAr ? 'اختر خياراً أو أكثر' : 'Select one or more')
                        : (isAr ? 'اختر خياراً واحداً' : 'Select one'),
                    style: StyleText.fontSize10Weight400
                        .copyWith(color: textColor.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 8.h),
                  for (int i = 0; i < poll.options.length; i++)
                    _LivePollOption(
                      label: poll.options[i],
                      picked: mine.contains(i),
                      multiple: poll.allowMultiple,
                      count: votes.values.where((v) => v.contains(i)).length,
                      total: voters,
                      voters: poll.hideVoters
                          ? const <String>[]
                          : votes.entries
                              .where((e) => e.value.contains(i))
                              .map((e) => _voterName(e.key, me, isAr))
                              .toList(),
                      textColor: textColor,
                      onTap: me.isEmpty
                          ? null
                          : () => PollVotesService.vote(
                                messageId: messageModel.messageId,
                                userId: me,
                                option: i,
                                allowMultiple: poll.allowMultiple,
                              ),
                    ),
                  SizedBox(height: 2.h),
                  Text(
                    isAr ? '$voters صوت' : '$voters ${voters == 1 ? 'vote' : 'votes'}',
                    style: StyleText.fontSize10Weight400
                        .copyWith(color: textColor.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _voterName(String id, String me, bool isAr) {
    if (id == me) return isAr ? 'أنت' : 'You';
    if (Get.isRegistered<ConnectionsCubit>()) {
      for (final c in Get.find<ConnectionsCubit>().connections) {
        if (c.userId.trim().toLowerCase() == id) return c.name;
      }
    }
    return id.split('@').first;
  }
}

class _LivePollOption extends StatelessWidget {
  const _LivePollOption({
    required this.label,
    required this.picked,
    required this.multiple,
    required this.count,
    required this.total,
    required this.voters,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final bool picked;
  final bool multiple;
  final int count;
  final int total;
  final List<String> voters;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double share = total == 0 ? 0 : count / total;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                multiple
                    ? CustomCheckBox(isSelected: picked, size: 16.r)
                    : _radio(),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(label,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: textColor)),
                ),
                Text('$count',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: textColor)),
              ],
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: share,
                minHeight: 4.h,
                backgroundColor: textColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.secondaryPrimary),
              ),
            ),
            if (voters.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  voters.join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize10Weight400
                      .copyWith(color: textColor.withValues(alpha: 0.7)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _radio() => Container(
        width: 16.r,
        height: 16.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: picked ? AppColors.secondaryPrimary : textColor,
            width: 1.5.r,
          ),
        ),
        child: picked
            ? Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryPrimary,
                ),
              )
            : null,
      );
}
