/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_size_model.dart
/// Purpose: The `Company_Size` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CompanySize {
  /// Firestore field keys.
  static const String fieldCompanySize = 'Company_Size';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? companySize;
  List<Timestamp?>? timestamps;
  CompanySize({
    this.companySize,
    this.timestamps,
  });

  CompanySize copyWith({
    List<String?>? companySize,
    List<Timestamp?>? timestamps,
  }) {
    return CompanySize(
      companySize: companySize ?? this.companySize,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldCompanySize: companySize,
      fieldTimestamp: timestamps,
    };
  }

  factory CompanySize.fromMap(Map<String, dynamic> map) {
    return CompanySize(
      companySize: map[fieldCompanySize] != null
          ? List<String?>.from(
              (map[fieldCompanySize]),
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

  factory CompanySize.fromJson(String source) =>
      CompanySize.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanySize(Company_Size: $companySize, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanySize other) {
    if (identical(this, other)) return true;

    return listEquals(other.companySize, companySize) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companySize.hashCode ^ timestamps.hashCode;
}
