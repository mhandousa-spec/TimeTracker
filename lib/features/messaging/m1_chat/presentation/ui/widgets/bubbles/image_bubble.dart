/// Module: messaging / chat / presentation/ui/widgets/bubbles/image_bubble.dart
// By: Youssef Ashraf
// Date: 9/9/2024
// Last update: 18/2/2026
// Objectives: This file is responsible for providing a widget that represents An Image bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class ImageBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;
  // ✅ Pass cubit from parent instead of Get.find
  final MasterChatCubit masterChatCubit;

  const ImageBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
    required this.masterChatCubit,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      bloc: masterChatCubit,
      builder: (context, state) {
        return DefaultBubble(
          index: index,
          isGroup: isGroup,
          messageModel: messageModel,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      /*   Get.toNamed(Routes.imageInteract,
                            arguments: {'image': messageModel.image!});*/
                    },
                    child: Hero(
                      tag: messageModel.mediaLink!,
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 150.h),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(messageModel.mediaLink!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
              Text(
                messageModel.messageContent ?? '',
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