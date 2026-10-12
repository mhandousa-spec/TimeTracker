// Date: 5/9/2024
// By: Nada Mohammed ,Mohamed Ashraf
// Last update: 5/9/2024
// Objectives: This file is responsible for providing a group members tile used in the group chat profile screen.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';


import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../domain/entities/member_entity.dart';
import '../../../../domain/enums/group_member_status.dart';
import '../../../controller/groups_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';

class GroupMemberTile extends StatelessWidget {
  final MemberEntity groupMember;
  final bool showPopup;
  final int index;
  final bool isMember;

  const GroupMemberTile({
    super.key,
    required this.groupMember,
    required this.showPopup,
    required this.index,
    required this.isMember,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is! GroupsLoaded) return const SizedBox();

        final controller = context.read<GroupsCubit>();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsetsDirectional.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ──────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: CustomSvgImage(
                  assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.fill,
                ),
              ),

              horizontalSpace(10),

              // ── Name / Dept / SubInfo ────────────────────────
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      groupMember.fullName,
                      style: StyleText.fontSize14Weight500
                          .copyWith(height: 1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      groupMember.departmentName,
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      groupMember.subInfo,
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              horizontalSpace(8),

              // ── Actions (role/remove/add) ────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,  // ✅ Changed from max
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,  // ✅ Added
                children: [
                  if (showPopup &&
                      groupMember.memberId != controller.currentUser.userId &&
                      isMember)
                    InkWell(
                      onTap: () => controller.setRole(index, S.of(context).remove),
                      child: SvgPicture.asset(
                        AppAssets.minusCircle,
                        width: 20.sp,
                        height: 20.sp,
                      ),
                    ),

                  if (showPopup &&
                      groupMember.memberId != controller.currentUser.userId &&
                      isMember)
                    SizedBox(height: 8.h),  // ✅ Changed from Spacer()

                  if (showPopup &&
                      groupMember.memberId != controller.currentUser.userId &&
                      isMember)
                    userRolePopupTile(index, context, state, controller),

                  if (!isMember)
                    _addButton(context, controller),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget userRolePopupTile(
      int index,
      BuildContext context,
      GroupsLoaded state,
      GroupsCubit controller,
      ) {
    // Prepare items for dropdown
    final dropdownItems = GroupMemberStatus.values
        .map((status) => DropdownItem<String>(
              value: status.name,
              label: status.name,
            ))
        .toList();

    // Determine current selected value
    String? currentValue;
    if (state.selectedRole[index] != null) {
      // Find the key that matches the translated value
      final matchingStatus = GroupMemberStatus.values.firstWhere(
            (element) => element.name == state.selectedRole[index],
        orElse: () => groupMember.isAdmin
            ? GroupMemberStatus.Admin
            : GroupMemberStatus.Member,
      );
      currentValue = matchingStatus.name;
    } else {
      currentValue = groupMember.isAdmin
          ? GroupMemberStatus.Admin.name
          : GroupMemberStatus.Member.name;
    }

    return SizedBox(
      width: 85.sp,
      height: 20.sp,
      child: CustomDropdown<String>(
        value: currentValue,
        items: dropdownItems,
        fillColor: AppColors.field,
        borderRadius: BorderRadius.circular(2.r),
        triggerPadding: EdgeInsets.symmetric(horizontal: 4.w),
        itemHeight: 20.sp,
        onChanged: (String newValue) {
          // Find the enum value and get its translated name
          final selectedStatus = GroupMemberStatus.values.firstWhere(
            (element) => element.name == newValue,
          );
          controller.setRole(index, selectedStatus.name);
        },
      ),
    );
  }

  Widget _addButton(BuildContext context, GroupsCubit controller) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GestureDetector(
      onTap: () {
        controller.addGroupMember(groupMember);
      },
      child: Container(
        width: 100.sp,
        height: 36.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: AppColors.primary,
        ),
        child: Row(
          spacing: 4.sp,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: isTablet ? 18.sp : 16.sp,
              color: AppTheme.contrastColor(),
            ),
            Text(
              S.of(context).add,
              style: isTablet
                  ? StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton)
                  : StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton),
            ),
          ],
        ),
      ),
    );
  }
}
