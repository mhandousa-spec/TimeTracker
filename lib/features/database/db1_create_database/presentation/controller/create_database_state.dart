/// Module: database / db1_create_database / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_state.dart
/// Purpose: Declares `CreateDatabaseState`, `CreateDatabaseStatus` and
///          `CreateDatabaseStep`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
/// Updated: 15/8/2026 - Grew from a single-form state into the whole wizard's
///          draft, so steps 2-5 share one object (see the cubit's header).

part of './create_database_cubit.dart';

enum CreateDatabaseStatus { initial, submitting, success, failure }

/// Where the user is in the flow. Named after the Figma screens so a reader
/// can map state to design without guessing.
enum CreateDatabaseStep {
  /// 7398:6137 / 6214 — bilingual title, description, access type.
  details,

  /// 7398:7396 / 7520 — pick people individually.
  addMembers,

  /// 7398:18600 — pick a department, then people inside it.
  byDepartment,

  /// 7398:17988 / 18213 — permissions, dates, final list.
  review,
}

@immutable
class CreateDatabaseState {
  const CreateDatabaseState({
    this.status = CreateDatabaseStatus.initial,
    this.step = CreateDatabaseStep.details,
    this.titleEn = '',
    this.titleAr = '',
    this.descriptionEn = '',
    this.descriptionAr = '',
    this.accessType,
    this.coverImage,
    this.grants = const <DatabaseAccessGrant>[],
    this.availableEmployees = const <DatabaseMember>[],
    this.departments = const <DatabaseDepartment>[],
    this.selectedDepartmentIds = const <String>[],
    this.selectedDepartmentId,
    this.memberSearchQuery = '',
    this.isLoadingDirectory = false,
    this.titleEnError,
    this.titleArError,
    this.accessTypeError,
    this.errorMessage,
    this.createdDatabase,
    this.savedAsDraft = false,
    this.submitted = false,
    this.resumedDraftId,
    this.resumedCoverImageUrl,
    this.isLoadingDraft = false,
  });

  /// Seeds the wizard from a PARKED DRAFT the user tapped in the list. ADDED
  /// 16/8/2026.
  ///
  /// Only the fields the wizard owns come across. `createdAt`, `createdBy` and
  /// `tablesCount` belong to the record rather than to the form, and carrying
  /// them into the state would invite them being written back on finish — see
  /// `DatabaseModel.toUpdateMap` for the other half of that rule.
  ///
  /// The GRANTS are not here: they live in a subcollection and need a read, so
  /// `CreateDatabaseCubit.loadDraftGrants` fills them in afterwards. The form
  /// renders immediately from what the list card already had rather than
  /// holding the first screen behind a spinner for people it does not show.
  factory CreateDatabaseState.fromDraft(DatabaseEntity draft) =>
      CreateDatabaseState(
        titleEn: draft.titleEn,
        titleAr: draft.titleAr,
        descriptionEn: draft.descriptionEn,
        descriptionAr: draft.descriptionAr,
        accessType: draft.accessType,
        resumedDraftId: draft.id,
        resumedCoverImageUrl: draft.coverImageUrl,
      );

  final CreateDatabaseStatus status;
  final CreateDatabaseStep step;

  // ── Step 1: details (Figma 7398:6137) ────────────────────────────────────
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  /// Null until the user picks one.
  ///
  /// CHANGED 15/8/2026: this defaulted to `restricted`, so the dropdown opened
  /// already showing "Restricted Access" and a user who never touched it
  /// created a restricted database believing they had chosen nothing. The
  /// access type decides the whole rest of the wizard, so it is now an
  /// explicit choice the form refuses to guess.
  final DatabaseAccessType? accessType;

  final File? coverImage;

  // ── Steps 2-4: access (Figma 7398:7396 / 18600 / 17988 / 18213) ──────────

  /// Every access rule in the draft.
  ///
  /// Individually-picked people live in a single grant with a null
  /// departmentId; department-scoped picks get one grant each. The Review
  /// screen renders one section per grant, which is exactly why the two
  /// Figma review layouts are one widget with a different count.
  final List<DatabaseAccessGrant> grants;

  /// The org directory, loaded once per flow from the existing controllers.
  final List<DatabaseMember> availableEmployees;
  final List<DatabaseDepartment> departments;

