/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: employee_photo_model.dart
/// Purpose: Declares `Photo`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Photo {
  List<String?>? photos;
  List<Timestamp?>? timestamps;
  Photo({
    this.photos,
    this.timestamps,
  });

  Photo copyWith({
    List<String?>? photos,
    List<Timestamp?>? timestamps,
  }) {
    return Photo(
      photos: photos ?? this.photos,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Photo': photos,
      'Timestamp': timestamps,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      photos: map['Photo'] != null
          ? List<String?>.from(
              (map['Photo']),
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

  factory Photo.fromJson(String source) =>
      Photo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => ' Photo(Photo: $photos, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Photo other) {
    if (identical(this, other)) return true;

    return listEquals(other.photos, photos) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => photos.hashCode ^ timestamps.hashCode;
}
