/// Module: messaging / groups / presentation/ui/widgets/new_group_tile.dart
/// ************************* FILE INFO *************************** ///
/// File Name: new_group_tile.dart
/// Purpose: New group tile — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 1/9/2024
// By: Nada Mohammed
// Last update: 3/9/2024
// Objectives: This file is responsible for providing the community new group tile used in the community feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/localized_text_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';


import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import '../../../../m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import '../../../../m2_connections/presentation/controller/connections_controller.dart';
import '../../../domain/entities/group_entity.dart';
import '../../controller/groups_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import '../../../../main_controller/helper/chat_settings_service.dart';
import '../../../../main_controller/helper/chat_state_icons.dart';

class NewGroupTile extends StatelessWidget {
  final GroupEntity groupEntity;
  final VoidCallback? onTap;

  const NewGroupTile({
    super.key,
    required this.groupEntity,
    this.onTap,
  });

  void _handleTap(BuildContext context) {
    final groupsCubit = context.read<GroupsCubit>();

    // Clear the open direct message so the panel switches to the group.
    context.read<ConnectionsCubit>().clearSelectedConnection();

    // Select the group
    groupsCubit.selectGroup(groupEntity);

    // ✅ FIX: read GroupChatCubit from context (must be provided above in widget tree)
    // instead of creating a new local instance which is never provided to BLoC
    final groupChatCubit = context.read<GroupChatCubit>();

    groupChatCubit.startChat(
      otherSideData: groupsCubit.selectedGroup!,
      currentUserData: groupsCubit.currentUser,
    );

    groupChatCubit.getFirstUnreadIndex();
    groupChatCubit.messageFocusNode.unfocus();

    if (ContextExtension(context).isTablett) {
      // Tablet: panel updates in place via BLoC state — no navigation needed
    } else {
      // Pure Bloc: push ChatMobileView with the active cubits (§3).
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ChatMobileView(
            masterChatCubit: groupChatCubit,
            connectionsCubit: context.read<ConnectionsCubit>(),
            groupsCubit: groupsCubit,
          ),
        ),
      );
    }

    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(4.r), // bug report #3: cards use 4.r
        ),
        padding: EdgeInsetsDirectional.all(8.sp),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  // DateFormat still emits Latin digits for `ar` (see
                  // LocalizedNumber.digits) — map them, so the date matches
                  // the Arabic-Indic counts elsewhere on this screen.
                  LocalizedNumber.digits(
                    context,
                    DateTimeHelper.formatDate(groupEntity.createdAt.toDate()),
                  ),
                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.inputColor)
                      .copyWith(fontSize: 10.sp, height: 1),
                ),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.background,
                  radius: 20.r,
                  backgroundImage: (groupEntity.groupImage != null)
                      ? NetworkImage(groupEntity.groupImage!)
                      : null,
                  child: groupEntity.groupImage == null
                      ? SvgPicture.asset(
                    AppAssets.message,
                    color: AppColors.text,
                    width: 20.sp,
                    height: 20.sp,
                  )
                      : null,
                ),
                horizontalSpace(5),
                Expanded(
                  child: BlocBuilder<GroupsCubit, GroupsState>(
                    builder: (context, state) {
                      final groupsCubit = context.read<GroupsCubit>();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 10.sp,
                        children: [
                          Text(
                            // Was `primaryLanguageName` alone, so a group with
                            // an Arabic name still showed its English one in
                            // Arabic mode. Same call groups_tile.dart makes;
                            // formatString capitalizes, so the separate
                            // FormatHelper.capitalize is gone with it.
                            LocalizedTextHelper.formatString(
                              primaryLanguageText:
                                  groupEntity.primaryLanguageName,
                              secondaryLanguageText: groupEntity.groupNameAr,
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize14Weight500
                                .copyWith(height: 1.3),
                          ),
                          if (groupEntity.createdBy ==
                              groupsCubit.currentUser.userId)
                            Text(
                              S.of(context).youCreatedThisGroup,
                              style: isTablet
                                  ? StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryPrimary)
                                  : StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryPrimary),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                // Bug report p.17: a group with no messages yet is drawn by
                // THIS tile, which had no pin / mute icons — so pinning
                // "Testers" moved it to the top but showed no pin. Same
                // widget GroupsTile uses.
                ChatStateIcons(
                  chatKey: ChatSettingsService.groupKey(groupEntity.groupId),
                  hasPinnedMessage: groupEntity.hasPinnedMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}