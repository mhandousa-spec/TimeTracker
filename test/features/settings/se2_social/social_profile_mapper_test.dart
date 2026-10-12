/// Module: test / settings / se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_profile_mapper_test.dart
/// Purpose: `SocialProfileMapper` reads the CURRENT revision (last element)
///          of each Employees_Info social list, plus the two older academic
///          layouts (pre-9/10 rows with `*_Status`, HR camelCase rows).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/se2_social/data/models/social_profile_mapper.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/social_profile.dart';

SocialProfile read(Map<String, dynamic> doc) =>
    SocialProfileMapper.fromEmployee(NewEmployeeModelHistory.fromMap(doc));

void main() {
  test('null employee → empty profile', () {
    expect(SocialProfileMapper.fromEmployee(null), SocialProfile.empty);
  });

  test('bio, skills and hobbies come from the LAST revision only', () {
    final SocialProfile profile = read(<String, dynamic>{
      'timestamps': <int>[1, 2, 3],
      'Bio': <String>['first', 'second', 'current'],
      'Skills': <Map<String, dynamic>>[
        <String, dynamic>{'items': <String>[]},
        <String, dynamic>{'items': <String>['Deleted skill']},
        <String, dynamic>{'items': <String>['Flutter', 'Dart']},
      ],
      'Hobbies': <Map<String, dynamic>>[
        <String, dynamic>{'items': <String>['Old hobby']},
        <String, dynamic>{'items': <String>['Chess']},
        <String, dynamic>{'items': <String>['Chess', ' ']},
      ],
    });

    expect(profile.bio, 'current');
    expect(profile.skills,
        const <SkillEntry>[SkillEntry(name: 'Flutter'), SkillEntry(name: 'Dart')]);
    expect(profile.hobbies, const <String>['Chess']);
  });

  test('academic revision: parallel lists → one row per index', () {
    final SocialProfile profile = read(<String, dynamic>{
      'timestamps': <int>[1, 2],
      'Academic_History': <Map<String, dynamic>>[
        <String, dynamic>{
          'Graduate_From': <String>['diploma'],
          'University': <String>['Old'],
          'Year_Of_Graduation': <String>['2010'],
          'GPA': <String>[''],
        },
        <String, dynamic>{
          'Graduate_From': <String>['bachelor', 'master'],
          'University': <String>['Cairo', 'AUC'],
          'Year_Of_Graduation': <String>['2018', '2021'],
          'GPA': <String>['', '3.8'],
        },
      ],
    });

    expect(profile.academicHistory, const <AcademicEntry>[
      AcademicEntry(degree: 'bachelor', university: 'Cairo', graduationYear: '2018'),
      AcademicEntry(degree: 'master', university: 'AUC', graduationYear: '2021', gpa: '3.8'),
    ]);
  });

  test('pre-9/10 academic rows (with *_Status) are all kept, duplicates once',
      () {
    Map<String, dynamic> legacy(String degree, String university) =>
        <String, dynamic>{
          'Graduate_From': <String>[degree],
          'Graduate_From_Status': <String>[''],
          'University': <String>[university],
          'University_Status': <String>[''],
          'Year_Of_Graduation': <String>['2020'],
          'Year_Of_Graduation_Status': <String>[''],
          'GPA': <String>[''],
          'GPA_Status': <String>[''],
        };

    final SocialProfile profile = read(<String, dynamic>{
      'timestamps': <int>[1, 2, 3],
      'Academic_History': <Map<String, dynamic>>[
        legacy('bachelor', 'Cairo'),
        legacy('master', 'AUC'),
        // a later synchronized write repeated the last element
        legacy('master', 'AUC'),
      ],
    });

    expect(profile.academicHistory, const <AcademicEntry>[
      AcademicEntry(degree: 'bachelor', university: 'Cairo', graduationYear: '2020'),
      AcademicEntry(degree: 'master', university: 'AUC', graduationYear: '2020'),
    ]);
  });

  test('HR-created row (camelCase single values) is read as one row', () {
    final SocialProfile profile = read(<String, dynamic>{
      'timestamps': <int>[1],
      'Academic_History': <Map<String, dynamic>>[
        <String, dynamic>{
          'university': 'AUC',
          'graduateFrom': 'bachelor',
          'gpa': '3.5',
          'yearOfGraduation': '2020',
        },
      ],
    });

    expect(profile.academicHistory, const <AcademicEntry>[
      AcademicEntry(
          degree: 'bachelor', university: 'AUC', graduationYear: '2020', gpa: '3.5'),
    ]);
  });

  test('an empty academic revision shows no rows', () {
    final SocialProfile profile = read(<String, dynamic>{
      'timestamps': <int>[1, 2],
      'Academic_History': <Map<String, dynamic>>[
        <String, dynamic>{
          'Graduate_From': <String>['bachelor'],
          'University': <String>['Cairo'],
          'Year_Of_Graduation': <String>['2018'],
          'GPA': <String>[''],
        },
        <String, dynamic>{
          'Graduate_From': <String>[],
          'University': <String>[],
          'Year_Of_Graduation': <String>[],
          'GPA': <String>[],
        },
      ],
    });

    expect(profile.academicHistory, isEmpty);
  });
}
