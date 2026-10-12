/// Module: messaging / chat / presentation/ui/widgets/menus/message_menu_popup_button.dart
// Date: 6/8/2024
// By: Nada Mohammed , Youssef Ashraf
// Last update: 28/4/2026
// Objectives: This file is responsible for providing a widget that represents the message menu popup button in the messaging screen.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../../main_controller/helper/chat_settings_service.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/menus/state_drop_down.dart';
import '../../../../../m3_groups/presentation/ui/pages/tablet/tablet_group_chat_profile_view.dart';
import '../../../../domain/enum/chat_actions.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import '../../../controller/main_controllers/group_chat_cubit.dart';
import '../../../controller/main_controllers/single_chat_cubit.dart';
import '../dialogs/disappearing_messages_dialog.dart';
import '../dialogs/mute_notifications_dialog.dart';
import '../dialogs/schedule_message_dialog.dart';

class MessageMenuPopupButton extends StatelessWidget {
  const MessageMenuPopupButton({
    this.isGroup = true,
    super.key,
  });

  final bool isGroup;

  static void _toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: AppColors.primary,
      textColor: AppColors.textButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: AppColors.transparent,
      ),
      child: SizedBox(
        // Height as well as width: the menu is anchored to the BOTTOM of this
        // box, so an unsized trigger made the anchor depend on the svg's
        // intrinsic height.
        width: 36.sp,
        height: 36.sp,
        child: StateDropDown(
            menuWidth: 151.sp, // Figma 6799:8931 (was 170 — bug report #26)
            // 0/0 — StateDropDown now anchors under the trigger itself
            // (PopupMenuPosition.under). These used to be 180.sp / 10.sp,
            // measured from the trigger's TOP, which is what put the menu
            // halfway down the chat instead of beneath the ⋮.
            yOffset: 0,
            xOffset: 0,
            items: isGroup
                ? ChatActionsEnum.groupActions
                : ChatActionsEnum.singleActions,
            currentValue: null,
            customButton: SvgPicture.asset(
              AppAssets.more,
              color: AppColors.text,
            ),
            textButton: "",
            // Labels follow the chat's current state (bug report #19–22).
            labelOf: (Enum value) {
              final cubit = context.read<MasterChatCubit>();
              final key = cubit.chatSettingsKey;
              final isAr = Localizations.localeOf(context).languageCode == 'ar';
              switch (value) {
                case ChatActionsEnum.pin:
                  return ChatSettingsService.isPinned(key)
                      ? (isAr ? 'إلغاء التثبيت' : 'Unpin')
                      : null;
                case ChatActionsEnum.muteNotifications:
                  return ChatSettingsService.isMuted(key)
                      ? (isAr ? 'إلغاء كتم الإشعارات' : 'Unmute Notifications')
                      : null;
                default:
                  return null;
              }
            },
            onChanged: (Enum value) async {
              final cubit = context.read<MasterChatCubit>();
              final isAr = Localizations.localeOf(context).languageCode == 'ar';

              switch (value as ChatActionsEnum) {
              // ── View Contact (single chat) — opens side panel ──
                case ChatActionsEnum.viewContact:
                  cubit.toggleContactInfoState();

              // ── View Group (group chat) ──
                case ChatActionsEnum.viewGroup:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TabletGroupChatProfileView(),
                    ),
                  );

              // ── Pin the CHAT (pin icon on its card) — bug report #21/#22 ──
              // Was toggleChatPin(), which only showed the last message in a
              // strip under the header. Pinning a single MESSAGE is still on
              // the message's own menu.
                case ChatActionsEnum.pin:
                  final pinned = await cubit.togglePinChat();
                  _toast(isAr
                      ? (pinned ? 'تم تثبيت المحادثة' : 'تم إلغاء التثبيت')
                      : (pinned ? 'Chat pinned' : 'Chat unpinned'));

              // ── Media, Links & Docs ──
                case ChatActionsEnum.mediaLinksAndDocs:
                  cubit.toggleMediaState();

              // ── Mute Notifications — Figma 6799:16763 (8 Hours / 1 Week /
              //    Always); unmutes directly when already muted ──
                case ChatActionsEnum.muteNotifications:
                  await showMuteNotificationsDialog(context, cubit);

              // ── Disappearing Messages — Figma 6799:16789 ──
                case ChatActionsEnum.disappearingMessages:
                  await showDisappearingMessagesDialog(context, cubit);

              // ── Schedule Messages — Figma 6799:16821 ──
                case ChatActionsEnum.scheduleMessages:
                  await showScheduleMessageDialog(context, cubit);
              }
            }),
      ),
    );
  }
}