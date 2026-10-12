/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_status.dart
/// Purpose: Declares `CardStatus`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class CardStatus {
  CardStatus({
    this.cardStatus,
    this.timestamp,
  });

  CardStatus.fromJson(dynamic json) {
    cardStatus =
        json['Card_Status'] != null ? json['Card_Status'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? cardStatus;
  List<Timestamp>? timestamp;
  CardStatus copyWith({
    List<String>? cardStatus,
    List<Timestamp>? timestamp,
  }) =>
      CardStatus(
        cardStatus: cardStatus ?? this.cardStatus,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Status'] = cardStatus;
    map['Timestamp'] = timestamp;
    return map;
  }
}
