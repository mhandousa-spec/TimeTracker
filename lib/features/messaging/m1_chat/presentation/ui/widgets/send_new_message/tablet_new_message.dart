/// Module: messaging / chat / presentation/ui/widgets/send_new_message/tablet_new_message.dart
// Date: 6/8/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 27/4/2026
// Objectives: This file is responsible for providing a widget that represents the new message input in the direct messaging screen.

import 'dart:io';

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
import '../../../../../../../core/helper/message_module/interface/controller/messaging_init_controller.dart';
import '../cards/edit_card.dart';
import '../../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../../../../../core/helper/message_module/main_helper/message_action_types.dart';
import '../../../controller/main_controllers/group_chat_cubit.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import '../../../controller/message_types_controllers/record_and_audio_cubit.dart';
import '../../pages/chat_mobile_view.dart';
import '../mention_card.dart';
import '../menus/menu_attachment_message.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class NewMessageTablet extends StatelessWidget {
  const NewMessageTablet({super.key});

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isArabic = Get.locale?.toString().contains('ar') ?? false;

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        final cubit = context.read<MasterChatCubit>();

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ── Reply preview ──────────────────────────────────────
            //
            // REBUILT 2/9/2026. It used to be a Stack whose box was placed by
            // `EdgeInsets.only(left: 40.w, right: 90.w)` and whose ✕ was placed
            // by `end: 95.w` — hand-picked numbers that matched nothing in the
            // input row, so the preview was a different width, a different
            // height and a different edge from the field it belongs to. (They
            // are also non-directional `left`/`right`, so they did not mirror
            // in Arabic.)
            //
            // It now goes through _ComposerAlignedRow, which reproduces the
            // input row's own leading and trailing widgets as empty boxes, so
            // the preview lands in EXACTLY the message field's slot whatever
            // the language or which buttons are shown. Height is pinned to the
            // field's 38.sp, and the ✕ lives inside the box (ReplyContent's
            // `trailing`) rather than floating over the text.
            if (state.messageActionType == MessageActionTypes.replyMessage)
              _ComposerAlignedRow(
                child: ReplyContent(
                  model: state.selectedMessage!,
                  padding: EdgeInsets.zero,
                  // Same 38.sp as the message field. maxLines: 1 goes with it —
                  // two 14sp lines do not fit in 38 and would overflow.
                  constraints: BoxConstraints(
                    minHeight: 38.sp,
                    maxHeight: 38.sp,
                  ),
                  maxLines: 1,
                  color: AppColors.background,
                  trailing: GestureDetector(
                    onTap: () =>
                        cubit.replyMessageCubit.cancelReply(context),
                    child: Icon(Icons.close,
                        color: AppColors.secondaryBlack, size: 18.sp),
                  ),
                ),
              ),

            // ── Edit preview ───────────────────────────────────────
            //
            // Same treatment as the reply preview above, for the same reason —
            // it carried its own `right: 90.w, left: 40.w` / `end: 92.w` set of
            // magic numbers, one pixel off from the reply's.
            if (state.messageActionType == MessageActionTypes.editMessage)
              _ComposerAlignedRow(
                child: EditCard(
                  content: state.selectedMessage?.messageContent,
                  constraints: BoxConstraints(
                    minHeight: 38.sp,
                    maxHeight: 38.sp,
                  ),
                  margin: EdgeInsets.only(bottom: 5.h),
                  trailing: GestureDetector(
                    onTap: () =>
                        cubit.editAndDeleteMessageCubit.cancelEdit(context),
                    child: Icon(Icons.close,
                        color: AppColors.secondaryBlack, size: 18.sp),
                  ),
                ),
              ),

            Column(
              children: [
                // ── Mention card ───────────────────────────────────
                if (state is GroupChatState && state.showMentionCard)
                  Row(
                    children: [
                      SizedBox(width: 24.sp + 10.w),
                      Expanded(child: MentionCard()),
                      SizedBox(width: 10.w + 78.w),
                      if (!Platform.isMacOS && !Platform.isWindows)
                        SizedBox(width: 24.sp + 10.w),
                    ],
                  ),

                // ✅ Multi-file preview row (scrollable)
                if (state.hasSelectedFiles)
                  Padding(
                    padding: EdgeInsets.only(
                        right: 40.w, left: 40.w, bottom: 8.h, top: 4.h),
                    child: SizedBox(
                      height: 80.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.selectedMediaPaths.length +
                            state.selectedDocPaths.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          final isMedia =
                              index < state.selectedMediaPaths.length;

                          if (isMedia) {
                            // ── Image/Video thumbnail ──
                            final path = state.selectedMediaPaths[index];
                            return _FilePreviewItem(
                              onRemove: () =>
                                  cubit.removeSelectedMedia(index),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(
                                  File(path),
                                  width: 80.w,
                                  height: 80.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80.w,
                                    height: 80.h,
                                    color: AppColors.background,
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.secondaryBlack,
                                      size: 28.sp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // ── Document icon ──
                            final docIndex =
                                index - state.selectedMediaPaths.length;
                            final path = state.selectedDocPaths[docIndex];
                            final fileName = path.split('/').last;
                            final ext = fileName.contains('.')
                                ? fileName.split('.').last.toUpperCase()
                                : 'DOC';

                            return _FilePreviewItem(
                              onRemove: () =>
                                  cubit.removeSelectedDoc(docIndex),
                              child: Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    // Bug report #14: a PDF shows the app's
                                    // pdf svg instead of a generic file glyph.
                                    ext == 'PDF'
                                        ? SvgPicture.asset(
                                            _kPdfSvg,
                                            width: 32.sp,
                                            height: 32.sp,
                                          )
                                        : Icon(
                                            Icons.insert_drive_file_outlined,
                                            color: AppColors.primary,
                                            size: 28.sp,
                                          ),
                                    SizedBox(height: 2.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w),
                                      child: Text(
                                        ext,
                                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                // ── Input row ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(bottom: 10.sp),
                  // ADDED 2/9/2026. While a voice note is recording the entire
                  // row is replaced by RecordingCard, the way WhatsApp does it
                  // — the bar carries its own trash and send, so leaving the
                  // composer's attachment / gallery / send buttons alongside
                  // it would give the user two sends that mean different
                  // things.
                  //
                  // `bloc:` is passed explicitly rather than resolving
                  // RecordAndAudioCubit off the context: the tablet tree does
                  // not necessarily provide the SAME instance that
                  // MasterChatCubit owns, and it is that instance the mic
                  // button below starts.
                  child: BlocBuilder<RecordAndAudioCubit, RecordAndAudioState>(
                    bloc: cubit.recordAndAudioCubit,
                    builder: (context, audioState) {
                      if (audioState.isRecording) {
                        return const RecordingCard();
                      }

                      return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Attachment button
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          HapticFeedbackHelper.triggerHapticFeedback(
                            vibration: VibrateType.mediumImpact,
                            hapticFeedback: HapticFeedback.mediumImpact,
                          );
                          final masterChatCubit =
                          context.read<MasterChatCubit>();
                          // CHANGED 2/9/2026: was Get.defaultDialog, which is
                          // styled by GetX and not by the app. The attachment
                          // menu now goes through CustomDialogManager like every
                          // other dialog. MenuAttachmentMessage already paints
                          // its own AppColors.card box (330.w, radius 8.r), so
                          // the shell is transparent and unpadded — otherwise
                          // the card renders inside a second card.
                          CustomDialogManager.showContent<void>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            child: MenuAttachmentMessage(
                              masterChatCubit: masterChatCubit,
                            ),
                          );
                        },
                        child: Container(
                          width: 38.sp,
                          height: 38.sp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.sp),
                            color: AppColors.primary,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              AppAssets.add,
                              color: AppColors.textButton,
                              width: 16.sp,
                              height: 16.sp,
                            ),
                          ),
                        ),
                      ),

                      horizontalSpace(10),

                      // Text input
                      //
                      // CHANGED 2/9/2026: the AnimatedSwitcher that swapped
                      // RecordingCard in HERE is gone — recording now replaces
                      // the whole row (see above), so the field simply is not
                      // built while it runs.
                      Expanded(
                        child: Padding(
                                padding: EdgeInsets.only(top: 0.h),
                                // CHANGED 2/9/2026: was a hand-rolled
                                // CustomTextField. Goes through the shared
                                // AppSearchTextField now.
                                //
                                // expanded: false is REQUIRED here — the widget
                                // wraps itself in an Expanded by default, and
                                // the parent is a Padding (already inside the
                                // Row's Expanded), which is not a Flex.
                                //
                                // showSearchIcon: false — this is a composer, not
                                // a search box, so no magnifier prefix.
                                child: AppSearchTextField(
                                  hintText: S.of(context).typeYourMessage,
                                  controller: cubit.textMessageEditingController,
                                  expanded: false,
                                  showSearchIcon: false,
                                  // RAW 38, not 38.sp — CustomTextField does
                                  // `height: widget.height?.sp` internally, so
                                  // passing 38.sp scales it twice and the field
                                  // comes out taller than every sibling.
                                  height: 38,
                                  textAlign: isArabic? TextAlign.right : TextAlign.left,
                                  fillColor: AppColors.background,
                                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                                  onChanged: cubit.setCurrentMessage,
                                  // ✅ NEW: Send message on Enter key press (laptop/desktop)
                                  onSubmitted: (_) {
                                    final hasContent = cubit
                                        .textMessageEditingController
                                        .text
                                        .isNotEmpty ||
                                        state.hasSelectedFiles;
                                    if (!hasContent) return;
                                    HapticFeedbackHelper
                                        .triggerHapticFeedback(
                                      vibration:
                                      VibrateType.mediumImpact,
                                      hapticFeedback:
                                      HapticFeedback.mediumImpact,
                                    );
                                    cubit.applySelectedMessageAction(
                                        context);
                                  },
                                ),
                              ),
                      ),

                      // ── Gallery + mic ────────────────────────────────
                      //
                      // ADDED 2/9/2026, from the MESBAH Figma composer, which
                      // shows both icons between the field and Send. Assets are
                      // the watermark set the design uses, not the older
                      // messaging glyphs.
                      //
                      // The camera block used to be hidden behind
                      // `!Platform.isMacOS && !Platform.isWindows`. That guard
                      // is gone: the design shows these on desktop, and both
                      // actions work there — the picker is a file dialog and
                      // recording goes through AudioRecordService.
                      if (Get.find<MessagingInitController>()
                          .messagingConfigurations
                          .photo) ...[
                        horizontalSpace(10),
                        _ComposerIconButton(
                          asset: AppAssets.cameraWatermark,
                          onTap: () {
                            HapticFeedbackHelper.triggerHapticFeedback(
                              vibration: VibrateType.mediumImpact,
                              hapticFeedback: HapticFeedback.mediumImpact,
                            );
                            // CHANGED 2/9/2026: was MessageTypes.cameraImage,
                            // which opens the CAMERA. This button opens the
                            // gallery / file picker instead.
                            cubit.selectMessageToMakeAction(
                              message: null,
                              actionType: MessageActionTypes.newMessage,
                              newMessageType: MessageTypes.galleryImage,
                              context: context,
                            );
                          },
                        ),
                      ],

                      horizontalSpace(10),

                      // Mic — tap to start; RecordingCard takes over the row
                      // and owns cancel / send.
                      //
                      // Not permission-gated: MessagingConfigurations has no
                      // voice-note flag (createGroup, photo, documents, poll…
                      // but nothing for audio). Adding one means touching the
                      // roles module, which this change does not do.
                      _ComposerIconButton(
                        asset: AppAssets.micWatermark,
                        onTap: () {
                          HapticFeedbackHelper.triggerHapticFeedback(
                            vibration: VibrateType.mediumImpact,
                            hapticFeedback: HapticFeedback.mediumImpact,
                          );
                          FocusScope.of(context).requestFocus(FocusNode());
                          cubit.recordAndAudioCubit.startRecording();
                        },
                      ),

                      horizontalSpace(10),

                      // ✅ Send button — spinner while uploading
                      state.isSending
                          ? SizedBox(
                        width: isPortrait ? 38.sp : 78.w,
                        // Same 38.sp as the button it stands in for, so the row
                        // does not resize while a message is uploading.
                        height: 38.sp,
                        child: Center(
                          child: SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                          : ValueListenableBuilder<TextEditingValue>(
                          valueListenable:
                          cubit.textMessageEditingController,
                          builder: (context, textValue, child) {
                            final hasContent =
                                textValue.text.isNotEmpty ||
                                    state.hasSelectedFiles;
                            void send() {
                              if (!hasContent) return;
                              HapticFeedbackHelper
                                  .triggerHapticFeedback(
                                vibration: VibrateType.mediumImpact,
                                hapticFeedback:
                                HapticFeedback.mediumImpact,
                              );
                              cubit.applySelectedMessageAction(
                                  context);
                            }

                            // CHANGED 2/9/2026: the landscape "Send" now uses
                            // the shared customButton.
                            //
                            // Portrait stays a hand-rolled box on purpose:
                            // customButton takes a `title` String only and has
                            // no icon slot, and portrait shows the 20.sp send
                            // arrow (mirrored in Arabic), not a word.
                            //
                            // customButton IGNORES `height` and `radius`
                            // (ButtonSizing enforces 38.sp / 8.r app-wide);
                            // `width` IS honoured. Every other item in this row
                            // is now sized to that same 38.sp so they all line
                            // up. The disabled look is carried by `color`, and
                            // `send()` is a no-op without content, so the tap is
                            // inert either way.
                            if (!isPortrait) {
                              return customButton(
                                title: S.of(context).send,
                                function: send,
                                width: 78.w,
                                color: hasContent
                                    ? AppColors.primary
                                    : AppColors.primary
                                    .withOpacity(0.4),
                                textStyle: StyleText
                                    .fontSize16Weight500
                                    .copyWith(
                                    color: AppColors.textButton),
                              );
                            }

                            return GestureDetector(
                              onTap: send,
                              child: Container(
                                // 38.sp square / radius 8.r — the same box
                                // ButtonSizing gives customButton, so the icon
                                // button and the "Send" button line up.
                                width: 38.sp,
                                height: 38.sp,
                                decoration: BoxDecoration(
                                  color: hasContent
                                      ? AppColors.primary
                                      : AppColors.primary
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: context.isArabic ? 3.14 : 0,
                                  child: SvgPicture.asset(
                                    AppAssets.send,
                                    width: 20.sp,
                                    height: 20.sp,
                                    color: AppColors.textButton,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ComposerAlignedRow — puts [child] in exactly the message field's slot.
//
// ADDED 2/9/2026. The reply and edit previews sit above the input row and have
// to line up with the FIELD, not with the row's outer edges — the row also
// holds the attachment button on one side and gallery / mic / Send on the
// other. Guessing that offset with padding is what the old
// `EdgeInsets.only(left: 40.w, right: 90.w)` was doing, and it was wrong in
// both directions and did not mirror under RTL.
//
// This rebuilds the row's leading and trailing children as empty boxes of the
// same widths, in the same order, so the Expanded in the middle is the same
// Expanded the field gets. Keep the two in step: if a button is added to or
// removed from the input row, add or remove its box here as well.
// ─────────────────────────────────────────────────────────────────────────────

class _ComposerAlignedRow extends StatelessWidget {
  final Widget child;

  const _ComposerAlignedRow({required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final bool showGallery = Get.find<MessagingInitController>()
        .messagingConfigurations
        .photo;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // attachment
        SizedBox(width: 38.sp),
        horizontalSpace(10),

        // the message field's slot
        Expanded(child: child),

        // gallery
        if (showGallery) ...[
          horizontalSpace(10),
          SizedBox(width: 38.sp),
        ],

        // mic
        horizontalSpace(10),
        SizedBox(width: 38.sp),

        // send
        horizontalSpace(10),
        SizedBox(width: isPortrait ? 38.sp : 78.w),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Composer icon button — a 38.sp tap target around a small glyph.
//
// ADDED 2/9/2026. The gallery and mic icons are 20.sp, but every other item in
// the composer row is a 38.sp box (see the ButtonSizing note on Send), and a
// bare SvgPicture is both too small to hit comfortably and shorter than its
// neighbours.
// ─────────────────────────────────────────────────────────────────────────────

class _ComposerIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _ComposerIconButton({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 38.sp,
        height: 38.sp,
        child: Center(
          child: SvgPicture.asset(
            asset,
            color: AppColors.text,
            width: 20.sp,
            height: 20.sp,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ Reusable file preview item with X remove button
// ─────────────────────────────────────────────────────────────────────────────

const String _kPdfSvg =
    'assets/icons_assets/main_icons_assets/pdf_file_red.svg';
const String _kMinusSvg =
    'assets/icons_assets/main_icons_assets/minus_circle_red.svg';

class _FilePreviewItem extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _FilePreviewItem({
    required this.child,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: -4.h,
          end: -4.w,
          // Bug report #14: remove badge is the app's minus svg.
          child: GestureDetector(
            onTap: onRemove,
            child: SvgPicture.asset(
              _kMinusSvg,
              width: 20.sp,
              height: 20.sp,
            ),
          ),
        ),
      ],
    );
  }
}