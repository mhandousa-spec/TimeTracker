/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: start_date.dart
/// Purpose: Declares `StartDate`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class StartDate {
  StartDate({
    this.startDate,
    this.timestamp,
  });

  StartDate.fromJson(dynamic json) {
    startDate =
        json['Start_Date'] != null ? json['Start_Date'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? startDate;
  List<Timestamp>? timestamp;
  StartDate copyWith({
    List<String>? startDate,
    List<Timestamp>? timestamp,
  }) =>
      StartDate(
        startDate: startDate ?? this.startDate,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Start_Date'] = startDate;
    map['Timestamp'] = timestamp;
    return map;
  }
}
