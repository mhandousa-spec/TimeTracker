/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: audio_playback_service.dart
/// Purpose: Declares `AudioPlaybackService` — the playback half of the
///          two-backend audio split described in [AudioRecordService].
/// Author: Knowticed Plus team
/// Created: 2/9/2026
///
/// ── WHY THIS EXISTS ────────────────────────────────────────────────────────
///
/// `audio_waveforms` is **Android and iOS only** — still true at 2.0.2, and
/// you can confirm it in `macos/Flutter/GeneratedPluginRegistrant.swift`,
/// where the plugin is absent. Recording was moved to `record` on desktop on
/// 2/9/2026, but PLAYBACK was left on `PlayerController`, so every voice note
/// on macOS blew up as an uncaught async error the moment it was touched:
///
///     MissingPluginException(No implementation found for method setRate on
///     channel simform_audio_waveforms_plugin/methods)
///
/// …and the same for `preparePlayer`, `startPlayer`, `pausePlayer` and
/// `stopPlayer`. `AudioMessageModel.initializeAudio()` calls `preparePlayer`
/// in its CONSTRUCTOR, so on desktop the failure started before the bubble was
/// even tapped — the waveform simply never had any data.
///
/// So: `audioplayers` (macOS / Windows / Linux / mobile, one package) plays on
/// desktop, and `audio_waveforms` keeps playing on mobile, where its
/// [PlayerController] also drives the `AudioFileWaveforms` UI. The split lives
/// in [AudioMessageModel], which exposes one platform-neutral API
/// (`play` / `pause` / `stop` / `setRate` / `seek`) over both.
///
/// If voice notes break on ONE platform only, this split is the first place to
/// look.
library;

import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';

abstract class AudioPlaybackService {
  /// True where `audio_waveforms` has no implementation and `audioplayers`
  /// does. Deliberately the same predicate as
  /// [AudioRecordService.usesDesktopRecorder] — keep the two in step.
  static bool get usesDesktopPlayer =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  /// Build the right `audioplayers` source for a path.
  ///
  /// A voice note the user just recorded is a LOCAL file path; a received one
  /// is the Firebase Storage download URL (`AudioMessageModel.fromMap` reads
  /// `Media_Link`). `audioplayers` needs a different Source class for each,
  /// and streaming the remote one needs `com.apple.security.network.client`,
  /// which `macos/Runner/*.entitlements` already declares.
  static ap.Source sourceFor(String path) {
    final uri = Uri.tryParse(path);
    final isRemote =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    return isRemote ? ap.UrlSource(path) : ap.DeviceFileSource(path);
  }
}
