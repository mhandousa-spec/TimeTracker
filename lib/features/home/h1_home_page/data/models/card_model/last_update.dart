/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: last_update.dart
/// Purpose: Declares `LastUpdate`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class LastUpdate {
  LastUpdate({
    this.lastUpdate,
  });

  LastUpdate.fromJson(dynamic json) {
    lastUpdate =
        json['Last_Update'] != null ? json['Last_Update'].cast<Timestamp>() : [];
  
  }

  List<Timestamp>? lastUpdate;

  LastUpdate copyWith({
    List<Timestamp>? lastUpdate,
  }) =>
      LastUpdate(
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Last_Update'] = lastUpdate;
    return map;
  }
}
