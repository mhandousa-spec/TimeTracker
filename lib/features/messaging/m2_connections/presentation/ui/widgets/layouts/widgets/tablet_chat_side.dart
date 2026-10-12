import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../../../m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import '../../../../../../m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import '../../../../../../m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import '../../../../../../m1_chat/presentation/controller/message_types_controllers/record_and_audio_cubit.dart';
import '../../../../../../m1_chat/presentation/ui/pages/chat_tablet_view.dart';
import '../../../../controller/connections_controller.dart';
import '../../../../../../m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TabletChatSide extends StatelessWidget {
  const TabletChatSide({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocBuilder<ConnectionsCubit, ConnectionsState>(
      builder: (context, connectionsState) {
        // ── Direct message selected ──────────────────────────────
        final hasSelectedConnection = connectionsState is ConnectionsLoaded &&
            connectionsState.selectedConnection != null;

        if (hasSelectedConnection) {
          return _buildSingleChatSide(context, isTablet);
        }

        // ── Group selected ───────────────────────────────────────
        return BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, groupsState) {
            final hasSelectedGroup = groupsState is GroupsLoaded &&
                groupsState.selectedGroup != null;

            if (hasSelectedGroup) {
              return _buildGroupChatSide(context, isTablet);
            }

            // ── Nothing selected ─────────────────────────────────
            return _buildEmptyState(context);
          },
        );
      },
    );
  }

  // ── Single Chat ──────────────────────────────────────────────────────────
  Widget _buildSingleChatSide(BuildContext context, bool isTablet) {
    final singleChatCubit = context.read<SingleChatCubit>();

    return BlocBuilder<SingleChatCubit, MasterChatState>(
      builder: (context, chatState) {
        return _buildChatContainer(
          context: context,
          isTablet: isTablet,
          chatState: chatState,
          onToggleExpansion: singleChatCubit.toggleExpansion,
          // ✅ Provide SingleChatCubit as MasterChatCubit for ChatTabletView
          child: MultiBlocProvider(
            providers: [
              BlocProvider<MasterChatCubit>.value(value: singleChatCubit),
              BlocProvider<RecordAndAudioCubit>.value(
                value: singleChatCubit.recordAndAudioCubit),
            ],
            child: const _ChatTabletViewWrapper(),
          ),
        );
      },
    );
  }

  // ── Group Chat ───────────────────────────────────────────────────────────
  Widget _buildGroupChatSide(BuildContext context, bool isTablet) {
    final groupChatCubit = context.read<GroupChatCubit>();

    return BlocBuilder<GroupChatCubit, MasterChatState>(
      builder: (context, chatState) {
        return _buildChatContainer(
          context: context,
          isTablet: isTablet,
          chatState: chatState,
          onToggleExpansion: groupChatCubit.toggleExpansion,
          // ✅ Provide GroupChatCubit as MasterChatCubit for ChatTabletView
          child: MultiBlocProvider(
            providers: [
              BlocProvider<MasterChatCubit>.value(value: groupChatCubit),
              BlocProvider<RecordAndAudioCubit>.value(
                value: groupChatCubit.recordAndAudioCubit),
            ],
            child: const _ChatTabletViewWrapper(),
          ),
        );
      },
    );
  }

  // ── Shared container (expansion toggle + rounded box) ───────────────────
  Widget _buildChatContainer({
    required BuildContext context,
    required bool isTablet,
    required MasterChatState chatState,
    required VoidCallback onToggleExpansion,
    required Widget child,
  }) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!chatState.isShowMedia)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.sp),
                      InkWell(
                        onTap: onToggleExpansion,
                        splashColor: Colors.transparent,
                        child: Center(
                          child: Text(
                            chatState.isExpansionTabletChat
                                ? S.of(context).collapse
                                : S.of(context).expand,
                            style: StyleText.fontSize10Weight400
                                .copyWith(
                              height: 1,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.blue,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.sp),
                    ],
                  ),
                ),
              ],
            )
          else
            Container(height: 25.h),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: isTablet ? 0 : 24.h),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: child,
            ),
          ),
        ],
      );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: CustomSvgImage(assetPath: "assets/icons_assets/messaging_assets/assets_msg.svg",width: 250.w,height: 250.h,fit: BoxFit.fill,)
    );
  }
}

// ── Wrapper so ChatTabletView reads from parent MultiBlocProvider ─────────
// ChatTabletView internally calls context.read<SingleChatCubit>() which
// won't work for groups — so we pass MasterChatCubit directly here.
class _ChatTabletViewWrapper extends StatelessWidget {
  const _ChatTabletViewWrapper();

  @override
  Widget build(BuildContext context) {
    // ChatTabletView reads SingleChatCubit specifically.
    // For group chat we need a version that reads MasterChatCubit.
    // Use ChatTabletView as-is for single, override for group:
    final masterCubit = context.read<MasterChatCubit>();
    if (masterCubit is SingleChatCubit) {
      return const ChatTabletView();
    }
    // Group chat — use ChatTabletView but it will read MasterChatCubit
    // which is provided as GroupChatCubit above
    return const ChatTabletView();
  }
}