/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: academic_model.dart
/// Purpose: Declares `AcademicHistory`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class AcademicHistory {
  List<String?>? graduateFrom;
  List<String?>? university;
  List<String?>? yearOfGraduation;
  List<String?>? gpa;
  List<String?>? graduateFromStatus;
  List<String?>? universityStatus;
  List<String?>? yearOfGraduationStatus;
  List<String?>? gpaStatus;
  List<Timestamp?>? timestamps;
  AcademicHistory({
    this.graduateFrom,
    this.university,
    this.yearOfGraduation,
    this.gpa,
    this.graduateFromStatus,
    this.universityStatus,
    this.yearOfGraduationStatus,
    this.gpaStatus,
    this.timestamps,
  });

  AcademicHistory copyWith({
    List<String?>? graduateFrom,
    List<String?>? university,
    List<String?>? yearOfGraduation,
    List<String?>? gpa,
    List<String?>? graduateFromStatus,
    List<String?>? universityStatus,
    List<String?>? yearOfGraduationStatus,
    List<String?>? gpaStatus,
    List<Timestamp?>? timestamps,
  }) {
    return AcademicHistory(
      graduateFrom: graduateFrom ?? this.graduateFrom,
      university: university ?? this.university,
      yearOfGraduation: yearOfGraduation ?? this.yearOfGraduation,
      gpa: gpa ?? this.gpa,
      graduateFromStatus: graduateFromStatus ?? this.graduateFromStatus,
      universityStatus: universityStatus ?? this.universityStatus,
      yearOfGraduationStatus:
          yearOfGraduationStatus ?? this.yearOfGraduationStatus,
      gpaStatus: gpaStatus ?? this.gpaStatus,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Graduate_From': graduateFrom,
      'University': university,
      'Year_Of_Graduation': yearOfGraduation,
      'GPA': gpa,
      'Graduate_From_Status': graduateFromStatus,
      'University_Status': universityStatus,
      'Year_Of_Graduation_Status': yearOfGraduationStatus,
      'GPA_Status': gpaStatus,
      'Timestamp': timestamps,
    };
  }

  factory AcademicHistory.fromMap(Map<String, dynamic> map) {
    return AcademicHistory(
      graduateFrom: map['Graduate_From'] != null
          ? List<String?>.from(
              (map['Graduate_From']),
            )
          : null,
      university: map['University'] != null
          ? List<String?>.from(
              (map['University']),
            )
          : null,
      yearOfGraduation: map['Year_Of_Graduation'] != null
          ? List<String?>.from(
              (map['Year_Of_Graduation']),
            )
          : null,
      gpa: map['GPA'] != null
          ? List<String?>.from(
              (map['GPA']),
            )
          : null,
      graduateFromStatus: map['Graduate_From_Status'] != null
          ? List<String?>.from(
              (map['Graduate_From_Status']),
            )
          : null,
      universityStatus: map['University_Status'] != null
          ? List<String?>.from(
              (map['University_Status']),
            )
          : null,
      yearOfGraduationStatus: map['Year_Of_Graduation_Status'] != null
          ? List<String?>.from(
              (map['Year_Of_Graduation_Status']),
            )
          : null,
      gpaStatus: map['GPA_Status'] != null
          ? List<String?>.from(
              (map['GPA_Status']),
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

  factory AcademicHistory.fromJson(String source) =>
      AcademicHistory.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AcademicHistory(Graduate_From: $graduateFrom, University: $university, Year_Of_Graduation: $yearOfGraduation, GPA: $gpa, Graduate_From_Status: $graduateFromStatus, University_Status: $universityStatus, Year_Of_Graduation_Status: $yearOfGraduationStatus, GPA_Status: $gpaStatus, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant AcademicHistory other) {
    if (identical(this, other)) return true;

    return listEquals(other.graduateFrom, graduateFrom) &&
        listEquals(other.university, university) &&
        listEquals(other.yearOfGraduation, yearOfGraduation) &&
        listEquals(other.gpa, gpa) &&
        listEquals(other.graduateFromStatus, graduateFromStatus) &&
        listEquals(other.universityStatus, universityStatus) &&
        listEquals(other.yearOfGraduationStatus, yearOfGraduationStatus) &&
        listEquals(other.gpaStatus, gpaStatus) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode =>
      graduateFrom.hashCode ^
      university.hashCode ^
      yearOfGraduation.hashCode ^
      gpa.hashCode ^
      graduateFromStatus.hashCode ^
      universityStatus.hashCode ^
      yearOfGraduationStatus.hashCode ^
      gpaStatus.hashCode ^
      timestamps.hashCode;
}
