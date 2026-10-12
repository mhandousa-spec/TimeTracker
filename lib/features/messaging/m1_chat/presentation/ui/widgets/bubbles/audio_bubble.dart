/// Module: messaging / chat / presentation/ui/widgets/bubbles/audio_bubble.dart
// By: Youssef Ashraf, Nada Mohamed
// Last update: 2/9/2026
// Objectives: This file is responsible for providing a widget that represents a audio bubble in the direct messaging view.
//
// UPDATED 2/9/2026 — DESKTOP PLAYBACK.
//
// Two things were wrong here on macOS:
//
//  1. `AudioFileWaveforms` needs a `PlayerController`, and audio_waveforms has
//     no desktop implementation — so on desktop the waveform never had data
//     and reading `audio.playerController` is now an assert. Desktop draws a
//     seekable progress bar off `AudioMessageModel.position` instead.
//  2. The bubble rebuilt on `MasterChatCubit`, which knows nothing about
//     playback, so the play/pause icon only flipped when something else
//     happened to emit. It listens to `RecordAndAudioCubit` now — with an
//     explicit `bloc:`, because the tablet tree does not necessarily provide
//     the instance MasterChatCubit owns.

part of '../../pages/chat_mobile_view.dart';

class AudioBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const AudioBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;
    var isTablet = ContextExtension(context).isTablett;
    final masterChatCubit = context.read<MasterChatCubit>();
    final audioCubit = masterChatCubit.recordAndAudioCubit;
    final audio = messageModel.audio!;

    return BlocBuilder<RecordAndAudioCubit, RecordAndAudioState>(
      bloc: audioCubit,
      builder: (context, state) {
        return DefaultBubble(
          index: index,
          messageModel: messageModel,
          isGroup: isGroup,
          hideSeen: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => audioCubit.startPlayingAudio(audio),
                    child: SvgPicture.asset(
                      audio.isCurrentPlaying
                          ? AppAssets.pause
                          : AppAssets.play,
                      color: AppColors.greyDark,
                      width: isTablet ? 32.w : 24.w,
                    ),
                  ),
                  Expanded(
                    child: audio.usesDesktopPlayer
                        ? _AudioProgressBar(
                            audio: audio,
                            isMe: isMe,
                            height: 30.h,
                          )
                        : AudioFileWaveforms(
                            margin: EdgeInsets.zero,
                            playerController: audio.playerController,
                            enableSeekGesture: true,
                            waveformType: WaveformType.fitWidth,
                            playerWaveStyle: PlayerWaveStyle(
                              spacing: AudioRecordService.audioWavesSpacing,
                              waveThickness: 2,
                              fixedWaveColor:
                                  isMe ? AppColors.white : AppColors.primary,
                              liveWaveColor: AppColors.black,
                            ),
                            size: Size(isTablet ? 328.w : 146.w, 30.h),
                          ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // if not audio loaded, and is an audio voice message
                  if (audio.duration != Duration.zero)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: 2.w),
                      child: _AudioTimeLabel(audio: audio),
                    ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: audio.duration != Duration.zero ? 15.w : 4.w,
                    ),
                    child: GestureDetector(
                      onTap: () => audioCubit.updateAudioSpeed(audio: audio),
                      child: Text(
                        audio.rate,
                        style: StyleText.fontSize10Weight400
                            .copyWith(color: AppColors.textButton),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (messageModel.isStarred)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: 4.w,
                        bottom: 2.h,
                      ),
                      child: Icon(
                        Icons.star,
                        color: !isMe
                            ? AppColors.primary
                            : AppTheme.contrastGreyColor(),
                        size: isTablet ? 18.r : 12.r,
                      ),
                    ),
                  Text(
                    DateTimeHelper.formatTime(messageModel.time.toDate()),
                    style: StyleText.fontSize8Weight500
                        .copyWith(color: AppColors.secondaryBlack)
                        .copyWith(
                          color: !isMe
                              ? AppColors.inverseBase
                              : AppTheme.contrastGreyColor(),
                        ),
                  ),
                  horizontalSpace(4),
                  if (isMe)
                    Icon(
                      messageModel.isSeen ? Icons.done_all : Icons.done,
                      color: /*messageModel.isRead
                          ? AppColors.blue
                          :*/
                          AppColors.secondaryBlack,
                      size: ContextExtension(context).isTablet ? 18.sp : 16.sp,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The length / countdown under the waveform.
///
/// Mobile keeps the original `TimerCountdown`, which fakes the countdown from
/// `DateTime.now() + duration` — it has no real playhead to read. Desktop has
/// one ([AudioMessageModel.position]), so it shows the true remaining time and
/// stays correct after a seek or a rate change.
class _AudioTimeLabel extends StatelessWidget {
  final AudioMessageModel audio;

  const _AudioTimeLabel({required this.audio});

  @override
  Widget build(BuildContext context) {
    final style = StyleText.fontSize12Weight500.copyWith(
      color: AppColors.textButton,
    );

    if (audio.usesDesktopPlayer) {
      return ValueListenableBuilder<Duration>(
        valueListenable: audio.position,
        builder: (context, _, __) => Text(
          audio.isCurrentPlaying
              ? audio.formatDuration(audio.remaining)
              : audio.formattedDuration,
          style: style,
        ),
      );
    }

    if (!audio.isCurrentPlaying) {
      return Text(audio.formattedDuration, style: style);
    }

    return TimerCountdown(
      colonsTextStyle: style,
      spacerWidth: 0,
      timeTextStyle: style,
      enableDescriptions: false,
      format: audio.countDownTimerFormat,
      endTime: DateTime.now().add(
        audio.rate == Speeds.speed_1.name
            ? audio.duration
            : audio.speedUpDuration!,
      ),
    );
  }
}

/// DESKTOP ONLY. Stand-in for `AudioFileWaveforms`.
///
/// audio_waveforms extracts its waveform natively, so there is nothing to draw
/// on macOS/Windows/Linux. This is a plain seekable track fed by
/// [AudioMessageModel.position] — a ValueNotifier, not cubit state, so the
/// playhead repaints this widget only and not the whole message list.
class _AudioProgressBar extends StatelessWidget {
  final AudioMessageModel audio;
  final bool isMe;
  final double height;

  const _AudioProgressBar({
    required this.audio,
    required this.isMe,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMe ? AppColors.white : AppColors.primary;

    return ValueListenableBuilder<Duration>(
      valueListenable: audio.position,
      builder: (context, position, _) {
        final total = audio.duration.inMilliseconds;
        final progress = total <= 0
            ? 0.0
            : (position.inMilliseconds / total).clamp(0.0, 1.0);

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isRtl = Directionality.of(context) == TextDirection.rtl;

            void seekTo(Offset local) {
              if (total <= 0 || width <= 0) return;
              var ratio = (local.dx / width).clamp(0.0, 1.0);
              if (isRtl) ratio = 1 - ratio;
              audio.seek(Duration(milliseconds: (total * ratio).round()));
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => seekTo(details.localPosition),
              onHorizontalDragUpdate: (details) => seekTo(details.localPosition),
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: Center(
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      Align(
                        alignment:
                            AlignmentDirectional(2 * progress - 1, 0),
                        child: Container(
                          height: 10.r,
                          width: 10.r,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
