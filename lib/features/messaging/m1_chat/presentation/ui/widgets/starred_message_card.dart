// Date: 8/9/2024
// By: Nada Mohammed
// Last update: 8/9/2024
// Objectives: This file is responsible for providing starred messages card in the starred messages view.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';




import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../data/models/message/message_model.dart';
import '../../../../m3_groups/presentation/ui/widgets/avatar_chat.dart';
import '../../controller/message_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class StarredMessageCard extends StatelessWidget {
  final MessageModel messageModel;
  final String title;
  final String? imageUrl;
  final bool isGroup;
  final int index;

  const StarredMessageCard({
    super.key,
    required this.messageModel,
    required this.title,
    required this.imageUrl,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state is! MessageLoaded) {
          return const SizedBox();
        }

        final messageCubit = context.read<MessageCubit>();
        final sentUser = messageCubit.getSentUserByID(
          messageModel.sentUserID,
          messageModel,
        );

        if (sentUser == null) {
          return const SizedBox();
        }

        return Column(
          children: [
            (!messageModel.isMeLastMessage)
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarChat(
                  imageUrl: sentUser.avatarUrl,
                ),
                horizontalSpace(12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isGroup
                              ? '${sentUser.firstName} - $title'
                              : title,
                          style: isTablet
                              ? StyleText.fontSize23Weight500
                              : StyleText.fontSize18Weight500,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 20.h),
                      child: Text(
                        isGroup ? '${S.of(context).you} - $title' : S.of(context).you,
                        style: isTablet
                            ? StyleText.fontSize23Weight500
                            : StyleText.fontSize18Weight500,
                      ),
                    ),
                    horizontalSpace(12),
                    AvatarChat(
                      imageUrl: sentUser.avatarUrl,
                    ),
                  ],
                ),
              ],
            ),
            IgnorePointer(child: getMessageBubble(messageModel)),
            Divider(
              color: AppColors.black,
              thickness: 1.5.w,
              height: 1,
            ),
            verticalSpace(24),
          ],
        );
      },
    );
  }

  Widget getMessageBubble(MessageModel message) {
    /*// message.isMeLastMessage = false;
    if (message.audioModel != null) {
      return AudioBubble(
        index: index,
        messageModel: message,
        isGroup: false,
      );
    }
    if (message.videoModel != null) {
      return VideoBubble(
        index: index,
        messageModel: message,
        isGroup: false,
      );
    }
    if (message.image != null) {
      return ImageBubble(
        index: index,
        messageModel: message,
        isGroup: false,
      );
    }
    if (message.locationModel != null) {
      return LocationBubble(
        index: index,
        messageModel: message,
        isGroup: false,
      );
    }
    if (message.docModel != null) {
      return DocBubble(
        index: index,
        messageModel: message,
        isGroup: isGroup,
      );
    }
    if (message.pollModel != null) {
      return PollBubble(
        index: index,
        messageModel: message,
        isGroup: isGroup,
      );
    }
    if (message.message != null) {
      return MessageBubble(
        index: index,
        messageModel: message,
        isGroup: false,
      );
    }
*/
    return const SizedBox();
  }
}