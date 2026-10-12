/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: language_model.dart
/// Purpose: Declares `Language`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Language {
  List<String?>? languages;
  List<Timestamp?>? timestamps;
  Language({
    this.languages,
    this.timestamps,
  });

  Language copyWith({
    List<String?>? languages,
    List<Timestamp?>? timestamps,
  }) {
    return Language(
      languages: languages ?? this.languages,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Language': languages,
      'Timestamp': timestamps,
    };
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      languages: map['Language'] != null
          ? List<String?>.from(
              (map['Language']),
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

  factory Language.fromJson(String source) =>
      Language.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Language(Language: $languages, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Language other) {
    if (identical(this, other)) return true;

    return listEquals(other.languages, languages) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => languages.hashCode ^ timestamps.hashCode;
}
