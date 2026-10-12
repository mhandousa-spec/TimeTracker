/// Module: messaging / chat / presentation/ui/widgets/bubbles/poll/widgets/animated_votes_bar.dart
part of '../../../../pages/chat_mobile_view.dart';

//Youssef Ashraf
class AnimatedVotesBar extends StatelessWidget {
  const AnimatedVotesBar({
    super.key,
    required this.messageModel,
    required this.voteIndex,
  });

  final MessageModel messageModel;
  final int voteIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 4.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: AppColors.white,
          ),
          width: double.infinity,
        ),
        SizedBox(
          height: 4.h,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(
              milliseconds: 400,
            ),
            widthFactor: messageModel.pollModel!.calcPercentages(
              currentVoteNumbers: messageModel.pollModel!.votes[voteIndex],
            ),
            child: Container(
              height: 4.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: AppColors.secondaryPrimary,
              ),
              width: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}