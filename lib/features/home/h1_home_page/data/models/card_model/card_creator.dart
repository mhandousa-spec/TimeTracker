/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_creator.dart
/// Purpose: Declares `CardCreator`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class CardCreator {
  List<String>? cardCreator;
  List<Timestamp>? timestamp;

  CardCreator({
    this.cardCreator,
    this.timestamp,
  });

  CardCreator.fromJson(dynamic json) {
    cardCreator =
        json['Card_Creator'] != null ? json['Card_Creator'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  CardCreator copyWith({
    List<String>? cardCreator,
    List<Timestamp>? timestamp,
  }) =>
      CardCreator(
        cardCreator: cardCreator ?? this.cardCreator,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Creator'] = cardCreator;
    map['Timestamp'] = timestamp;
    return map;
  }
}
