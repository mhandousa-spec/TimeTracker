/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_name_model.dart
/// Purpose: The `Company_Name` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CompanyName {
  /// Firestore field keys.
  static const String fieldCompanyName = 'Company_Name';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? companyName;
  List<Timestamp?>? timestamps;
  CompanyName({
    this.companyName,
    this.timestamps,
  });

  CompanyName copyWith({
    List<String?>? companyName,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyName(
      companyName: companyName ?? this.companyName,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldCompanyName: companyName,
      fieldTimestamp: timestamps,
    };
  }

  factory CompanyName.fromMap(Map<String, dynamic> map) {
    return CompanyName(
      companyName: map[fieldCompanyName] != null
          ? List<String?>.from(
              (map[fieldCompanyName]),
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

  factory CompanyName.fromJson(String source) =>
      CompanyName.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyName(Company_Name: $companyName, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyName other) {
    if (identical(this, other)) return true;

    return listEquals(other.companyName, companyName) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyName.hashCode ^ timestamps.hashCode;
}
