/// Module: messaging / chat / data/models/message/audio_message_model.dart
import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

import 'package:knowticed_plus/core/services/message_module/audio_playback_service.dart';
import 'package:knowticed_plus/core/services/message_module/audio_record_service.dart';

// Date: 2/9/2024
// By: Youssef Ashraf, Nada Mohamed
// Audio Model which is part of message model to handle its own configurations.
//
// UPDATED 2/9/2026 — TWO PLAYBACK BACKENDS.
//
// This class used to expose a bare `PlayerController` (audio_waveforms) and
// let the cubit and the bubble drive it directly. audio_waveforms is
// Android/iOS only, so on macOS every one of those calls threw
// MissingPluginException — `preparePlayer` from this constructor, then
// `startPlayer` / `setRate` from RecordAndAudioCubit — and voice notes could
// not be played at all.
//
// It now owns BOTH backends and exposes one platform-neutral API:
//
//     play() / pause() / stop() / toggle() / setRate() / seek()
//     isCurrentPlaying, position, duration, stateChanges
//
// Callers must use that API. `playerController` is still here because
// `AudioFileWaveforms` needs it, but it is MOBILE ONLY — see its doc.
// See AudioPlaybackService for the full why.

/// Part of Message Model
class AudioMessageModel {
  String audioPath;
  String rate;
  bool isCurrentPlaying;
  Duration duration;
  Duration? speedUpDuration;

  /// Live playhead. Driven by whichever backend is active; the desktop bubble
  /// paints its progress bar straight off this, so it is a [ValueNotifier]
  /// rather than cubit state — a 60fps playhead must not rebuild the chat.
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  /// Fires whenever playback starts, pauses, completes, or learns its real
  /// duration. `RecordAndAudioCubit` listens and re-emits so the play/pause
  /// icon and the timer follow.
  Stream<void> get stateChanges => _stateChanges.stream;
  final StreamController<void> _stateChanges =
      StreamController<void>.broadcast();

  PlayerController? _mobileController;
  ap.AudioPlayer? _desktopPlayer;
  bool _desktopSourceSet = false;
  double _rateValue = 1.0;
  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription>[];

  AudioMessageModel({
    required this.audioPath,
    required this.duration,
    this.speedUpDuration,
    this.isCurrentPlaying = false,
    this.rate = '1.0x',
  }) {
    initializeAudio();
  }

  /// True where playback runs on `audioplayers` instead of `audio_waveforms`.
  bool get usesDesktopPlayer => AudioPlaybackService.usesDesktopPlayer;

  /// MOBILE ONLY. `AudioFileWaveforms` takes a [PlayerController], and there is
  /// no desktop implementation of one — touching this on macOS/Windows/Linux
  /// is exactly the MissingPluginException this class exists to prevent, so
  /// the bubble must check [usesDesktopPlayer] before reading it.
  PlayerController get playerController {
    assert(
      !usesDesktopPlayer,
      'PlayerController (audio_waveforms) has no desktop implementation. '
      'Use play()/pause()/setRate() on AudioMessageModel instead.',
    );
    return _mobileController ??= PlayerController();
  }

  void initializeAudio() {
    // Desktop builds its player lazily on the first play(): a chat can hold
    // dozens of voice notes and an AudioPlayer per bubble is not free.
    if (usesDesktopPlayer) return;

    final controller = playerController;
    controller.preparePlayer(
      volume: 1,
      shouldExtractWaveform: true,
      path: audioPath,
      noOfSamples:
          controller.getNumOfSamples(AudioRecordService.audioWavesSpacing),
    );

    _subs.add(controller.onCompletion.listen((_) {
      isCurrentPlaying = false;
      position.value = Duration.zero;
      _notify();
    }));
  }

  // ── Unified playback API ──────────────────────────────────────────────────

  Future<void> toggle() => isCurrentPlaying ? pause() : play();

  Future<void> play() async {
    if (usesDesktopPlayer) {
      final player = _ensureDesktopPlayer();
      if (!_desktopSourceSet) {
        await player.setSource(AudioPlaybackService.sourceFor(audioPath));
        _desktopSourceSet = true;
        // The stored duration is unreliable (it is persisted in whole MINUTES,
        // so anything under a minute comes back as zero) — the player knows
        // the real one.
        final real = await player.getDuration();
        if (real != null && real > Duration.zero) duration = real;
        await player.setPlaybackRate(_rateValue);
      }
      await player.resume();
    } else {
      await playerController.startPlayer();
    }
    isCurrentPlaying = true;
    _notify();
  }

  Future<void> pause() async {
    if (usesDesktopPlayer) {
      await _desktopPlayer?.pause();
    } else {
      await playerController.pausePlayer();
    }
    isCurrentPlaying = false;
    _notify();
  }

