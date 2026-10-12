/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: board_name.dart
/// Purpose: Declares `BoardName`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class BoardName {
  BoardName({
    this.boardgName,
    this.timestamp,
  });

  BoardName.fromJson(dynamic json) {
    boardgName =
        json['Board_Name'] != null ? json['Board_Name'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  List<String>? boardgName;
  List<Timestamp>? timestamp;

  BoardName copyWith({
    List<String>? boardgName,
    List<Timestamp>? timestamp,
  }) =>
      BoardName(
        boardgName: boardgName ?? this.boardgName,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Board_Name'] = boardgName;
    map['Timestamp'] = timestamp;
    return map;
  }
}
