/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: board_department.dart
/// Purpose: Declares `BoardDepartment`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class BoardDepartment {
  BoardDepartment({
    this.boardgDepartment,
    this.timestamp,
  });

  BoardDepartment.fromJson(dynamic json) {
    boardgDepartment = json['Board_Department'] != null
        ? json['Board_Department'].cast<String>()
        : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  List<String>? boardgDepartment;
  List<Timestamp>? timestamp;

  BoardDepartment copyWith({
    List<String>? boardgDepartment,
    List<Timestamp>? timestamp,
  }) =>
      BoardDepartment(
        boardgDepartment: boardgDepartment ?? this.boardgDepartment,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Board_Department'] = boardgDepartment;
    map['Timestamp'] = timestamp;
    return map;
  }
}