  /// The departments the user picked in the Department MULTI-SELECT
  /// (Figma 7398:18600 — the field reads "Marketing" and the chips under it
  /// are "Marketing / Design / Finance").
  ///
  /// Held separately from [grants] on purpose. A department is chosen first
  /// and filled with people afterwards, and `toggleMember` drops a grant that
  /// ends up with nobody in it — deriving the chips from grants would make a
  /// chip vanish the moment you unticked its last person, which is not what
  /// the user asked for by picking that department.
  final List<String> selectedDepartmentIds;

  /// Which of those chips is currently FOCUSED — the yellow one. It scopes
  /// the permission/date fields and the employee list below them. Distinct
  /// from [selectedDepartmentIds]: that is "which departments are in play",
  /// this is "which one am I editing".
  final String? selectedDepartmentId;

  /// Live text from the "Search" field. Held in state rather than in the
  /// widget so returning to the screen keeps the filter.
  final String memberSearchQuery;

  final bool isLoadingDirectory;

  // ── Validation / result ──────────────────────────────────────────────────
  final String? titleEnError;
  final String? titleArError;

  /// "Choose an access type" — set when the user presses the primary button
  /// with the dropdown still empty. Rendered under the dropdown itself rather
  /// than raised as a dialog, so the message sits on the control that has to
  /// change, exactly like the two title errors.
  final String? accessTypeError;

  final String? errorMessage;
  final DatabaseEntity? createdDatabase;

  /// True when the record that just landed was written by "Save For Later"
  /// rather than by Grant Access / Create — the screens use it to pick which
  /// success dialog to show.
  final bool savedAsDraft;

  final bool submitted;

  /// Document id of the parked draft this wizard was REOPENED on, or null for
  /// a brand new database. ADDED 16/8/2026.
  ///
  /// Everything the resume path needs hangs off this one field: the write
  /// becomes an update instead of a create, and the duplicate-title check is
  /// told to forgive this record so a draft is not refused for clashing with
  /// itself.
  final String? resumedDraftId;

  /// The cover already stored on the resumed draft, as a remote URL.
  ///
  /// [coverImage] is a local `File` the picker produced, so the two cannot be
  /// the same field. Carried so that finishing a draft WITHOUT touching the
  /// picker keeps the image it was saved with — the update writes
  /// `cover_image_url`, and without this it would write null over it.
  final String? resumedCoverImageUrl;

  /// True while the resumed draft's grants are being read.
  final bool isLoadingDraft;

  /// True when this wizard is finishing an existing record rather than
  /// creating one. The screens read it to say "Save" where they would say
  /// "Create".
  bool get isResumingDraft =>
      resumedDraftId != null && resumedDraftId!.isNotEmpty;

  bool get isSubmitting => status == CreateDatabaseStatus.submitting;

  // ── Derived: the Review summary tiles ────────────────────────────────────

  /// "Total Employees / 20". Deduped across grants — one person reachable
  /// through both a department grant and an individual pick is one employee,
  /// not two.
  int get totalEmployees => allMembers.length;

  /// "Total Departments / 3".
  int get totalDepartments => grants
      .where((DatabaseAccessGrant g) => g.isDepartmentScoped)
      .map((DatabaseAccessGrant g) => g.departmentId)
      .toSet()
      .length;

  /// Every distinct person in the draft. `DatabaseMember` compares by
  /// employeeId, so the Set does the deduping.
  Set<DatabaseMember> get allMembers => grants
      .expand((DatabaseAccessGrant g) => g.members)
      .toSet();

  /// "Permissions / Custom" vs "Permissions / Viewer".
  ///
  /// Null while nothing is chosen anywhere; [DatabasePermissionLevel.custom]
  /// once two grants disagree — which is what the Figma's "Custom" tile
  /// (7398:18213) means.
  DatabasePermissionLevel? get effectivePermission {
    final Set<DatabasePermissionLevel> levels = grants
        .map((DatabaseAccessGrant g) => g.permission)
        .whereType<DatabasePermissionLevel>()
        .toSet();

    if (levels.isEmpty) return null;
    if (levels.length == 1) return levels.first;
    return DatabasePermissionLevel.custom;
  }

  // `hasCustomViewableFields` / `sharedViewableFields` REMOVED 16/8/2026 with
  // the Viewable Fields control. The wizard never wrote a non-empty field set —
  // a database being created has no tables — so both getters had exactly one
  // answer. `DatabaseAccessGrant.viewableFields` itself stays: db3 sets it once
  // a table exists.

