/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: board_image.dart
/// Purpose: Declares `BoardImage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class BoardImage {
  BoardImage({
    this.boardImage,
    this.timestamp,
  });

  BoardImage.fromJson(dynamic json) {
    boardImage =
        json['Board_Image'] != null ? json['Board_Image'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? boardImage;
  List<Timestamp>? timestamp;
  BoardImage copyWith({
    List<String>? boardImage,
    List<Timestamp>? timestamp,
  }) =>
      BoardImage(
        boardImage: boardImage ?? this.boardImage,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Board_Image'] = boardImage;
    map['Timestamp'] = timestamp;
    return map;
  }
}
