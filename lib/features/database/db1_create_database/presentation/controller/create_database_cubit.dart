/// Module: database / db1_create_database / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_cubit.dart
/// Purpose: Declares `CreateDatabaseCubit`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
/// Updated: 15/8/2026 - Now owns the whole wizard, not just the form.
///
/// ONE CUBIT FOR THE WHOLE FLOW
/// ----------------------------
/// The Figma section "MAIN PAGE : Creating A DataBase" is four screens that
/// build one record together:
///
///   details (7398:6137) -> add members (7398:7396) or by department
///   (7398:18600) -> review (7398:17988 / 18213) -> Grant Access
///
/// Nothing is written until the last step. If each screen owned its own cubit
/// the draft would have to be threaded through Navigator arguments, and going
/// back a step — which the breadcrumb invites — would drop whatever the later
/// screen had collected. "Save For Later" would also have to re-assemble the
/// draft from pieces held in different places.
///
/// So one cubit owns `CreateDatabaseState` for the whole flow, provided above
/// the wizard's Navigator. Each screen is a view on it.
///
/// The directory (employees, departments) is loaded ONCE per flow into the
/// state rather than per screen: steps 2, 3 and 4 all render the same people,
/// and re-querying on every push made the member list flicker.

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// Imported for the `part` file: `DatabaseDepartment.localizedName` in
// create_database_state.dart title-cases through FormatHelper.
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/create_database_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
// Also for the `part` file: `CreateDatabaseState.hasValidTitles` reads
// `CreateDatabaseLimits.titleMinLength`, so the button and the validator agree
// on how short is too short.
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/usecases/create_database_use_case.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

part './create_database_state.dart';

class CreateDatabaseCubit extends Cubit<CreateDatabaseState> {
  CreateDatabaseCubit({CreateDatabaseBaseRepository? repository})
      : this._(repository ?? CreateDatabaseRepository(),
            const CreateDatabaseState());

  /// Function Name: [CreateDatabaseCubit.resumingDraft]
  ///
  /// Purpose: Reopen the wizard on a PARKED DRAFT — what tapping a draft card
  /// in the Database Builder list does since 16/8/2026.
  ///
  /// The form fills in synchronously from the row the list already had, so the
  /// first screen is never blank behind a spinner. The people picked before
  /// the draft was parked live in a subcollection and arrive through
  /// [loadDraftGrants], which the flow calls on the way in.
  CreateDatabaseCubit.resumingDraft({
    required DatabaseEntity draft,
    CreateDatabaseBaseRepository? repository,
  }) : this._(repository ?? CreateDatabaseRepository(),
            CreateDatabaseState.fromDraft(draft));

  /// One place the repository is turned into a use case, so the two
  /// constructors cannot drift into building it differently.
  CreateDatabaseCubit._(this._repository, CreateDatabaseState initial)
      : _useCase = CreateDatabaseUseCase(_repository),
        super(initial);

  /// Held alongside the use case because the resume path reads the draft's
  /// grants directly — a plain fetch with no rule attached, so wrapping it in
  /// a use case would only add a layer that forwards.
  final CreateDatabaseBaseRepository _repository;

  final CreateDatabaseUseCase _useCase;

  /// Function Name: [loadDraftGrants]
  ///
  /// Purpose: Put a resumed draft's access rules back into the wizard.
  ///
  /// A no-op unless this wizard was opened on a draft, so the flow can call it
  /// unconditionally next to [loadDirectory].
  ///
  /// A failure degrades to "no grants yet" rather than blocking the screen —
  /// the same shape [loadDirectory] uses — but it is NOT silent: the message
  /// goes to the banner, because a draft that quietly reopens with an empty
  /// member list looks like the picks were thrown away, and finishing it from
  /// there would write that emptiness back over them.
  ///
  /// `selectedDepartmentIds` is rebuilt from the grants rather than stored on
  /// the record: the department chips on step 2 are what the user picked, and
  /// for a resumed draft the department-scoped grants ARE that list.
  Future<void> loadDraftGrants() async {
    final String? id = state.resumedDraftId;
    if (id == null || id.isEmpty) return;

    emit(state.copyWith(isLoadingDraft: true, clearErrorMessage: true));

    final Either<Failure, List<DatabaseAccessGrant>> result =
        await _repository.fetchGrants(id);

    emit(result.fold(
      (Failure failure) => state.copyWith(
        isLoadingDraft: false,
        errorMessage: failure.errMessage,
      ),
      (List<DatabaseAccessGrant> grants) => state.copyWith(
        isLoadingDraft: false,
        grants: grants,
        selectedDepartmentIds: <String>[
          for (final DatabaseAccessGrant g in grants)
            if (g.departmentId != null) g.departmentId!,
        ],
      ),
    ));
  }

