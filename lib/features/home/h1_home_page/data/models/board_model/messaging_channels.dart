/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: messaging_channels.dart
/// Purpose: Declares `MessagingChannels`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingChannels {
  MessagingChannels({
    this.messagingChannels,
    this.timestamp,
  });

  MessagingChannels.fromJson(dynamic json) {
    messagingChannels = json['Messaging_Channels'] != null
        ? json['Messaging_Channels'].cast<String>()
        : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? messagingChannels;
  List<Timestamp>? timestamp;
  MessagingChannels copyWith({
    List<String>? messagingChannels,
    List<Timestamp>? timestamp,
  }) =>
      MessagingChannels(
        messagingChannels: messagingChannels ?? this.messagingChannels,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Messaging_Channels'] = messagingChannels;
    map['Timestamp'] = timestamp;
    return map;
  }
}
