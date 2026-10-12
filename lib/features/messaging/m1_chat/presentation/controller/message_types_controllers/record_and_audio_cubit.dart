/// Module: messaging / chat / presentation/controller/message_types_controllers/record_and_audio_cubit.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/main_helper/app_toast.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_types_controllers/record_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/core/services/message_module/audio_record_service.dart';
import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import '../../../data/models/message/audio_message_model.dart';
import '../../../domain/entity/new_message_content_entity.dart';
import '../../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../../../../../core/helper/message_module/main_helper/chat_constants.dart';
import '../main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

///********************** FILE INFO ********************///
/// Class Name: RecordAndAudioCubit
/// Purpose: This class is responsible for handling the record and audio messages.
/// Attributes:
///           MasterChatCubit masterChatCubit - The main cubit that manages the chat.
///           BaseChatRepository chatRepository - The repository that handles the chat data.
/// Created By: Mohamed Elrashidy
/// Created On: 2/11/2024

// State class
class RecordAndAudioState {
  final bool isRecording;
  final bool isProcessing;
  final int elapsedSeconds;
  final int elapsedMinutes;
  final Duration newRecordDuration;
  final int speedIndex;
  final AudioMessageModel? currentlyPlayingAudioModel;
  final String? error;

  RecordAndAudioState({
    this.isRecording = false,
    this.isProcessing = false,
    this.elapsedSeconds = 0,
    this.elapsedMinutes = 0,
    this.newRecordDuration = Duration.zero,
    this.speedIndex = 0,
    this.currentlyPlayingAudioModel,
    this.error,
  });

  RecordAndAudioState copyWith({
    bool? isRecording,
    bool? isProcessing,
    int? elapsedSeconds,
    int? elapsedMinutes,
    Duration? newRecordDuration,
    int? speedIndex,
    AudioMessageModel? Function()? currentlyPlayingAudioModel,
    String? Function()? error,
  }) {
    return RecordAndAudioState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes,
      newRecordDuration: newRecordDuration ?? this.newRecordDuration,
      speedIndex: speedIndex ?? this.speedIndex,
      currentlyPlayingAudioModel: currentlyPlayingAudioModel != null
          ? currentlyPlayingAudioModel()
          : this.currentlyPlayingAudioModel,
      error: error != null ? error() : this.error,
    );
  }
}

// Cubit
class RecordAndAudioCubit extends Cubit<RecordAndAudioState> {
  final MasterChatCubit masterChatCubit;
  final BaseChatRepository chatRepository;
  late RecordCubit recordCubit;

  final stopwatch = Stopwatch();
  Timer? _timer;

  /// Models whose [AudioMessageModel.stateChanges] we already listen to.
  ///
  /// FIXED 2/9/2026 — [startPlayingAudio] used to attach a fresh
  /// `addListener` + `onCompletion.listen` on EVERY tap, so a note played five
  /// times had five live listeners, all emitting. Identity set, because two
  /// different notes can compare equal.
  final Set<AudioMessageModel> _wiredModels = Set.identity();
  final List<StreamSubscription<void>> _modelSubs = <StreamSubscription<void>>[];

  RecordAndAudioCubit({
    required this.masterChatCubit,
    required this.chatRepository,
  }) : super(RecordAndAudioState()) {
    recordCubit = RecordCubit(masterChatCubit: masterChatCubit);
  }

  /// Method Name: startPlayingAudio
  /// Purpose: Start or pause audio playback
  ///
  /// REWRITTEN 2/9/2026 — this used to reach into `model.playerController`
  /// (audio_waveforms) directly, which has no desktop implementation, so on
  /// macOS the first tap threw MissingPluginException out of `startPlayer`.
  /// The model now owns both backends; this only decides WHICH note plays.
  Future<void> startPlayingAudio(AudioMessageModel model) async {
    _wire(model);

    // Stop currently playing audio if different
    final current = state.currentlyPlayingAudioModel;
    if (current != null && !identical(current, model) && current.isCurrentPlaying) {
      await current.pause();
    }

    emit(state.copyWith(currentlyPlayingAudioModel: () => model));

    await model.toggle();
  }

