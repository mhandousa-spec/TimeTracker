/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: title_model.dart
/// Purpose: Declares `TitleModel`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class TitleModel {
  List<String?>? title;
  List<Timestamp?>? timestamps;
  TitleModel({
    this.title,
    this.timestamps,
  });

  TitleModel copyWith({
    List<String?>? title,
    List<Timestamp?>? timestamps,
  }) {
    return TitleModel(
      title: title ?? this.title,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Title': title,
      'Timestamp': timestamps,
    };
  }

  factory TitleModel.fromMap(Map<String, dynamic> map) {
    return TitleModel(
      title: map['Title'] != null
          ? List<String?>.from(
              (map['Title']),
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

  factory TitleModel.fromJson(String source) =>
      TitleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Title(Title: $title, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant TitleModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.title, title) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => title.hashCode ^ timestamps.hashCode;
}
