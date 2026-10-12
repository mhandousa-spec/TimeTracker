/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: car_plates_model.dart
/// Purpose: Declares `CarPlates`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class CarPlates {
  List<String?>? carPlates;
  List<Timestamp?>? timestamps;
  CarPlates({
    this.carPlates,
    this.timestamps,
  });

  CarPlates copyWith({
    List<String?>? carPlates,
    List<Timestamp?>? timestamps,
  }) {
    return CarPlates(
      carPlates: carPlates ?? this.carPlates,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Car_Plates': carPlates,
      'Timestamp': timestamps,
    };
  }

  factory CarPlates.fromMap(Map<String, dynamic> map) {
    return CarPlates(
      carPlates: map['Car_Plates'] != null
          ? List<String?>.from(
              (map['Car_Plates']),
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

  factory CarPlates.fromJson(String source) =>
      CarPlates.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CarPlates(Car_Plates: $carPlates, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CarPlates other) {
    if (identical(this, other)) return true;

    return listEquals(other.carPlates, carPlates) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => carPlates.hashCode ^ timestamps.hashCode;
}
