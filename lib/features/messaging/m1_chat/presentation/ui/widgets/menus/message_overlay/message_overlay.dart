/// Module: messaging / chat / presentation/ui/widgets/menus/message_overlay/message_overlay.dart
//Youssef Ashraf
///Overlay widget that pops up when user long press on message

part of '../../../pages/chat_mobile_view.dart';

class MessageOverlay extends StatelessWidget {
  final int index;
  final MessageEntity messageModel;
  final OverlayEntry overlayEntry;

  /// The message bubble the long-press started from.
  ///
  /// NO LONGER RENDERED (2/9/2026) — see the note in [build]. Kept on the
  /// constructor because [OverlayCubit.showMessageOverlay] measures and passes
  /// it, and [bubbleBoxHeight] (derived from it) still drives the vertical
  /// placement below. Restore the `IgnorePointer(child: bubbleBox)` line if the
  /// duplicated bubble is ever wanted back.
  final Widget bubbleBox;
  final Offset position;
  final double bubbleBoxHeight;
  final MasterChatCubit masterChatCubit;

  const MessageOverlay({
    super.key,
    required this.index,
    required this.messageModel,
    required this.overlayEntry,
    required this.position,
    required this.bubbleBox,
    required this.bubbleBoxHeight,
    required this.masterChatCubit,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = messageModel.isMe;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomBarHeight = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    // ✅ Permission checks
    final mainController = Get.find<MainCoreEmployeeController>();

    final bool hasReactionsPermission = mainController.isHasPermission(
      module: Modules.messages,
      permission: MessagesPermissions.reactions,
      section: MessagesPermissionsSections.messagesPermissions,
    );

    // ✅ Reaction bar width
    final double reactionBarWidth =
    (6 * 34.w + 20.w).clamp(0.0, screenWidth - 32.w);

    // ✅ Available space calculations
    final double spaceBelow =
        screenHeight - position.dy - bubbleBoxHeight - bottomBarHeight;
    final double spaceAbove = position.dy - topPadding;

    // ✅ Estimate menu + reaction bar height
    final double reactionBarH =
    hasReactionsPermission ? 48.h + 6.h : 0; // bar + spacing (0 if no permission)
    final double menuEstimateH = 220.h; // approximate menu height

    final bool fitsBelow = spaceBelow >= menuEstimateH + 16.h;
    final bool fitsAbove = spaceAbove >= reactionBarH + 16.h;

    // ✅ Calculate top position
    double? adjustTop;
    double? adjustBottom;

    if (fitsBelow && fitsAbove) {
      // Ideal: place reaction bar above bubble, menu below
      adjustTop = position.dy - reactionBarH + (index == 0 ? 52.h : 0);
    } else if (!fitsBelow) {
      // Not enough space below — anchor to bottom
      adjustBottom = bottomBarHeight + 8.h;
    } else {
      // Not enough space above — anchor to top
      adjustTop = topPadding + 8.h;
    }

    // ✅ Max height for the entire overlay content
    final double maxOverlayHeight =
        screenHeight - topPadding - bottomBarHeight - 16.h;

    return BlocProvider<MasterChatCubit>.value(
      value: masterChatCubit,
      child: BlocBuilder<CommunityCubit, CommunityState>(
        builder: (context, state) {
          final showAdditionalInfo =
          state is CommunityLoaded ? state.showAdditionalInfo : false;

          return Stack(
            children: [
              // ── Dimmed background ─────────────────────────────────────
              Container(color: AppColors.darkWhiteShadow),

              // ── Main overlay content ──────────────────────────────────
              PositionedDirectional(
                start: isMe
                    ? null
                    : ContextExtension(context).isPhone
                    ? 16.w
                    : showAdditionalInfo ?? false
                    ? 32.w
                    : 305.w,
                end: isMe
                    ? ContextExtension(context).isPhone
                    ? 16.w
                    : showAdditionalInfo ?? false
                    ? 320.w
                    : 32.w
                    : null,
                top: adjustTop,
                bottom: adjustBottom,
                child: Material(
                  color: AppColors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxOverlayHeight,
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── 1. Reaction bar (permission gated) ────────
                          if (hasReactionsPermission) ...[
                            _ReactionBar(
                              isMe: isMe,
                              messageIndex: index,
                              masterChatCubit: masterChatCubit,
                              reactionBarWidth: reactionBarWidth,
                              onReact: () =>
                                  masterChatCubit.overlayCubit.removeOverlay(),
                            ),
                            verticalSpace(6),
                          ],
                          // ── 2. Action menu ────────────────────────────
                          //
                          // CHANGED 2/9/2026: a non-interactive COPY of the
                          // bubble used to sit here, between the reaction bar
                          // and the menu —
                          //
                          //     IgnorePointer(child: bubbleBox),
                          //     verticalSpace(8),
                          //
                          // The real bubble is already visible behind the
                          // dimmed backdrop at the same place, so the overlay
                          // showed the message twice and pushed the menu down
                          // the screen. Only the menu is drawn now.
                          MessageMenuItems(
                            overlayEntry: overlayEntry,
                            messageModel: messageModel,
                            index: index,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReactionBar
// ─────────────────────────────────────────────────────────────────────────────

class _ReactionBar extends StatefulWidget {
  final bool isMe;
  final int messageIndex;
  final VoidCallback onReact;
  final MasterChatCubit masterChatCubit;
  final double reactionBarWidth;

  const _ReactionBar({
    required this.isMe,
    required this.messageIndex,
    required this.onReact,
    required this.masterChatCubit,
    required this.reactionBarWidth,
  });

  @override
  State<_ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<_ReactionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleReact(Reacts react, int i) {
    setState(() => _tappedIndex = i);
    widget.masterChatCubit.reactToMessage(
      messageIndex: widget.messageIndex,
      react: react,
    );
    Future.delayed(const Duration(milliseconds: 200), widget.onReact);
  }

  @override
  Widget build(BuildContext context) {
    final reactions = [
      Reacts.like,
      Reacts.love,
      Reacts.xd,
      Reacts.wow,
      Reacts.sad,
      Reacts.clap,
    ];

    return ScaleTransition(
      scale: _scaleAnim,
      alignment: widget.isMe ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Container(
        width: widget.reactionBarWidth,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(40.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(reactions.length, (i) {
            final react = reactions[i];
            final isTapped = _tappedIndex == i;

            return GestureDetector(
              onTap: () => _handleReact(react, i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..translate(0.0, isTapped ? -8.0 : 0.0),
                child: AnimatedScale(
                  scale: isTapped ? 1.4 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: SvgPicture.asset(
                    react.getReact,
                    width: 28.w,
                    height: 28.h,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}