/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_access_cubit.dart
/// Purpose: Declares `TableAccessCubit`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Editing Table Access" — the Viewable Fields half of the Figma section
/// "INSIDE DATABASE PAGE: Creating Table + Viewable Fields".
///
///   picker  7398:13651 (iPad H 1024x1097) / 7398:13925 (iPad V 768x1097)
///   review  7398:14553 (iPad V 768x1086) — Summary tiles, rule, fields
///   granted 7398:14122 / 7398:14296 — the picked people and their fields
///
/// ONE GRANT, NOT A LIST. See `TableAccessState.grant` for why the table screens
/// differ from db1's department-tabbed review here.
///
/// The directory comes from `MainCoreEmployeeController` /
/// `MainCoreDepartmentCubit` — the app's single source for the org chart —
/// rather than a second set of Firestore queries, the same arrangement db1 and
/// db2 use.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/viewable_fields_field.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/repository/create_table_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

part './table_access_state.dart';

class TableAccessCubit extends Cubit<TableAccessState> {
  TableAccessCubit({
    required DatabaseTableEntity table,
    this.databaseNameEn = '',
    this.databaseNameAr = '',
    CreateTableBaseRepository? repository,
  })  : _repository = repository ?? CreateTableRepository(),
        super(TableAccessState(table: table));

  final CreateTableBaseRepository _repository;

  /// The parent database's bilingual title, for the notifications [save] raises
  /// — the §1.7 access bodies read "access to {{databaseName}} / {{tableName}}",
  /// so a table grant has to name both. ADDED 17/8/2026.
  ///
  /// Same reasoning as `CreateTableCubit.databaseNameEn`: two strings rather
  /// than a `DatabaseEntity`, defaulted so a caller that does not pass them
  /// still compiles.
  final String databaseNameEn;
  final String databaseNameAr;

  @override
  void emit(TableAccessState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  /// Function Name: [load]
  ///
  /// Purpose: Read this table's grants and the org directory, then seed the
  /// single rule the screens edit.
  ///
  /// The two reads run CONCURRENTLY. They are independent — grants come from
  /// the table's subcollection, the directory from controllers the app already
  /// registers — and awaiting them in sequence made db2's equivalent screen
  /// appear in two stages.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Future<Either<Failure, List<DatabaseAccessGrantRecord>>> grantsFuture =
        _repository.fetchTableGrants(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
    );
    final Future<_Directory> directoryFuture = _loadDirectory();

    final Either<Failure, List<DatabaseAccessGrantRecord>> grants =
        await grantsFuture;
    final _Directory directory = await directoryFuture;

    emit(grants.fold(
      (Failure failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.errMessage,
        employees: directory.employees,
        departments: directory.departments,
      ),
      (List<DatabaseAccessGrantRecord> records) {
        final DatabaseAccessGrantRecord? first =
            records.isEmpty ? null : records.first;

        // MERGED, not "the first one wins". A table's grants are only ever
        // written by this screen, which writes exactly one — so more than one
        // row means something else wrote them, and dropping the extras on load
        // would silently revoke people the moment this screen saved. The union
        // is the conservative direction to be wrong in, and the save replaces
        // the whole subcollection with the merged result.
        final DatabaseAccessGrant merged = _merge(records);
        final Map<String, List<String>> memberFields = _fieldsByMember(records);

        return state.copyWith(
          isLoading: false,
          memberFields: memberFields,
          grant: merged,
          original: merged,
          recordId: first?.id ?? '',
          removedMembers: first?.removedMembers ?? const <RemovedAccessMember>[],
          employees: directory.employees,
          departments: directory.departments,
          clearErrorMessage: true,
        );
      },
    ));
  }

  /// Folds however many grant documents exist into the one rule this screen
  /// edits: every person, the first level and window anyone was given, and the
  /// union of the field restrictions.
  ///
  /// The field union matters: two grants restricting different columns are
  /// merged into a rule that shows both, never into one that shows fewer than
  /// somebody already had.
  /// Function Name: [_fieldsByMember]
  ///
  /// Purpose: Employee id -> the columns THAT person's own grant lets them see.
  ///
  /// The subcollection holds one document per distinct field set (see [save]),
  /// so this is the read half of that split: it unpacks the documents back into
  /// the per-person map the review screen edits.
  ///
  /// A member listed on two records keeps the FIRST one's fields rather than a
  /// union — a union would silently widen what somebody can see, which is the
  /// wrong direction to be wrong in on an access screen.
  ///
  /// Returns: [Map] employee id -> column ids.
  static Map<String, List<String>> _fieldsByMember(
    List<DatabaseAccessGrantRecord> records,
  ) {
    final Map<String, List<String>> out = <String, List<String>>{};
    for (final DatabaseAccessGrantRecord record in records) {
      for (final DatabaseMember member in record.grant.members) {
        out.putIfAbsent(
          member.employeeId,
          () => List<String>.unmodifiable(record.grant.viewableFields),
        );
      }
    }
    return out;
  }