  /// The grant holding individually-picked people, if any.
  DatabaseAccessGrant? get individualGrant {
    for (final DatabaseAccessGrant g in grants) {
      if (!g.isDepartmentScoped) return g;
    }
    return null;
  }

  /// The picked departments as full records, in pick order — what the chip
  /// row renders. Ids with no matching department are skipped rather than
  /// drawn as an empty chip.
  List<DatabaseDepartment> get selectedDepartments {
    final List<DatabaseDepartment> picked = <DatabaseDepartment>[];
    for (final String id in selectedDepartmentIds) {
      for (final DatabaseDepartment d in departments) {
        if (d.id == id) {
          picked.add(d);
          break;
        }
      }
    }
    return picked;
  }

  /// The display NAME for a department id, or '' when it cannot be resolved.
  ///
  /// `DatabaseMember` stores `departmentId` because that is what the employee
  /// record carries and what has to be written back; the name only exists in
  /// [departments]. Every screen that shows a person needs this join, so it
  /// lives here rather than being repeated in each widget.
  ///
  /// Unresolvable ids return '' rather than the id itself — see MemberGrid's
  /// `_departmentLabel` for why a raw key must never reach the card.
  String departmentNameFor(String? departmentId, {required bool isArabic}) {
    if (departmentId == null || departmentId.isEmpty) return '';
    for (final DatabaseDepartment d in departments) {
      if (d.id == departmentId) return d.localizedName(isArabic: isArabic);
    }
    return '';
  }

  DatabaseAccessGrant? grantForDepartment(String departmentId) {
    for (final DatabaseAccessGrant g in grants) {
      if (g.departmentId == departmentId) return g;
    }
    return null;
  }

