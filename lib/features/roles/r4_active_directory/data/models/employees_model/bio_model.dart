/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: bio_model.dart
/// Purpose: Declares `Bio`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Bio {
  List<String?>? bio;
  List<Timestamp?>? timestamps;
  Bio({
    this.bio,
    this.timestamps,
  });

  Bio copyWith({
    List<String?>? bio,
    List<Timestamp?>? timestamps,
  }) {
    return Bio(
      bio: bio ?? this.bio,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Bio': bio,
      'Timestamp': timestamps,
    };
  }

  factory Bio.fromMap(Map<String, dynamic> map) {
    return Bio(
      bio: map['Bio'] != null
          ? List<String?>.from(
              (map['Bio']),
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

  factory Bio.fromJson(String source) =>
      Bio.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Bio(Bio: $bio, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Bio other) {
    if (identical(this, other)) return true;

    return listEquals(other.bio, bio) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => bio.hashCode ^ timestamps.hashCode;
}
