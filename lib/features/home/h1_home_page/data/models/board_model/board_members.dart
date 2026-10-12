/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: board_members.dart
/// Purpose: Declares `BoardMember`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class BoardMember {
  List<String>? boardMembers;
  List<String>? boardMembersStatus;
  List<Timestamp>? timestamp;

  BoardMember({
    this.boardMembers,
    this.boardMembersStatus,
    this.timestamp,
  });

  BoardMember.fromJson(dynamic json) {
    boardMembers = json['Board_Members'] != null
        ? json['Board_Members'].cast<String>()
        : [];
    boardMembersStatus = json['Board_Members_Status'] != null
        ? json['Board_Members_Status'].cast<String>()
        : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  BoardMember copyWith({
    List<String>? boardMembers,
    List<String>? boardMembersStatus,
    List<Timestamp>? timestamp,
  }) =>
      BoardMember(
        boardMembers: boardMembers ?? this.boardMembers,
        boardMembersStatus: boardMembersStatus ?? this.boardMembersStatus,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Board_Members'] = boardMembers;
    map['Board_Members_Status'] = boardMembersStatus;
    map['Timestamp'] = timestamp;
    return map;
  }
}