  static DatabaseAccessGrant _merge(List<DatabaseAccessGrantRecord> records) {
    if (records.isEmpty) {
      return const DatabaseAccessGrant(members: <DatabaseMember>[]);
    }
    if (records.length == 1) return records.first.grant;

    final Set<DatabaseMember> members = <DatabaseMember>{};
    final Set<String> fields = <String>{};
    DatabasePermissionLevel? permission;
    DateTime? start;
    DateTime? end;

    for (final DatabaseAccessGrantRecord record in records) {
      members.addAll(record.grant.members);
      fields.addAll(record.grant.viewableFields);
      permission ??= record.grant.permission;
      start ??= record.grant.startDate;
      end ??= record.grant.endDate;
    }

    return DatabaseAccessGrant(
      members: members.toList(growable: false),
      permission: permission,
      startDate: start,
      endDate: end,
      viewableFields: fields.toList(growable: false),
    );
  }

  /// Degrades to empty rather than throwing: a screen that cannot reach the
  /// directory should still show the people already on the grant, not an error
  /// over data it did load.
  Future<_Directory> _loadDirectory() async {
    try {
      final MainCoreEmployeeController employees =
          Get.find<MainCoreEmployeeController>();
      final MainCoreDepartmentCubit departments =
          Get.find<MainCoreDepartmentCubit>();

      final List<EmployeeEntityPro> rawEmployees =
          (await employees.getAllNewEmployees()) ?? <EmployeeEntityPro>[];
      final List<DepartmentModelPro> rawDepartments =
          await departments.getAllDepartments();

      return _Directory(
        employees: rawEmployees
            .map(_memberFromEmployee)
            .where((DatabaseMember m) => m.employeeId.isNotEmpty)
            .toList(growable: false),
        departments: rawDepartments
            .map((DepartmentModelPro d) => DatabaseDepartment(
                  id: d.departmentID ?? '',
                  nameEn: d.departmentName ?? '',
                  nameAr: d.departmentNameInArabic ?? '',
                ))
            .where((DatabaseDepartment d) => d.id.isNotEmpty)
            .toList(growable: false),
      );
    } catch (_) {
      return const _Directory(
        employees: <DatabaseMember>[],
        departments: <DatabaseDepartment>[],
      );
    }
  }

