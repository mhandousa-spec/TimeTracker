/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: country_model.dart
/// Purpose: The `Country` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Country {
  /// Firestore field keys.
  static const String fieldCountry = 'Country';
  static const String fieldTimestamp = 'Timestamp';

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
      fieldCountry: country,
      fieldTimestamp: timestamps,
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      country: map[fieldCountry] != null
          ? List<String?>.from(
              (map[fieldCountry]),
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
