/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_progress.dart
/// Purpose: Declares `CardProgress`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class CardProgress {
  CardProgress({
    this.cardProgress,
    this.timestamp,
  });

  CardProgress.fromJson(dynamic json) {
    cardProgress =
        json['Card_Progress'] != null ? json['Card_Progress'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  List<String>? cardProgress;
  List<Timestamp>? timestamp;

  CardProgress copyWith({
    List<String>? cardProgress,
    List<Timestamp>? timestamp,
  }) =>
      CardProgress(
        cardProgress: cardProgress ?? this.cardProgress,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Progress'] = cardProgress;
    map['Timestamp'] = timestamp;
    return map;
  }
}
