/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_profile.dart
/// Purpose: The social section of an employee profile — bio, academic history,
///          skills and hobbies.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N02. This is what the five `changeX` booleans on the
/// controller were standing in for: with a real value type, "did anything
/// change" is `edited != original` rather than a flag that any listener could
/// set and any save path could forget to reset.

import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';

@immutable
class SocialProfile {
  const SocialProfile({
    this.bio = '',
    this.bioInArabic = '',
    this.academicHistory = const <AcademicEntry>[],
    this.skills = const <SkillEntry>[],
    this.hobbies = const <String>[],
  });

  /// Top-level Firestore keys on the employee document.
  static const String fieldBio = 'Bio';
  // NOTE 9/10/2026: `Bio_Status` / `Bio_In_Arabic_Status` are no longer
  // written by the social save (never read anywhere; dropped by the Settings
  // schema of 9 Oct). Existing documents may still carry them.
  static const String fieldBioStatus = 'Bio_Status';

  /// ADDED 24/8/2026. A separate top-level field, matching
  /// `First_Name_In_Arabic` / `Title_In_Arabic` — not a sub-key of `Bio`, so
  /// the two languages keep independent histories and approval statuses.
  static const String fieldBioInArabic = 'Bio_In_Arabic';
  static const String fieldBioInArabicStatus = 'Bio_In_Arabic_Status';
  static const String fieldAcademicHistory = 'Academic_History';
  static const String fieldSkills = 'Skills';
  static const String fieldHobbies = 'Hobbies';

  /// Firestore stores a hobby as `{'items': [text]}`.
  static const String fieldHobbyItems = 'items';

  static const SocialProfile empty = SocialProfile();

  final String bio;

  /// The Arabic-language bio. Independent of [bio] — an employee may fill in
  /// one, the other, or both.
  final String bioInArabic;
  final List<AcademicEntry> academicHistory;
  final List<SkillEntry> skills;
  final List<String> hobbies;

  SocialProfile copyWith({
    String? bio,
    String? bioInArabic,
    List<AcademicEntry>? academicHistory,
    List<SkillEntry>? skills,
    List<String>? hobbies,
  }) {
    return SocialProfile(
      bio: bio ?? this.bio,
      bioInArabic: bioInArabic ?? this.bioInArabic,
      academicHistory: academicHistory ?? this.academicHistory,
      skills: skills ?? this.skills,
      hobbies: hobbies ?? this.hobbies,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialProfile &&
          other.bio == bio &&
          other.bioInArabic == bioInArabic &&
          listEquals(other.academicHistory, academicHistory) &&
          listEquals(other.skills, skills) &&
          listEquals(other.hobbies, hobbies);

  @override
  int get hashCode => Object.hash(
        bio,
        bioInArabic,
        Object.hashAll(academicHistory),
        Object.hashAll(skills),
        Object.hashAll(hobbies),
      );
}
