/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: bio_in_arabic_model.dart
/// Purpose: Declares `BioInArabic` — the Arabic-language bio.
/// Author: Knowticed Plus team
/// Created at: 24/8/2026
///
/// A separate top-level Firestore field, `Bio_In_Arabic`, exactly like
/// `First_Name_In_Arabic` / `Title_In_Arabic`. It is NOT a sub-key of `Bio`:
/// the two languages keep independent value/timestamp histories, so editing
/// one does not stamp the other.
///
/// Shape mirrors `bio_model.dart` — a parallel list of values and the
/// timestamps at which each was written.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BioInArabic {
  List<String?>? bioInArabic;
  List<Timestamp?>? timestamps;

  BioInArabic({
    this.bioInArabic,
    this.timestamps,
  });

  BioInArabic copyWith({
    List<String?>? bioInArabic,
    List<Timestamp?>? timestamps,
  }) {
    return BioInArabic(
      bioInArabic: bioInArabic ?? this.bioInArabic,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Bio_In_Arabic': bioInArabic,
      'Timestamp': timestamps,
    };
  }

  factory BioInArabic.fromMap(Map<String, dynamic> map) {
    return BioInArabic(
      bioInArabic: map['Bio_In_Arabic'] != null
          ? List<String?>.from(
              (map['Bio_In_Arabic']),
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

  factory BioInArabic.fromJson(String source) =>
      BioInArabic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'BioInArabic(Bio_In_Arabic: $bioInArabic, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant BioInArabic other) {
    if (identical(this, other)) return true;

    return listEquals(other.bioInArabic, bioInArabic) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => bioInArabic.hashCode ^ timestamps.hashCode;
}
