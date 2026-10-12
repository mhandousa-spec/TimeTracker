/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: end_time.dart
/// Purpose: Declares `EndTime`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class EndTime {
  EndTime({
    this.endTime,
    this.timestamp,
  });

  EndTime.fromJson(dynamic json) {
    endTime = json['End_Time'] != null ? json['End_Time'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? endTime;
  List<Timestamp>? timestamp;
  EndTime copyWith({
    List<String>? endTime,
    List<Timestamp>? timestamp,
  }) =>
      EndTime(
        endTime: endTime ?? this.endTime,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['End_Time'] = endTime;
    map['Timestamp'] = timestamp;
    return map;
  }
}
