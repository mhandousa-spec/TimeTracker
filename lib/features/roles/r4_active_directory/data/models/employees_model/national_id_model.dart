/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: national_id_model.dart
/// Purpose: Declares `NationalId`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class NationalId {
  List<String?>? nationalId;
  List<Timestamp?>? timestamps;
  NationalId({
    this.nationalId,
    this.timestamps,
  });

  NationalId copyWith({
    List<String?>? nationalId,
    List<Timestamp?>? timestamps,
  }) {
    return NationalId(
      nationalId: nationalId ?? this.nationalId,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'National_Id': nationalId,
      'Timestamp': timestamps,
    };
  }

  factory NationalId.fromMap(Map<String, dynamic> map) {
    return NationalId(
      nationalId: map['National_Id'] != null
          ? List<String?>.from(
              (map['National_Id']),
            )
          : null,
      timestamps: map['Timestamp'] != null
          ? List<Timestamp?>.from(
              (map['Timestamp']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NationalId.fromJson(String source) =>
      NationalId.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'NationalId(National_Id: $nationalId, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant NationalId other) {
    if (identical(this, other)) return true;

    return listEquals(other.nationalId, nationalId) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => nationalId.hashCode ^ timestamps.hashCode;
}
