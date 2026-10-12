/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_profile_mapper.dart
/// Purpose: Read a [SocialProfile] out of the raw employee history model.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
/// Updated: 9/10/2026 - Reads the CURRENT REVISION (the last element), the
///          Employees_Info rule. `Skills`, `Hobbies` and `Academic_History`
///          used to be read as "one array element per row", which only held
///          for documents the old social save had just overwritten: every
///          other Employees_Info write (approvals, status changes, the new
///          social save) appends one element per revision, so those readings
///          listed every historical revision as a row — duplicates, and
///          deleted rows coming back. Now:
///            * Bio / Bio_In_Arabic → last string;
///            * Skills / Hobbies → the items of the last element;
///            * Academic_History → the rows held in the last element (parallel
///              lists, see `BuildSocialUpdate.academicRevision`; HR-created
///              single-row maps with camelCase keys are read too). Rows written
///              by the pre-9/10/2026 social save still carry their `*_Status`
///              twins, which identify that layout, so those rows are all kept.
///
/// Added for CR-SKEL-SE2-N01. The parsing below started as a straight port of
/// `getSkills` / `getHobbies` / `getAcademicHistory` from the controller.

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/social_profile.dart';

abstract class SocialProfileMapper {
  /// Function Name: [fromEmployee]
  ///
  /// Purpose: Build the read model for the social page.
  ///
  /// Parameters:
  /// - [employee]: the loaded employee, or `null` before it has loaded.
  ///
  /// Returns: [SocialProfile] — [SocialProfile.empty] for a null employee.
  static SocialProfile fromEmployee(NewEmployeeModelHistory? employee) {
    if (employee == null) return SocialProfile.empty;

    return SocialProfile(
      bio: employee.bio.isNotEmpty ? employee.bio.last : '',
      bioInArabic:
          employee.bioInArabic.isNotEmpty ? employee.bioInArabic.last : '',
      academicHistory: academicRows(employee.academicHistory),
      skills: _skills(employee.skills),
      hobbies: _hobbies(employee.hobbies),
    );
  }

  /// CHANGED 9/10/2026 — the skills of the current (last) revision. Each
  /// stored string is one skill name; level is not part of the design.
  static List<SkillEntry> _skills(List<List<String>>? raw) {
    if (raw == null || raw.isEmpty) return const <SkillEntry>[];
    return <SkillEntry>[
      for (final String name in raw.last)
        if (name.trim().isNotEmpty) SkillEntry(name: name.trim()),
    ];
  }

  /// CHANGED 9/10/2026 — the hobbies of the current (last) revision.
  static List<String> _hobbies(List<List<String>>? raw) {
    if (raw == null || raw.isEmpty) return const <String>[];
    return <String>[
      for (final String hobby in raw.last)
        if (hobby.trim().isNotEmpty) hobby.trim(),
    ];
  }

  /// Function Name: [academicRows]
  ///
  /// Purpose: The academic rows of the current revision (CHANGED 9/10/2026).
  ///
  /// Parameters:
  /// - [raw]: the `Academic_History` history, one map per element.
  ///
  /// Returns: [List<AcademicEntry>] the rows, empty ones dropped.
  static List<AcademicEntry> academicRows(List<Map<String, dynamic>>? raw) {
    if (raw == null || raw.isEmpty) return const <AcademicEntry>[];

    final Map<String, dynamic> current = raw.last;

    // Pre-9/10/2026 layout: the old social save wrote one element PER ROW,
    // each with `*_Status` twins, and later synchronized writes repeated the
    // last row. Keep every distinct row of that layout.
    if (_isLegacyRow(current)) {
      final List<AcademicEntry> rows = <AcademicEntry>[];
      for (final Map<String, dynamic> element in raw) {
        if (!_isLegacyRow(element)) continue;
        final AcademicEntry entry = AcademicEntry(
          degree: _latest(element[AcademicEntry.fieldDegree]),
          university: _latest(element[AcademicEntry.fieldUniversity]),
          graduationYear: _latest(element[AcademicEntry.fieldGraduationYear]),
          gpa: _latest(element[AcademicEntry.fieldGpa]),
        );
        if (_keep(entry) && !rows.contains(entry)) rows.add(entry);
      }
      return rows;
    }

    // Revision layout: every row of the current revision as parallel lists
    // (row i = element i of each column). An HR-created row stores single
    // values under camelCase keys; a single value is a one-row column.
    final List<String> degrees =
        _column(current, AcademicEntry.fieldDegree, 'graduateFrom');
    final List<String> universities =
        _column(current, AcademicEntry.fieldUniversity, 'university');
    final List<String> years =
        _column(current, AcademicEntry.fieldGraduationYear, 'yearOfGraduation');
    final List<String> gpas = _column(current, AcademicEntry.fieldGpa, 'gpa');

    int count = degrees.length;
    for (final List<String> column in <List<String>>[universities, years, gpas]) {
      if (column.length > count) count = column.length;
    }

    String at(List<String> column, int i) =>
        i < column.length ? column[i].trim() : '';

    return <AcademicEntry>[
      for (int i = 0; i < count; i++)
        AcademicEntry(
          degree: at(degrees, i),
          university: at(universities, i),
          graduationYear: at(years, i),
          gpa: at(gpas, i),
        ),
    ].where(_keep).toList();
  }

  /// Same rule the page always used: a row with only a GPA is still shown.
  static bool _keep(AcademicEntry entry) =>
      !entry.isEmpty || entry.gpa.isNotEmpty;

  /// A row written by the pre-9/10/2026 social save carries `*_Status` keys.
  static bool _isLegacyRow(Map<String, dynamic> row) =>
      row.keys.any((String key) => key.endsWith('_Status'));

  /// One column of the revision map: a list as-is, a single value as one row.
  static List<String> _column(
      Map<String, dynamic> row, String key, String camelCaseKey) {
    final dynamic value = row.containsKey(key) ? row[key] : row[camelCaseKey];
    if (value == null) return const <String>[];
    if (value is List) {
      return value.map((dynamic e) => e?.toString() ?? '').toList();
    }
    return <String>[value.toString()];
  }

  /// Legacy-row field: its newest non-empty value (inner arrays of old rows
  /// could hold their own history, current value last).
  static String _latest(dynamic data) {
    if (data == null) return '';
    if (data is List) {
      for (int i = data.length - 1; i >= 0; i--) {
        final String value = data[i]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
      return '';
    }
    return data.toString().trim();
  }
}
