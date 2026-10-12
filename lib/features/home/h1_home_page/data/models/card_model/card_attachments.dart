/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: card_attachments.dart
/// Purpose: Declares `CardAttachments`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class CardAttachments {
  List<String>? cardAttachments;
  List<String>? cardAttachmentsStatus;
  List<Timestamp>? timestamp;

  CardAttachments({
    this.cardAttachments,
    this.cardAttachmentsStatus,
    this.timestamp,
  });

  CardAttachments.fromJson(dynamic json) {
    cardAttachments = json['Card_Attachments'] != null
        ? json['Card_Attachments'].cast<String>()
        : [];
    cardAttachmentsStatus = json['Card_Attachments_Status'] != null
        ? json['Card_Attachments_Status'].cast<String>()
        : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  CardAttachments copyWith({
    List<String>? cardAttachments,
    List<String>? cardAttachmentsStatus,
    List<Timestamp>? timestamp,
  }) =>
      CardAttachments(
        cardAttachments: cardAttachments ?? this.cardAttachments,
        cardAttachmentsStatus:
            cardAttachmentsStatus ?? this.cardAttachmentsStatus,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Attachments'] = cardAttachments;
    map['Card_Attachments_Status'] = cardAttachmentsStatus;
    map['Timestamp'] = timestamp;
    return map;
  }
}
