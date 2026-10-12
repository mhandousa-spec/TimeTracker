/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_access_cubit.dart
/// Purpose: Declares `EditDatabaseAccessCubit`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Editing Database Access" — Figma 7398:9476 (Open, iPad V) / 7398:9790
/// (Open, iPad H), 7398:10176 + 10331 (Restricted, card and list views),
/// 7398:10612 (Personal), and the review screen 7398:18356 / 10002.
///
/// WHY THIS EXTENDS THE CREATE CUBIT INSTEAD OF COPYING IT
/// ------------------------------------------------------
/// Put the create screens and the edit screens side by side and the difference
/// is the header, the footer labels, and what the last button does. The middle
/// — a department multi-select that drives chips, a permission-and-dates block
/// scoped to the focused chip, a searchable employee grid, dedupe across
/// grants, "who is selected" — is the same behaviour on the same state, and it
/// is roughly six hundred lines of it.
///
/// Reimplementing that here would mean two definitions of "a person can be in
/// exactly one department grant", and the first bug fixed in one would live on
/// in the other. So `CreateDatabaseState` and every selection method are
/// INHERITED, and this class adds only the three things editing needs:
///
///   1. [seed]        — start from what is stored, not from an empty draft
///   2. per-person rules for the Restricted screen (see below)
///   3. [saveAccess]  — rewrite the subcollection instead of creating a record
///
/// PER-PERSON RULES ON THE RESTRICTED SCREEN
/// -----------------------------------------
/// The create wizard gives everyone picked individually ONE window and ONE
/// permission level: a single grant with a null departmentId. The editing
/// screen does not — Figma 7398:10176 draws "Access Begins", "Access Ends" and
/// "Permissions" INSIDE each person's card, so Mona can be a viewer until
/// March while Salma edits until December.
///
/// That is expressed by giving each individually-picked person their own
/// single-member grant, which is why the methods below exist instead of the
/// inherited `toggleMember` — that one funnels everybody into the first
/// null-department grant it finds and would collapse the per-person windows
/// back into one the moment a second person was ticked.
///
/// The `Access_Grants` shape does not change: a grant has always been "a
/// permission, a window, and the people it applies to". One person is a legal
/// value of "the people".

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/repository/database_details_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';

class EditDatabaseAccessCubit extends CreateDatabaseCubit {
  EditDatabaseAccessCubit({
    required DatabaseEntity database,
    required List<DatabaseAccessGrantRecord> records,
    DatabaseDetailsBaseRepository? repository,
    this.grantedBy,
  })  : _database = database,
        _originalRecords = records,
        _repository = repository ?? DatabaseDetailsRepository();

  DatabaseEntity _database;
  final List<DatabaseAccessGrantRecord> _originalRecords;
  final DatabaseDetailsBaseRepository _repository;

  /// Employee id of whoever is doing the editing — stamped onto every grant
  /// this save writes, so the Access table's "Access Grantor" column names the
  /// person who actually granted it rather than whoever first created the
  /// database.
  final String? grantedBy;

  DatabaseEntity get database => _database;

  /// The record as it stands after a successful save, for the caller to swap
  /// into the screen behind this one.
  DatabaseEntity? get savedDatabase => state.createdDatabase;

  // ── Seeding ──────────────────────────────────────────────────────────────

  /// Function Name: [seed]
  ///
  /// Purpose: Load the directory and open on the stored grants.
  ///
  /// The directory load is awaited FIRST because the seeded state depends on
  /// it: `loadDirectory` emits a state built from whatever it was handed when
  /// it started, so seeding before it returns would have the directory's emit
  /// overwrite the grants a moment later — the screen would flash the right
  /// selection and then lose it.
  Future<void> seed() async {
    await loadDirectory();

    final List<DatabaseAccessGrant> grants = _originalRecords
        .map((DatabaseAccessGrantRecord r) => r.grant)
        .where((DatabaseAccessGrant g) => g.members.isNotEmpty)
        .toList(growable: false);

    // Department ids in the order they were written, deduped. This is what
    // draws the chip row, and a department that lost every member still counts
    // as picked — dropping it here would make the chip vanish from a screen
    // the user has not touched yet.
    final List<String> departmentIds = <String>[];
    for (final DatabaseAccessGrant g in grants) {
      final String? id = g.departmentId;
      if (id != null && id.isNotEmpty && !departmentIds.contains(id)) {
        departmentIds.add(id);
      }
    }

    final DatabaseAccessType type = _database.accessType;

    emit(state.copyWith(
      accessType: type,
      grants: grants,
      selectedDepartmentIds: departmentIds,
      selectedDepartmentId: departmentIds.isEmpty ? null : departmentIds.first,
      clearSelectedDepartment: departmentIds.isEmpty,
      step: _stepFor(type),
    ));
  }

