/// Module: messaging / chat / presentation/ui/widgets/send_new_message/mobile_new_message.dart
// Date: 6/8/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 18/2/2026
// Objectives: This file is responsible for providing a widget that represents the new message input in the direct messaging screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import 'package:knowticed_plus/core/helper/main_helper/haptic_feedback_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import '../../../../../../../core/helper/message_module/interface/controller/messaging_init_controller.dart';
import '../cards/edit_card.dart';
import '../../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../../../../../core/helper/message_module/main_helper/message_action_types.dart';
import '../../../controller/functions_on_messages_controllers/forward_message_cubit.dart';
import '../../../controller/main_controllers/group_chat_cubit.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import '../../pages/chat_mobile_view.dart';
import '../mention_card.dart';
import '../menus/menu_attachment_message.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class NewMessageMobile extends StatelessWidget {
  const NewMessageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    bool isArabic = Get.locale.toString().contains('ar');
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<ForwardMessageCubit, ForwardMessageState>(
      builder: (context, forwardState) {
        return forwardState.selectMessages
            ? SelectForwardMsgsCard(
          selectedMsgsCount:
          forwardState.selectedForwardMessages.length,
        )
            : BlocBuilder<MasterChatCubit, MasterChatState>(
          builder: (context, state) {
            final cubit = context.read<MasterChatCubit>();

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (state.messageActionType ==
                    MessageActionTypes.replyMessage)
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: ReplyContent(
                          padding: EdgeInsets.only(right: 35.w,left: 11.w),
                          model: state.selectedMessage!,
                          constraints: BoxConstraints(
                            maxHeight: 65.h,
                            minHeight: 45.h,
                          ),
                          color:
                          AppColors.darkGrey.withOpacity(0.1),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cubit.replyMessageCubit.cancelReply(context);
                        },
                        child: Padding(
                          padding:
                          EdgeInsetsDirectional.only(end: 11.w),
                          child: Icon(
                            Icons.close,
                            color: AppColors.secondaryBlack,
                            size: 24.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (state.messageActionType ==
                    MessageActionTypes.editMessage)
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: EditCard(
                            content:
                            state.selectedMessage?.messageContent),
                      ),
                      GestureDetector(
                        onTap: () {
                          cubit.editAndDeleteMessageCubit
                              .cancelEdit(context);
                        },
                        child: Padding(
                          padding:
                          EdgeInsetsDirectional.only(end: 8.0.w),
                          child: Icon(
                            Icons.close,
                            color: AppColors.secondaryBlack,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(FocusNode());
                            HapticFeedbackHelper.triggerHapticFeedback(
                              vibration: VibrateType.mediumImpact,
                              hapticFeedback:
                              HapticFeedback.mediumImpact,
                            );

                            // ✅ Read cubit from BlocProvider context
                            // BEFORE opening bottom sheet — the sheet
                            // has a new context with no BlocProvider
                            final masterChatCubit =
                            context.read<MasterChatCubit>();

                            Get.defaultDialog(
                              contentPadding: EdgeInsets.zero,
                              titlePadding: EdgeInsets.zero,
                              backgroundColor: AppColors.card,
                              title: '',
                              content: MenuAttachmentMessage(
                                masterChatCubit: masterChatCubit,
                              ),
                            );
                          },
                          child: Container(
                            width: 26.sp,
                            height: 26.sp,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8.r)
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppAssets.add,
                                color: AppColors.icon,
                                width: 16.w,
                                height: 16.h,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4.sp)
                      ],
                    ),
                    horizontalSpace(10),
                    Expanded(
                      child: Column(
                        children: [
                          if (state is GroupChatState &&
                              state.showMentionCard)
                            MentionCard(),
                          AnimatedSwitcher(
                            duration:
                            const Duration(milliseconds: 350),
                            child: CustomTextField(
                              minLines: 1,
                              height: 36,
                              textAlign: isArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                              hint: S.of(context).typeYourMessage,
                              maxLines: 1,
                              showCharCount: false,
                              hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                              fillColor: AppColors.background,
                              width: double.infinity,
                              controller:
                              cubit.textMessageEditingController,
                              contentPadding:
                              const EdgeInsetsDirectional.only(
                                  top: 7,
                                  bottom: 7,
                                  start: 9,
                                  end: 9),
                              onChanged: cubit.setCurrentMessage,),
                          ),
                        ],
                      ),
                    ),
                    horizontalSpace(10),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable:
                      cubit.textMessageEditingController,
                      builder: (context, textValue, child) {
                        return textValue.text.isEmpty
                            ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            children: [
                        Column(
                        children: [
                        if (Get.find <MessagingInitController>()

                            .messagingConfigurations
                            .photo)
                        GestureDetector(
                        onTap: () {
                        HapticFeedbackHelper
                            .triggerHapticFeedback(
                        vibration: VibrateType
                            .mediumImpact,
                        hapticFeedback:
                        HapticFeedback
                            .mediumImpact,
                        );
                        cubit
                            .selectMessageToMakeAction(
                        message: null,
                        actionType:
                        MessageActionTypes
                            .newMessage,
                        newMessageType: MessageTypes
                            .cameraImage,
                        context: context,
                        );
                        },
                        child: SvgPicture.asset(
                        AppAssets.camera,
                        color: AppColors.text,
                        width: 24.w,
                        height: 24.h,
                        ),
                        ),
                        SizedBox(height: 5.sp)
                        ],
                        ),
                        if (false) horizontalSpace(10),
                        if (false)
                        Column(
                        children: [
                        LongPressDraggable(
                        onDragStarted: () {
                        HapticFeedbackHelper
                            .triggerHapticFeedback(
                        vibration: VibrateType
                            .mediumImpact,
                        hapticFeedback:
                        HapticFeedback
                            .mediumImpact,
                        );
                        cubit.recordAndAudioCubit
                            .startRecording();
                        },
                        onDragEnd: (details) {
                        cubit.recordAndAudioCubit
                            .stopRecording(
                        cancel: Get.locale
                            .toString()
                            .contains('ar')
                        ? details.offset
                            .dx >=
                        20.w
                            : details.offset
                            .dx <=
                        Get.width -
                        100.w,
                        );
                        },
                        feedback: const SizedBox(),
                        axis: Axis.horizontal,
                        child: SvgPicture.asset(
                        AppAssets.mic,
                        color: AppColors.text,
                        ),
                        ),
                        SizedBox(height: 4.sp)
                        ],
                        ),
                        ],
                        )
                            : Column(
                        children: [
                        GestureDetector(
                        onTap: () {
                        HapticFeedbackHelper
                            .triggerHapticFeedback(
                        vibration:
                        VibrateType.mediumImpact,
                        hapticFeedback: HapticFeedback
                            .mediumImpact,
                        );
                        cubit.applySelectedMessageAction(
                        context);
                        cubit.textMessageEditingController
                            .text = "";
                        },
                        child: Container(
                        width: isPortrait ? 38.h : 78.w,
                        height: 38.h,
                        decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                        BorderRadius.circular(
                        5.91.r),
                        ),
                        alignment: Alignment.center,
                        child: isPortrait
                        ? Transform.rotate(
                        angle: context.isArabic
                        ? 3.14
                            : 0,
                        child: SvgPicture.asset(
                        AppAssets.send,
                        width: 20.sp,
                        height: 20.sp,
                        color: AppColors
                            .textButton,
                        ),
                        )
                            : Text(
                        S.of(context).send,
                        style: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
                        ),
                        ),
                        ),
                        ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(),
              ],
            );
          },
        );
      },
    );
  }
}