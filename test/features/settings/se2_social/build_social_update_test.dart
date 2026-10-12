/// Module: test / settings / se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: build_social_update_test.dart
/// Purpose: `BuildSocialUpdate` produces ONE revision value per changed social
///          field — no history overwrite, no `*_Status` twins.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/social_profile.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/use_cases/build_social_update.dart';

void main() {
  const BuildSocialUpdate build = BuildSocialUpdate();

  const SocialProfile original = SocialProfile(
    bio: 'Old bio',
    bioInArabic: 'نبذة',
    academicHistory: <AcademicEntry>[
      AcademicEntry(degree: 'bachelor', university: 'Cairo', graduationYear: '2018'),
    ],
    skills: <SkillEntry>[SkillEntry(name: 'Flutter')],
    hobbies: <String>['Chess'],
  );

  test('nothing changed → empty map (the caller skips the write)', () {
    expect(build(original: original, edited: original), isEmpty);
  });

  test('a changed bio is the new string only — no Bio_Status twin', () {
    final Map<String, dynamic> update = build(
      original: original,
      edited: original.copyWith(bio: '  New bio  '),
    );

    expect(update, <String, dynamic>{SocialProfile.fieldBio: 'New bio'});
    expect(update.containsKey(SocialProfile.fieldBioStatus), isFalse);
  });

  test('Arabic bio is diffed on its own', () {
    final Map<String, dynamic> update = build(
      original: original,
      edited: original.copyWith(bioInArabic: 'نبذة جديدة'),
    );

    expect(update, <String, dynamic>{
      SocialProfile.fieldBioInArabic: 'نبذة جديدة',
    });
  });

  test('skills: one revision = the whole list of names, blanks dropped', () {
    final Map<String, dynamic> update = build(
      original: original,
      edited: original.copyWith(skills: const <SkillEntry>[
        SkillEntry(name: 'Flutter'),
        SkillEntry(name: ' Dart '),
        SkillEntry(), // the empty row the form keeps for typing
      ]),
    );

    expect(update, <String, dynamic>{
      SocialProfile.fieldSkills: <String>['Flutter', 'Dart'],
    });
  });

  test('hobbies: clearing every row persists an EMPTY revision', () {
    final Map<String, dynamic> update = build(
      original: original,
      edited: original.copyWith(hobbies: const <String>['  ']),
    );

    expect(update, <String, dynamic>{SocialProfile.fieldHobbies: <String>[]});
  });

  test('academic: every row in ONE revision, as parallel lists, no *_Status',
      () {
    final Map<String, dynamic> update = build(
      original: original,
      edited: original.copyWith(academicHistory: const <AcademicEntry>[
        AcademicEntry(degree: 'bachelor', university: 'Cairo', graduationYear: '2018'),
        AcademicEntry(degree: 'master', university: 'AUC', graduationYear: '2021', gpa: '3.8'),
      ]),
    );

    expect(update.keys, <String>[SocialProfile.fieldAcademicHistory]);
    expect(update[SocialProfile.fieldAcademicHistory], <String, dynamic>{
      AcademicEntry.fieldDegree: <String>['bachelor', 'master'],
      AcademicEntry.fieldUniversity: <String>['Cairo', 'AUC'],
      AcademicEntry.fieldGraduationYear: <String>['2018', '2021'],
      AcademicEntry.fieldGpa: <String>['', '3.8'],
    });
  });

  test('academicRevision of no rows is four empty columns, never {}', () {
    expect(BuildSocialUpdate.academicRevision(const <AcademicEntry>[]),
        <String, dynamic>{
          AcademicEntry.fieldDegree: <String>[],
          AcademicEntry.fieldUniversity: <String>[],
          AcademicEntry.fieldGraduationYear: <String>[],
          AcademicEntry.fieldGpa: <String>[],
        });
  });
}