  CreateDatabaseStep _stepFor(DatabaseAccessType type) {
    switch (type) {
      case DatabaseAccessType.open:
        return CreateDatabaseStep.byDepartment;
      case DatabaseAccessType.restricted:
        return CreateDatabaseStep.addMembers;
      case DatabaseAccessType.personal:
        return CreateDatabaseStep.details;
    }
  }

  /// Switching the access type in the dropdown at the top of the screen.
  ///
  /// The three types are three different ways of choosing people, not three
  /// labels on one selection: Open grants to whole departments, Restricted to
  /// named individuals with their own windows, Personal to nobody. There is no
  /// honest automatic translation between them — flattening a department into
  /// individuals invents a per-person window nobody set, and grouping
  /// individuals into departments silently merges windows that disagree.
  ///
  /// So the picks are CLEARED on a real change, and the screen asks first
  /// (see `EditDatabaseAccessPage._onAccessTypeChanged`). Re-selecting the
  /// type that is already set is not a change and clears nothing.
  @override
  void accessTypeChanged(DatabaseAccessType value) {
    if (state.accessType == value) return;

    emit(state.copyWith(
      accessType: value,
      grants: const <DatabaseAccessGrant>[],
      selectedDepartmentIds: const <String>[],
      clearSelectedDepartment: true,
      clearAccessTypeError: true,
      step: _stepFor(value),
    ));
  }

  // ── Restricted: one grant per person ─────────────────────────────────────

