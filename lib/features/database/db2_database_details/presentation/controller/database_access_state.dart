/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_state.dart
/// Purpose: Declares `DatabaseAccessState` and `DatabaseExportStatus`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026

part of './database_access_cubit.dart';

/// Where the Export button is in its lifecycle.
///
/// A separate axis from the screen's loading flag on purpose: exporting must
/// not blank out the table it is exporting, and a failed export must not make
/// the access list look unreadable.
enum DatabaseExportStatus { idle, running, empty, success, failure }

@immutable
class DatabaseAccessState {
  const DatabaseAccessState({
    required this.database,
    this.table,
    this.isLoading = false,
    this.records = const <DatabaseAccessGrantRecord>[],
    this.employees = const <DatabaseMember>[],
    this.departments = const <DatabaseDepartment>[],
    this.filter = DatabaseAccessFilter.all,
    this.searchQuery = '',
    this.departmentFilter,
    this.errorMessage,
    this.exportStatus = DatabaseExportStatus.idle,
    this.exportedFile,
  });

  /// The record whose access this is. Held in state rather than passed to
  /// every method because the Access Grantor fallback needs its `created_by`
  /// and the CSV file name needs its title.
  final DatabaseEntity database;

  /// Set when this screen is showing ONE TABLE's access rather than the whole
  /// database's (Figma 7398:11000, the `Access` crumb under Table Name
  /// Details). Null on the database-level screen, and that null is what every
  /// branch in the cubit and the page keys off.
  final DatabaseTableEntity? table;

  final bool isLoading;

  /// The `Access_Grants` documents, unflattened. The rows are derived from
  /// these — see `DatabaseAccessCubit.allRows`.
  final List<DatabaseAccessGrantRecord> records;

  /// The org directory, used only to turn ids into names.
  final List<DatabaseMember> employees;
  final List<DatabaseDepartment> departments;

  final DatabaseAccessFilter filter;
  final String searchQuery;

  /// The Filter dialog's department narrowing, on top of the chip. Null when
  /// no department filter is applied — distinct from the empty string, which
  /// is the dialog's "All" sentinel.
  final String? departmentFilter;

  final String? errorMessage;

  final DatabaseExportStatus exportStatus;

  /// The written CSV, so the success dialog can name it.
  final File? exportedFile;

  bool get isExporting => exportStatus == DatabaseExportStatus.running;

  bool get hasDepartmentFilter =>
      departmentFilter != null && departmentFilter!.isNotEmpty;

  String get filterKey => filter.name;

  /// The nullable fields take explicit clear flags — `copyWith` alone cannot
  /// express "set this back to null", so clearing the department filter or a
  /// consumed error would otherwise be impossible.
  DatabaseAccessState copyWith({
    DatabaseEntity? database,
    DatabaseTableEntity? table,
    bool? isLoading,
    List<DatabaseAccessGrantRecord>? records,
    List<DatabaseMember>? employees,
    List<DatabaseDepartment>? departments,
    DatabaseAccessFilter? filter,
    String? searchQuery,
    String? departmentFilter,
    String? errorMessage,
    DatabaseExportStatus? exportStatus,
    File? exportedFile,
    bool clearDepartmentFilter = false,
    bool clearErrorMessage = false,
    bool clearExportedFile = false,
  }) {
    return DatabaseAccessState(
      database: database ?? this.database,
      table: table ?? this.table,
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      employees: employees ?? this.employees,
      departments: departments ?? this.departments,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      departmentFilter: clearDepartmentFilter
          ? null
          : (departmentFilter ?? this.departmentFilter),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      exportStatus: exportStatus ?? this.exportStatus,
      exportedFile:
          clearExportedFile ? null : (exportedFile ?? this.exportedFile),
    );
  }
}
