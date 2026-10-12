/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_priority.dart
/// Purpose: Declares `CardPriority`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class CardPriority {
  CardPriority({
    this.cardPriority,
    this.timestamp,
  });

  CardPriority.fromJson(dynamic json) {
    cardPriority =
        json['Card_Priority'] != null ? json['Card_Priority'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  List<String>? cardPriority;
  List<Timestamp>? timestamp;

  CardPriority copyWith({
    List<String>? cardPriority,
    List<Timestamp>? timestamp,
  }) =>
      CardPriority(
        cardPriority: cardPriority ?? this.cardPriority,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Priority'] = cardPriority;
    map['Timestamp'] = timestamp;
    return map;
  }
}
