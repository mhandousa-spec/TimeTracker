/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: board_description.dart
/// Purpose: Declares `BoardDescription`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class BoardDescription {
  BoardDescription({
    this.boardDescription,
    this.timestamp,
  });

  BoardDescription.fromJson(dynamic json) {
    boardDescription = json['Board_Description'] != null
        ? json['Board_Description'].cast<String>()
        : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? boardDescription;
  List<Timestamp>? timestamp;
  BoardDescription copyWith({
    List<String>? boardDescription,
    List<Timestamp>? timestamp,
  }) =>
      BoardDescription(
        boardDescription: boardDescription ?? this.boardDescription,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Board_Description'] = boardDescription;
    map['Timestamp'] = timestamp;
    return map;
  }
}
