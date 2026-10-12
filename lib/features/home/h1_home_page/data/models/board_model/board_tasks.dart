/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: board_tasks.dart
/// Purpose: Declares `BoardTasks`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class BoardTasks {
  BoardTasks({
    this.boardTasks,
    this.timestamp,
  });

  BoardTasks.fromJson(dynamic json) {
    boardTasks =
        json['Board_Tasks'] != null ? json['Board_Tasks'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? boardTasks;
  List<Timestamp>? timestamp;

  BoardTasks copyWith({
    List<String>? boardTasks,
    List<Timestamp>? timestamp,
  }) =>
      BoardTasks(
        boardTasks: boardTasks ?? this.boardTasks,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Board_Tasks'] = boardTasks;
    map['Timestamp'] = timestamp;
    return map;
  }
}
