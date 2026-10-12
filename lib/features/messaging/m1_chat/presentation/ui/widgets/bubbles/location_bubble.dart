/// Module: messaging / chat / presentation/ui/widgets/bubbles/location_bubble.dart
// Date: 6/8/2024
// By: Nada Mohammed
// Last update: 28/8/2024
// Objectives: This file is responsible for providing a widget that represents a message bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class LocationBubble extends StatelessWidget {
  final MessageModel messageModel;
  final bool isGroup;
  final int index;

  const LocationBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MasterChatCubit>();
    //var isMe = messageModel.isMeLastMessage;
    var isTablet = ContextExtension(context).isTablett;
    final street = messageModel.locationModel!.address.split('-')[0];
    final stateAndCountry = messageModel.locationModel!.address.split('-')[1];
    var isMe = messageModel.isMeLastMessage;

    return /* DefaultBubble(
      index: index,
      isGroup: isGroup,
      messageModel: messageModel,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              controller.setCurrentLocation(
                false,
                location: messageModel.locationModel!,
              );
              Get.toNamed(
                Routes.maps,
                arguments: {
                  'isSelecting': false,
                },
              );
            },
            child: SizedBox(
              width: double.infinity,
              height: isTablet ? 200.h : 150.h,
              child: Image.memory(
                messageModel.locationModel!.locationImagePngBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          verticalSpace(8),
          Text(
            street,
            style: StyleText.fontSize14Weight400,
            overflow: TextOverflow.visible,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  stateAndCountry,
                  overflow: TextOverflow.visible,
                  style: isMe
                      ? StyleText.fontSize14Weight400
                          .copyWith(color: AppColors.textButton)
                      : StyleText.fontSize14Weight400,
                ),
              ),
            ],
          ),
        ],
      ),
    );*/
        Container();
  }
}