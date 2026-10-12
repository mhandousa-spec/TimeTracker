/// Module: messaging / chat / data/models/message/video_message_model.dart
import 'dart:io';

import 'package:video_player/video_player.dart';

// Date: 2/9/2024
// By: Youssef Ashraf
// video Model which is part of message model to handle its own configurations.

/// Part of Message Model
class VideoMessageModel {
  String id = DateTime.now().microsecond.toString();

  String videoFilePath;
  late String duration;
  late final VideoPlayerController playerController;
  String? caption;
  VideoMessageModel({
    required this.videoFilePath,
     this.caption,
  }) {
    initializeVideo();
  }

  void initializeVideo() async {
    if(videoFilePath.contains('http')){

      playerController = VideoPlayerController.file(
        File(videoFilePath),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: false),
      )..initialize().then(
          (value) {
            duration = formatDuration(playerController.value.duration);
          },
        );

    }
    else {
      playerController = VideoPlayerController.file(
      File(videoFilePath),
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: false),
    )..initialize().then(
        (value) {
          duration = formatDuration(playerController.value.duration);
        },
      );
    }
  }

  bool get isCurrentPlaying {
    return playerController.value.isPlaying;
  }

  VideoMessageModel copyWith({
    File? videoFile,
  }) {
    return VideoMessageModel(
      videoFilePath: videoFilePath,
      caption: caption,
    );
  }

  static const String videoFileKey = 'Media_Link';
  static const String captionKey = 'Caption';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      videoFileKey: videoFilePath,
      captionKey: caption,
    };
  }

  factory VideoMessageModel.fromMap(Map<String, dynamic> map) {
    return VideoMessageModel(
      videoFilePath: map[videoFileKey],
      caption: map[captionKey],
    );
  }
  String formatDuration(Duration duration) {
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  double getBufferedProgress() {
    final buffered = playerController.value.buffered;

    final bufferedEnd = buffered.last.end;
    final duration = playerController.value.duration;
    return bufferedEnd.inMilliseconds / duration.inMilliseconds;
  }
}