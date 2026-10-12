/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: city_model.dart
/// Purpose: The `City` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class City {
  /// Firestore field keys.
  static const String fieldCity = 'City';
  static const String fieldTimestamp = 'Timestamp';

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
      fieldCity: city,
      fieldTimestamp: timestamps,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      city: map[fieldCity] != null
          ? List<String?>.from(
              (map[fieldCity]),
            )
          : null,
      timestamps: map[fieldTimestamp] != null
          ? List<Timestamp?>.from(
              (map[fieldTimestamp]),
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
