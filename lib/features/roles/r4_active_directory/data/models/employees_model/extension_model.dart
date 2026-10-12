// ignore_for_file: unnecessary_this

/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: extension_model.dart
/// Purpose: Declares `Extension`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Extension {
  List<String?>? extension;
  List<Timestamp?>? timestamps;
  Extension({
    this.extension,
    this.timestamps,
  });

  Extension copyWith({
    List<String?>? extension,
    List<String?>? isSecondExtension,
    List<Timestamp?>? timestamps,
  }) {
    return Extension(
      extension: extension ?? this.extension,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Extension': extension,
      'Timestamp': timestamps,
    };
  }

  factory Extension.fromMap(Map<String, dynamic> map) {
    return Extension(
      extension: map['Extension'] != null
          ? List<String?>.from(
              (map['Extension']),
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

  factory Extension.fromJson(String source) =>
      Extension.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Extension(Extension: $extension, Timestamp: $timestamps,)';

  @override
  bool operator ==(covariant Extension other) {
    if (identical(this, other)) return true;

    return listEquals(other.extension, extension) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => extension.hashCode ^ timestamps.hashCode;
}
