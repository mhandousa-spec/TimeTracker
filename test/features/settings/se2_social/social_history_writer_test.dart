/// Module: test / settings / se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_history_writer_test.dart
/// Purpose: A Social Information save APPENDS one Employees_Info revision:
///          one entry in `timestamps` and in every history list, the new
///          value for the changed fields, the last value repeated for the
///          rest, and the social lists end exactly as long as `timestamps`.
///          Also the round trip back through `SocialProfileMapper`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/se2_social/data/models/social_history_writer.dart';
import 'package:knowticed_plus/features/settings/se2_social/data/models/social_profile_mapper.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/social_profile.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/use_cases/build_social_update.dart';

/// An Employees_Info document as the old social save left it: three
/// revisions in `timestamps`, `Bio` overwritten with one element, `Skills`
/// overwritten with one element per skill.
Map<String, dynamic> storedDoc() => <String, dynamic>{
      'Id': 'emp-1',
      'timestamps': <int>[1000, 2000, 3000],
      'First_Name': <String>['amr', 'amr', 'amr'],
      'Email': <String>['amr@x.com', 'amr@x.com', 'amr@x.com'],
      'Insurance_Name': <String>['Allianz', 'Allianz', 'Allianz'],
      'Bio': <String>['Old bio'],
      'Bio_Status': <String>[''],
      'Skills': <Map<String, dynamic>>[
        <String, dynamic>{'items': <String>['Flutter']},
      ],
      'Hobbies': <Map<String, dynamic>>[
        <String, dynamic>{'items': <String>[]},
        <String, dynamic>{'items': <String>[]},
        <String, dynamic>{'items': <String>['Chess']},
      ],
      'Password': 'secret',
      'Default_Password': 'default',
    };

void main() {
  const int now = 4000;

  group('buildWrite', () {
    final Map<String, dynamic> write = SocialHistoryWriter.buildWrite(
      stored: storedDoc(),
      changes: <String, dynamic>{
        SocialProfile.fieldBio: 'New bio',
        SocialProfile.fieldSkills: <String>['Go', 'Rust'],
      },
      timestamp: now,
    );

    test('appends ONE timestamp (int ms, like the rest of Employees_Info)',
        () {
      expect(write['timestamps'], <int>[1000, 2000, 3000, now]);
    });

    test('a changed field gets its new value appended, aligned to timestamps',
        () {
      // Was ['Old bio'] — one element short of three revisions. Brought up
      // to length 3 by carrying the value forward, then the new one appended.
      expect(write['Bio'], <String>['Old bio', 'Old bio', 'Old bio', 'New bio']);

      final List<dynamic> skills = write['Skills'] as List<dynamic>;
      expect(skills, hasLength(4));
      expect(skills.last, <String, dynamic>{
        'items': <String>['Go', 'Rust'],
      });
    });

    test('an unchanged field repeats its last value (current value kept)', () {
      final List<dynamic> hobbies = write['Hobbies'] as List<dynamic>;
      expect(hobbies, hasLength(4));
      expect(hobbies.last, <String, dynamic>{'items': <String>['Chess']});

      expect(write['First_Name'], <String>['amr', 'amr', 'amr', 'amr']);
      expect(write['Insurance_Name'],
          <String>['Allianz', 'Allianz', 'Allianz', 'Allianz']);
    });

    test('every written social list is as long as timestamps', () {
      final int rows = (write['timestamps'] as List<dynamic>).length;
      for (final String key in <String>[
        'Bio',
        'Bio_In_Arabic',
        'Skills',
        'Hobbies',
        'Academic_History',
      ]) {
        expect((write[key] as List<dynamic>).length, rows, reason: key);
      }
    });

    test('never rewrites credentials / ids and writes no *_Status twin', () {
      for (final String key in <String>[
        'Password',
        'Default_Password',
        'Id',
        'Bio_Status',
        'Bio_In_Arabic_Status',
      ]) {
        expect(write.containsKey(key), isFalse, reason: key);
      }
    });
  });

  test('no changes still appends exactly one revision (nothing is lost)', () {
    final NewEmployeeModelHistory history = SocialHistoryWriter.appendRevision(
      stored: storedDoc(),
      changes: const <String, dynamic>{},
      timestamp: now,
    );

    expect(history.timestamps, hasLength(4));
    expect(history.bio.last, 'Old bio');
    expect(history.skills.last, <String>['Flutter']);
    expect(history.hobbies.last, <String>['Chess']);
  });

  group('alignTo', () {
    test('pads a short list with its last value', () {
      expect(SocialHistoryWriter.alignTo<String>(<String>['a'], 3, ''),
          <String>['a', 'a', 'a']);
    });

    test('uses the filler only for an empty list', () {
      expect(SocialHistoryWriter.alignTo<String>(<String>[], 2, '-'),
          <String>['-', '-']);
    });

    test('never shortens a long list', () {
      expect(SocialHistoryWriter.alignTo<String>(<String>['a', 'b', 'c'], 2, ''),
          <String>['a', 'b', 'c']);
    });
  });

  test('round trip: save → stored document → page shows what was saved', () {
    const SocialProfile edited = SocialProfile(
      bio: 'New bio',
      bioInArabic: 'نبذة',
      academicHistory: <AcademicEntry>[
        AcademicEntry(degree: 'bachelor', university: 'Cairo', graduationYear: '2018'),
        AcademicEntry(degree: 'master', university: 'AUC', graduationYear: '2021', gpa: '3.8'),
      ],
      skills: <SkillEntry>[SkillEntry(name: 'Go'), SkillEntry(name: 'Rust')],
      hobbies: <String>['Chess', 'Running'],
    );

    final Map<String, dynamic> stored = storedDoc();
    final SocialProfile before = SocialProfileMapper.fromEmployee(
        NewEmployeeModelHistory.fromMap(stored));

    final Map<String, dynamic> changes =
        const BuildSocialUpdate()(original: before, edited: edited);
    final Map<String, dynamic> write = SocialHistoryWriter.buildWrite(
        stored: stored, changes: changes, timestamp: now);

    // Firestore `update` = the stored document with the written keys replaced.
    final Map<String, dynamic> after = <String, dynamic>{...stored, ...write};
    final SocialProfile reloaded =
        SocialProfileMapper.fromEmployee(NewEmployeeModelHistory.fromMap(after));

    expect(reloaded, edited);
    // …and the edit is a NEW revision: the previous bio is still in history.
    expect((after['Bio'] as List<dynamic>).first, 'Old bio');
    // A second save with no edits writes nothing new to diff against.
    expect(const BuildSocialUpdate()(original: reloaded, edited: edited),
        isEmpty);
  });
}
