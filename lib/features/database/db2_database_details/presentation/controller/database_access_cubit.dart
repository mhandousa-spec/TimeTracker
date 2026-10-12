/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_cubit.dart
/// Purpose: Declares `DatabaseAccessCubit`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The Access screen — Figma 7398:10662 (iPad V) / 7398:10875 (iPad H).
///
/// WHAT IT DOES THAT THE SCREEN CANNOT
/// -----------------------------------
/// The screen shows a flat table of PEOPLE. Firestore holds a subcollection of
/// GRANTS — a department with twelve members is one document. Two joins have
/// to happen before a row can be drawn, and both need data that lives outside
/// the grant:
///
///   * the Department column is a NAME; the member snapshot only carries the id
///   * the Access Grantor column is a NAME; the grant carries an employee id,
///     and older grants carry nothing at all and fall back to the database's
///     `created_by`
///
/// So the directory is loaded alongside the grants and the flattening happens
/// here, once, into `DatabaseAccessRow`. Doing it in the table widget would
/// re-resolve a department name per cell per rebuild and would leave the
/// Export button re-deriving the same list a second time — the classic way for
/// a CSV to disagree with the screen it was exported from.

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/share_helper.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/repository/database_details_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/repository/create_table_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_row.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/enums/database_access_status.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

part './database_access_state.dart';

class DatabaseAccessCubit extends Cubit<DatabaseAccessState> {
  DatabaseAccessCubit({
    required DatabaseEntity database,
    DatabaseTableEntity? table,
    DatabaseDetailsBaseRepository? repository,
    CreateTableBaseRepository? tableRepository,
    CSVHelper? csvHelper,
  })  : _repository = repository ?? DatabaseDetailsRepository(),
        _tableRepository = tableRepository ?? CreateTableRepository(),
        _csv = csvHelper ?? CSVHelper(),
        super(DatabaseAccessState(database: database, table: table));

  final DatabaseDetailsBaseRepository _repository;

  /// Only reached when the screen is showing a TABLE's access. Constructed
  /// either way because a cubit that builds half its dependencies lazily is a
  /// cubit whose failure mode depends on which screen opened it.
  final CreateTableBaseRepository _tableRepository;

  final CSVHelper _csv;

  @override
  void emit(DatabaseAccessState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  /// Function Name: [load]
  ///
  /// Purpose: Read the grants and the directory, then build the rows.
  ///
  /// The two reads run CONCURRENTLY. They are independent — grants come from
  /// this database's subcollection, the directory from controllers the app
  /// already registers — and awaiting them in sequence made the table appear
  /// a directory-read later than it needed to, on a screen whose whole content
  /// is that table.
  ///
  /// A directory failure is NOT fatal: the rows still render, just with blank
  /// Department and Access Grantor cells. Refusing to show anyone's access
  /// because the org chart could not be read would hide the security-relevant
  /// half of the screen over the cosmetic half.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    // A TABLE's grants live one subcollection deeper than a database's, and
    // both reads return the same `DatabaseAccessGrantRecord` — the two
    // subcollections are deliberately the same document shape (see
    // `CreateTableBaseRepository.fetchTableGrants`). That is what lets one
    // screen render either, instead of a near-copy per level.
    final DatabaseTableEntity? table = state.table;
    final Future<Either<Failure, List<DatabaseAccessGrantRecord>>> grantsFuture =
        table == null
            ? _repository.fetchGrants(state.database.id)
            : _tableRepository.fetchTableGrants(
                databaseId: table.databaseId,
                tableId: table.id,
              );
    final Future<_Directory> directoryFuture = _loadDirectory();

    final Either<Failure, List<DatabaseAccessGrantRecord>> grants =
        await grantsFuture;
    final _Directory directory = await directoryFuture;

    emit(grants.fold(
      (Failure failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.errMessage,
      ),
      (List<DatabaseAccessGrantRecord> records) => state.copyWith(
        isLoading: false,
        records: records,
        departments: directory.departments,
        employees: directory.employees,
        clearErrorMessage: true,
      ),
    ));
  }

  /// Reuses `MainCoreEmployeeController` / `MainCoreDepartmentCubit` — the
  /// app's single source for the org directory — rather than opening a second
  /// set of Firestore queries, the same reasoning as
  /// `CreateDatabaseCubit.loadDirectory`.
  ///
  /// Degrades to empty rather than throwing; see [load] for why that is the
  /// right failure mode on this screen.
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

  void filterChanged(String key) {
    for (final DatabaseAccessFilter f in DatabaseAccessFilter.values) {
      if (f.name == key) {
        emit(state.copyWith(filter: f));
        return;
      }
    }
  }

  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  /// Applies the Filter dialog's department narrowing. Null clears it.
  void departmentFilterChanged(String? departmentId) => emit(
        departmentId == null
            ? state.copyWith(clearDepartmentFilter: true)
            : state.copyWith(departmentFilter: departmentId),
      );

