/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_logo_model.dart
/// Purpose: The `Company_Logo` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CompanyLogo {
  /// Firestore field keys.
  static const String fieldCompanyLogo = 'Company_Logo';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? companyLogo;
  List<Timestamp?>? timestamps;
  CompanyLogo({
    this.companyLogo,
    this.timestamps,
  });

  CompanyLogo copyWith({
    List<String?>? companyLogo,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyLogo(
      companyLogo: companyLogo ?? this.companyLogo,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldCompanyLogo: companyLogo,
      fieldTimestamp: timestamps,
    };
  }

  factory CompanyLogo.fromMap(Map<String, dynamic> map) {
    return CompanyLogo(
      companyLogo: map[fieldCompanyLogo] != null
          ? List<String?>.from(
              (map[fieldCompanyLogo]),
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

  factory CompanyLogo.fromJson(String source) =>
      CompanyLogo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyLogo(Company_Logo: $companyLogo, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyLogo other) {
    if (identical(this, other)) return true;

    return listEquals(other.companyLogo, companyLogo) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyLogo.hashCode ^ timestamps.hashCode;
}
