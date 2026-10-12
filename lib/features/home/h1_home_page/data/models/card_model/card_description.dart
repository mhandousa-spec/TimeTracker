/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_description.dart
/// Purpose: Declares `CardDescription`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class CardDescription {
  CardDescription({
    this.cardDescription,
    this.timestamp,
  });

  CardDescription.fromJson(dynamic json) {
    cardDescription = json['Card_Description'] != null
        ? json['Card_Description'].cast<String>()
        : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? cardDescription;
  List<Timestamp>? timestamp;
  CardDescription copyWith({
    List<String>? cardDescription,
    List<Timestamp>? timestamp,
  }) =>
      CardDescription(
        cardDescription: cardDescription ?? this.cardDescription,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Description'] = cardDescription;
    map['Timestamp'] = timestamp;
    return map;
  }
}
