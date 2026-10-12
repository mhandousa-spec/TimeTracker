/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: start_time.dart
/// Purpose: Declares `StartTime`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class StartTime {
  StartTime({
    this.startTime,
    this.timestamp,
  });

  StartTime.fromJson(dynamic json) {
    startTime =
        json['Start_Time'] != null ? json['Start_Time'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? startTime;
  List<Timestamp>? timestamp;
  StartTime copyWith({
    List<String>? startTime,
    List<Timestamp>? timestamp,
  }) =>
      StartTime(
        startTime: startTime ?? this.startTime,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Start_Time'] = startTime;
    map['Timestamp'] = timestamp;
    return map;
  }
}