  /// Directory filtered by the search box and by the active department.
  ///
  /// THE DEPARTMENT FILTER NOW APPLIES ON BOTH SCREENS (16/8/2026). It used to
  /// be gated on `step == byDepartment`, which made the Department dropdown on
  /// the ADD MEMBERS screen a dead control: picking "Marketing" set
  /// `selectedDepartmentId` and emitted a new state, the field showed the
  /// choice, and the list underneath carried on showing the whole company.
  ///
  /// One field, two jobs, same effect on this list: on Add Members it is a
  /// filter, on By Department it is the chip in focus. Either way it names the
  /// department the person underneath must belong to, so the step it was picked
  /// on is not something this getter needs to know.
  ///
  /// What the step DOES still decide is where a pick is filed —
  /// `CreateDatabaseCubit.toggleMember` sends Add Members picks to the
  /// individual grant regardless of the filter, so narrowing the list here
  /// cannot quietly turn an individual pick into a department-scoped one.
  List<DatabaseMember> get visibleEmployees {
    final String query = memberSearchQuery.trim().toLowerCase();

    return availableEmployees.where((DatabaseMember m) {
      if (selectedDepartmentId != null &&
          m.departmentId != selectedDepartmentId) {
        return false;
      }
      if (query.isEmpty) return true;
      return m.nameEn.toLowerCase().contains(query) ||
          m.nameAr.contains(query) ||
          (m.email?.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);
  }

  bool isMemberSelected(DatabaseMember member) => allMembers.contains(member);

  /// "Grant Access" is only live once every grant is complete and no window
  /// is inverted. An empty draft is not complete — granting access to nobody
  /// is a mis-tap, not an intention.
  ///
  /// Personal Access is exempt: the database is the creator's own, so it
  /// legitimately has no grants and never reaches the Review screen at all.
  /// (Swapped with Open on 15/8/2026 along with the step branch — Open is now
  /// the type that picks departments, so it must NOT be exempt here or the
  /// Review screen would let an empty Open database through.)
  bool get canGrantAccess {
    if (accessType == DatabaseAccessType.personal) return true;
    return grants.isNotEmpty &&
        grants.every((DatabaseAccessGrant g) => g.isComplete) &&
        grants.every((DatabaseAccessGrant g) => !g.hasInvalidDateRange);
  }

  /// The grants [canGrantAccess] is refusing — WHICH ones, not just that there
  /// are some. ADDED 16/8/2026.
  ///
  /// On the tabbed review only one department's fields are on screen at a
  /// time, so a user who has filled the tab in front of them sees three
  /// complete boxes and a dead button. Every grant behind another tab is
  /// invisible, and the screen never named them. This is what lets it.
  ///
  /// Same three conditions as [canGrantAccess], read the other way round, so
  /// the list and the gate cannot disagree about what "finished" means.
  List<DatabaseAccessGrant> get blockingGrants => grants
      .where((DatabaseAccessGrant g) => !g.isComplete || g.hasInvalidDateRange)
      .toList(growable: false);

  /// Comma-joined names of [blockingGrants], for the message under the button.
  ///
  /// An individual-members grant has no department name, so it falls back to
  /// the label the simple review uses for it — the sentence has to name
  /// something, and "" would read as a bug.
  String blockingGrantNames({
    required bool isArabic,
    required String individualLabel,
  }) =>
      blockingGrants.map((DatabaseAccessGrant g) {
        final String name = g.localizedDepartmentName(isArabic: isArabic);
        return name.isEmpty ? individualLabel : name;
      }).join(isArabic ? '، ' : ', ');

  // ── What each screen's primary button waits for (16/8/2026) ──────────────
  //
  // The three buttons are gated rather than validated-on-press: a button that
  // cannot do its job says so by being grey, instead of letting the user press
  // it and answering with a dialog.
  //
  // These read the SAME conditions the press handlers already enforced —
  // `CreateDatabaseUseCase.validate` for the titles, `allMembers.isEmpty` for
  // Review, [canGrantAccess] for the write — so the button and the guard behind
  // it cannot disagree. The guards stay where they are: they are what catches
  // a state that changed between the frame being built and the tap landing.

  /// Both titles are long enough to be saved. Trimmed, because a title of
  /// spaces is not a title and the validator will refuse it.
  bool get hasValidTitles =>
      titleEn.trim().length >= CreateDatabaseLimits.titleMinLength &&
      titleAr.trim().length >= CreateDatabaseLimits.titleMinLength;

  /// Step 1's "Next" / "Create". Both titles plus a chosen access type — the
  /// type decides the entire rest of the wizard, so it cannot be skipped.
  ///
  /// The description and the cover image are NOT required: neither is validated
  /// on submit, and a database with no description is a normal database.
  bool get canAdvanceDetails => hasValidTitles && accessType != null;

  /// Step 2's "Review".
  ///
  /// Access granted to nobody is a mis-tap, not an intention — the condition
  /// `_onReviewPressed` was already checking.
  ///
  /// WHAT THE STEP CAN FIX DECIDES WHAT IT DEMANDS (16/8/2026). The two
  /// variants of step 2 are not the same form, so they cannot have the same
  /// gate:
  ///
  ///   * BY DEPARTMENT — the Permissions dropdown and both date fields are ON
  ///     this screen, one set per department chip. Review used to light up the
  ///     moment one person was ticked, so an empty permission and an empty end
  ///     date sailed through to a Review screen whose own button then greyed
  ///     out, one step away from the fields that would have fixed it. The same
  ///     three conditions [canGrantAccess] enforces are enforced HERE, where
  ///     the fields are.
  ///   * ADD MEMBERS — that screen has no permission or date fields at all;
  ///     they live on the Review screen. Demanding them here would be a
  ///     deadlock, because the only place to fill them is behind this button.
  ///
  /// A grant with nobody in it is dropped by the cubit (`_replaceGrant`'s
  /// `dropIfEmpty`), so this cannot be held up by a department the user picked
  /// and then left empty — only by one they put people in.
  bool get canReview {
    if (allMembers.isEmpty) return false;
    if (step != CreateDatabaseStep.byDepartment) return true;
    return grants.every((DatabaseAccessGrant g) =>
        g.isComplete && !g.hasInvalidDateRange);
  }

  bool get isDirty =>
      titleEn.isNotEmpty ||
      titleAr.isNotEmpty ||
      descriptionEn.isNotEmpty ||
      descriptionAr.isNotEmpty ||
      // Picking an access type is now a real edit — it starts null, so unlike
      // before it can no longer be "the value it always had".
      accessType != null ||
      coverImage != null ||
      grants.isNotEmpty;

  String? get visibleTitleEnError => submitted ? titleEnError : null;
  String? get visibleTitleArError => submitted ? titleArError : null;
  String? get visibleAccessTypeError => submitted ? accessTypeError : null;

  /// The nullable fields take explicit clear flags — `copyWith` alone cannot
  /// express "set this back to null", so clearing a field error after the
  /// user fixes it would otherwise be impossible.
  CreateDatabaseState copyWith({
    CreateDatabaseStatus? status,
    CreateDatabaseStep? step,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    DatabaseAccessType? accessType,
    File? coverImage,
    List<DatabaseAccessGrant>? grants,
    List<DatabaseMember>? availableEmployees,
    List<DatabaseDepartment>? departments,
    List<String>? selectedDepartmentIds,
    String? selectedDepartmentId,
    String? memberSearchQuery,
    bool? isLoadingDirectory,
    String? titleEnError,
    String? titleArError,
    String? accessTypeError,
    String? errorMessage,
    DatabaseEntity? createdDatabase,
    bool? savedAsDraft,
    bool? submitted,
    String? resumedDraftId,
    String? resumedCoverImageUrl,
    bool? isLoadingDraft,
    bool clearTitleEnError = false,
    bool clearTitleArError = false,
    bool clearAccessTypeError = false,
    bool clearErrorMessage = false,
    bool clearCoverImage = false,
    bool clearSelectedDepartment = false,
  }) {
    return CreateDatabaseState(
      status: status ?? this.status,
      step: step ?? this.step,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      accessType: accessType ?? this.accessType,
      coverImage: clearCoverImage ? null : (coverImage ?? this.coverImage),
      grants: grants ?? this.grants,
      availableEmployees: availableEmployees ?? this.availableEmployees,
      departments: departments ?? this.departments,
      selectedDepartmentIds:
          selectedDepartmentIds ?? this.selectedDepartmentIds,
      selectedDepartmentId: clearSelectedDepartment
          ? null
          : (selectedDepartmentId ?? this.selectedDepartmentId),
      memberSearchQuery: memberSearchQuery ?? this.memberSearchQuery,
      isLoadingDirectory: isLoadingDirectory ?? this.isLoadingDirectory,
      titleEnError:
          clearTitleEnError ? null : (titleEnError ?? this.titleEnError),
      titleArError:
          clearTitleArError ? null : (titleArError ?? this.titleArError),
      accessTypeError: clearAccessTypeError
          ? null
          : (accessTypeError ?? this.accessTypeError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      createdDatabase: createdDatabase ?? this.createdDatabase,
      savedAsDraft: savedAsDraft ?? this.savedAsDraft,
      submitted: submitted ?? this.submitted,
      // No clear flags for these two: a wizard never stops being a resume
      // halfway through. They are set once, by `fromDraft`, and carried.
      resumedDraftId: resumedDraftId ?? this.resumedDraftId,
      resumedCoverImageUrl: resumedCoverImageUrl ?? this.resumedCoverImageUrl,
      isLoadingDraft: isLoadingDraft ?? this.isLoadingDraft,
    );
  }

  CreateDatabaseState consumed() => copyWith(clearErrorMessage: true);
}

/// A department, reduced to what the chips and dropdowns need.
///
/// Same reasoning as [DatabaseMember]: `DepartmentModelPro` carries a
/// Firestore `Timestamp` and an `addedBy` audit field, neither of which the
/// presentation layer should be handling.
@immutable
class DatabaseDepartment {
  const DatabaseDepartment({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  /// The department's display name, title-cased through `FormatHelper`.
  ///
  /// CAPITALIZED HERE, NOT AT EVERY CALL SITE (16/8/2026). The directory
  /// stores what was typed into it — "customer support", "human resources" —
  /// and this one method feeds every department label in the module: the
  /// chips, both dropdowns, the filter dialogs, the review tabs and the
  /// subtitle on every person card (through [departmentNameFor]). Wrapping the
  /// dozen call sites instead would mean the thirteenth is lower case.
  ///
  /// `FormatHelper.capitalize` also fixes the acronyms — "hr" becomes "HR",
  /// not "Hr" — which a plain `toUpperCase` on the first letter cannot do.
  ///
  /// Arabic passes through unchanged: it has no letter case, and the acronym
  /// list is Latin, so nothing in it can match.
  String localizedName({required bool isArabic}) {
    if (isArabic) return nameAr.isNotEmpty ? nameAr : nameEn;
    return FormatHelper.capitalize(nameEn.isNotEmpty ? nameEn : nameAr);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DatabaseDepartment && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
