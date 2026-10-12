/// Module: messaging / chat / presentation/controller/message_types_controllers/image_message_cubit.dart
import 'dart:io';

import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:mime/mime.dart';

import '../../../data/models/message/video_message_model.dart';
import '../../../domain/entity/new_message_content_entity.dart';
import '../../../domain/repository/chat_repository/base_chat_repository.dart';

// State class
class ImageMessageState {
  final List<File> mediaPaths;
  final double bufferedVideo;
  final bool isPlaying;
  final String videoDuration;
  final bool progressShown;
  final bool slideChanging;

  ImageMessageState({
    this.mediaPaths = const [],
    this.bufferedVideo = 0.0,
    this.isPlaying = false,
    this.videoDuration = '',
    this.progressShown = true,
    this.slideChanging = false,
  });

  ImageMessageState copyWith({
    List<File>? mediaPaths,
    double? bufferedVideo,
    bool? isPlaying,
    String? videoDuration,
    bool? progressShown,
    bool? slideChanging,
  }) {
    return ImageMessageState(
      mediaPaths: mediaPaths ?? this.mediaPaths,
      bufferedVideo: bufferedVideo ?? this.bufferedVideo,
      isPlaying: isPlaying ?? this.isPlaying,
      videoDuration: videoDuration ?? this.videoDuration,
      progressShown: progressShown ?? this.progressShown,
      slideChanging: slideChanging ?? this.slideChanging,
    );
  }
}

// Cubit
class ImageMessageCubit extends Cubit<ImageMessageState> {
  final MasterChatCubit masterChatCubit;
  final BaseChatRepository chatRepository;

  ImageMessageCubit({
    required this.masterChatCubit,
    required this.chatRepository,
  }) : super(ImageMessageState());

  /// Take a single image from camera (picker owned by MediaPickerService — §16).
  Future<void> getImageCamera() async {
    final picked = await MediaPickerService().pickImage(fromCamera: true);
    if (picked?.path != null) {
      final updated = List<File>.from(state.mediaPaths)..add(File(picked!.path!));
      emit(state.copyWith(mediaPaths: updated));

      // ✅ Add to preview queue
      masterChatCubit.addSelectedMediaPaths([picked.path!]);

      masterChatCubit.generateCaptionsFormFields(
          masterChatCubit.state.selectedMediaPaths.length);
    }
  }

  /// ✅ Pick multiple PHOTOS (via MediaPickerService — §16).
  ///
  /// Bug report #16: was pickMediaPaths(), which on Windows only offered
  /// video files. The attachment button is "Photos" now, so images only.
  Future<void> getImageGallery() async {
    final newPaths = await MediaPickerService().pickImagePaths();

    if (newPaths.isNotEmpty) {
      final newFiles = newPaths.map((p) => File(p)).toList();

      final updated = List<File>.from(state.mediaPaths)..addAll(newFiles);
      emit(state.copyWith(mediaPaths: updated));

      // ✅ Add all to preview queue
      masterChatCubit.addSelectedMediaPaths(newPaths);

      masterChatCubit.generateCaptionsFormFields(
          masterChatCubit.state.selectedMediaPaths.length);
    }
  }

  /// ✅ Send multiple media files (called from MasterChatCubit.applySelectedMessageAction)
  Future<void> sendMultipleMedia(List<String> paths) async {

    for (int i = 0; i < paths.length; i++) {
      final filePath = paths[i];
      final file = File(filePath);

      if (!file.existsSync()) {
        continue;
      }

      final mimeType = lookupMimeType(filePath);
      final isVideo = mimeType?.startsWith('video/') ?? false;


      try {
        if (isVideo) {
          await _sendSingleVideo(filePath);
        } else {
          await _sendSingleImage(filePath);
        }
      } catch (e) {
      }
    }

    // Clear internal state
    emit(state.copyWith(mediaPaths: []));
  }

  Future<void> _sendSingleImage(String filePath) async {
    final caption = masterChatCubit.captionControllers.isNotEmpty
        ? masterChatCubit.captionControllers[0].text
        : '';

    NewMessageContentEntity messageContent = ImageMessageContentEntity(
      filePath: filePath,
      caption: caption,
    );

    await chatRepository.sendNewMessage(
      currentUser: masterChatCubit.state.currentUser!,
      otherConnectionSide: masterChatCubit.state.otherConnectionSide!,
      messageContent: messageContent,
    );
  }

  Future<void> _sendSingleVideo(String filePath) async {
    final caption = masterChatCubit.captionControllers.isNotEmpty
        ? masterChatCubit.captionControllers[0].text
        : '';

    NewMessageContentEntity messageContent = VideoMessageContentEntity(
      video: VideoMessageModel(
        videoFilePath: filePath,
        caption: caption,
      ),
      caption: caption,
    );

    await chatRepository.sendNewMessage(
      currentUser: masterChatCubit.state.currentUser!,
      otherConnectionSide: masterChatCubit.state.otherConnectionSide!,
      messageContent: messageContent,
    );
  }

  /// Legacy single-file send (kept for backward compatibility)
  Future<void> sendMessage() async {
    if (state.mediaPaths.isEmpty) {
      return;
    }
    final paths = state.mediaPaths.map((f) => f.path).toList();
    masterChatCubit.setSending(true);
    try {
      await sendMultipleMedia(paths);
    } finally {
      masterChatCubit.setSending(false);
      masterChatCubit.clearAllSelectedFiles();
      emit(state.copyWith(mediaPaths: []));
    }
  }

  // ─── Video player controls (unchanged) ────────────────────────────────

  void videoListener(VideoMessageModel model, [String? id]) {
    model.playerController.addListener(() async {
      emit(state.copyWith(
        isPlaying: model.isCurrentPlaying,
        bufferedVideo: model.playerController.value.position.inMilliseconds
            .toDouble(),
        videoDuration:
        model.formatDuration(model.playerController.value.position),
      ));

      if (model.isCurrentPlaying &&
          state.progressShown &&
          !state.slideChanging) {
        await Future.delayed(const Duration(seconds: 2));
        emit(state.copyWith(progressShown: false));
      }
    });
  }

  void playVideo(VideoMessageModel model) {
    if (model.playerController.value.isPlaying) {
      model.playerController.pause();
    } else {
      model.playerController.play();
    }
  }

  void updateBufferedVideo(double value) {
    emit(state.copyWith(bufferedVideo: value));
  }

  void updateIsPlaying(bool value) {
    emit(state.copyWith(isPlaying: value));
  }

  void updateVideoDuration(String value) {
    emit(state.copyWith(videoDuration: value));
  }

  void updateProgressShown(bool value) {
    emit(state.copyWith(progressShown: value));
  }

  void updateSlideChanging(bool value) {
    emit(state.copyWith(slideChanging: value));
  }

  void clearMediaPath() {
    emit(state.copyWith(mediaPaths: []));
    masterChatCubit.clearAllSelectedFiles();
  }
}