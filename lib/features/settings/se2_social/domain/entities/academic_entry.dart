/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: academic_entry.dart
/// Purpose: One academic-history record on an employee's social profile.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N02. The feature had no domain layer: an academic
/// record existed only as a `Map<String, TextEditingController>` on the
/// controller, so "what is a record" was defined by four string keys typed out
/// in five different places.

import 'package:flutter/foundation.dart';

@immutable
class AcademicEntry {
  const AcademicEntry({
    this.degree = '',
    this.university = '',
    this.graduationYear = '',
    this.gpa = '',
  });

  /// Firestore field keys for one record inside `Academic_History`.
  ///
  /// NOTE 9/10/2026: the four `*_Status` keys are no longer written (Settings
  /// schema 9 Oct: never-read twins, dropped). They are kept only to name the
  /// pre-9/10 layout the reader still recognises.
  static const String fieldDegree = 'Graduate_From';
  static const String fieldDegreeStatus = 'Graduate_From_Status';
  static const String fieldUniversity = 'University';
  static const String fieldUniversityStatus = 'University_Status';
  static const String fieldGraduationYear = 'Year_Of_Graduation';
  static const String fieldGraduationYearStatus = 'Year_Of_Graduation_Status';
  static const String fieldGpa = 'GPA';
  static const String fieldGpaStatus = 'GPA_Status';

  /// The degree key as persisted — `bachelor`, `master`, `phd`, `diploma`,
  /// `certificate`. Deliberately untranslated; the label is looked up in the UI.
  final String degree;
  final String university;
  final String graduationYear;
  final String gpa;

  /// An entry with nothing in the three meaningful fields is not written.
  /// Matches the old `if (graduateFrom.isNotEmpty || university.isNotEmpty ||
  /// yearOfGrad.isNotEmpty)` guard, GPA excluded exactly as before.
  bool get isEmpty =>
      degree.trim().isEmpty &&
      university.trim().isEmpty &&
      graduationYear.trim().isEmpty;

  AcademicEntry copyWith({
    String? degree,
    String? university,
    String? graduationYear,
    String? gpa,
  }) {
    return AcademicEntry(
      degree: degree ?? this.degree,
      university: university ?? this.university,
      graduationYear: graduationYear ?? this.graduationYear,
      gpa: gpa ?? this.gpa,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicEntry &&
          other.degree == degree &&
          other.university == university &&
          other.graduationYear == graduationYear &&
          other.gpa == gpa;

  @override
  int get hashCode => Object.hash(degree, university, graduationYear, gpa);

  @override
  String toString() => 'AcademicEntry($degree, $university, $graduationYear, '
      '$gpa)';
}
