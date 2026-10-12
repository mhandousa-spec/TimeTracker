/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_members.dart
/// Purpose: Declares `CardMember`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class CardMember {
  List<String>? cardMembers;
  List<String>? cardMembersStatus;
  List<Timestamp>? timestamp;

  CardMember({
    this.cardMembers,
    this.cardMembersStatus,
    this.timestamp,
  });

  CardMember.fromJson(dynamic json) {
    cardMembers =
        json['Card_Members'] != null ? json['Card_Members'].cast<String>() : [];
    cardMembersStatus = json['Card_Members_Status'] != null
        ? json['Card_Members_Status'].cast<String>()
        : [];
    timestamp = json['Timestamp'] != null
        ? List<Timestamp>.from(json['Timestamp'].map((t) => t is Timestamp ? t : Timestamp.fromMillisecondsSinceEpoch(t.seconds * 1000)))
        : [];
  }

  CardMember copyWith({
    List<String>? cardMembers,
    List<String>? cardMembersStatus,
    List<Timestamp>? timestamp,
  }) =>
      CardMember(
        cardMembers: cardMembers ?? this.cardMembers,
        cardMembersStatus: cardMembersStatus ?? this.cardMembersStatus,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Members'] = cardMembers;
    map['Card_Members_Status'] = cardMembersStatus;
    map['Timestamp'] = timestamp;
    return map;
  }
}
