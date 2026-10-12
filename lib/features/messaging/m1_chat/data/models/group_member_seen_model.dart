/// Module: messaging / chat / data/models/group_member_seen_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMemberSeenModel{
  String memberId;
  Timestamp seenTime;

  GroupMemberSeenModel({
    required this.memberId,
    required this.seenTime,
  });

  static const String MEMBER_ID = "Member_Id";
  static const String SEEN_TIME = "Seen_Time";

  toMap() {
    return {
      MEMBER_ID: memberId,
      SEEN_TIME: seenTime,
    };
  }

  static fromMap(Map<String, dynamic> map) {
    return GroupMemberSeenModel(
      memberId: map[MEMBER_ID],
      seenTime: map[SEEN_TIME],
    );
  }
}