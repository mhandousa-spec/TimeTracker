/// Module: messaging / chat / presentation/ui/pages/chat_mobile_view.dart
// Date: 6/8/2024
// By: Nada Mohammed , Youssef Ashraf
// Last update: 6/8/2024
// Objectives: This file is responsible for the direct messaging view.

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import '../../../../../../core/helper/main_helper/extensions.dart' hide ContextExtension;
import '../../../domain/enum/reacts.dart';
import '../../../domain/entity/new_message_content_entity.dart'
    show LocationPayload, ContactPayload, PollPayload;
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:knowticed_plus/core/helper/message_module/main_helper/messaging_interface_implementation.dart'
    show MessagingInterfaceImplementation, OpenChatResult, showOpenChatFailure;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/helper_controllers/chat_scroll_cubit.dart';
import 'package:knowticed_plus/core/enums/message_module/permissions/messages_permissions.dart';
import 'package:knowticed_plus/core/enums/message_module/permissions/messages_permissions_sections.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:video_player/video_player.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/services/message_module/audio_record_service.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/haptic_feedback_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_font_weights.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import '../../../../../../core/helper/message_module/interface/controller/messaging_init_controller.dart';
import '../../../../m2_connections/presentation/controller/community_controller.dart';
import '../../../../m3_groups/presentation/ui/widgets/avatar_chat.dart';
import '../../../data/models/chat_enums.dart';
import '../../controller/message_controller.dart';
import '../widgets/cards/message_date_card.dart';
import '../../../../m2_connections/presentation/controller/connections_controller.dart';
import '../../../../m3_groups/presentation/controller/groups_controller.dart';
import '../../../data/models/message/audio_message_model.dart';
import '../../../data/models/message/message_model.dart';
import '../../../domain/entity/group_message_entity.dart';
import '../../../domain/entity/message_entity.dart';
import '../../../domain/enum/file_types.dart';
import '../../../../../../core/helper/message_module/main_helper/message_action_types.dart';
import '../../../../../../core/helper/message_module/main_helper/update_ui_ids.dart';
import '../../controller/main_controllers/master_chat_cubit.dart';
import '../../../../main_controller/helper/poll_votes_service.dart';
import '../../../../../../core/custom/23-custom_check_box.dart';
import '../../controller/message_types_controllers/record_and_audio_cubit.dart';
import '../widgets/app_bar/message_mobile_appbar.dart';
import '../widgets/media_links_widget.dart';
import '../widgets/menus/message_overlay/forward_message_dialog.dart';
import '../widgets/pinned_message.dart';
import '../widgets/send_new_message/mobile_new_message.dart';
import '../widgets/video_player_view.dart';
import './all_chat_view_tablet.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/forward_message_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/pin_message_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/reply_message_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/edit_and_delete_message_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/overlay_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_types_controllers/record_and_audio_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_types_controllers/image_message_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_types_controllers/text_message_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_types_controllers/document_message_cubit.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/88-stacked_avatars.dart';
import 'package:knowticed_plus/core/custom/74-custom_stacked_avatars.dart';
part '../widgets/bubbles/audio_bubble.dart';
part '../widgets/bubbles/default_bubble.dart';
part '../widgets/bubbles/deleted_bubble.dart';
part '../widgets/bubbles/doc_bubble.dart';
part '../widgets/bubbles/forward_checkbox/forward_checkbox.dart';
part '../widgets/bubbles/image_bubble.dart';
part '../widgets/bubbles/location_bubble.dart';
part '../widgets/bubbles/shared_location_contact_bubbles.dart';
part '../widgets/bubbles/message_bubble.dart';
part '../widgets/bubbles/poll/poll_bubble.dart';
part '../widgets/bubbles/poll/live_poll_bubble.dart';
part '../widgets/bubbles/poll/widgets/animated_votes_bar.dart';
part '../widgets/bubbles/poll/widgets/poll_checkbox.dart';
part '../widgets/bubbles/poll/widgets/poll_radio.dart';
part '../widgets/bubbles/reaction/reaction_widget.dart';
part '../widgets/bubbles/video_bubble.dart';
part '../widgets/menus/message_overlay/menu_items.dart';
part '../widgets/menus/message_overlay/message_overlay.dart';
part '../widgets/cards/recording_card.dart';
part '../widgets/cards/select_forward_msgs_card.dart';
part '../widgets/message_list_view.dart';
part '../widgets/reply_content.dart';

class ChatMobileView extends StatelessWidget {
  /// The active chat cubit (SingleChatCubit or GroupChatCubit). Injected by the
  /// navigator (no GetX service-location — §3).
  final MasterChatCubit masterChatCubit;
  final ConnectionsCubit connectionsCubit;

  /// Only present for group chats (needed by MentionCard). Null for single chat.
  final GroupsCubit? groupsCubit;

  const ChatMobileView({
    super.key,
    required this.masterChatCubit,
    required this.connectionsCubit,
    this.groupsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final masterChatCubit = this.masterChatCubit;
    final connectionsCubit = this.connectionsCubit;

    // Clear unread messages on init
    if (masterChatCubit.state.otherConnectionSide != null) {
      masterChatCubit.clearNumOfUnReadMessages(
        currentUserId: connectionsCubit.currentUser.userId,
        otherUserId: masterChatCubit.state.otherConnectionSide!.otherSideId,
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<MasterChatCubit>.value(value: masterChatCubit),
        BlocProvider<ConnectionsCubit>.value(value: connectionsCubit),
        if (groupsCubit != null)
          BlocProvider<GroupsCubit>.value(value: groupsCubit!),
        BlocProvider<ForwardMessageCubit>.value(
          value: masterChatCubit.forwardMessageCubit,
        ),
        BlocProvider<PinMessageCubit>.value(
          value: masterChatCubit.pinnedMessageCubit,
        ),
        BlocProvider<ChatScrollCubit>.value(
          value: masterChatCubit.chatScrollCubit,
        ),
        BlocProvider<ReplyMessageCubit>.value(
          value: masterChatCubit.replyMessageCubit,
        ),
        BlocProvider<EditAndDeleteMessageCubit>.value(
          value: masterChatCubit.editAndDeleteMessageCubit,
        ),
        BlocProvider<OverlayCubit>.value(
          value: masterChatCubit.overlayCubit,
        ),
        BlocProvider<RecordAndAudioCubit>.value(
          value: masterChatCubit.recordAndAudioCubit,
        ),
        BlocProvider<ImageMessageCubit>.value(
          value: masterChatCubit.imageMessageCubit,
        ),
        BlocProvider<TextMessageCubit>.value(
          value: masterChatCubit.textMessageCubit,
        ),
        BlocProvider<DocumentMessageCubit>.value(
          value: masterChatCubit.documentMessageCubit,
        ),
      ],
      child: BlocBuilder<MasterChatCubit, MasterChatState>(
        bloc: masterChatCubit,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.field,
            resizeToAvoidBottomInset: ContextExtension(context).isLandscape ? false : true,
            body: SafeArea(
              child: Column(

                children: [
                  MessageMobileAppBar(),
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(25.sp),
                          child: Column(
                            children: [
                              // PinnedMessage(),
                              verticalSpace(16),
                              Expanded(child: MessageListView(isGroup: false)),
                              const NewMessageMobile(),
                            ],
                          ),
                        ),
                        if (state.isShowMedia) MediaLinksWidget()
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}