/// Module: messaging / chat / presentation/ui/widgets/mention_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart'; // Keep for .tr and context extensions


import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import '../../../../m3_groups/domain/entities/member_entity.dart';
import '../../../../m3_groups/presentation/controller/groups_controller.dart';
import '../../controller/main_controllers/group_chat_cubit.dart';
import '../../controller/main_controllers/master_chat_cubit.dart';
import './member_mention_widget.dart';

class MentionCard extends StatelessWidget {
  const MentionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        // Ensure we're dealing with a GroupChatCubit
        if (state is! GroupChatState) {
          return const SizedBox.shrink();
        }

        final groupChatCubit = context.read<MasterChatCubit>() as GroupChatCubit;
        final mentionPrefix = groupChatCubit.getMentionPrefix();
        final mentionedMembers = state.mentionedMembers;

        // Get filtered members from GroupsController
        final filteredMembers = context.read<GroupsCubit>()
            .filteredMentionsMembers(mentionPrefix);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          width: double.infinity,
          height: ContextExtension(context).isTablett ? null : 150.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.background,
          ),
          child: Column(
            spacing: 8.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 4.w,
                children: [
                  SvgPicture.asset(
                    "assets/icons_assets/messaging_assets/mention_icon.svg",
                    height: 20.sp,
                    width: 20.sp,
                    color: AppColors.secondaryBlack,
                  ),
                  Text(
                    "Mentions",
                    style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                  ),
                ],
              ),
              !ContextExtension(context).isTablett
                  ? SizedBox(
                height: 105.h,
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 8.h,
                    children: [
                      for (MemberEntity member in filteredMembers)
                        if (!mentionedMembers.containsKey(member.memberId))
                          MemberMentionWidget(member: member)
                    ],
                  ),
                ),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8.w,
                  children: [
                    for (MemberEntity member in filteredMembers)
                      if (!mentionedMembers.containsKey(member.memberId))
                        MemberMentionWidget(member: member)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}