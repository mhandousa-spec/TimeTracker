/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_industry_model.dart
/// Purpose: The `Company_Industry` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CompanyIndustry {
  /// Firestore field keys.
  static const String fieldCompanyIndustry = 'Company_Industry';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? companyIndustry;
  List<Timestamp?>? timestamps;
  CompanyIndustry({
    this.companyIndustry,
    this.timestamps,
  });

  CompanyIndustry copyWith({
    List<String?>? companyIndustry,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyIndustry(
      companyIndustry: companyIndustry ?? this.companyIndustry,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldCompanyIndustry: companyIndustry,
      fieldTimestamp: timestamps,
    };
  }

  factory CompanyIndustry.fromMap(Map<String, dynamic> map) {
    return CompanyIndustry(
      companyIndustry: map[fieldCompanyIndustry] != null
          ? List<String?>.from(
              (map[fieldCompanyIndustry]),
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

  factory CompanyIndustry.fromJson(String source) =>
      CompanyIndustry.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyIndustry(Company_Industry: $companyIndustry, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyIndustry other) {
    if (identical(this, other)) return true;

    return listEquals(other.companyIndustry, companyIndustry) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyIndustry.hashCode ^ timestamps.hashCode;
}
