/// Module: messaging / chat / presentation/ui/widgets/all_chats_tile.dart
// Date: 12/9/2024
// By: Nada Mohammed,Mohamed Ashraf
// Last update: 12/9/2024
// Objectives: This file is responsible for providing the all chats tile.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/community_controller.dart';

import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import '../../../data/models/chat/chat_model.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class AllChatsTile extends StatelessWidget {
  final ChatModel chat;

  const AllChatsTile({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablett;
    final isGroup = chat.groupModel != null;

    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        final cubit = context.read<CommunityCubit>();
        final selectedChats = state is CommunityLoaded
            ? state.selectedChats
            : <ChatModel, bool>{};

        // Get the checkbox value, defaulting to false if not found
        final isSelected = selectedChats[chat] ?? false;

        return Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildAvatar(isTablet),
              horizontalSpace(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isGroup
                          ? chat.groupModel!.groupName
                          : chat.otherUser!.firstName,
                      style: isTablet
                          ? StyleText.fontSize19Weight400
                          : StyleText.fontSize16Weight400,
                    ),
                    if (isGroup)
                      Column(
                        children: [
                          verticalSpace(4),
                          Text(
                            chat.groupModel!.groupMembers
                                .map((e) => e.firstName)
                                .join(', '),
                            overflow: TextOverflow.ellipsis,
                            style: isTablet
                                ? StyleText.fontSize16Weight400.copyWith(color: AppColors.lightGrey)
                                : StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
                            maxLines: 1,
                          )
                        ],
                      ),
                  ],
                ),
              ),
              buildCheckbox(context, isSelected, cubit),
            ],
          ),
        );
      },
    );
  }

  CircleAvatar buildAvatar(bool isTablet) {
    final isGroup = chat.groupModel != null;
    return CircleAvatar(
      radius: 16.r,
      backgroundColor: AppColors.mediumGrey,
      backgroundImage: isGroup
          ? chat.groupModel!.groupImage != null
          ? appImageProvider(chat.groupModel!.groupImage!)
          : null
          : chat.otherUser != null
          ? appImageProvider(chat.otherUser!.avatarUrl)
          : null,
      child: isGroup && chat.groupModel!.groupImage == null
          ? Icon(
        Icons.group,
        color: AppColors.moreLightGrey,
        size: isTablet ? 32.w : 24.w,
      )
          : null,
    );
  }

  Checkbox buildCheckbox(BuildContext context, bool isSelected, CommunityCubit cubit) {
    return Checkbox(
      value: isSelected,
      onChanged: (bool? value) {
        cubit.toggleSelectedChat(chat);
      },
      side: WidgetStateBorderSide.resolveWith(
            (states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(
              color: AppColors.secondaryPrimary,
            );
          }
          return BorderSide(
            width: 0.5.w,
            color: AppColors.darkGrey,
          );
        },
      ),
      checkColor: AppColors.white,
      activeColor: AppColors.secondaryPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}