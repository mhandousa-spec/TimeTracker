part of '../../pages/chat_mobile_view.dart';

//Youssef Ashraf

/// The bar that replaces the composer while a voice note is being recorded.
///
/// REWRITTEN 2/9/2026. It used to be a read-only strip — a timer and the text
/// "swipe left to cancel" — which only made sense next to the phone's
/// hold-to-record mic (the `LongPressDraggable` in mobile_new_message.dart,
/// still disabled behind `if (false)`). The tablet composer runs on macOS and
/// Windows too, where holding and dragging with a mouse is not a gesture, so
/// this now follows WhatsApp *Desktop*:
///
///     [trash]  ● 00:07 ................................  [send]
///
/// Recording starts on a tap of the composer's mic and ends here — trash
/// discards, send stops and uploads. Both go through the one method that
/// already existed for it, `RecordAndAudioCubit.stopRecording(cancel:)`, so
/// there is no second code path to keep in sync.
///
/// It is a [StatefulWidget] only for the pulsing dot; everything else is
/// driven by the cubit.
class RecordingCard extends StatefulWidget {
  const RecordingCard({super.key});

  @override
  State<RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<RecordingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.25,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DI via Bloc — MasterChatCubit is provided by ChatMobileView (§3).
    final controller = context.read<MasterChatCubit>();
    final recordAndAudioCubit = controller.recordAndAudioCubit;
    final bool isTablet = ContextExtension(context).isTablett;

    return Container(
      // 38.sp, the height every other item in the composer row uses, so the
      // row does not jump when recording starts.
      height: 38.sp,
      padding: EdgeInsetsDirectional.only(start: 8.w, end: 6.w),
      decoration: BoxDecoration(
        color: isTablet ? AppColors.background : AppColors.chatField,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // ── Discard ────────────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedbackHelper.triggerHapticFeedback(
                vibration: VibrateType.mediumImpact,
                hapticFeedback: HapticFeedback.mediumImpact,
              );
              recordAndAudioCubit.stopRecording(cancel: true);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: SvgPicture.asset(
                AppAssets.trash,
                width: 18.sp,
                height: 18.sp,
                color: AppColors.red,
              ),
            ),
          ),

          horizontalSpace(10),

          // ── Pulsing "live" dot ─────────────────────────────────────
          FadeTransition(
            opacity: _pulse,
            child: Container(
              width: 8.sp,
              height: 8.sp,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),

          horizontalSpace(8),

          // ── Elapsed time ───────────────────────────────────────────
          BlocBuilder<RecordAndAudioCubit, RecordAndAudioState>(
            bloc: recordAndAudioCubit,
            builder: (context, state) {
              final String elapsed =
                  "${state.elapsedMinutes.toString().padLeft(2, '0')}:${state.elapsedSeconds.toString().padLeft(2, '0')}";
              return Text(
                // Arabic-Indic numerals under Arabic, like every other
                // number in the app.
                LocalizedNumber.digits(context, elapsed),
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text),
              );
            },
          ),

          const Spacer(),

          // ── Stop and send ──────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedbackHelper.triggerHapticFeedback(
                vibration: VibrateType.mediumImpact,
                hapticFeedback: HapticFeedback.mediumImpact,
              );
              // stopRecording(cancel: false) stops the recorder and hands the
              // file straight to sendAudioMessage.
              recordAndAudioCubit.stopRecording(cancel: false);
            },
            child: Container(
              width: 28.sp,
              height: 28.sp,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: context.isArabic ? 3.14 : 0,
                child: SvgPicture.asset(
                  AppAssets.send,
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.textButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
