/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: audio_record_service.dart
/// Purpose: Declares `AudioRecordService`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 2/9/2026 - Desktop recording via `record`; see the class doc.

import 'dart:io' show Platform;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart' as rec;

import 'package:path_provider/path_provider.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';

//Youssef Ashraf
/// Class for Providing recording /playing audio Services
///
/// ── TWO BACKENDS (2/9/2026) ────────────────────────────────────────────────
///
/// `audio_waveforms` is **Android and iOS only** — it has no macOS, Windows or
/// Linux implementation. You can confirm that in
/// `macos/Flutter/GeneratedPluginRegistrant.swift`, where it is absent. Calling
/// [RecorderController.record] on desktop therefore throws
/// MissingPluginException, which this class caught and turned into a generic
/// Failure, which the cubit showed as "Error Occurred, Please try again". That
/// was the whole reason voice notes never worked on the desktop build — the
/// macOS microphone entitlement was necessary but not sufficient.
///
/// So: `record` (which does support macOS/Windows/Linux) does the recording on
/// desktop, and `audio_waveforms` keeps doing it on mobile, where its
/// [RecorderController] also drives the live waveform UI. Both write the same
/// kind of .m4a to the same directory, so everything downstream —
/// [AudioMessageModel], the upload, playback — is unchanged.
///
/// If voice notes break on ONE platform only, this split is the first place to
/// look.
abstract class AudioRecordService {
  /// True where `audio_waveforms` has no implementation and `record` does.
  static bool get usesDesktopRecorder =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  // ── Mobile backend: audio_waveforms ───────────────────────────────────────

  /// FIXED 2/9/2026 — was `static late final RecorderController`, assigned only
  /// by [initializeController]. That is awaited in `MasterChatCubit._initialize`
  /// and in `MessageCubit`'s tab setup, both inside a silent try/catch — and a
  /// `late final` can only be assigned once, so the SECOND chat cubit's call
  /// threw LateInitializationError into that catch. Lazy and idempotent now, so
  /// the number of callers and their order stop mattering.
  static RecorderController? _recorderController;

  static RecorderController get recorderController =>
      // audio_waveforms 2: the encoder is passed per recording through
      // RecorderSettings (AAC-LC on Android, MPEG4 AAC on iOS by default,
      // which is what the old androidEncoder/iosEncoder setters chose).
      _recorderController ??= RecorderController();

  // ── Desktop backend: record ───────────────────────────────────────────────

  static rec.AudioRecorder? _desktopRecorder;

  static rec.AudioRecorder get _desktop =>
      _desktopRecorder ??= rec.AudioRecorder();

  // set the spacing between the audio waves
  static double get audioWavesSpacing => 5;

  /// Eagerly build the mobile controller. Optional — [recorderController] does
  /// it on demand — and safe to call more than once.
  ///
  /// `Future<void>`, not `void`: both callers await it, and awaiting a `void`
  /// expression does not compile. It used to be an untyped
  /// `static initializeController()`, i.e. `dynamic`, which is why the awaits
  /// were legal before.
  static Future<void> initializeController() async {
    if (usesDesktopRecorder) return;
    recorderController;
  }

  static Future<Either<Failure, void>> startRecording() async {
    try {
      var directory = await getApplicationDocumentsDirectory();

      // -----for saving the file in the external storage if needed-----
      // var directory = Platform.isAndroid
      //     ? await getExternalStorageDirectory() // FOR ANDROID
      //     : await getApplicationSupportDirectory(); //FOR iOS

      // microsecondsSinceEpoch, not `.microsecond` — that is the microsecond
      // FIELD, 0..999, so two recordings a second apart collided routinely and
      // one silently overwrote the other.
      final path =
          "${directory.path}/${DateTime.now().microsecondsSinceEpoch}.m4a";

      if (usesDesktopRecorder) {
        // `record` asks the OS itself (AVCaptureDevice on macOS), which is
        // what raises the system microphone prompt. It needs
        // com.apple.security.device.audio-input + NSMicrophoneUsageDescription
        // in macos/Runner, or it returns false with no prompt at all.
        if (!await _desktop.hasPermission()) {
          return Left(
            FeatureFailure('Microphone permission was not granted'),
          );
        }

        await _desktop.start(
          const rec.RecordConfig(
            encoder: rec.AudioEncoder.aacLc,
            bitRate: 48000,
          ),
          path: path,
        );
        return const Right(null);
      }

      return Right(
        await recorderController.record(
          path: path,
          recorderSettings: const RecorderSettings(bitRate: 48000),
        ),
      );
    } catch (e) {
      return Left(
        FeatureFailure(
          e.toString(),
        ),
      );
    }
  }

  static Future<Either<Failure, String?>> stopAndSave(bool? cancel) async {
    try {
      final path = usesDesktopRecorder
          ? await _desktop.stop()
          : await recorderController.stop();

      if (cancel ?? false) {
        return const Right(null);
      }
      return Right(path);
    } catch (e) {
      return Left(
        FeatureFailure(
          e.toString(),
        ),
      );
    }
  }
}
