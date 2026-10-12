/// Module: messaging / chat / presentation/ui/widgets/pinned_message.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'; // Keep for context extensions only
import 'package:knowticed_plus/features/messaging/m1_chat/domain/entity/message_entity.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import '../../controller/functions_on_messages_controllers/pin_message_cubit.dart';
import '../../controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class PinnedMessage extends StatelessWidget {
  const PinnedMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        final cubit = context.read<MasterChatCubit>();

        return BlocBuilder<PinMessageCubit, PinMessageState>(
          bloc: cubit.pinnedMessageCubit,
          builder: (context, pinState) {

            if (pinState.pinnedMessagesInRow.isEmpty) {
              return const SizedBox.shrink();
            }

            // Get the current pinned message to display
            final currentMessage = cubit.pinnedMessageCubit.message;

            return GestureDetector(
              onTap: () {
                cubit.chatScrollCubit.scrollAndHighlight(
                  pinState.pinnedMessagesInRow.first,
                );
              },
              child: Column(
                children: [
                  // Container(
                  //   height: 60.h,
                  //   padding: EdgeInsetsDirectional.only(start: 24, end: 16.w),
                  //   color: AppColors.field,
                  //   child: Row(
                  //     spacing: 10.w,
                  //     children: [
                  //       Container(
                  //         height: 40.h,
                  //         width: 40.h,
                  //         padding: EdgeInsets.all(10.h),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8.r),
                  //           color: ContextExtension(context).isPhone
                  //               ? AppColors.darkGrey.withOpacity(0.1)
                  //               : AppColors.whiteShadow,
                  //         ),
                  //         child: SvgPicture.asset(AppAssets.pin),
                  //       ),
                  //       Expanded(
                  //         child: _buildMessageTypeIcon(state, currentMessage),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  _buildAppBarDivider(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageTypeIcon(MasterChatState state, MessageEntity? message) {
    if (state.messages.isEmpty || message == null) {
      return const SizedBox.shrink();
    }

    if (message.messageType == MessageTypes.audio) {
      return SvgPicture.asset(
        AppAssets.audio,
        height: 20.h,
        width: 20.h,
        color: AppColors.secondaryBlack,
      );
    }
    if (message.messageType == MessageTypes.cameraImage ||
        message.messageType == MessageTypes.galleryImage) {
      return SvgPicture.asset(AppAssets.galleryWhite);
    }
    if (message.messageType == MessageTypes.video) {
      return SvgPicture.asset(AppAssets.video);
    }
    if (message.messageType == MessageTypes.doc) {
      return SvgPicture.asset(AppAssets.document);
    }
    if (message.messageType == MessageTypes.text) {
      return Text(
        message.messageContent!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAppBarDivider() {
    return  Divider(
      color: AppColors.lightGrey,
      thickness: 0.5,
      height: 1,
    );
  }
}