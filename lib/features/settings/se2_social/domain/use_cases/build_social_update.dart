/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: build_social_update.dart
/// Purpose: Diff two social profiles and produce the NEW REVISION value of
///          every changed social field.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
/// Updated: 9/10/2026 - Returns revision values, not a Firestore overwrite.
///          The map used to hold `Bio: [bio]`, `Skills: [{items: [...]}, …]`
///          and so on, which the data source wrote straight over the
///          employee's history arrays — wiping every earlier revision and
///          never touching `timestamps`. It now holds the value of ONE new
///          revision per changed field, in the shape the Employees_Info append
///          helper (`NewEmployeeModelHistory.copyWithUpdateSynchronized`)
///          takes; `SocialHistoryWriter` appends it to the history lists and
///          to `timestamps`. The never-read `*_Status` twins (`Bio_Status`,
///          `Bio_In_Arabic_Status`, `Graduate_From_Status` …) are no longer
///          produced (Settings schema 9 Oct: dropped).
///
/// Added for CR-SKEL-SE2-N02. This logic used to be ~150 lines inlined in
/// `SocialController.updateAllSocialInformation`, interleaved with loading
/// indicators, snackbars and the Firestore call, and driven by five `changeX`
/// booleans that text-field listeners set. Two consequences of that design are
/// fixed by moving to a value diff:
///
///   * A listener fired on *any* text change, including the programmatic
///     `bioController.text = …` in `restartVariables()` — so simply opening the
///     page could mark the bio dirty.
///   * Clearing every skill or hobby produced an empty entry list, which the
///     old code skipped with `if (allSkillEntries.isNotEmpty)`, so a deletion
///     of the last row silently never persisted.

import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/social_profile.dart';

class BuildSocialUpdate {
  const BuildSocialUpdate();

  /// Function Name: [call]
  ///
  /// Purpose: Build the new revision value of every changed social field.
  ///
  /// Parameters:
  /// - [original]: the profile as loaded from the employee record.
  /// - [edited]: the profile as the user left it.
  ///
  /// Returns: [Map<String, dynamic>] keyed by the Employees_Info field name —
  ///          empty when nothing changed, which is the caller's signal to skip
  ///          the write entirely. Value shapes (9/10/2026), one revision each:
  ///   * `Bio`, `Bio_In_Arabic` → [String]
  ///   * `Skills`, `Hobbies` → `List<String>` — the whole current list
  ///     (stored as `{items: [...]}` by the model)
  ///   * `Academic_History` → `Map<String, dynamic>` — the whole current list
  ///     of rows as parallel lists, see [academicRevision]
  Map<String, dynamic> call({
    required SocialProfile original,
    required SocialProfile edited,
  }) {
    final Map<String, dynamic> update = <String, dynamic>{};

    // CHANGED 9/10/2026 — the new value only; no `[bio]` overwrite and no
    // `Bio_Status: ['']` twin.
    final String bio = edited.bio.trim();
    if (bio != original.bio.trim()) {
      update[SocialProfile.fieldBio] = bio;
    }

    // ADDED 24/8/2026. Diffed separately from [bio] on purpose: editing the
    // English text must not stamp the Arabic one.
    // CHANGED 9/10/2026 — revision value only, no `Bio_In_Arabic_Status`.
    final String bioInArabic = edited.bioInArabic.trim();
    if (bioInArabic != original.bioInArabic.trim()) {
      update[SocialProfile.fieldBioInArabic] = bioInArabic;
    }

    final List<AcademicEntry> academic = _cleanAcademic(edited.academicHistory);
    if (!_sameAcademic(academic, _cleanAcademic(original.academicHistory))) {
      // CHANGED 9/10/2026 — one revision holding every row (was one array
      // element per row, each with four `*_Status` twins).
      update[SocialProfile.fieldAcademicHistory] = academicRevision(academic);
    }

    final List<SkillEntry> skills = _cleanSkills(edited.skills);
    if (!_sameSkills(skills, _cleanSkills(original.skills))) {
      // CHANGED 9/10/2026 — one revision = the list of skill names. Skill
      // level is not in the design and has no input, so it is not stored.
      update[SocialProfile.fieldSkills] =
          skills.map((SkillEntry s) => s.name.trim()).toList();
    }

    final List<String> hobbies = _cleanHobbies(edited.hobbies);
    if (!_sameStrings(hobbies, _cleanHobbies(original.hobbies))) {
      // CHANGED 9/10/2026 — one revision = the list of hobbies.
      update[SocialProfile.fieldHobbies] = hobbies;
    }

    return update;
  }

  /// Function Name: [academicRevision]
  ///
  /// Purpose: Encode every academic row as ONE revision (ADDED 9/10/2026).
  ///
  /// The Employees_Info append helper stores one `Map` per revision, so the
  /// rows travel as parallel lists under the existing keys — row `i` is
  /// `Graduate_From[i]`, `University[i]`, `Year_Of_Graduation[i]`, `GPA[i]`.
  /// Keeping the keys means the org-chart reader, which takes the last
  /// non-empty value of each key, keeps working unchanged. No rows → four
  /// empty lists (never an empty map, which the model's parser drops).
  ///
  /// Parameters:
  /// - [rows]: the cleaned rows, in display order.
  ///
  /// Returns: [Map<String, dynamic>] the revision value.
  static Map<String, dynamic> academicRevision(List<AcademicEntry> rows) =>
      <String, dynamic>{
        AcademicEntry.fieldDegree: <String>[
          for (final AcademicEntry e in rows) e.degree.trim(),
        ],
        AcademicEntry.fieldUniversity: <String>[
          for (final AcademicEntry e in rows) e.university.trim(),
        ],
        AcademicEntry.fieldGraduationYear: <String>[
          for (final AcademicEntry e in rows) e.graduationYear.trim(),
        ],
        AcademicEntry.fieldGpa: <String>[
          for (final AcademicEntry e in rows) e.gpa.trim(),
        ],
      };

  /// Blank rows exist only so the form has something to type into; they are
  /// never persisted.
  static List<AcademicEntry> _cleanAcademic(List<AcademicEntry> entries) =>
      entries.where((AcademicEntry e) => !e.isEmpty).toList();

  static List<SkillEntry> _cleanSkills(List<SkillEntry> entries) =>
      entries.where((SkillEntry e) => !e.isEmpty).toList();

  static List<String> _cleanHobbies(List<String> hobbies) => hobbies
      .map((String h) => h.trim())
      .where((String h) => h.isNotEmpty)
      .toList();

  static bool _sameAcademic(List<AcademicEntry> a, List<AcademicEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameSkills(List<SkillEntry> a, List<SkillEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameStrings(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