  void clearMessages() => emit(state.copyWith(
        clearErrorMessage: true,
        clearExportedFile: true,
      ));

  /// Called after the edit-access flow saves, so the table reflects the new
  /// grants without the screen being rebuilt from scratch.
  void databaseChanged(DatabaseEntity database) {
    emit(state.copyWith(database: database));
    load();
  }

  // ── Export ───────────────────────────────────────────────────────────────

  /// Function Name: [exportVisibleRows]
  ///
  /// Purpose: Write what is ON SCREEN to a CSV and hand it to the share sheet.
  ///
  /// VISIBLE rows, not every row. The chips and the search box are the user's
  /// statement of what they are looking at; an export that silently widened
  /// that back out to everyone would be a data leak dressed as a convenience —
  /// someone filtering to "Removed" before exporting is asking for the removed
  /// list, not the whole access list.
  ///
  /// `CSVHelper` writes a UTF-8 BOM, which is what makes the Arabic name column
  /// open correctly in Excel; that is the reason this goes through the shared
  /// helper rather than joining commas here.
  Future<void> exportVisibleRows({
    required List<String> headers,
    required String Function(DatabaseAccessRow row) statusLabel,
    required String Function(DatabasePermissionLevel? level) permissionLabel,
    required String Function(DateTime? date) dateLabel,
    required bool isArabic,
  }) async {
    final List<DatabaseAccessRow> rows = visibleRows(isArabic: isArabic);
    if (rows.isEmpty) {
      emit(state.copyWith(exportStatus: DatabaseExportStatus.empty));
      return;
    }

    emit(state.copyWith(
      exportStatus: DatabaseExportStatus.running,
      clearExportedFile: true,
    ));

    try {
      final List<List<dynamic>> table = <List<dynamic>>[
        headers,
        for (final DatabaseAccessRow row in rows)
          <dynamic>[
            // Title-cased like the table on screen. The export is the same data
            // the user was just looking at, and a CSV that spells names
            // differently from the screen it came from reads as a different
            // report. The file NAME below is left alone — that is a path, not
            // text.
            FormatHelper.capitalize(
                row.member.localizedName(isArabic: isArabic)),
            row.departmentName,
            row.grantorName,
            dateLabel(row.startDate),
            dateLabel(row.endDate),
            permissionLabel(row.permission),
            statusLabel(row),
          ],
      ];

      // The file name carries the database title so two exports sitting in the
      // same Downloads folder can be told apart. Anything that is not a letter
      // or a digit becomes an underscore — a title with a slash in it would
      // otherwise be read as a directory that does not exist.
      final String safeTitle = state.database
          .localizedTitle(isArabic: isArabic)
          .replaceAll(RegExp(r'[^\w؀-ۿ]+'), '_');
      final String fileName =
          'access_${safeTitle.isEmpty ? 'database' : safeTitle}';

      final File file = await _csv.exportToCSV(table, fileName);

      emit(state.copyWith(
        exportStatus: DatabaseExportStatus.success,
        exportedFile: file,
      ));

      // Sharing is best-effort and deliberately AFTER the success emit: the
      // file is already written, so a share sheet the platform refuses to open
      // must not be reported as a failed export.
      await ShareHelper.shareFile(file);
    } catch (error) {
      emit(state.copyWith(
        exportStatus: DatabaseExportStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void exportHandled() => emit(state.copyWith(
        exportStatus: DatabaseExportStatus.idle,
        clearExportedFile: true,
      ));

  // ── Rows ─────────────────────────────────────────────────────────────────

  /// Every person on this database, live and removed, one row each.
  ///
  /// Built on demand rather than stored in state because it depends on the UI
  /// locale — the Department and Grantor columns are names — and a cubit that
  /// cached a localized string would hand the wrong language to a user who
  /// switched it without leaving the screen.
  List<DatabaseAccessRow> allRows({required bool isArabic}) {
    final List<DatabaseAccessRow> rows = <DatabaseAccessRow>[];

    for (final DatabaseAccessGrantRecord record in state.records) {
      final DatabaseAccessGrant grant = record.grant;
      final String grantor = _grantorName(record, isArabic: isArabic);
      final DatabaseAccessStatus status = DatabaseAccessStatus.resolve(grant);

      for (final DatabaseMember member in grant.members) {
        rows.add(DatabaseAccessRow(
          member: member,
          status: status,
          // The grant's department wins over the member's own when the grant
          // is department-scoped: that is the department the access was given
          // THROUGH, which is what the column is reporting. Someone who has
          // since transferred still holds this access via their old team.
          departmentName: grant.isDepartmentScoped
              ? _departmentName(grant.departmentId, isArabic: isArabic,
                  fallbackEn: grant.departmentNameEn,
                  fallbackAr: grant.departmentNameAr)
              : _departmentName(member.departmentId, isArabic: isArabic),
          grantorName: grantor,
          permission: grant.permission,
          startDate: grant.startDate,
          endDate: grant.endDate,
        ));
      }

      for (final RemovedAccessMember removed in record.removedMembers) {
        rows.add(DatabaseAccessRow(
          member: removed.member,
          status: DatabaseAccessStatus.removed,
          departmentName: _departmentName(
            removed.departmentId ?? removed.member.departmentId,
            isArabic: isArabic,
            fallbackEn: removed.departmentNameEn,
            fallbackAr: removed.departmentNameAr,
          ),
          grantorName: grantor,
          permission: removed.permission,
          startDate: removed.startDate,
          endDate: removed.endDate,
          removedAt: removed.removedAt,
        ));
      }
    }

    return rows;
  }

  /// What the table draws: [allRows] narrowed by the chip, the search box and
  /// the Filter dialog's department.
  List<DatabaseAccessRow> visibleRows({required bool isArabic}) {
    final DatabaseAccessStatus? wanted = state.filter.status;
    final String? department = state.departmentFilter;

    return allRows(isArabic: isArabic).where((DatabaseAccessRow row) {
      if (wanted != null && row.status != wanted) return false;
      if (department != null &&
          department.isNotEmpty &&
          row.member.departmentId != department) {
        return false;
      }
      return row.matches(state.searchQuery);
    }).toList(growable: false);
  }

  /// The number on one chip. Counted from [allRows] rather than from the
  /// visible list, so narrowing to "Active" does not zero every other chip and
  /// make the row look like the data disappeared.
  int countFor(DatabaseAccessFilter filter, {required bool isArabic}) {
    final List<DatabaseAccessRow> rows = allRows(isArabic: isArabic);
    final DatabaseAccessStatus? wanted = filter.status;
    if (wanted == null) return rows.length;
    return rows.where((DatabaseAccessRow r) => r.status == wanted).length;
  }

  // ── Name joins ───────────────────────────────────────────────────────────

  /// "Access Grantor" — the person who CREATED THE DATABASE.
  ///
  /// CHANGED 17/8/2026. It used to be the grant's own grantor: whichever
  /// employee's id was stamped on that particular `Access_Grants` document,
  /// falling back to the creator only when the document did not say.
  ///
  /// It is now always the creator, and the record's own `granted_by` is ignored
  /// for display. In this module the database's owner is who administers access
  /// to it — the Access screen is reached from the owner's own details page —
  /// so one column saying who is answerable for the whole list is more useful
  /// than a column that changes per row depending on which admin happened to
  /// press Save last.
  ///
  /// The `granted_by` fields are still WRITTEN, untouched, by
  /// `replaceGrants` / `replaceTableGrants`. They are the audit trail, and
  /// dropping them because one column stopped rendering them would throw away
  /// the answer to "who actually did this" — this method only decides what the
  /// column shows.
  ///
  /// [record] is kept in the signature for that reason: it is the argument this
  /// would need again the moment the column goes back to being per-row.
  String _grantorName(
    DatabaseAccessGrantRecord record, {
    required bool isArabic,
  }) {
    final String? id = state.database.createdBy;
    if (id == null || id.isEmpty) return '';

    for (final DatabaseMember m in state.employees) {
      if (m.employeeId == id) {
        return FormatHelper.capitalize(m.localizedName(isArabic: isArabic));
      }
    }

    // The creator is no longer in the directory — they left the company, or the
    // directory could not be reached. An empty cell renders as "—", which is
    // the honest answer; the raw employee id would read as corruption.
    return '';
  }

  /// Resolves a department id to a NAME, preferring the live directory and
  /// falling back to the snapshot stored on the grant.
  ///
  /// Live first because a renamed department should show its new name; the
  /// snapshot second because a department that has since been deleted still
  /// has to render as the thing the access was granted through, not as blank.
  /// A raw id is never returned — see `MemberGrid._departmentLabel` for why a
  /// bare Firestore key in a person's row reads as corruption.
  String _departmentName(
    String? departmentId, {
    required bool isArabic,
    String? fallbackEn,
    String? fallbackAr,
  }) {
    if (departmentId != null && departmentId.isNotEmpty) {
      for (final DatabaseDepartment d in state.departments) {
        if (d.id == departmentId) return d.localizedName(isArabic: isArabic);
      }
    }

    final String? preferred = isArabic ? fallbackAr : fallbackEn;
    final String? other = isArabic ? fallbackEn : fallbackAr;
    if (preferred != null && preferred.isNotEmpty) return preferred;
    return other ?? '';
  }
}

/// The two directory lists, returned together so [DatabaseAccessCubit.load]
/// can await one future instead of two.
@immutable
class _Directory {
  const _Directory({required this.employees, required this.departments});

  final List<DatabaseMember> employees;
  final List<DatabaseDepartment> departments;
}
