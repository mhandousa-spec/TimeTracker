/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_controller.dart
/// Purpose: Holds the editable social profile (bio, academic history, skills,
///          hobbies) and saves it through the repository.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE2-N01/N02/N06/N07/N08/N09/N10/N11/N12:
///          converted from a plain class to a Cubit; the Firestore write moved
///          behind `SocialRepository`; the six lists of TextEditingControllers
///          moved into the section widgets' State; `Get.dialog` / `Get.snackbar`
///          / `Get.context!` / `Get.back()` and the `Future.delayed(3s)` dialog
///          dismissal replaced with one-shot states the page consumes; the
///          five `changeX` flags replaced with a value diff.
///
/// The class name is kept: `SettingsController.socialController` and the four
/// section widgets resolve it by that name, and the shell owns its lifecycle.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se2_social/data/models/social_profile_mapper.dart';
import 'package:knowticed_plus/features/settings/se2_social/data/repository/social_repository.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/base_repository/social_base_repository.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/social_profile.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/use_cases/build_social_update.dart';

part './social_state.dart';

class SocialController extends Cubit<SocialState> {
  SocialController({
    required this.settingsController,
    SocialBaseRepository? repository,
    BuildSocialUpdate? buildSocialUpdate,
  })  : repository = repository ?? SocialRepository(),
        _buildSocialUpdate = buildSocialUpdate ?? const BuildSocialUpdate(),
        super(const SocialInitial()) {
    restartController();
  }

  final SettingsController settingsController;

  /// Typed as the domain contract so it can be faked in tests.
  final SocialBaseRepository repository;

  final BuildSocialUpdate _buildSocialUpdate;

  /// The profile as loaded. The diff baseline.
  SocialProfile _original = SocialProfile.empty;

  /// The profile as edited. Replaces `bioController`, `skillsControllers`,
  /// `skillsFields`, `skillss`, `hobbiesControllers`, `hobbiess` and
  /// `academicHistoryFields` — seven mutable structures the UI kept in sync by
  /// hand (CR-SKEL-SE2-N07, N18).
  SocialProfile _draft = SocialProfile.empty;

  SocialProfile get profile => _draft;

  /// Whether anything would actually be written. Replaces the four `changeX`
  /// booleans, which a programmatic `controller.text = …` could set.
  bool get hasChanges => _pendingUpdate().isNotEmpty;

  // ── Loading ───────────────────────────────────────────────────────────────

  /// Function Name: [restartController]
  ///
  /// Purpose: Reload the draft from the currently loaded employee, discarding
  ///          any unsaved edits. Called by the settings shell after a refresh.
  void restartController() {
    _original = SocialProfileMapper.fromEmployee(settingsController.employee);
    _draft = _original;
    _publish();
  }

  /// Bumped on every publish so consecutive [SocialEditing] emits are distinct
  /// values and bloc does not dedupe them away. See the note on [SocialEditing].
  int _revision = 0;

  void _publish() {
    if (!isClosed) emit(SocialEditing(++_revision));
  }

  // ── Bio ───────────────────────────────────────────────────────────────────

  /// Function Name: [setBio]
  ///
  /// Purpose: Record the edited bio. Does not emit — the field already holds
  ///          the text, and rebuilding on every keystroke would fight the
  ///          cursor.
  void setBio(String value) {
    _draft = _draft.copyWith(bio: value);
  }

  /// Function Name: [setBioInArabic]
  ///
  /// Purpose: Record the edited Arabic bio. Like [setBio] it does not emit —
  /// the field already holds the text, and rebuilding on every keystroke would
  /// fight the cursor. `SocialScreen` keeps its update button in step through
  /// its own notifier.
  void setBioInArabic(String value) {
    _draft = _draft.copyWith(bioInArabic: value);
  }

  // ── Academic history ──────────────────────────────────────────────────────

  List<AcademicEntry> get academicHistory => _draft.academicHistory;

