/// Module: messaging / chat / presentation/ui/pages/chat_tablet_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import '../../../../m2_connections/presentation/controller/connections_controller.dart';
import '../../../../m3_groups/domain/entities/group_entity.dart';
import '../../controller/main_controllers/master_chat_cubit.dart';
import '../../controller/main_controllers/single_chat_cubit.dart';
import '../../controller/message_types_controllers/record_and_audio_cubit.dart';
import '../widgets/app_bar/message_tablet_appbar.dart';
import '../widgets/media_links_widget.dart';
import '../widgets/pinned_message.dart';
import '../widgets/send_new_message/tablet_new_message.dart';
import './chat_mobile_view.dart';

class ChatTabletView extends StatelessWidget {
  const ChatTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Read MasterChatCubit — works for both SingleChatCubit and GroupChatCubit
    // since both are provided as MasterChatCubit via BlocProvider.value in TabletChatSide
    final masterChatCubit = context.read<MasterChatCubit>();

    // Clear unread messages only for single chat
    if (masterChatCubit is SingleChatCubit &&
        masterChatCubit.state.otherConnectionSide != null) {
      masterChatCubit.clearNumOfUnReadMessages(
        currentUserId: context.read<ConnectionsCubit>().currentUser.userId,
        otherUserId: masterChatCubit.state.otherConnectionSide!.otherSideId,
      );
    }

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        return PopScope(
          onPopInvoked: (didPop) {},
          child: Row(
            children: [
              // ── Chat Column (always visible) ──────────────────
              Expanded(
                child: Column(
                  children: [
                    MessageTabletAppBar(),
                    // PinnedMessage(),
                    verticalSpace(16),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.sp),
                        child: MessageListView(
                          isGroup: state.otherConnectionSide is GroupEntity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 0.sp,
                        left: 25.sp,
                        right: 25.sp,
                      ),
                      child: NewMessageTablet(),
                    ),
                  ],
                ),
              ),

              // // ── Media Panel (slides in from right) ────────────
              // AnimatedSize(
              //   duration: const Duration(milliseconds: 250),
              //   curve: Curves.easeInOut,
              //   child: state.isShowMedia
              //       ? SizedBox(
              //     width: 280.sp,
              //     child: MediaLinksWidget(),
              //   )
              //       : const SizedBox.shrink(),
              // ),
            ],
          ),
        );
      },
    );
  }
}