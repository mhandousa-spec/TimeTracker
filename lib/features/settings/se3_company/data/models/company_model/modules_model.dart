/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: modules_model.dart
/// Purpose: The `Modules` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CompanyModules {
  /// Firestore field keys.
  static const String fieldModules = 'Modules';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? modules;
  List<Timestamp?>? timestamps;
  CompanyModules({
    this.modules,
    this.timestamps,
  });

  CompanyModules copyWith({
    List<String?>? modules,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyModules(
      modules: modules ?? this.modules,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldModules: modules,
      fieldTimestamp: timestamps,
    };
  }

  factory CompanyModules.fromMap(Map<String, dynamic> map) {
    return CompanyModules(
      modules: map[fieldModules] != null
          ? List<String?>.from(
              (map[fieldModules]),
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

  factory CompanyModules.fromJson(String source) =>
      CompanyModules.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Modules(Modules: $modules, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyModules other) {
    if (identical(this, other)) return true;

    return listEquals(other.modules, modules) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => modules.hashCode ^ timestamps.hashCode;
}
