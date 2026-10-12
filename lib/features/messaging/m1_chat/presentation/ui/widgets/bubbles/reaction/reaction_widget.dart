/// Module: messaging / chat / presentation/ui/widgets/bubbles/reaction/reaction_widget.dart
// Youssef Ashraf
/// message reaction container
part of '../../../pages/chat_mobile_view.dart';

class ReactionWidget extends StatelessWidget {
  final bool isMe;
  final int messageIndex;

  const ReactionWidget({
    super.key,
    required this.isMe,
    required this.messageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
              onTap: () {
                context.read<MessageCubit>().reactToMessage(
                    messageIndex: messageIndex, react: Reacts.like);
              },
              child: SvgPicture.asset(Reacts.like.getReact)),
          GestureDetector(
              onTap: () {
                context.read<MessageCubit>().reactToMessage(
                    messageIndex: messageIndex, react: Reacts.love);
              },
              child: SvgPicture.asset(Reacts.love.getReact)),
          GestureDetector(
            onTap: () {
              context.read<MessageCubit>().reactToMessage(
                  messageIndex: messageIndex, react: Reacts.xd);
            },
            child: SvgPicture.asset(
              Reacts.xd.getReact,
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<MessageCubit>().reactToMessage(
                  messageIndex: messageIndex, react: Reacts.wow);
            },
            child: SvgPicture.asset(Reacts.wow.getReact),
          ),
          GestureDetector(
            onTap: () {
              context.read<MessageCubit>().reactToMessage(
                  messageIndex: messageIndex, react: Reacts.sad);
            },
            child: SvgPicture.asset(Reacts.sad.getReact),
          ),
          GestureDetector(
            onTap: () {
              context.read<MessageCubit>().reactToMessage(
                  messageIndex: messageIndex, react: Reacts.clap);
            },
            child: SvgPicture.asset(Reacts.clap.getReact),
          ),
          CircleAvatar(
            backgroundColor: AppColors.darkWhiteShadow,
            radius: 8.r,
            child: SvgPicture.asset(
              AppAssets.add,
              height: 8.h,
              width: 8.w,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// `enum Reacts` moved to domain/enum/reacts.dart (§3). Extension stays here (needs AppAssets).

extension GetReact on Reacts {
  String get getReact {
    switch (this) {
      case Reacts.like:
        return AppAssets.emotions["like"]!;
      case Reacts.love:
        return AppAssets.emotions["love"]!;
      case Reacts.xd:
        return AppAssets.emotions["xd"]!;
      case Reacts.sad:
        return AppAssets.emotions["sad"]!;
      case Reacts.wow:
        return AppAssets.emotions["wow"]!;
      case Reacts.clap:
        return AppAssets.emotions["clap"]!;
    }
  }
}