  Future<void> stop() async {
    if (usesDesktopPlayer) {
      await _desktopPlayer?.stop();
    } else {
      await playerController.stopPlayer();
    }
    isCurrentPlaying = false;
    position.value = Duration.zero;
    _notify();
  }

  Future<void> setRate(double value) async {
    _rateValue = value;
    if (usesDesktopPlayer) {
      // Only if a player exists — setting a rate on a note that was never
      // played is a no-op that _rateValue already remembers for us.
      await _desktopPlayer?.setPlaybackRate(value);
    } else {
      await playerController.setRate(value);
    }
    _notify();
  }

  Future<void> seek(Duration to) async {
    if (usesDesktopPlayer) {
      await _desktopPlayer?.seek(to);
      position.value = to;
    } else {
      await playerController.seekTo(to.inMilliseconds);
    }
  }

  /// Remaining time at the current playhead — what the bubble shows while a
  /// note is playing.
  Duration get remaining {
    final left = duration - position.value;
    return left.isNegative ? Duration.zero : left;
  }

  /// Release both backends. Nothing calls this today (the models are rebuilt
  /// from each Firestore snapshot and simply dropped), but a desktop
  /// AudioPlayer holds a native player, so anything that starts caching these
  /// models must call it.
  Future<void> disposeAudio() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
    await _desktopPlayer?.dispose();
    _desktopPlayer = null;
    _mobileController?.dispose();
    _mobileController = null;
    if (!_stateChanges.isClosed) await _stateChanges.close();
  }

  // ── Desktop backend ───────────────────────────────────────────────────────

  ap.AudioPlayer _ensureDesktopPlayer() {
    final existing = _desktopPlayer;
    if (existing != null) return existing;

    final player = ap.AudioPlayer();
    // stop, not release: releasing drops the prepared source on completion and
    // the next tap would have to re-buffer the whole file.
    player.setReleaseMode(ap.ReleaseMode.stop);

    _subs.add(player.onPositionChanged.listen((value) {
      position.value = value;
    }));
    _subs.add(player.onDurationChanged.listen((value) {
      if (value > Duration.zero && value != duration) {
        duration = value;
        _notify();
      }
    }));
    _subs.add(player.onPlayerComplete.listen((_) {
      isCurrentPlaying = false;
      position.value = Duration.zero;
      _notify();
    }));

    _desktopPlayer = player;
    return player;
  }

  void _notify() {
    if (!_stateChanges.isClosed) _stateChanges.add(null);
  }

  // ── Formatting / serialization ────────────────────────────────────────────

  String get formattedDuration => formatDuration(duration);

  String formatDuration(Duration value) {
    if (value.inHours > 0) {
      return "${value.inHours.toString().padLeft(2, '0')}:${value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    }
    return "${value.inMinutes.toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  CountDownTimerFormat get countDownTimerFormat {
    return duration.inHours > 0
        ? CountDownTimerFormat.hoursMinutesSeconds
        : CountDownTimerFormat.minutesSeconds;
  }

  AudioMessageModel copyWith({
    String? audioPath,
    String? rate,
    bool? isCurrentPlaying,
    Duration? duration,
    Duration? speedUpDuration,
  }) {
    return AudioMessageModel(
      audioPath: audioPath ?? this.audioPath,
      rate: rate ?? this.rate,
      isCurrentPlaying: isCurrentPlaying ?? this.isCurrentPlaying,
      duration: duration ?? this.duration,
      speedUpDuration: speedUpDuration ?? this.speedUpDuration,
    );
  }

  static const String AUDIO_PATH = "Media_Link";
  static const String DURATION = "Duration";

  // KNOWN ISSUE (pre-existing): the duration is written in whole MINUTES, so
  // every voice note shorter than 60s round-trips as Duration.zero — which is
  // also why the bubble hides the length for most notes. Changing the unit
  // here means changing what fromMap reads, and old messages already on
  // Firestore carry minutes, so it needs a keyed migration, not a one-liner.
  // Desktop playback sidesteps it by asking the player for the real duration.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DURATION: duration.inMinutes,
      AUDIO_PATH: audioPath,
    };
  }

  factory AudioMessageModel.fromMap(Map<String, dynamic> map) {
    return AudioMessageModel(
      audioPath: map[AUDIO_PATH],
      duration: Duration(minutes: map[DURATION] as int),
    );
  }
}

enum Speeds {
  speed_1,
  speed_1_0_5,
  speed_2,
}

extension GetName on Speeds {
  String get name {
    switch (this) {
      case Speeds.speed_1:
        return '1.0x';
      case Speeds.speed_1_0_5:
        return '1.5x';
      case Speeds.speed_2:
        return '2.0x';
    }
  }

  double get rate {
    switch (this) {
      case Speeds.speed_1:
        return 1.0;
      case Speeds.speed_1_0_5:
        return 1.5;
      case Speeds.speed_2:
        return 2.0;
    }
  }
}