  /// Function Name: [setAcademicEntry]
  ///
  /// Purpose: Replace one academic record.
  void setAcademicEntry(int index, AcademicEntry entry) {
    if (index < 0 || index >= _draft.academicHistory.length) return;
    final List<AcademicEntry> next =
        List<AcademicEntry>.of(_draft.academicHistory);
    next[index] = entry;
    _draft = _draft.copyWith(academicHistory: next);
  }

  void addAcademicEntry() {
    _draft = _draft.copyWith(
      academicHistory: <AcademicEntry>[
        ..._draft.academicHistory,
        const AcademicEntry(),
      ],
    );
    _publish();
  }

  /// The first record is the employee's primary one and is never removable —
  /// the same rule the UI applied with `canDelete = index > 0`.
  void removeAcademicEntry(int index) {
    if (index <= 0 || index >= _draft.academicHistory.length) return;
    final List<AcademicEntry> next =
        List<AcademicEntry>.of(_draft.academicHistory)..removeAt(index);
    _draft = _draft.copyWith(academicHistory: next);
    _publish();
  }

  // ── Skills ────────────────────────────────────────────────────────────────

  List<SkillEntry> get skills => _draft.skills;

  void setSkill(int index, SkillEntry entry) {
    if (index < 0 || index >= _draft.skills.length) return;
    final List<SkillEntry> next = List<SkillEntry>.of(_draft.skills);
    next[index] = entry;
    _draft = _draft.copyWith(skills: next);
  }

  void addSkill() {
    _draft = _draft
        .copyWith(skills: <SkillEntry>[..._draft.skills, const SkillEntry()]);
    _publish();
  }

  void removeSkill(int index) {
    if (index < 0 || index >= _draft.skills.length) return;
    if (_draft.skills.length <= 1) return;
    final List<SkillEntry> next = List<SkillEntry>.of(_draft.skills)
      ..removeAt(index);
    _draft = _draft.copyWith(skills: next);
    _publish();
  }

  // ── Hobbies ───────────────────────────────────────────────────────────────

  List<String> get hobbies => _draft.hobbies;

  void setHobby(int index, String value) {
    if (index < 0 || index >= _draft.hobbies.length) return;
    final List<String> next = List<String>.of(_draft.hobbies);
    next[index] = value;
    _draft = _draft.copyWith(hobbies: next);
  }

  void addHobby() {
    _draft = _draft.copyWith(hobbies: <String>[..._draft.hobbies, '']);
    _publish();
  }

  void removeHobby(int index) {
    if (index < 0 || index >= _draft.hobbies.length) return;
    if (_draft.hobbies.length <= 1) return;
    final List<String> next = List<String>.of(_draft.hobbies)..removeAt(index);
    _draft = _draft.copyWith(hobbies: next);
    _publish();
  }

  // ── Saving ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _pendingUpdate() =>
      _buildSocialUpdate(original: _original, edited: _draft);

  /// Function Name: [updateAllSocialInformation]
  ///
  /// Purpose: Persist whatever changed, then reload the employee.
  ///
  /// Emits [SocialNoChanges], [SocialSaved] or [SocialError]; it no longer
  /// presents anything itself. The global loading overlay is gone too — the
  /// page reads [SocialSaving] (CR-SKEL-SE2-N08).
  Future<void> updateAllSocialInformation() async {
    final Map<String, dynamic> update = _pendingUpdate();

    if (update.isEmpty) {
      if (!isClosed) emit(const SocialNoChanges());
      _publish();
      return;
    }

    if (!isClosed) emit(const SocialSaving());

    final Either<Failure, void> result = await repository.updateSocialFields(
      employeeId: settingsController.employee?.id ?? '',
      fields: update,
    );

    if (result.isLeft()) {
      final String message = result.fold(
          (Failure l) => l.errMessage, (_) => 'Could not save your changes.');
      if (!isClosed) emit(SocialError(message));
      _publish();
      return;
    }

    // Reload so the next diff is against what is actually stored. The old code
    // reset its `changeX` flags instead, which drifted from the document
    // whenever a write partially failed.
    await settingsController.getEmployee();
    restartController();

    if (!isClosed) emit(const SocialSaved());
    _publish();
  }
}