  @override
  void emit(CreateDatabaseState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Directory ────────────────────────────────────────────────────────────

  /// Function Name: [loadDirectory]
  ///
  /// Purpose: Pull employees and departments from the controllers main.dart
  /// already registers, and map them to the narrow view models.
  ///
  /// Reuses `MainCoreEmployeeController` / `MainCoreDepartmentCubit` rather
  /// than opening a second set of Firestore queries: those two are the app's
  /// single source for the org directory, they are already warm by the time
  /// any screen is reachable, and a private copy would drift from the roles
  /// module the first time someone is added there.
  ///
  /// Failures degrade to an empty directory instead of throwing — the screen
  /// then shows its empty state, which is the honest thing when the org list
  /// genuinely could not be read. The banner still reports it.
  Future<void> loadDirectory() async {
    if (state.isLoadingDirectory) return;
    emit(state.copyWith(isLoadingDirectory: true));

    try {
      final MainCoreEmployeeController employees =
          Get.find<MainCoreEmployeeController>();
      final MainCoreDepartmentCubit departments =
          Get.find<MainCoreDepartmentCubit>();

      final List<EmployeeEntityPro> rawEmployees =
          (await employees.getAllNewEmployees()) ?? <EmployeeEntityPro>[];
      final List<DepartmentModelPro> rawDepartments =
          await departments.getAllDepartments();

      emit(state.copyWith(
        isLoadingDirectory: false,
        availableEmployees: rawEmployees
            .map(_memberFromEmployee)
            .where((DatabaseMember m) => m.employeeId.isNotEmpty)
            .toList(growable: false),
        departments: rawDepartments
            .map(_departmentFromModel)
            .where((DatabaseDepartment d) => d.id.isNotEmpty)
            .toList(growable: false),
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoadingDirectory: false,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Narrows a ~70-field employee record to the eight fields the access list
  /// needs. See [DatabaseMember]'s header for why the full entity is not
  /// carried through the flow.
  DatabaseMember _memberFromEmployee(EmployeeEntityPro e) {
    String join(String? first, String? last) =>
        <String?>[first, last].whereType<String>().where((String s) => s.isNotEmpty).join(' ');

    return DatabaseMember(
      employeeId: e.id ?? '',
      nameEn: join(e.firstName, e.lastName),
      nameAr: join(e.firstNameInArabic, e.lastNameInArabic),
      email: e.email,
      departmentId: e.departmentId,
      jobTitleEn: e.title,
      jobTitleAr: e.titleInArabic,
      photoUrl: e.photo,
    );
  }

  DatabaseDepartment _departmentFromModel(DepartmentModelPro d) =>
      DatabaseDepartment(
        id: d.departmentID ?? '',
        nameEn: d.departmentName ?? '',
        nameAr: d.departmentNameInArabic ?? '',
      );

  // ── Step 1: details ──────────────────────────────────────────────────────

  void titleEnChanged(String value) =>
      emit(state.copyWith(titleEn: value, clearTitleEnError: true));

  void titleArChanged(String value) =>
      emit(state.copyWith(titleAr: value, clearTitleArError: true));

  void descriptionEnChanged(String value) =>
      emit(state.copyWith(descriptionEn: value));

  void descriptionArChanged(String value) =>
      emit(state.copyWith(descriptionAr: value));

  void accessTypeChanged(DatabaseAccessType value) => emit(
        state.copyWith(accessType: value, clearAccessTypeError: true),
      );

  void coverImagePicked(File file) => emit(state.copyWith(coverImage: file));

  void coverImageCleared() => emit(state.copyWith(clearCoverImage: true));

  // ── Navigation between steps ─────────────────────────────────────────────

  void goToStep(CreateDatabaseStep step) => emit(state.copyWith(step: step));

  /// True when the chosen access type needs no people-picking step, so the
  /// details screen creates the record directly.
  ///
  /// SWAPPED 15/8/2026: this used to be Open Access, with Personal pushed to
  /// the By Department step — backwards on both sides. PERSONAL means the
  /// database belongs to its creator alone, so there is nobody to select and
  /// asking for departments made no sense. OPEN is the one that is opened to
  /// departments, so it is the one that needs the picking step.
  bool get skipsAccessStep => state.accessType == DatabaseAccessType.personal;

  /// Validates the details screen and, if it passes, advances.
  /// Returns whether it advanced so the page can decide to push.
  bool validateDetailsAndAdvance({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String accessRequiredMessage,
  }) {
    final CreateDatabaseValidation validation = _useCase.validate(
      _draft(),
      requiredEnMessage: requiredEnMessage,
      requiredArMessage: requiredArMessage,
      tooShortMessage: tooShortMessage,
    );

    // The access type is checked HERE and not in the use case: the use case
    // validates a `DatabaseEntity`, whose accessType is non-nullable by
    // design (a saved record always has one). "The user has not chosen yet"
    // is a state of this form, not of the record.
    final bool accessMissing = state.accessType == null;

    if (!validation.isValid || accessMissing) {
      emit(state.copyWith(
        submitted: true,
        titleEnError: validation.titleEnError,
        titleArError: validation.titleArError,
        accessTypeError: accessMissing ? accessRequiredMessage : null,
        clearTitleEnError: validation.titleEnError == null,
        clearTitleArError: validation.titleArError == null,
        clearAccessTypeError: !accessMissing,
      ));
      return false;
    }

    // Which screen comes next is decided entirely by the access type chosen
    // on the details card. The three branches are separate flows in the
    // Figma, not variations of one:
    //
    //   PERSONAL   card -> confirm -> success            (no access step;
    //              the database is the creator's own, nobody to pick)
    //   RESTRICTED card -> Add Members     -> Review (2 tiles)   -> success
    //   OPEN       card -> By Department   -> Review (4 tiles,
    //                                        department tabs)    -> success
    emit(state.copyWith(
      submitted: true,
      step: _nextStepForAccessType(),
      clearTitleEnError: true,
      clearTitleArError: true,
      clearAccessTypeError: true,
    ));
    return true;
  }

  CreateDatabaseStep _nextStepForAccessType() {
    switch (state.accessType) {
      case DatabaseAccessType.personal:
        // Nothing to pick — the details screen submits from here.
        return CreateDatabaseStep.details;
      case DatabaseAccessType.restricted:
        return CreateDatabaseStep.addMembers;
      case DatabaseAccessType.open:
        return CreateDatabaseStep.byDepartment;
      case null:
        // Unreachable: the caller above returns false while it is null. Stays
        // on the details card rather than throwing, so a future caller that
        // forgets the guard strands nobody mid-wizard.
        return CreateDatabaseStep.details;
    }
  }

  // ── Steps 2-3: choosing people ───────────────────────────────────────────

  void memberSearchChanged(String query) =>
      emit(state.copyWith(memberSearchQuery: query));

  /// Focuses one chip — the yellow one on 7398:18600. Does NOT change which
  /// departments are in play; see [departmentsChanged] for that.
  void departmentSelected(String? departmentId) => emit(
        departmentId == null
            ? state.copyWith(clearSelectedDepartment: true)
            : state.copyWith(selectedDepartmentId: departmentId),
      );

  /// Function Name: [departmentsChanged]
  ///
  /// Purpose: Applies the Department MULTI-SELECT's new full selection.
  ///
  /// Two things follow from a change here, and both have to happen in one
  /// emit or the screen renders a half-updated draft:
  ///
  ///   * DESELECTING a department drops its grant. Leaving it behind would
  ///     write access for a department the user removed from the field, and
  ///     it would still show up as a tab on the Review screen.
  ///   * The FOCUS has to stay on a chip that still exists. When the focused
  ///     department is deselected, focus moves to the most recent pick —
  ///     which is also the one the user just added, so ticking a department
  ///     immediately scopes the fields and the employee list to it.
  void departmentsChanged(List<String> departmentIds) {
    final List<String> ids = List<String>.from(departmentIds);

    String? focus = state.selectedDepartmentId;
    if (focus == null || !ids.contains(focus)) {
      focus = ids.isEmpty ? null : ids.last;
    }

    final List<DatabaseAccessGrant> grants = state.grants
        .where((DatabaseAccessGrant g) =>
            !g.isDepartmentScoped || ids.contains(g.departmentId))
        .toList(growable: false);

    emit(state.copyWith(
      selectedDepartmentIds: ids,
      grants: grants,
      selectedDepartmentId: focus,
      clearSelectedDepartment: focus == null,
    ));
  }

  /// Adds or removes one person, creating the grant on first pick.
  ///
  /// WHICH grant depends on the screen. On Add Members there is one flat list
  /// of people, so they go into the individual grant (null departmentId). On
  /// By Department every pick belongs to the department currently in focus —
  /// that scoping is what gives the Review screen its per-department tabs.
  /// Sending them all to the individual grant, as this used to, collapsed
  /// four departments into one untitled section.
  void toggleMember(DatabaseMember member) {
    final String? scope = state.step == CreateDatabaseStep.byDepartment
        ? state.selectedDepartmentId
        : null;

    final DatabaseAccessGrant existing = (scope == null
            ? state.individualGrant
            : state.grantForDepartment(scope)) ??
        _emptyGrantFor(scope);

    final List<DatabaseMember> members =
        List<DatabaseMember>.from(existing.members);

    if (members.contains(member)) {
      members.remove(member);
    } else {
      members.add(member);
    }

    _replaceGrant(existing, existing.copyWith(members: members),
        dropIfEmpty: true);
  }

  /// Selects every currently visible person into the active department's
  /// grant — the "Deselect All" / select-all control on 7398:18600. The
  /// button toggles, so this clears them when they are already all in.
  ///
  /// Scoped by the SAME rule as [toggleMember] (aligned 16/8/2026). It read
  /// `selectedDepartmentId` unconditionally, which was harmless only because
  /// that field could not be set outside the by-department screen. It can now
  /// — it is the Add Members department FILTER as well — so without this the
  /// two paths would disagree: tapping people one by one would file them under
  /// the individual grant while a select-all would file the same people under
  /// whichever department the list happened to be filtered to.
  void toggleAllVisible() {
    final List<DatabaseMember> visible = state.visibleEmployees;
    if (visible.isEmpty) return;

    final String? departmentId = state.step == CreateDatabaseStep.byDepartment
        ? state.selectedDepartmentId
        : null;
    final DatabaseAccessGrant existing = (departmentId == null
            ? state.individualGrant
            : state.grantForDepartment(departmentId)) ??
        _emptyGrantFor(departmentId);

    final bool allIn =
        visible.every((DatabaseMember m) => existing.members.contains(m));

    final List<DatabaseMember> members =
        List<DatabaseMember>.from(existing.members);

    if (allIn) {
      members.removeWhere(visible.contains);
    } else {
      for (final DatabaseMember m in visible) {
        if (!members.contains(m)) members.add(m);
      }
    }

    _replaceGrant(existing, existing.copyWith(members: members),
        dropIfEmpty: true);
  }

  /// Removes one person wherever they appear — the red minus on the Review
  /// screens (7398:17988, 7398:18213), which is not scoped to a section.
  void removeMemberEverywhere(DatabaseMember member) {
    final List<DatabaseAccessGrant> next = <DatabaseAccessGrant>[];

    for (final DatabaseAccessGrant grant in state.grants) {
      if (!grant.members.contains(member)) {
        next.add(grant);
        continue;
      }
      final List<DatabaseMember> members =
          List<DatabaseMember>.from(grant.members)..remove(member);
      // A grant with nobody left is dropped, so the summary tiles and the
      // department tabs cannot show an empty section.
      if (members.isNotEmpty) next.add(grant.copyWith(members: members));
    }

    emit(state.copyWith(grants: next));
  }

  // ── Step 4: review ───────────────────────────────────────────────────────

  /// Function Name: [_mutateGrant]
  ///
  /// Purpose: Apply [change] to the grant(s) [departmentId] names, CREATING the
  /// grant when there is not one yet.
  ///
  /// THE FIX OF 16/8/2026, and the reason the three setters below now go
  /// through one place. Each of them used to map over `state.grants`, so a
  /// change aimed at a grant that was not in the list yet matched nothing and
  /// was silently dropped.
  ///
  /// On the By Department screen that is the NORMAL order of events: pick a
  /// department, then fill Permissions and the two dates — all three sit ABOVE
  /// the employee list — and no grant exists until somebody is ticked. So every
  /// date the user chose went nowhere, the field re-read the same absent grant,
  /// and it kept showing its hint as though nothing had been selected.
  ///
  /// A null [departmentId] means "every grant", which is how the single-rule
  /// Review screen edits them together; with no grants at all it creates the
  /// individual one rather than doing nothing.
  void _mutateGrant(
    String? departmentId,
    DatabaseAccessGrant Function(DatabaseAccessGrant grant) change,
  ) {
    bool matched = false;

    final List<DatabaseAccessGrant> next =
        state.grants.map((DatabaseAccessGrant g) {
      if (departmentId != null && g.departmentId != departmentId) return g;
      matched = true;
      return change(g);
    }).toList(growable: false);

    emit(state.copyWith(
      grants: matched
          ? next
          : <DatabaseAccessGrant>[
              ...next,
              change(_emptyGrantFor(departmentId)),
            ],
    ));
  }

  /// Applies a permission level. With [departmentId] null it applies to every
  /// grant — the single dropdown on 7398:17988; with one set it applies to
  /// that department only — the per-tab dropdown on 7398:18213.
  void permissionChanged(
    DatabasePermissionLevel permission, {
    String? departmentId,
  }) =>
      _mutateGrant(
        departmentId,
        (DatabaseAccessGrant g) => g.copyWith(permission: permission),
      );

  void startDateChanged(DateTime date, {String? departmentId}) => _mutateGrant(
        departmentId,
        (DatabaseAccessGrant g) => g.copyWith(startDate: date),
      );

  void endDateChanged(DateTime date, {String? departmentId}) => _mutateGrant(
        departmentId,
        (DatabaseAccessGrant g) => g.copyWith(endDate: date),
      );

  // `viewableFieldsChanged` REMOVED 16/8/2026 with the Viewable Fields control.
  // Nothing in the create wizard could call it: the database has no tables yet,
  // so there were no columns to restrict. Grants written here carry an empty
  // field list, which already means "all fields" — db3's `TableAccessCubit` is
  // where that list gets set, once a table exists.

  // ── Submit ───────────────────────────────────────────────────────────────

  void clearMessages() => emit(state.consumed());

  /// Clears the draft back to an empty form, keeping the directory so the next
  /// pass does not re-query it.
  ///
  /// `resumedDraftId` and `resumedCoverImageUrl` are carried through: a wizard
  /// opened on a parked draft is still editing THAT record after a reset, and
  /// dropping the id here would turn the next write into a create and leave a
  /// duplicate beside the draft.
  void reset() => emit(CreateDatabaseState(
        availableEmployees: state.availableEmployees,
        departments: state.departments,
        resumedDraftId: state.resumedDraftId,
        resumedCoverImageUrl: state.resumedCoverImageUrl,
      ));

  /// Function Name: [submit]
  ///
  /// Purpose: The finished write — "Grant Access" on the Review screen, or
  /// "Create" straight from the details card on Personal Access.
  ///
  /// The localized copy is passed in because the cubit has no BuildContext,
  /// and the domain layer must not acquire one.
  Future<void> submit({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
    required String accessRequiredMessage,
    String? createdBy,
  }) =>
      _write(
        lifecycle: DatabaseStatus.active,
        requiredEnMessage: requiredEnMessage,
        requiredArMessage: requiredArMessage,
        tooShortMessage: tooShortMessage,
        duplicateMessage: duplicateMessage,
        accessRequiredMessage: accessRequiredMessage,
        createdBy: createdBy,
      );

  /// Function Name: [saveAsDraft]
  ///
  /// Purpose: "Save For Later" — park the wizard's work as a DRAFT.
  ///
  /// This used to be wired to the flow's exit callback, so pressing it threw
  /// the draft away: nothing was written, and the Drafts chip on the list
  /// counted zero for ever. It is a real write now, at the same moment and
  /// through the same use case as Grant Access — only the lifecycle differs,
  /// which is what puts the record under Drafts instead of under its access
  /// type.
  ///
  /// The grants ARE written with it. A draft that dropped the people already
  /// picked would make "Save For Later" mean "start again later", which is
  /// the opposite of what the button says.
  Future<void> saveAsDraft({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
    required String accessRequiredMessage,
    String? createdBy,
  }) =>
      _write(
        lifecycle: DatabaseStatus.draft,
        requiredEnMessage: requiredEnMessage,
        requiredArMessage: requiredArMessage,
        tooShortMessage: tooShortMessage,
        duplicateMessage: duplicateMessage,
        accessRequiredMessage: accessRequiredMessage,
        createdBy: createdBy,
      );

  /// The one write both buttons go through.
  ///
  /// Validation is identical for a draft: a record with no title is one the
  /// user cannot recognise in the list, so "Save For Later" is not an escape
  /// hatch from naming it. What a draft is NOT asked for is a complete set of
  /// grants — `canGrantAccess` gates the Review screen's primary button, not
  /// this path.
  Future<void> _write({
    required DatabaseStatus lifecycle,
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
    required String accessRequiredMessage,
    String? createdBy,
  }) async {
    final DatabaseEntity draft =
        _draft(createdBy: createdBy).copyWith(status: lifecycle);

    final CreateDatabaseValidation validation = _useCase.validate(
      draft,
      requiredEnMessage: requiredEnMessage,
      requiredArMessage: requiredArMessage,
      tooShortMessage: tooShortMessage,
    );

    // Same guard as the advance path, repeated because this is the write:
    // `_draft()` fills a fallback access type to satisfy the entity, so
    // without this a submit reached with an empty dropdown would silently
    // store that fallback.
    final bool accessMissing = state.accessType == null;

    if (!validation.isValid || accessMissing) {
      emit(state.copyWith(
        submitted: true,
        step: CreateDatabaseStep.details,
        status: CreateDatabaseStatus.initial,
        titleEnError: validation.titleEnError,
        titleArError: validation.titleArError,
        accessTypeError: accessMissing ? accessRequiredMessage : null,
        clearTitleEnError: validation.titleEnError == null,
        clearTitleArError: validation.titleArError == null,
        clearAccessTypeError: !accessMissing,
      ));
      return;
    }

    emit(state.copyWith(
      submitted: true,
      status: CreateDatabaseStatus.submitting,
      clearErrorMessage: true,
    ));

    final Either<Failure, DatabaseEntity> result = await _useCase(
      draft,
      coverImage: state.coverImage,
      // Personal Access carries no grants by design: the database is the
      // creator's own, so there is no member list to write. The other two
      // types always arrive here with at least one.
      grants: state.grants,
      // Null for a new database, the draft's id when the wizard was reopened
      // on one — which turns this write into an UPDATE of that record and
      // stops the duplicate check refusing the draft for clashing with its own
      // title. See `CreateDatabaseUseCase.call`.
      existingId: state.resumedDraftId,
      duplicateMessage: duplicateMessage,
    );

    final CreateDatabaseState next = result.fold(
      (Failure failure) => state.copyWith(
        status: CreateDatabaseStatus.failure,
        errorMessage: failure.errMessage,
      ),
      (DatabaseEntity created) => state.copyWith(
        status: CreateDatabaseStatus.success,
        createdDatabase: created,
        // Which success dialog the screen shows. Without this the draft path
        // would announce "You Successfully Created New Database", which is
        // exactly what it did not do.
        savedAsDraft: lifecycle.isDraft,
      ),
    );

    emit(next);

    // ── Notifications (spec §1.7) ───────────────────────────────────────────
    //
    // AFTER the emit and NOT awaited. The dispatcher sends one template read
    // and one push per recipient, so awaiting it here would hold the success
    // dialog back by the length of the member list — and it can only fail in
    // ways that do not change what was written (see the dispatcher's header,
    // which swallows everything).
    //
    // DRAFTS SEND NOTHING. "Save For Later" writes the picked members with the
    // record so the wizard can resume, but nobody has been granted anything
    // yet: the database is under Drafts and appears in no access list. Telling
    // nine people they have Edit access to it would be a promise the module has
    // not made — and finishing the draft later would tell them again.
    final DatabaseEntity? created = next.createdDatabase;
    if (next.status == CreateDatabaseStatus.success &&
        !lifecycle.isDraft &&
        created != null) {
      DatabaseNotificationDispatcher.databaseCreated(
        databaseNameEn: created.titleEn,
        databaseNameAr: created.titleAr,
        grants: state.grants,
      );
    }
  }

  // ── Internals ────────────────────────────────────────────────────────────

  DatabaseAccessGrant _emptyGrantFor(String? departmentId) {
    if (departmentId == null) {
      return const DatabaseAccessGrant(members: <DatabaseMember>[]);
    }
    DatabaseDepartment? match;
    for (final DatabaseDepartment d in state.departments) {
      if (d.id == departmentId) {
        match = d;
        break;
      }
    }
    return DatabaseAccessGrant(
      departmentId: departmentId,
      departmentNameEn: match?.nameEn,
      departmentNameAr: match?.nameAr,
      members: const <DatabaseMember>[],
    );
  }

  /// Swaps one grant for another in the list, appending when it was not there
  /// and dropping it when it ends up empty.
  ///
  /// "EMPTY" MEANS NO PEOPLE *AND* NO RULE (16/8/2026). It used to mean no
  /// people, full stop — which was safe only while the rule fields could not be
  /// filled before somebody was picked. Now that they can (see [_mutateGrant]),
  /// unticking the last person would have deleted the grant and taken the
  /// permission and both dates with it, blanking three fields the user was
  /// still looking at and had not asked to clear.
  ///
  /// A grant kept this way still fails `isComplete`, so Grant Access stays
  /// disabled until people are picked — the rule is preserved, not accepted.
  void _replaceGrant(
    DatabaseAccessGrant from,
    DatabaseAccessGrant to, {
    bool dropIfEmpty = false,
  }) {
    final bool keep = !dropIfEmpty || to.members.isNotEmpty || to.hasRule;

    final List<DatabaseAccessGrant> next = <DatabaseAccessGrant>[];
    bool replaced = false;

    for (final DatabaseAccessGrant g in state.grants) {
      if (identical(g, from) || g.departmentId == from.departmentId) {
        replaced = true;
        if (keep) next.add(to);
      } else {
        next.add(g);
      }
    }

    if (!replaced && keep) next.add(to);

    emit(state.copyWith(grants: next));
  }

  /// The entity the wizard is about to write.
  ///
  /// [id] stays empty even when resuming a draft: `existingId` on the use case
  /// is what decides create vs update, and two places holding the same id is
  /// how they end up disagreeing.
  ///
  /// `coverImageUrl` carries the resumed draft's existing cover. The update
  /// writes that field, so without it, finishing a draft whose cover picker
  /// was never touched would blank the image it was saved with.
  DatabaseEntity _draft({String? createdBy}) => DatabaseEntity(
        id: '',
        coverImageUrl: state.resumedCoverImageUrl,
        titleEn: state.titleEn,
        titleAr: state.titleAr,
        descriptionEn: state.descriptionEn,
        descriptionAr: state.descriptionAr,
        // `DatabaseEntity.accessType` is non-nullable — a SAVED record always
        // has one. The fallback only ever feeds the title-only validation
        // pass, which does not read it; every path that writes checks
        // `state.accessType != null` first.
        accessType: state.accessType ?? DatabaseAccessType.restricted,
        createdBy: createdBy,
      );
}
