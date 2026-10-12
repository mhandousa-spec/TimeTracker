/// Module: messaging / chat / presentation/ui/widgets/member_mention_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; // Keep for context extensions only

import 'package:knowticed_plus/core/helper/message_module/main_helper/localized_text_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../m3_groups/domain/entities/member_entity.dart';
import '../../controller/main_controllers/group_chat_cubit.dart';
import '../../controller/main_controllers/master_chat_cubit.dart';
import './user_image.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MemberMentionWidget extends StatelessWidget {
  final MemberEntity member;

  const MemberMentionWidget({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final groupChatCubit = context.read<MasterChatCubit>() as GroupChatCubit;
        groupChatCubit.addMention(member);
      },
      child: ContextExtension(context).isTablet
          ? Container(
        width: 88.w,
        padding: EdgeInsets.all(4.sp),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            verticalSpace(10),
            UserImage(member: member, radius: 35),
            verticalSpace(5),
            FittedBox(
              child: Text(
                LocalizedTextHelper.formatString(
                  secondaryLanguageText: member.secondaryLanguageName,
                  primaryLanguageText: member.primaryLanguageName,
                ),
                maxLines: 1,
                style: StyleText.fontSize12Weight500,
              ),
            ),
            verticalSpace(10),
          ],
        ),
      )
          : Row(
        spacing: 4.w,
        children: [
          UserImage(member: member, radius: 30),
          Text(
            LocalizedTextHelper.formatString(
              secondaryLanguageText: member.secondaryLanguageName,
              primaryLanguageText: member.primaryLanguageName,
            ),
            style: StyleText.fontSize12Weight500,
          ),
        ],
      ),
    );
  }
}