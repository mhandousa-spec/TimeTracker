/// Module: messaging / groups / presentation/ui/pages/mobile/mobile_group_chat_profile_view.dart
/// ************************* FILE INFO *************************** ///
/// File Name: mobile_group_chat_profile_view.dart
/// Purpose: Mobile group chat profile view — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 5/9/2024
// By: Mohamed Ashraf
// Last update: 5/9/2024
// Objectives: This file is responsible for providing a chat profile view used in the message feature to show the group chat profile.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';

import 'package:knowticed_plus/core/helper/message_module/main_helper/localized_text_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/main_helper/custom_app_bar.dart';
import '../../../../../m1_chat/data/models/chat/chat_model.dart';
import '../../../../../m1_chat/presentation/controller/message_controller.dart';
import '../../widgets/about_group_profile.dart';
import '../../widgets/group_chat_profile_header.dart';
import '../../widgets/list_view/group_members_list_view.dart';
import '../../widgets/shared_content.dart';
import '../../widgets/tab_bar_name.dart';
import '../../../../domain/entities/group_entity.dart';

class MobileGroupChatProfileView extends StatelessWidget {
  const MobileGroupChatProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the current device is a tablet
    var isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.w : 16.w),
          child: SingleChildScrollView(
            child: BlocBuilder<GroupsCubit, GroupsState>(
              builder: (context, state) {
                final controller = context.read<GroupsCubit>();

                // Check if selectedGroup is null
                if (controller.selectedGroup == null) {
                  return const Center(
                    child: Text('No group selected'),
                  );
                }

                GroupEntity groupEntity = controller.selectedGroup!;
                /* var descriptionController =
                    controller.groupDescriptionController;*/
                //    var groupNameController = controller.groupNameController;

                // descriptionController.text = groupEntity.groupDescription;

                //groupNameController.text = groupEntity.primaryLanguageName;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(title: 'Message', centerTitle: false),
                    SizedBox(height: isTablet ? 40.h : 32.h),
                    GroupChatProfileHeader(
                      title: LocalizedTextHelper.formatString(
                          secondaryLanguageText:
                          groupEntity.secondaryLanguageName,
                          primaryLanguageText:
                          groupEntity.primaryLanguageName),
                      countMember: '+ ${groupEntity.members.length}',
                    ),
                    verticalSpace(24),
                    const TabBarNameGroupProfile(),
                    verticalSpace(18),
                    // Group members list view
                    /*           if (controller.selectedAllTab == 'About') {
                      return AboutGroupProfile(
                        groupDescription:
                            controller.groupDescriptionController,
                        groupName: controller.groupNameController,
                      );
                    }*/
                    /*  if (controller.selectedAllTab == 'Member') {*/
                    GroupMembersListView(

                    ),
                    //  }
                    /*       return SharedContent(
                      model: controller.chatModel!.mediaModel,
                      verticalSpacing: 70,
                    );*/
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}