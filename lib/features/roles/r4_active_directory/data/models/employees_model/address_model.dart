/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: address_model.dart
/// Purpose: Declares `Address`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Address {
  List<String?>? address;
  List<Timestamp?>? timestamps;
  Address({
    this.address,
    this.timestamps,
  });

  Address copyWith({
    List<String?>? address,
    List<Timestamp?>? timestamps,
  }) {
    return Address(
      address: address ?? this.address,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Address': address,
      'Timestamp': timestamps,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      address: map['Address'] != null
          ? List<String?>.from(
              (map['Address']),
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

  factory Address.fromJson(String source) =>
      Address.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Address(Address: $address, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Address other) {
    if (identical(this, other)) return true;

    return listEquals(other.address, address) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => address.hashCode ^ timestamps.hashCode;
}
