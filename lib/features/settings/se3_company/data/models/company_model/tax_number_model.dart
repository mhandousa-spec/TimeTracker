/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: tax_number_model.dart
/// Purpose: The `Tax_Number` history field of the company document.
/// Author: MohamedFouad
/// Created at: January/7/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N25: the Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap,
///          and the file carries the standard header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TaxNumber {
  /// Firestore field keys.
  static const String fieldTaxNumber = 'Tax_Number';
  static const String fieldTimestamp = 'Timestamp';

  List<String?>? taxNumber;
  List<Timestamp?>? timestamps;
  TaxNumber({
    this.taxNumber,
    this.timestamps,
  });

  TaxNumber copyWith({
    List<String?>? taxNumber,
    List<Timestamp?>? timestamps,
  }) {
    return TaxNumber(
      taxNumber: taxNumber ?? this.taxNumber,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldTaxNumber: taxNumber,
      fieldTimestamp: timestamps,
    };
  }

  factory TaxNumber.fromMap(Map<String, dynamic> map) {
    return TaxNumber(
      taxNumber: map[fieldTaxNumber] != null
          ? List<String?>.from(
              (map[fieldTaxNumber]),
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

  factory TaxNumber.fromJson(String source) =>
      TaxNumber.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TaxNumer(Tax_Numer: $taxNumber, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant TaxNumber other) {
    if (identical(this, other)) return true;

    return listEquals(other.taxNumber, taxNumber) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => taxNumber.hashCode ^ timestamps.hashCode;
}