  /// Re-emit whenever a note starts, pauses, finishes or learns its real
  /// duration, so the bubble's play/pause icon and timer follow.
  ///
  /// `copyWith()` with no arguments on purpose: [RecordAndAudioState] does not
  /// override `==`, so a NEW instance is what makes bloc rebuild — the old
  /// `emit(state)` re-emitted the identical object and bloc dropped it, which
  /// is why the icon never flipped.
  void _wire(AudioMessageModel model) {
    if (!_wiredModels.add(model)) return;
    _modelSubs.add(model.stateChanges.listen((_) {
      if (!isClosed) emit(state.copyWith());
    }));
  }

  /// Whether `permission_handler` can answer a microphone question here.
  ///
  /// ADDED 2/9/2026. permission_handler (^11.4.0) ships NO macOS
  /// implementation, so `Permission.microphone.status` on macOS throws
  ///
  ///     MissingPluginException(No implementation found for method
  ///     checkPermissionStatus on channel
  ///     flutter.baseflow.com/permissions/methods)
  ///
  /// straight out of [startRecording] — which is exactly what happened the
  /// first time the composer's mic button was pressed on desktop.
  ///
  /// Desktop does not need it anyway: macOS prompts for the microphone by
  /// itself the first time an app opens an input device, using
  /// NSMicrophoneUsageDescription from Info.plist, and refuses outright
  /// without the com.apple.security.device.audio-input entitlement. Both are
  /// declared in macos/Runner. So on desktop we simply try to record and let
  /// the failure path below report it.
  bool get _usesRuntimePermission =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Method Name: startRecording
  /// Purpose: Start audio recording with permission check
  Future<void> startRecording() async {
    if (_usesRuntimePermission) {
      var res = await Permission.microphone.status;

      // FIXED 2/9/2026 — this used to toast "Please enable microphone
      // service!" and give up on `denied`, and only call `request()` in the
      // else branch, i.e. when the permission was PERMANENTLY denied and
      // requesting can no longer show a prompt. The two were the wrong way
      // round, so the very first tap (state: denied, never asked) never
      // produced a system prompt.
      if (res == PermissionStatus.denied) {
        res = await Permission.microphone.request();
      }

      if (!res.isGranted) {
        AppToast.show('Please enable microphone service!');
        return;
      }
    }

    // Pause currently playing audio
    final playing = state.currentlyPlayingAudioModel;
    if (playing != null) {
      await playing.pause();
      emit(state.copyWith());
    }

    // Start stopwatch and timer
    stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(
        elapsedSeconds: stopwatch.elapsed.inSeconds % 60,
        elapsedMinutes: stopwatch.elapsed.inMinutes,
      ));
    });

    // Start recording
    final result = await AudioRecordService.startRecording();

    result.fold(
          (error) {
        // AppToast, not Fluttertoast: fluttertoast has no macOS
        // implementation, so on desktop the toast reporting this
        // failure threw MissingPluginException and buried the failure
        // it was reporting.
        AppToast.show('Error Occurred, Please try again');
        stopwatch.stop();
        stopwatch.reset();
        _stopTimer();
        emit(state.copyWith(
          isRecording: false,
          elapsedSeconds: 0,
          elapsedMinutes: 0,
          error: () => error.toString(),
        ));
      },
          (success) {
        emit(state.copyWith(
          isRecording: true,
          error: () => null,
        ));
      },
    );
  }

  /// Method Name: stopRecording
  /// Purpose: Stop recording and optionally save
  Future<void> stopRecording({bool? cancel}) async {
    stopwatch.stop();
    final duration = stopwatch.elapsed;
    stopwatch.reset();
    _stopTimer();

    emit(state.copyWith(
      elapsedSeconds: 0,
      elapsedMinutes: 0,
      newRecordDuration: duration,
    ));

    final result = await AudioRecordService.stopAndSave(cancel);

    result.fold(
          (error) {
        AppToast.show('Error Occurred, Please try again');
        emit(state.copyWith(
          isRecording: false,
          error: () => error.toString(),
        ));
      },
          (recordPath) {
        emit(state.copyWith(isRecording: false, error: () => null));

        if (recordPath != null) {
          sendAudioMessage(audio: File(recordPath));
        }
      },
    );
  }

  /// Method Name: stopAudios
  /// Purpose: Stop all currently playing audios
  Future<void> stopAudios() async {
    final playing = state.currentlyPlayingAudioModel;
    if (playing == null) return;
    await playing.stop();
    emit(state.copyWith(currentlyPlayingAudioModel: () => null));
  }

  /// Method Name: updateAudioSpeed
  /// Purpose: Cycle through audio playback speeds
  Future<void> updateAudioSpeed({required AudioMessageModel audio}) async {
    int newSpeedIndex = state.speedIndex;

    // Cycle through speeds
    if (newSpeedIndex >= speeds.length - 1) {
      newSpeedIndex = 0;
    } else {
      newSpeedIndex++;
    }

    final speed = speeds[newSpeedIndex];

    // Update speed-up duration
    if (speed.rate.toInt() == 2) {
      audio.speedUpDuration = audio.duration ~/ 2;
    } else {
      audio.speedUpDuration = audio.duration ~/ (speed.rate.toInt() + 1);
    }

    audio.rate = speed.name;
    // Platform-neutral: audio_waveforms on mobile, audioplayers on desktop.
    // The old `audio.playerController.setRate(...)` here is the exact call
    // that threw MissingPluginException(setRate on channel
    // simform_audio_waveforms_plugin/methods) on macOS.
    await audio.setRate(speed.rate);

    emit(state.copyWith(speedIndex: newSpeedIndex));
  }

  /// Method Name: pickAudio
  /// Purpose: Pick audio files from device
  Future<void> pickAudio({required BuildContext context}) async {
    emit(state.copyWith(isProcessing: true, error: () => null));

    try {
      // Picker owned by MediaPickerService — cubit no longer touches FilePicker (§16).
      final paths = await MediaPickerService()
          .pickFilePaths(allowedExtensions: ChatConstants.audioExtensions);

      emit(state.copyWith(isProcessing: false));

      if (paths.isNotEmpty && context.mounted) {
        await CustomDialogManager.showDialogFlow(
          context: context,
          confirmWidth: 411, // narrower confirm dialog (bug report #7)
          confirmLottie: AppAssets.media,
          confirmTitle: S.of(context).totalPickedFiles,
          confirmSubtitle: paths.length.toString(),
          confirmYesText: S.of(context).send,
          confirmNoText: S.of(context).Cancel,
          onConfirm: () async {
            for (final p in paths) {
              sendAudioMessage(audio: File(p));
            }
            return true;
          },
          successLottie: AppAssets.media,
          successTitle: S.of(context).send,
          successSubtitle: S.of(context).totalPickedFiles,
        );
      }
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        error: () => 'Failed to pick audio files',
      ));
    }
  }

  /// Method Name: sendAudioMessage
  /// Purpose: Send audio message to chat
  Future<void> sendAudioMessage({required File audio}) async {

    try {
      AudioMessageModel audioMessageModel = AudioMessageModel(
        audioPath: audio.path,
        duration: state.newRecordDuration,
      );

      AudioMessageContentEntity messageContentEntity =
      AudioMessageContentEntity(audio: audioMessageModel);

      final currentUser = masterChatCubit.state.currentUser;
      final otherConnectionSide = masterChatCubit.state.otherConnectionSide;

      if (currentUser == null || otherConnectionSide == null) {
        throw Exception('Missing user or connection data');
      }

      await chatRepository.sendNewMessage(
        currentUser: currentUser,
        otherConnectionSide: otherConnectionSide,
        messageContent: messageContentEntity,
      );

      // Reset duration after sending
      emit(state.copyWith(newRecordDuration: Duration.zero));
    } catch (e) {
      emit(state.copyWith(error: () => 'Failed to send audio message'));
    }
  }

  /// Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: () => null));
  }

  /// Reset state
  void reset() {
    _stopTimer();
    stopwatch.stop();
    stopwatch.reset();
    emit(RecordAndAudioState());
  }

  @override
  Future<void> close() async {
    _stopTimer();
    stopwatch.stop();
    for (final sub in _modelSubs) {
      await sub.cancel();
    }
    _modelSubs.clear();
    _wiredModels.clear();
    return super.close();
  }
}

// Speed configurations
List<Speeds> speeds = [
  Speeds.speed_1,
  Speeds.speed_1_0_5,
  Speeds.speed_2,
];