  DatabaseMember _memberFromEmployee(EmployeeEntityPro e) {
    String join(String? first, String? last) => <String?>[first, last]
        .whereType<String>()
        .where((String s) => s.isNotEmpty)
        .join(' ');

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

  // ── Filtering ────────────────────────────────────────────────────────────

  void searchChanged(String query) =>
      emit(state.copyWith(searchQuery: query));

  void departmentFilterChanged(String? departmentId) => emit(
        departmentId == null || departmentId.isEmpty
            ? state.copyWith(clearDepartmentFilter: true)
            : state.copyWith(departmentFilter: departmentId),
      );

  // ── Members ──────────────────────────────────────────────────────────────

  void toggleMember(DatabaseMember member) {
    final List<DatabaseMember> members = <DatabaseMember>[...state.grant.members];
    members.contains(member) ? members.remove(member) : members.add(member);
    _setMembers(members);
  }

  /// "Select All" / "Deselect All" — scoped to what the search and the
  /// department filter currently show. See `TableAccessState.allVisibleSelected`.
  void toggleSelectAllVisible() {
    final List<DatabaseMember> visible = state.visibleEmployees;
    if (visible.isEmpty) return;

    final List<DatabaseMember> members = <DatabaseMember>[...state.grant.members];

    if (state.allVisibleSelected) {
      members.removeWhere(visible.contains);
    } else {
      for (final DatabaseMember m in visible) {
        if (!members.contains(m)) members.add(m);
      }
    }
    _setMembers(members);
  }

  /// Function Name: [removeMember]
  ///
  /// Purpose: Take one person off the grant, keeping the record of what they
  /// held.
  ///
  /// The removal is filed under `removedMembers` rather than simply dropped:
  /// the Access table's red "Removed" row is about someone with no grant left,
  /// and it cannot be drawn from a person who has been erased. Re-adding them
  /// afterwards cancels the entry, so a mis-tap does not leave a phantom
  /// removal behind.
  void removeMember(DatabaseMember member) {
    final List<DatabaseMember> members = <DatabaseMember>[...state.grant.members]
      ..remove(member);

    final List<RemovedAccessMember> removed = <RemovedAccessMember>[
      ...state.removedMembers,
    ];
    final RemovedAccessMember entry =
        RemovedAccessMember.from(member, state.grant);
    if (!removed.contains(entry)) removed.add(entry);

    emit(state.copyWith(
      grant: state.grant.copyWith(members: members),
      removedMembers: List<RemovedAccessMember>.unmodifiable(removed),
    ));
  }

  /// "Remove All Access" (Figma 7398:14280) — empties the grant in one action.
  ///
  /// Every person is filed as removed, exactly as if they had been taken off
  /// one at a time, so the Access table can still account for them.
  void removeAllAccess() {
    final List<RemovedAccessMember> removed = <RemovedAccessMember>[
      ...state.removedMembers,
    ];
    for (final DatabaseMember member in state.grant.members) {
      final RemovedAccessMember entry =
          RemovedAccessMember.from(member, state.grant);
      if (!removed.contains(entry)) removed.add(entry);
    }

    emit(state.copyWith(
      grant: state.grant.copyWith(members: const <DatabaseMember>[]),
      removedMembers: List<RemovedAccessMember>.unmodifiable(removed),
    ));
  }

  /// Adding someone back cancels their removal entry — see [removeMember].
  void _setMembers(List<DatabaseMember> members) {
    final List<RemovedAccessMember> removed = state.removedMembers
        .where((RemovedAccessMember r) => !members.contains(r.member))
        .toList(growable: false);

    emit(state.copyWith(
      grant: state.grant.copyWith(
        members: List<DatabaseMember>.unmodifiable(members),
      ),
      removedMembers: removed,
    ));
  }

  // ── The rule ─────────────────────────────────────────────────────────────

  void permissionChanged(DatabasePermissionLevel level) =>
      emit(state.copyWith(grant: state.grant.copyWith(permission: level)));

  void startDateChanged(DateTime date) =>
      emit(state.copyWith(grant: state.grant.copyWith(startDate: date)));

  void endDateChanged(DateTime date) =>
      emit(state.copyWith(grant: state.grant.copyWith(endDate: date)));

  /// Which of the table's columns the grant's holders may see. An empty list is
  /// a real value meaning "all fields"; see `DatabaseAccessGrant.viewableFields`.
  /// Function Name: [memberFieldsChanged]
  ///
  /// Purpose: Set the columns ONE person may see (Figma 7398:14122 / 14296).
  ///
  /// Writes an explicit entry even when the list matches the grant's own set,
  /// so a person who has been deliberately given the default is not silently
  /// re-widened the next time the shared set changes.
  void memberFieldsChanged(String memberId, List<String> fields) {
    final Map<String, List<String>> next =
        Map<String, List<String>>.of(state.memberFields);
    next[memberId] = List<String>.unmodifiable(fields);
    emit(state.copyWith(memberFields: next));
  }

  void viewableFieldsChanged(List<String> fields) => emit(
        state.copyWith(
          grant: state.grant.copyWith(
            viewableFields: List<String>.unmodifiable(fields),
          ),
        ),
      );

  // ── Discard / Save ───────────────────────────────────────────────────────

  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  /// "Discard Changes" — back to the rule as loaded.
  void discard() {
    final DatabaseAccessGrant? loaded = state.original;
    if (loaded == null) return;

    emit(state.copyWith(
      grant: loaded,
      removedMembers: const <RemovedAccessMember>[],
      status: TableAccessStatus.initial,
      clearErrorMessage: true,
    ));
  }

  /// Function Name: [save]
  ///
  /// Purpose: Write the rule as the table's whole `Access_Grants` subcollection.
  ///
  /// The guard is the page's, not this method's: `canSave` names which field is
  /// missing better than a boolean returned from here could, and the page has
  /// the localized copy to say it with.
  ///
  /// One record out, always — with the id it was loaded under so the document is
  /// rewritten rather than duplicated. The repository REPLACES the collection,
  /// so any extra rows merged in on load disappear in the same batch.
  Future<void> save({
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    emit(state.copyWith(
      status: TableAccessStatus.submitting,
      clearErrorMessage: true,
    ));

    // ONE RECORD PER DISTINCT FIELD SET (17/8/2026).
    //
    // The review screen gives every person their own Viewable Fields, so a
    // single document can no longer hold the answer. It is not one document per
    // PERSON either: ten people who see the same columns are one rule, and ten
    // identical documents would be ten things to keep in step.
    //
    // Everything else on the rule — the permission and the two dates — is the
    // same on every record, because the review screen does not edit them: they
    // come from the grant that was created earlier and this screen carries them
    // through. See `TableAccessState.hasInheritedRule`.
    final Map<String, List<DatabaseMember>> byFields =
        <String, List<DatabaseMember>>{};
    final Map<String, List<String>> fieldsByKey = <String, List<String>>{};

    for (final DatabaseMember member in state.grant.members) {
      final List<String> fields = List<String>.of(state.fieldsFor(member))
        ..sort();
      // Sorted before joining, so the same set picked in a different order is
      // still one bucket rather than two rules that happen to agree.
      final String key = fields.join('\u0000');
      byFields.putIfAbsent(key, () => <DatabaseMember>[]).add(member);
      fieldsByKey[key] = fields;
    }

    final List<DatabaseAccessGrantRecord> records = <DatabaseAccessGrantRecord>[
      for (final MapEntry<String, List<DatabaseMember>> entry
          in byFields.entries)
        DatabaseAccessGrantRecord(
          // The FIRST bucket keeps the document id that was loaded, so an edit
          // that did not split anyone rewrites the same row instead of leaving
          // the old one to be swept and a new one created.
          id: entry.key == byFields.keys.first ? state.recordId : '',
          grant: state.grant.copyWith(
            members: entry.value,
            viewableFields: fieldsByKey[entry.key]!,
          ),
          // The removed people ride on the first record only — they are a
          // property of the table's access as a whole, not of one field set,
          // and repeating them would count each person once per bucket.
          removedMembers: entry.key == byFields.keys.first
              ? state.removedMembers
              : const <RemovedAccessMember>[],
          grantedBy: grantedBy,
          grantedByNameEn: grantedByNameEn,
          grantedByNameAr: grantedByNameAr,
        ),
    ];

    // Nobody on the grant means the rule is gone, not that an empty rule should
    // be stored: an empty `members` list would leave a document claiming a
    // permission level nobody holds. The removed people still travel — they are
    // on the record, and the record is only dropped when there is nothing left
    // to say about them either.
    final bool empty =
        state.grant.members.isEmpty && state.removedMembers.isEmpty;

    final Either<Failure, void> result = await _repository.replaceTableGrants(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
      records: empty ? const <DatabaseAccessGrantRecord>[] : records,
      grantedBy: grantedBy,
      grantedByNameEn: grantedByNameEn,
      grantedByNameAr: grantedByNameAr,
    );

    // Captured BEFORE the emit, because the emit replaces `original` with the
    // rule that was just saved — after it there is nothing left to diff against.
    final DatabaseAccessGrant? loaded = state.original;
    final DatabaseAccessGrant written = state.grant;

    emit(result.fold(
      (Failure failure) => state.copyWith(
        status: TableAccessStatus.failure,
        errorMessage: failure.errMessage,
      ),
      (_) => state.copyWith(
        status: TableAccessStatus.success,
        // The saved rule becomes the new baseline, so the next Discard returns
        // here rather than to the state before this save.
        original: state.grant,
        table: state.table.copyWith(memberCount: state.grant.members.length),
        clearErrorMessage: true,
      ),
    ));

    if (state.status != TableAccessStatus.success) return;

    // ── Notifications (spec §1.7) ───────────────────────────────────────────
    //
    // After the emit, not awaited — see `DatabaseNotificationDispatcher`.
    //
    // `viewableFieldsChanged` is passed EXPLICITLY rather than left to the
    // dispatcher's rule diff. That diff decides whether a person's own access
    // moved, which is a per-person question; the field list is one value on one
    // grant that everybody on it shares, and it has its own event
    // ("Data Visibility Permissions Updated"). Comparing as a SET, because
    // reordering the columns somebody may see is not a change to what they see.
    DatabaseNotificationDispatcher.accessSaved(
      databaseNameEn: databaseNameEn,
      databaseNameAr: databaseNameAr,
      tableNameEn: state.table.nameEn,
      tableNameAr: state.table.nameAr,
      before: loaded == null
          ? const <DatabaseAccessGrant>[]
          : <DatabaseAccessGrant>[loaded],
      after: <DatabaseAccessGrant>[written],
      viewableFieldsChanged: loaded != null &&
          !_sameFields(loaded.viewableFields, written.viewableFields),
    );
  }

  /// Two field lists that hold the same column ids, in any order.
  static bool _sameFields(List<String> before, List<String> after) {
    final Set<String> was = before.toSet();
    final Set<String> now = after.toSet();
    return was.length == now.length && was.containsAll(now);
  }
}

/// The org directory, fetched once per screen. A private pair so [load] can
/// await ONE future instead of two.
class _Directory {
  const _Directory({required this.employees, required this.departments});

  final List<DatabaseMember> employees;
  final List<DatabaseDepartment> departments;
}
