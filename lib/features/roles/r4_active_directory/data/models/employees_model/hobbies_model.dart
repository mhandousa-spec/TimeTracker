/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: hobbies_model.dart
/// Purpose: Declares `Hobbies`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Import Timestamp if not already imported

class Hobbies {
  List<String?>? hobbies;
  List<String?>? status;
  List<Timestamp?>? timestamps;
  Hobbies({
    this.hobbies,
    this.status,
    this.timestamps,
  });

  Hobbies copyWith({
    List<String?>? hobbies,
    List<String?>? status,
    List<Timestamp?>? timestamps,
  }) {
    return Hobbies(
      hobbies: hobbies ?? this.hobbies,
      status: status ?? this.status,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Hobbies': hobbies,
      'Status': status,
      'Timestamp': timestamps,
    };
  }

  factory Hobbies.fromMap(Map<String, dynamic> map) {
    return Hobbies(
      hobbies: map['Hobbies'] != null
          ? List<String?>.from(
              (map['Hobbies']),
            )
          : null,
      status: map['Status'] != null
          ? List<String?>.from(
              (map['Status']),
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

  factory Hobbies.fromJson(String source) =>
      Hobbies.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Hobbies(Hobbies: $hobbies, Status: $status, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Hobbies other) {
    if (identical(this, other)) return true;

    return listEquals(other.hobbies, hobbies) &&
        listEquals(other.status, status) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => hobbies.hashCode ^ status.hashCode ^ timestamps.hashCode;
}
