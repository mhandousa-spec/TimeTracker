/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: city_model.dart
/// Purpose: Declares `City`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class City {
  List<String?>? city;
  List<Timestamp?>? timestamps;
  City({
    this.city,
    this.timestamps,
  });

  City copyWith({
    List<String?>? city,
    List<Timestamp?>? timestamps,
  }) {
    return City(
      city: city ?? this.city,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'City': city,
      'Timestamp': timestamps,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      city: map['City'] != null
          ? List<String?>.from(
              (map['City']),
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

  factory City.fromJson(String source) =>
      City.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'City(City: $city, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant City other) {
    if (identical(this, other)) return true;

    return listEquals(other.city, city) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => city.hashCode ^ timestamps.hashCode;
}