  /// The employee list the Restricted screen draws.
  ///
  /// `state.visibleEmployees` only applies the department narrowing on the
  /// by-department step, because that is the only create screen that has one.
  /// The editing screen has a Department dropdown next to the search box on
  /// the Restricted variant too (Figma 7398:10176), so the filter is applied
  /// here rather than by widening the inherited getter — that one is shared
  /// with the create wizard, where a department filter on Add Members would
  /// change which people the user can pick.
  ///
  /// THE LIST IS THE ACCESS LIST UNTIL YOU SEARCH (16/8/2026)
  /// -------------------------------------------------------
  /// With no query this returns ONLY the people who already hold a grant, not
  /// the whole directory. This screen is "Editing Database Access": what it is
  /// for is reading and changing the access that exists, and each row here is
  /// a person's whole rule — their window and their permission level. Drawing
  /// all 400 employees put four rows of live date pickers and permission
  /// dropdowns between the user and the two people they came to edit, and the
  /// picked faces above were the only way to tell which was which.
  ///
  /// Adding someone new is what the SEARCH box is for: type, and the whole
  /// directory is matched again so anyone can be found and ticked. Once ticked
  /// they hold a grant, so they stay in the list when the box is cleared.
  ///
  /// The department dropdown stays a FILTER either way — it narrows whatever
  /// is being shown (the access list, or the search results) rather than
  /// revealing unpicked people on its own. Browsing a department to find
  /// someone is the search box's job, and one control that sometimes adds
  /// people to the list and sometimes removes them is the confusing part.
  List<DatabaseMember> get filteredEmployees {
    final String query = state.memberSearchQuery.trim().toLowerCase();
    final String? department = state.selectedDepartmentId;
    final bool isSearching = query.isNotEmpty;

    return state.availableEmployees.where((DatabaseMember m) {
      if (department != null &&
          department.isNotEmpty &&
          m.departmentId != department) {
        return false;
      }
      if (!isSearching) return grantForMember(m) != null;
      return m.nameEn.toLowerCase().contains(query) ||
          m.nameAr.contains(state.memberSearchQuery.trim()) ||
          (m.email?.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);
  }

  /// The grant carrying exactly [member], or null while they are not picked.
  DatabaseAccessGrant? grantForMember(DatabaseMember member) {
    for (final DatabaseAccessGrant g in state.grants) {
      if (!g.isDepartmentScoped && g.members.contains(member)) return g;
    }
    return null;
  }

  /// Ticking or unticking one person on the Restricted screen.
  ///
  /// Adds a single-member grant, or drops theirs. Not the inherited
  /// `toggleMember` — see this file's header for why the individual grants
  /// must stay separate.
  void toggleIndividualMember(DatabaseMember member) {
    final DatabaseAccessGrant? existing = grantForMember(member);

    if (existing != null) {
      emit(state.copyWith(
        grants: state.grants
            .where((DatabaseAccessGrant g) => !identical(g, existing))
            .toList(growable: false),
      ));
      return;
    }

    emit(state.copyWith(
      grants: <DatabaseAccessGrant>[
        ...state.grants,
        DatabaseAccessGrant(members: <DatabaseMember>[member]),
      ],
    ));
  }

  /// Ticks or unticks everyone currently listed — the select-all control.
  ///
  /// ONLY MEANINGFUL WHILE A SEARCH IS RUNNING (noted 16/8/2026). With an
  /// empty query [filteredEmployees] is the people who already hold a grant,
  /// so "everyone listed" is already in and this would REVOKE the lot. The
  /// Restricted screen has no select-all button for exactly that reason — if
  /// one is ever added, gate it on a non-empty `memberSearchQuery`.
  void toggleAllFiltered() {
    final List<DatabaseMember> visible = filteredEmployees;
    if (visible.isEmpty) return;

    final bool allIn =
        visible.every((DatabaseMember m) => grantForMember(m) != null);

    if (allIn) {
      emit(state.copyWith(
        grants: state.grants
            .where((DatabaseAccessGrant g) =>
                g.isDepartmentScoped ||
                !g.members.any(visible.contains))
            .toList(growable: false),
      ));
      return;
    }

    final List<DatabaseAccessGrant> next =
        List<DatabaseAccessGrant>.from(state.grants);
    for (final DatabaseMember m in visible) {
      if (grantForMember(m) == null &&
          !next.any((DatabaseAccessGrant g) => g.members.contains(m))) {
        next.add(DatabaseAccessGrant(members: <DatabaseMember>[m]));
      }
    }
    emit(state.copyWith(grants: next));
  }

  /// Applies one person's own permission / window. A no-op while they are not
  /// picked, so a stray tap on a date field in an unticked card cannot create
  /// a grant nobody asked for.
  void memberRuleChanged(
    DatabaseMember member, {
    DatabasePermissionLevel? permission,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final DatabaseAccessGrant? existing = grantForMember(member);
    if (existing == null) return;

    final DatabaseAccessGrant updated = existing.copyWith(
      permission: permission,
      startDate: startDate,
      endDate: endDate,
    );

    emit(state.copyWith(
      grants: state.grants
          .map((DatabaseAccessGrant g) => identical(g, existing) ? updated : g)
          .toList(growable: false),
    ));
  }

  /// True once every picked person has a level and both dates — what gates
  /// "Grant Access" on the Restricted screen. `state.canGrantAccess` says the
  /// same thing; this reads it under the name the screen uses.
  bool get individualRulesComplete => state.canGrantAccess;

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Function Name: [saveAccess]
  ///
  /// Purpose: Rewrite the `Access_Grants` subcollection and bring the parent
  /// record back in step.
  ///
  /// This does NOT go through the inherited `submit`. That one creates a new
  /// document from the whole draft — title, description, cover, lifecycle —
  /// and this screen has none of those; running it here would write a second
  /// database rather than edit the one on screen.
  Future<void> saveAccess() async {
    emit(state.copyWith(
      status: CreateDatabaseStatus.submitting,
      clearErrorMessage: true,
    ));

    final Either<Failure, void> written = await _repository.replaceGrants(
      databaseId: _database.id,
      accessType: state.accessType ?? _database.accessType,
      records: _recordsToWrite(),
      grantedBy: grantedBy,
    );

    final Failure? failure = written.fold(
      (Failure f) => f,
      (_) => null,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: CreateDatabaseStatus.failure,
        errorMessage: failure.errMessage,
      ));
      return;
    }

    // ── Notifications (spec §1.7) ───────────────────────────────────────────
    //
    // Raised HERE, between the write and the read-back, and NOT awaited. The
    // write is what earned them; the read-back that follows only refreshes a
    // count, and a notification failure must not delay the success state (see
    // the dispatcher's header).
    //
    // The diff is against `_originalRecords` — the grants this screen was SEEDED
    // with — so a person whose rule was not touched gets nothing even though the
    // save rewrote their document. `_originalRecords` is final and this flow pops
    // on success, so it is still the right baseline; a screen that stayed open
    // for a second save would have to re-seed it.
    DatabaseNotificationDispatcher.accessSaved(
      databaseNameEn: _database.titleEn,
      databaseNameAr: _database.titleAr,
      before: _originalRecords
          .map((DatabaseAccessGrantRecord r) => r.grant)
          .toList(growable: false),
      after: state.grants,
    );

    // Re-read rather than patching the local copy: the batch also wrote
    // `member_count` and `updated_at`, and the screen behind this one shows
    // both. Patching would leave the details card claiming the old count until
    // the module was reopened.
    final Either<Failure, DatabaseEntity> refreshed =
        await _repository.fetchDatabase(_database.id);

    emit(refreshed.fold(
      // The write SUCCEEDED — only the read-back did not. Reporting a failure
      // here would tell the user their change was lost when it is safely in
      // Firestore, so the save is confirmed with the record as last known.
      (Failure _) => state.copyWith(
        status: CreateDatabaseStatus.success,
        createdDatabase: _database,
      ),
      (DatabaseEntity saved) {
        _database = saved;
        return state.copyWith(
          status: CreateDatabaseStatus.success,
          createdDatabase: saved,
        );
      },
    ));
  }

  /// Function Name: [_recordsToWrite]
  ///
  /// Purpose: Turn the draft grants back into documents, carrying the removed
  /// people with them.
  ///
  /// THE REMOVAL BOOKKEEPING IS THE WHOLE POINT OF THIS METHOD. The Access
  /// table has a "Removed" chip; if a save simply wrote the current grants,
  /// everyone taken off would vanish and that chip would count zero for ever —
  /// the screen would have no way to answer "who used to have access to this?"
  /// which is the question an access log exists to answer.
  ///
  /// So: anybody in the stored grants who is not in the draft is moved into
  /// `removedMembers`, keeping the window and level they HELD (not the grant's
  /// current ones — the grant may have been re-dated in the same edit).
  /// Anybody previously removed who has been granted access again is dropped
  /// from that list, so a person cannot be both current and removed.
  List<DatabaseAccessGrantRecord> _recordsToWrite() {
    final Set<DatabaseMember> keeping = state.grants
        .expand((DatabaseAccessGrant g) => g.members)
        .toSet();

    final DateTime now = DateTime.now();
    final List<RemovedAccessMember> removed = <RemovedAccessMember>[];

    for (final DatabaseAccessGrantRecord original in _originalRecords) {
      // People who were on this grant and are not in the draft any more.
      for (final DatabaseMember member in original.grant.members) {
        if (keeping.contains(member)) continue;
        removed.add(RemovedAccessMember.from(member, original.grant,
            removedAt: now));
      }

      // Previously-removed people stay removed, unless they are back.
      for (final RemovedAccessMember was in original.removedMembers) {
        if (keeping.contains(was.member)) continue;
        if (removed.contains(was)) continue;
        removed.add(was);
      }
    }

    // Reuse the stored document id for a grant that still covers the same
    // department, so the subcollection stays stable across edits instead of
    // every save looking like a brand-new set of grants to anything watching
    // it. Individually-scoped grants are one per person now and have no such
    // key, so they are written fresh.
    String? idForDepartment(String? departmentId) {
      if (departmentId == null || departmentId.isEmpty) return null;
      for (final DatabaseAccessGrantRecord r in _originalRecords) {
        if (r.grant.departmentId == departmentId) return r.id;
      }
      return null;
    }

    final List<DatabaseAccessGrantRecord> records = <DatabaseAccessGrantRecord>[
      for (final DatabaseAccessGrant grant in state.grants)
        DatabaseAccessGrantRecord(
          id: idForDepartment(grant.departmentId) ?? '',
          grant: grant,
        ),
    ];

    if (removed.isEmpty) return records;

    // Removed people are filed against the grant they lost, when it still
    // exists. When it does not — a whole department was dropped, or the
    // database was switched to Personal and has no grants left — they go on a
    // member-less holder document, because a removal that has nowhere to live
    // is a removal that disappears from the table.
    final List<DatabaseAccessGrantRecord> withRemovals =
        <DatabaseAccessGrantRecord>[...records];
    final List<RemovedAccessMember> orphaned = <RemovedAccessMember>[];

    for (final RemovedAccessMember entry in removed) {
      final int index = withRemovals.indexWhere(
        (DatabaseAccessGrantRecord r) =>
            entry.departmentId != null &&
            r.grant.departmentId == entry.departmentId,
      );

      if (index == -1) {
        orphaned.add(entry);
        continue;
      }

      withRemovals[index] = withRemovals[index].copyWith(
        removedMembers: <RemovedAccessMember>[
          ...withRemovals[index].removedMembers,
          entry,
        ],
      );
    }

    if (orphaned.isEmpty) return withRemovals;

    if (withRemovals.isEmpty) {
      return <DatabaseAccessGrantRecord>[
        DatabaseAccessGrantRecord(
          grant: const DatabaseAccessGrant(members: <DatabaseMember>[]),
          removedMembers: orphaned,
        ),
      ];
    }

    withRemovals[0] = withRemovals[0].copyWith(
      removedMembers: <RemovedAccessMember>[
        ...withRemovals[0].removedMembers,
        ...orphaned,
      ],
    );
    return withRemovals;
  }
}
