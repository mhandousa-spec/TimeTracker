/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: country_model.dart
/// Purpose: Declares `Country`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Country {
  List<String?>? country;
  List<Timestamp?>? timestamps;
  Country({
    this.country,
    this.timestamps,
  });

  Country copyWith({
    List<String?>? country,
    List<Timestamp?>? timestamps,
  }) {
    return Country(
      country: country ?? this.country,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Country': country,
      'Timestamp': timestamps,
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      country: map['Country'] != null
          ? List<String?>.from(
              (map['Country']),
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

  factory Country.fromJson(String source) =>
      Country.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Country(Country: $country, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Country other) {
    if (identical(this, other)) return true;

    return listEquals(other.country, country) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => country.hashCode ^ timestamps.hashCode;
}
