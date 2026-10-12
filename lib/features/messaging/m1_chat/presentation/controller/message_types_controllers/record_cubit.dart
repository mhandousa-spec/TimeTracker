/// Module: messaging / chat / presentation/controller/message_types_controllers/record_cubit.dart
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/core/services/message_module/audio_record_service.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../data/models/message/audio_message_model.dart';
import '../main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

// State class for RecordCubit
class RecordState {
  final bool isRecording;
  final int ellapsedSeconds;
  final int ellapsedMinutes;
  final Duration newRecordDuration;
  final AudioMessageModel? currentlyPlayingAudioModel;

  RecordState({
    this.isRecording = false,
    this.ellapsedSeconds = 0,
    this.ellapsedMinutes = 0,
    this.newRecordDuration = Duration.zero,
    this.currentlyPlayingAudioModel,
  });

  RecordState copyWith({
    bool? isRecording,
    int? ellapsedSeconds,
    int? ellapsedMinutes,
    Duration? newRecordDuration,
    AudioMessageModel? Function()? currentlyPlayingAudioModel,
  }) {
    return RecordState(
      isRecording: isRecording ?? this.isRecording,
      ellapsedSeconds: ellapsedSeconds ?? this.ellapsedSeconds,
      ellapsedMinutes: ellapsedMinutes ?? this.ellapsedMinutes,
      newRecordDuration: newRecordDuration ?? this.newRecordDuration,
      currentlyPlayingAudioModel: currentlyPlayingAudioModel != null
          ? currentlyPlayingAudioModel()
          : this.currentlyPlayingAudioModel,
    );
  }
}

// RecordCubit
class RecordCubit extends Cubit<RecordState> {
  RecordCubit({required this.masterChatCubit}) : super(RecordState());

  final MasterChatCubit masterChatCubit;
  final stopwatch = Stopwatch();
  Timer? _timer;

  List<Speeds> speeds = [
    Speeds.speed_1,
    Speeds.speed_1_0_5,
    Speeds.speed_2,
  ];
  int speedIndex = 0;

  Future<void> startPlayingAudio(AudioMessageModel model) async {
    // listen to the player state to update the ui
    model.playerController.addListener(
          () {
        model.playerController.playerState == PlayerState.playing
            ? model.isCurrentPlaying = true
            : model.isCurrentPlaying = false;
        // Trigger rebuild by emitting current state
        emit(state.copyWith());
      },
    );

    // listen to the completion of the audio
    model.playerController.onCompletion.listen((event) {
      model.isCurrentPlaying = false;
      emit(state.copyWith());
    });

    if (state.currentlyPlayingAudioModel != null &&
        !identical(state.currentlyPlayingAudioModel, model) &&
        state.currentlyPlayingAudioModel!.isCurrentPlaying) {
      // Stop the currently playing audio before starting the new one
      await state.currentlyPlayingAudioModel!.playerController.pausePlayer();
    }

    final isPlaying = model.playerController.playerState == PlayerState.playing;
    final isInitialized =
        model.playerController.playerState == PlayerState.initialized;
    final isPaused = model.playerController.playerState == PlayerState.paused;

    // Update the currently playing controller to this one
    emit(state.copyWith(
      currentlyPlayingAudioModel: () => model,
    ));

    if (isInitialized || isPaused) {
      model.isCurrentPlaying = true;
    } else if (isPlaying) {
      await model.playerController.pausePlayer();
    }
  }

  Future<void> startRecording() async {
    final res = await Permission.microphone.status;
    if (res == PermissionStatus.granted) {
      if (state.currentlyPlayingAudioModel != null) {
        //pause so that if i resume it again it can be played
        await state.currentlyPlayingAudioModel!.playerController.pausePlayer();
        state.currentlyPlayingAudioModel!.isCurrentPlaying = false;
        emit(state.copyWith());
      }

      stopwatch.start();
      _timer = Timer.periodic(
        const Duration(seconds: 1),
            (timer) {
          emit(state.copyWith(
            ellapsedSeconds: stopwatch.elapsed.inSeconds % 60,
            ellapsedMinutes: stopwatch.elapsed.inMinutes,
          ));
        },
      );

      final result = await AudioRecordService.startRecording();
      result.fold(
            (l) {
          Fluttertoast.showToast(
            msg: S.current.errorOccuredPleaseTryAgain,
            backgroundColor: AppColors.primary,
            textColor: AppTheme.contrastColor(),
          );
        },
            (r) {
          emit(state.copyWith(isRecording: true));
        },
      );
    } else {
      if (res == PermissionStatus.denied) {
        Fluttertoast.showToast(
          msg: S.current.pleaseEnableMicrophoneService,
          backgroundColor: AppColors.primary,
          textColor: AppTheme.contrastColor(),
        );
        return;
      }

      await Permission.microphone.request();
    }
  }

  Future<void> stopRecording({bool? cancel}) async {
    stopwatch.stop();
    _timer?.cancel();

    // get the duration of the new recording
    final recordDuration = stopwatch.elapsed;

    stopwatch.reset();

    final result = await AudioRecordService.stopAndSave(cancel);

    result.fold(
          (l) {
        Fluttertoast.showToast(
          msg: S.current.errorOccuredPleaseTryAgain,
          backgroundColor: AppColors.primary,
          textColor: AppTheme.contrastColor(),
        );
      },
          (r) {
        emit(state.copyWith(
          isRecording: false,
          ellapsedSeconds: 0,
          ellapsedMinutes: 0,
          newRecordDuration: recordDuration,
        ));

        if (r != null) {
          // Handle the recorded audio file path
          // You might want to call a method on masterChatCubit here
        }
      },
    );
  }

  void stopAudios() {
    if (state.currentlyPlayingAudioModel != null) {
      state.currentlyPlayingAudioModel!.playerController.pausePlayer();
      state.currentlyPlayingAudioModel!.isCurrentPlaying = false;
      state.currentlyPlayingAudioModel!.playerController.stopPlayer();
      emit(state.copyWith());
    }
  }

  Future<void> uploadAudio(AudioMessageModel model) async {
    //Firebase Storage= >  putFile()
    File(model.audioPath);
    //Api (Byte Data)
    await rootBundle.load(model.audioPath);
  }

  Future<void> updateAudioSpeed({required AudioMessageModel audio}) async {
    //here we reset to the first index
    if (speedIndex == speeds.length) {
      speedIndex = 0;
    } else {
      speedIndex++;
    }

    // testing for countdown timer
    if (speeds[speedIndex].rate.toInt() == 2) {
      audio.speedUpDuration = audio.duration ~/ 2;
    } else {
      audio.speedUpDuration =
          audio.duration ~/ (speeds[speedIndex].rate.toInt() + 1);
    }

    audio.rate = speeds[speedIndex].name;
    await audio.playerController.setRate(speeds[speedIndex].rate);

    emit(state.copyWith());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    stopwatch.stop();
    return super.close();
  }
}