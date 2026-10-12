/// Module: messaging / chat / presentation/ui/widgets/bubbles/default_bubble.dart
part of '../../pages/chat_mobile_view.dart';

//Youssef Ashraf


class DefaultBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final bool? hideSeen;
  final Widget content;
  final BoxConstraints? constraints;
  final int index;
  final bool? noMargin;
  final bool? isOverlay;

  const DefaultBubble({
    super.key,
    required this.index,
    this.hideSeen,
    this.constraints,
    this.isOverlay,
    this.noMargin,
    required this.content,
    required this.messageModel,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;

    // ── DEBUG ──
    if (isMe) {
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final cubit = context.read<MasterChatCubit>();
        cubit.resetResources();

        if (cubit.overlayCubit.isVisible) {
          cubit.overlayCubit.removeOverlay();
          return;
        }

        if (cubit.state.selectMessages == true) {
          cubit.toggleSelectMessages(false);
          return;
        }

        // ✅ Use Get.back() since we navigated in with Get.toNamed()
        // Navigator.of(context).pop() pops from the wrong (nested tab) navigator
        Get.back();
      },
      child: BlocBuilder<MasterChatCubit, MasterChatState>(
        builder: (context, state) {
          final cubit = context.read<MasterChatCubit>();

          return GestureDetector(
            onLongPress: () {
              if (isOverlay ?? false) return;

              cubit.overlayCubit.showMessageOverlay(
                content: content,
                context: context,
                index: index,
                isGroup: messageModel.isGroup,
                messageModel: messageModel,
              );
            },
            child: Column(
              children: [
                // ── WhatsApp-style date separator ──
                if (isOverlay == null)
                  _buildDateSeparatorIfNeeded(cubit),

                Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: [
                    Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: noMargin ?? false
                                ? 0
                                : ContextExtension(context).isPhone
                                ? 24.h
                                : 16.h,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Select checkbox (receiver side) ──
                              if (state.selectMessages && !isMe)
                                FrowardCheckBox(isMe: isMe, index: index),

                              // ── Group avatar (receiver side) ──
                              // ── Group avatar (receiver side) ──
                              if (!isMe && messageModel.isGroup)
                                Padding(
                                  padding: EdgeInsetsDirectional.only(end: 8.w),
                                  child: messageModel is GroupMessageEntity
                                      ? AvatarChat(
                                    imageUrl: (messageModel as GroupMessageEntity).senderImage,
                                  )
                                      : ClipRRect(
                                    borderRadius: BorderRadius.circular(30.r),
                                    child: CustomSvgImage(
                                      assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
                                      fit: BoxFit.fill,
                                      width: 40.w,
                                      height: 40.h,
                                    ),
                                  ),
                                ),

                              // ── Bubble ──
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    alignment:
                                    AlignmentDirectional.bottomStart,
                                    children: [
                                      Container(
                                        constraints: constraints ??
                                            BoxConstraints(
                                              minHeight: 41.h,
                                              maxWidth: 186.w,
                                              minWidth: 186.w,
                                            ),
                                        padding:
                                        EdgeInsetsDirectional.only(
                                          start: 8.w,
                                          end: 8.w,
                                          top: 8.h,
                                          bottom: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4.r),
                                          color: messageModel.isMe
                                              ? AppColors.primary
                                              : AppColors.background,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            // ── Replied message ──
                                            if (messageModel
                                                .repliedMessage !=
                                                null)
                                              GestureDetector(
                                                onTap: () {
                                                  cubit.chatScrollCubit
                                                      .scrollAndHighlight(
                                                    messageModel
                                                        .repliedMessage!
                                                        .index,
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                      horizontal: 0.w),
                                                  child: ReplyContent(
                                                    model: messageModel
                                                        .repliedMessage!,
                                                  ),
                                                ),
                                              ),

                                            // ── Main content ──
                                            content,

                                            // ── Time + seen row ──
                                            if (!(hideSeen ?? false))
                                              _buildTimeAndSeenRow(
                                                  context, isMe),
                                          ],
                                        ),
                                      ),

                                      // ── Reacts ──
                                      if (messageModel.reacts.isNotEmpty &&
                                          isOverlay == null)
                                        PositionedDirectional(
                                          bottom: -8.h,
                                          child: CustomStackedAvatars(
                                            avatars: messageModel.reacts
                                                .map((e) => e.getReact)
                                                .toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),

                              // ── Group avatar (sender side) ──
                              if (isMe && messageModel.isGroup)
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: 8.w),
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(30.r),
                                    child: CustomSvgImage(
                                      assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
                                      fit: BoxFit.fill,
                                      width: 40.w,
                                      height: 40.h,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Select checkbox (sender side) ──
                    if (state.selectMessages && isMe)
                      FrowardCheckBox(isMe: isMe, index: index),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── WhatsApp-style date separator logic ──
  Widget _buildDateSeparatorIfNeeded(MasterChatCubit cubit) {
    final messages = cubit.state.messages;
    final currentDate = messageModel.time.toDate();

    // First message → always show date
    if (index == 0) {
      return MessageDate(date: currentDate);
    }

    // Compare with previous message date
    final previousDate = messages[index - 1].time.toDate();
    final bool isDifferentDay = !_isSameDay(currentDate, previousDate);

    if (isDifferentDay) {
      return MessageDate(date: currentDate);
    }

    return const SizedBox.shrink();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTimeAndSeenRow(BuildContext context, bool isMe) {
    final seenAndUnseenEnabled = Get.find<MessagingInitController>()
        .messagingConfigurations
        .seenAndUnseen;

    // ── DEBUG ──
    if (isMe) {
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Star icon (reserved)
        if (false)
          Padding(
            padding: EdgeInsetsDirectional.only(end: 4.w, bottom: 2.h),
            child: Icon(
              Icons.star,
              color: !isMe
                  ? AppColors.secondaryPrimary
                  : AppTheme.contrastGreyColor(),
              size: 12.r,
            ),
          ),

        // Edited label
        if (messageModel.isEdited ?? false)
          Text(
            S.of(context).edited,
            style: StyleText.fontSize10Weight400.copyWith(
              color: isMe ? AppColors.textButton : AppColors.text,
            ),
            softWrap: true,
          ),

        const Spacer(),

        // Time
        Text(
          DateTimeHelper.formatTime(messageModel.time.toDate()),
          style: StyleText.fontSize8Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
            color: !isMe
                ? AppColors.inverseBase
                : AppColors.textButton,
          ),
        ),

        SizedBox(width: 4.w),

        // ── Seen / Sent icon ──



        if (isMe &&
            Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.messages,
              section: MessagesPermissionsSections.messagesPermissions,
              permission: MessagesPermissions.seenAndUnseen,
            ))
          Icon(
            (seenAndUnseenEnabled && messageModel.isSeen)
                ? Icons.done_all
                : Icons.done,
            color: (seenAndUnseenEnabled && messageModel.isSeen)
                ? AppColors.blue
                : AppColors.textButton,
            size: ContextExtension(context).isTablet ? 18.sp : 16.sp,
          ),
      ],
    );
  }
}