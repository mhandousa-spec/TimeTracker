// Date: 5/9/2024
// By: Nada Mohammed , Mohamed Ashraf
// Last update: 5/9/2024
// Objectives: This file is responsible for providing group members list view used in the group chat profile screen.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';

import '../../../../domain/entities/group_entity.dart';
import '../../../../domain/entities/member_entity.dart';
import '../../../controller/groups_controller.dart';
import '../tiles/group_member_tile.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class GroupMembersListView extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is! GroupsLoaded || state.selectedGroup == null) {
          return const SizedBox();
        }

        final controller = context.read<GroupsCubit>();


        bool isCurrentUserAdmin = state.selectedGroup!.members
            .where((element) {
          if (element.memberId == controller.currentUser.userId) {
            return element.isAdmin;
          }
          return false;
        })
            .toList()
            .isNotEmpty;

        List<MemberEntity> groupMembers = _getGroupMembers(controller, state);

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
            mainAxisExtent: 75.sp,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: ContextExtension(context).isPhone ? 1.5 : 1.2,
          ),
          itemCount: groupMembers.length,
          itemBuilder: (context, index) {
            return GroupMemberTile(
              groupMember: groupMembers[index],
              showPopup: isCurrentUserAdmin,
              index: index,
              isMember: (controller.membersSearchTextField.text.trim().isEmpty),
            );
          },
        );
      },
    );
  }

  List<MemberEntity> _getGroupMembers(GroupsCubit controller, GroupsLoaded state) {
    List<MemberEntity> members = (
        controller.membersSearchTextField.text.trim().isEmpty
            ? state.selectedGroup!.members  // ✅ Always fresh from state
            : state.members
    ).toSet().toList();

    members.removeWhere(
          (element) => element.memberId == controller.currentUser.userId,
    );
    return members;
  }
}