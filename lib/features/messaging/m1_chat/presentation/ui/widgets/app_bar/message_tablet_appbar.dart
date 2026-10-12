/// Module: messaging / chat / presentation/ui/widgets/app_bar/message_tablet_appbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../controller/main_controllers/group_chat_cubit.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import '../../../controller/main_controllers/single_chat_cubit.dart';
import '../menus/message_menu_popup_button.dart';
import 'scheduled_message_banner.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/88-stacked_avatars.dart';

class MessageTabletAppBar extends StatelessWidget {
  final double height;
  const MessageTabletAppBar({super.key, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    bool isTablet = ContextExtension(context).isTablett;

    // ✅ Use context.read — MasterChatCubit is provided via BlocProvider.value in ChatTabletView
    final masterChatCubit = context.read<MasterChatCubit>();

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Main AppBar ──
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.sp),
                  topRight: Radius.circular(8.sp),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.2),
                    offset: const Offset(0, 1), // x: 0, y: 4 → pushes shadow downward
                    blurRadius: 1,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: masterChatCubit is SingleChatCubit
                  ? _buildSingleChatAppBar(context, isTablet, state)
                  : masterChatCubit is GroupChatCubit
                  ? _buildGroupAppBar(context, isTablet, state)
                  : const SizedBox(),
            ),

            // ── Pinned Message Preview Strip ──
            if (state.chatPinnedMessage != null)
              _buildPinnedMessageStrip(context, state),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pinned Message Strip (below appbar)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPinnedMessageStrip(BuildContext context, MasterChatState state) {
    final pinnedMsg = state.chatPinnedMessage!;
    final cubit = context.read<MasterChatCubit>();

    return GestureDetector(
      onTap: () {
        // Scroll to the pinned message
        final index = state.messages.indexWhere(
              (m) => m.messageId == pinnedMsg.messageId,
        );
        if (index != -1) {
          cubit.chatScrollCubit.scrollAndHighlight(index);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        color: AppColors.background,
        child: Row(
          children: [
            Icon(
              Icons.push_pin_rounded,
              color: AppColors.primary,
              size: 16.sp,
            ),
            horizontalSpace(8),
            Expanded(
              child: Text(
                pinnedMsg.messageContent ?? '',
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            horizontalSpace(8),
            GestureDetector(
              onTap: () {
                cubit.toggleChatPin();
              },
              child: Icon(
                Icons.close,
                color: AppColors.secondaryBlack,
                size: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Single Chat AppBar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSingleChatAppBar(
      BuildContext context, bool isTablet, MasterChatState state) {
    if (state.otherConnectionSide == null) return const SizedBox();

    final singleConnection =
    state.otherConnectionSide as SingleConnectionEntity;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.sp),
          topRight: Radius.circular(8.sp),
        ),
        color: AppColors.field,
      ),
      padding: EdgeInsetsDirectional.only(
          start: 10.sp, top: 10.sp, bottom: 10.sp, end: 16.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'profileChat',
                    child: Container(
                      height: 45.sp,
                      width: 45.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mediumGrey,
                        image: state.otherConnectionSide!.imageUri.isNotEmpty
                            ? DecorationImage(
                          fit: BoxFit.cover,
                          image: state.otherConnectionSide!.imageUri
                              .contains("http")
                              ? NetworkImage(
                              state.otherConnectionSide!.imageUri)
                              : appImageProvider(state.otherConnectionSide!
                              .imageUri) as ImageProvider,
                        )
                            : null,
                      ),
                      child: state.otherConnectionSide!.imageUri.isEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: CustomSvgImage(
                          assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
                          width: 30.w,
                          height: 30.h,
                          fit: BoxFit.fill,
                        ),
                      )
                          : null,
                    ),
                  ),
                  horizontalSpace(5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 2.sp,
                      children: [
                        Text(
                          singleConnection.name,
                          style: StyleText.fontSize14Weight500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          singleConnection.subInfo,
                          style:
                          StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                        ),
                      ],
                    ),
                  ),
                  // Figma 6799:8931 — next scheduled message, left of ⋮.
                  const ScheduledMessageBanner(),
                  const MessageMenuPopupButton(isGroup: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Group Chat AppBar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGroupAppBar(
      BuildContext context, bool isTablet, MasterChatState state) {
    if (state.otherConnectionSide == null) return const SizedBox();

    final groupEntity = state.otherConnectionSide as GroupEntity;

    return Container(
      padding: EdgeInsetsDirectional.only(
          start: 10.sp, top: 10.sp, bottom: 10.sp, end: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.sp),
          topRight: Radius.circular(8.sp),
        ),
        color: AppColors.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  groupEntity.groupImage == null
                      ? Container(
                    height: 45.sp,
                    width: 45.sp,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.all(6.sp),
                    child: SvgPicture.asset(
                      AppAssets.message,
                      color: AppColors.text,
                      width: 20.sp,
                      height: 20.sp,
                    ),
                  )
                      : Hero(
                    tag: 'profileChat',
                    child: Container(
                      height: 45.sp,
                      width: 45.sp,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image:
                          (groupEntity.imageUri.contains("http"))
                              ? NetworkImage(groupEntity.imageUri)
                              : appImageProvider(groupEntity.imageUri)
                          as ImageProvider,
                        ),
                      ),
                    ),
                  ),
                  horizontalSpace(16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  FormatHelper.capitalize(
                                    groupEntity.primaryLanguageName,
                                  ),
                                  style: StyleText.fontSize14Weight500
                                      .copyWith(height: 1.3),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              verticalSpace(
                                  ContextExtension(context).isTablett ? 4.sp : 8.sp),
                              StackedAvatars(
                                height: 24.sp,
                                avatarColor: AppColors.white,
                                avatarTextColor: AppColors.secondaryBlack,
                                width: 70.sp,
                                fontSize: 10.sp,
                                images: groupEntity.members
                                    .map((e) => "assets/icons_assets/main_icons_assets/assets_male.svg")
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const ScheduledMessageBanner(),
                        const MessageMenuPopupButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}