import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of groups model
class GroupsModel {
  List<String?>? groups;
  List<Timestamp?>? timestamps;
  GroupsModel({
    this.groups,
    this.timestamps,
  });

  GroupsModel copyWith({
    List<String?>? groups,
    List<Timestamp?>? timestamps,
  }) {
    return GroupsModel(
      groups: groups ?? this.groups,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Groups': groups,
      'Timestamp': timestamps,
    };
  }

  factory GroupsModel.fromMap(Map<String, dynamic> map) {
    return GroupsModel(
      groups: map['Groups'] != null
          ? List<String?>.from(
              (map['Groups']),
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

  factory GroupsModel.fromJson(String source) =>
      GroupsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Groups(Groups: $groups, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant GroupsModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.groups, groups) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => groups.hashCode ^ timestamps.hashCode;
}
