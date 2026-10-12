/// Module: messaging / groups / presentation/ui/pages/mobile/mobile_single_chat_profile_view.dart
/// ************************* FILE INFO *************************** ///
/// File Name: mobile_single_chat_profile_view.dart
/// Purpose: Mobile single chat profile view — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 5/9/2024
// By: Youssef Ashraf
// Last update: 5/9/2024
// Objectives: This file is responsible for providing a chat profile view used in the message feature to show the single chat profile.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_controller.dart';


import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../../m1_chat/presentation/ui/widgets/chat_profile_header.dart';
import '../../widgets/list_view/common_groups_list_view.dart';
import '../../../../../m1_chat/presentation/ui/widgets/media_section.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MobileSingleChatProfileView extends StatelessWidget {
  const MobileSingleChatProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<MessageCubit, MessageState>(
          builder: (context, state) {
            final cubit = context.read<MessageCubit>();
            final chatModel = state is MessageLoaded
                ? state.chatModel
                : cubit.chatModel;

            // Return empty scaffold if chat model is null
            if (chatModel == null || chatModel.otherUser == null) {
              return const Center(child: Text('No chat data available'));
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24.w : 16.w,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: isTablet ? 40.h : 32.h),
                    ChatProfileHeader(
                      title: chatModel.otherUser!.firstName,
                      subtitle: chatModel.otherUser!.phoneNumber,
                    ),
                    SizedBox(height: isTablet ? 54.h : 40.h),
                    MediaSection(
                      mediaModel: chatModel.mediaModel,
                      title: chatModel.otherUser!.firstName,
                    ),
                    SizedBox(height: 33.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.star,
                              width: 24.w,
                              height: 24.h,
                              color: AppColors.text,
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.starredMessages,
                                  arguments: {
                                    'title': chatModel.otherUser!.firstName,
                                    'imageUrl': chatModel.otherUser!.avatarUrl,
                                  },
                                );
                              },
                              child: Text(
                                S.of(context).starredMessages,
                                style: ContextExtension(context).isTablett
                                    ? StyleText.fontSize19Weight500.copyWith(color: AppColors.darkGrey)
                                    : StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              chatModel.starredMessagesCount.toString(),
                              style: ContextExtension(context).isTablett
                                  ? StyleText.fontSize19Weight500.copyWith(color: AppColors.darkGrey)
                                  : StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            cubit.menuSelectAndNavigate(
                              S.of(context).disappearingMessages,
                              chatModel.otherUser!.firstName,
                              context: context,
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.visibility_off_outlined,
                                color: AppColors.text,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Text(
                                S.of(context).disappearingMessages,
                                style: ContextExtension(context).isTablett
                                    ? StyleText.fontSize19Weight500.copyWith(color: AppColors.darkGrey)
                                    : StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            cubit.menuSelectAndNavigate(
                              S.of(context).muteNotifications,
                              chatModel.otherUser!.firstName,
                              context: context,
                            );
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.emptyNotification,
                                color: AppColors.black,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Text(
                                S.of(context).muteNotifications,
                                style: ContextExtension(context).isTablett
                                    ? StyleText.fontSize19Weight500.copyWith(color: AppColors.darkGrey)
                                    : StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey),
                              ),
                            ],
                          ),
                        ),
                        verticalSpace(32),
                        Text(
                          chatModel.otherUser!.groupsInCommon.isEmpty
                              ? S.of(context).noGroupsInCommon
                              : '${chatModel.otherUser!.groupsInCommon.length} ${S.of(context).groupsInCommon}',
                          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.inputColor),
                        ),
                        verticalSpace(16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${S.of(context).createANewGroupWith} ${chatModel.otherUser!.firstName}',
                            style: StyleText.fontSize12Weight400),
                          subtitle: Text(
                            '${S.of(context).you2} ${chatModel.otherUser!.firstName}, ....',
                            overflow: TextOverflow.ellipsis,
                            style: isTablet
                                ? StyleText.fontSize16Weight400.copyWith(color: AppColors.lightGrey)
                                : StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: SvgPicture.asset(
                              AppAssets.group,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(Routes.createGroupPageMobile);
                          },
                        ),
                        CommonGroupsListView(
                          chatModel: chatModel,
                        ),
                      ],
                    ),
                    verticalSpace(isTablet ? 40 : 120),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}