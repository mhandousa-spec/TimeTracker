/// Module: roles / r4_active_directory / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: active_directory_controller.dart
/// Purpose: Declares `ActiveDirectoryController`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

/// **************************
/// file name: active_directory_controller.dart
/// purpose: file control active directory section to add employees to system
/// Author: Mohamed Elrashidy
/// refactored: 18/12/2024

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/wrong_employee_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data_functions.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';


import 'package:knowticed_plus/core/network/failure_model.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/invalid_import_row_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/core/helper/role/id_constants.dart';
import 'package:knowticed_plus/core/helper/role/csv_enums.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/constants/active_directory_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/repository/active_directory_repository.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import './employees_csv_file_data_consistency.dart';
import './employees_csv_file_uploader.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/main.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

part './active_directory_state.dart';
part './active_directory_controller_export.dart';

// REMOVED 12/8/2026: `final storage = GetStorage();` — a top-level GetStorage
// instance with no readers, and the last GetX dependency in this file.

// ─────────────────────────────────────────────────────────────────────────────
// Column indices — must match EmployeeDataItems enum order.
// Referenced by filteredUsersData getter below.
//   15:gender  16:country  23:departmentEnglishName
//   25:supervisorEmail  26:role  27:englishTitle  29:workLocation
// ─────────────────────────────────────────────────────────────────────────────

class ActiveDirectoryController extends Cubit<ActiveDirectoryState> {
  /// Department lookups are injected; no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  /// Function Name: [emitSafely]
  ///
  /// Purpose: Publish [state] only while this cubit is still open.
  ///
  /// Every load path here awaits Firestore before emitting; navigating away
  /// mid-fetch closed the cubit and the completion then threw
  /// "Cannot emit after close" (§16). Routing every emit through here makes the
  /// guard impossible to forget at a new call site.
  ///
  /// Parameters:
  /// - [state]: The state to publish.
  ///
  /// Returns: [void]
  void emitSafely(ActiveDirectoryState state) {
    if (isClosed) return;
    emit(state);
  }

  ActiveDirectoryController({required this.departmentCubit})
      : super(ActiveDirectoryInitial()) {
    init();
  }

  /// Public trigger so widgets can request a rebuild (replaces the old GetX
  /// `update()` API, since [emit] is protected).
  void refresh() => emitSafely(ActiveDirectoryUpdated());
  void emitState(ActiveDirectoryState state) => emitSafely(state);

  final ActiveDirectoryRepository activeDirectoryRepository =
  ActiveDirectoryRepository();

  // ── Loading / tab state ───────────────────────────────────────────────────
  bool loadingData = false;
  int selectedIndex = 0;
  int invalidFieldsCount = 0;

  late List<bool> isSaved;
  late List<bool> isChanged;
  late List<bool> isInvalidSaved;
  late List<bool> isInvalidChanged;

  AddWrongEmployeeController addWrongEmployeeController =
      AppControllers.wrongEmployees;
  EmployeeController employeeController = AppControllers.employeeDirectory;

  bool isEditMode = false;


  // ── Raw data ──────────────────────────────────────────────────────────────
  List<dynamic> usersData = [];
  List<dynamic> invalidChangedFields = [];
  List<dynamic> changedFields = [];
  CsvStatus? status;
  List<dynamic> rowInvalid = [];
  // Cubit conversion: GetX no longer calls onInit(), so init() is explicit.
  EmployeeController addEmployeeFromExcel =
      AppControllers.putEmployeeDirectory();
  late List<bool> isEditable;
  late List<bool> isInvalidEditable;

  // ══════════════════════════════════════════════════════════════════════════
  // FILTER & SEARCH STATE
  // ══════════════════════════════════════════════════════════════════════════

  String? filterDepartment;
  String? filterRole;
  String? filterTitle;
  String? filterWorkLocation;
  String? filterSupervisor;
  String? filterGender;
  String? filterNationality; // kept for UI parity; not in CSV → always null
  String? filterCountry;
  String searchQuery = '';

  /// Backs the search field. `AppSearchTextField` (the shared search widget)
  /// needs a TextEditingController, and the search state already lives here.
  final TextEditingController searchController = TextEditingController();

  // ── Derived helpers ───────────────────────────────────────────────────────

  /// True when at least one dropdown filter or search term is active.
  bool get hasActiveFilters =>
      filterDepartment != null ||
          filterRole != null ||
          filterTitle != null ||
          filterWorkLocation != null ||
          filterSupervisor != null ||
          filterGender != null ||
          filterNationality != null ||
          filterCountry != null ||
          searchQuery.isNotEmpty;

  /// Count of active dropdown filters only (used for the badge on the button).
  int get activeFilterCount => [
    filterDepartment,
    filterRole,
    filterTitle,
    filterWorkLocation,
    filterSupervisor,
    filterGender,
    filterNationality,
    filterCountry,
  ].where((v) => v != null && v.isNotEmpty).length;

  /// Filtered + searched subset of [usersData].
  ///
  /// Returns the full [usersData] list when nothing is active so the table
  /// never shows an unexpected empty state.
  List<dynamic> get filteredUsersData {
    if (!hasActiveFilters) return usersData;

    return usersData.where((row) {
      // ── Helper: case-insensitive exact match for a single column ──────────
      bool _match(String? filter, int colIndex) {
        if (filter == null || filter.isEmpty) return true;
        if (row.length <= colIndex) return false;
        return row[colIndex]?.toString().trim().toLowerCase() ==
            filter.trim().toLowerCase();
      }

      if (!_match(filterDepartment,   23)) return false;
      if (!_match(filterRole,         26)) return false;
      if (!_match(filterTitle,        27)) return false;
      if (!_match(filterWorkLocation, 29)) return false;
      if (!_match(filterSupervisor,   25)) return false;
      if (!_match(filterGender,       15)) return false;
      if (!_match(filterCountry,      16)) return false;
      // filterNationality: not in CSV (index -1) — intentionally skipped

      // ── Search: any cell in the row contains the query ────────────────────
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final hit = row.any(
              (cell) => cell?.toString().toLowerCase().contains(q) ?? false,
        );
        if (!hit) return false;
      }

      return true;
    }).toList();
  }

  // ── Public API called by the filter dialog ────────────────────────────────

  /// Apply all dropdown selections at once and rebuild the table.
  void applyFilters({
    String? department,
    String? role,
    String? title,
    String? workLocation,
    String? supervisor,
    String? gender,
    String? nationality,
    String? country,
  }) {
    filterDepartment   = department;
    filterRole         = role;
    filterTitle        = title;
    filterWorkLocation = workLocation;
    filterSupervisor   = supervisor;
    filterGender       = gender;
    filterNationality  = nationality;
    filterCountry      = country;
    emitSafely(ActiveDirectoryUpdated());
  }

  /// Clear all filters and the search query, then rebuild the table.
  void clearFilters() {
    filterDepartment   = null;
    filterRole         = null;
    filterTitle        = null;
    filterWorkLocation = null;
    filterSupervisor   = null;
    filterGender       = null;
    filterNationality  = null;
    filterCountry      = null;
    searchQuery        = '';
    searchController.clear();
    emitSafely(ActiveDirectoryUpdated());
  }

  /// Called on every keystroke in the search bar.
  void onSearchChanged(String query) {
    searchQuery = query;
    emitSafely(ActiveDirectoryUpdated());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EDIT MODE
  // ══════════════════════════════════════════════════════════════════════════

  void toggleEditMode() {
    isEditMode = !isEditMode;
    emitSafely(ActiveDirectoryUpdated());
  }

  void discardAllChanges() {
    isEditMode = false;
    if (invalidChangedFields.isNotEmpty) {
      invalidChangedFields =
          rowInvalid.map((subList) => List.from(subList)).toList();
    }
    if (changedFields.isNotEmpty) {
      changedFields = usersData.map((subList) => List.from(subList)).toList();
    }
    if (isInvalidEditable.isNotEmpty) {
      isInvalidEditable = List.generate(rowInvalid.length, (_) => false);
    }
    if (isEditable.isNotEmpty) {
      isEditable = List.generate(usersData.length, (_) => false);
    }
    emitSafely(ActiveDirectoryUpdated());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REMOVE ROWS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> removeInvalidEmployee(int rowIndex) async {
    try {
      rowInvalid.removeAt(rowIndex);
      invalidChangedFields.removeAt(rowIndex);
      isInvalidEditable = List.generate(rowInvalid.length, (_) => false);
      isInvalidChanged  = List.generate(rowInvalid.length, (_) => false);
      isInvalidSaved    = List.generate(rowInvalid.length, (_) => false);
      invalidFieldsCount = 0;
      for (int i = 0; i < rowInvalid.length; i++) {
        validateWrongRowFields(rowInvalid[i]);
      }
      emitSafely(ActiveDirectoryUpdated());
    } catch (e) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
      debugPrint('active_directory_controller.dart: non-fatal failure: $e');
    }
  }

  /// Remove a valid employee from Firebase and update local lists.
  Future<void> removeValidEmployee(int rowIndex) async {
    try {
      if (rowIndex >= usersData.length) {
        return;
      }

      final String employeeId =
          usersData[rowIndex][EmployeeDataItems.id.index]?.toString() ?? '';

      if (employeeId.isEmpty) {
        return;
      }

      showLoadingIndicator();

      final result = await activeDirectoryRepository.removeValidEmployee(
        employeeId: employeeId,
      );

      hideLoadingIndicator();

      result.fold(
            (failure) {
          CustomDialogManager.showMessage(
            context: globalNavigatorKey.currentContext!,
            title: "Error",
            subtitle: failure.message,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        },
            (_) {
          usersData.removeAt(rowIndex);
          changedFields.removeAt(rowIndex);
          isEditable = List.generate(usersData.length, (_) => false);
          isChanged  = List.generate(usersData.length, (_) => false);
          isSaved    = List.generate(usersData.length, (_) => false);
          emitSafely(ActiveDirectoryUpdated());
        },
      );
    } catch (e, st) {
      hideLoadingIndicator();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INIT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> setUserData() async {
    try {
      changedFields = usersData.map((subList) => List.from(subList)).toList();
      isEditable = List.generate(usersData.length, (index) => false);
      emitSafely(ActiveDirectoryUpdated());
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
      debugPrint('active_directory_controller.dart: non-fatal failure: $e');
    }
  }

  Future<void> init() async {

    try {
      await fetchTableData().then((value) {

        loadingData = true;
        emitSafely(ActiveDirectoryUpdated());

        isSaved = List.generate(usersData.length, (index) => false);

        isChanged = List.generate(usersData.length, (index) => false);

        loadingData = false;
        emitSafely(ActiveDirectoryUpdated());

        emitSafely(ActiveDirectoryUpdated());

      });
    } catch (e, stackTrace) {
      loadingData = false;
      emitSafely(ActiveDirectoryUpdated());
    }
  }

  toggleIndex(int value) {
    selectedIndex = value;
    emitSafely(ActiveDirectoryUpdated());
  }

  resetVariables(int count, int invalidCount) {

    try {
      isEditable       = List.generate(count,        (index) => false);
      isInvalidEditable = List.generate(invalidCount, (index) => false);
      isSaved          = List.generate(count,        (index) => false);
      isInvalidSaved   = List.generate(invalidCount, (index) => false);
      isChanged        = List.generate(count,        (index) => false);
      isInvalidChanged = List.generate(invalidCount, (index) => false);
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
      debugPrint('active_directory_controller.dart: non-fatal failure: $e');
    }
  }

  toggleRowEdit(int index) {
    isEditable[index] = !isEditable[index];
    emitSafely(ActiveDirectoryUpdated());
  }

  toggleRowEditInvalid(int index) {
    isInvalidEditable[index] = !isInvalidEditable[index];
    emitSafely(ActiveDirectoryUpdated());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DATA FETCHING
  // ══════════════════════════════════════════════════════════════════════════

  /// Get all employees from the database.
  getEmployees() async {

    try {
      await employeeController.getAllEmployees();

      await addWrongEmployeeController.getAllEmployees();

      emitSafely(ActiveDirectoryUpdated());
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Get the employees data and convert it to a 2D list of strings.
  Future<void> fetchTableData() async {

    try {
      loadingData = true;

      await getEmployees();

      await getEmployeesTableData();

      getEmployeesTableWrongData();

      loadingData = false;
      emitSafely(ActiveDirectoryUpdated());

    } catch (e, stackTrace) {
      loadingData = false;
      emitSafely(ActiveDirectoryUpdated());
      rethrow;
    }
  }

  Future<void> getEmployeesTableData() async {

    try {
      usersData = [];

      if (employeeController.employeesWithoutFilter == null) {
        changedFields = [];
        resetVariables(0, rowInvalid.length);
        return;
      }

      // Load departments
      try {
        final departmentController = departmentCubit;
        await departmentController.getAllDepartments();
      } catch (e) {
        // Was an empty `catch {}` — the failure is deliberately
        // non-fatal here, but it must not vanish silently (§11.5).
        debugPrint('active_directory_controller.dart: non-fatal failure: $e');
      }

      for (int i = 0;
      i < employeeController.employeesWithoutFilter!.length;
      i++) {
        try {
          NewEmployeeModelHistory employee =
          employeeController.employeesWithoutFilter![i];
          List<String> row =
          List.filled(EmployeeDataItems.values.length, '');
          this._getRowDataFromModel(
              row: row, employee: employee, isWrongEmployee: false);
          usersData.add(row);
        } catch (e, stackTrace) {
          // Was an empty `catch {}` — the failure is deliberately
          // non-fatal here, but it must not vanish silently (§11.5).
          debugPrint('active_directory_controller.dart: non-fatal failure: $e');
        }
      }


      changedFields =
          usersData.map((subList) => List.from(subList)).toList();
      resetVariables(usersData.length, rowInvalid.length);

    } catch (e, stackTrace) {
      rethrow;
    }
  }

  void getEmployeesTableWrongData() {

    try {
      rowInvalid = [];

      if (addWrongEmployeeController.allWrongEmployees == null) {
        invalidChangedFields = [];
        invalidFieldsCount   = 0;
        resetVariables(usersData.length, 0);
        return;
      }

      for (int i = 0;
      i < addWrongEmployeeController.allWrongEmployees!.length;
      i++) {
        try {
          WrongEmployeeModel employee =
          addWrongEmployeeController.allWrongEmployees![i];
          List<String?> row =
          List.filled(EmployeeDataItems.values.length, '');
          this._getRowDataFromModel(
              row: row, employee: employee, isWrongEmployee: true);
          rowInvalid.add(row);
        } catch (e, stackTrace) {
          // Was an empty `catch {}` — the failure is deliberately
          // non-fatal here, but it must not vanish silently (§11.5).
          debugPrint('active_directory_controller.dart: non-fatal failure: $e');
        }
      }


      invalidChangedFields =
          rowInvalid.map((subList) => List.from(subList)).toList();

      invalidFieldsCount = 0;
      for (int i = 0; i < rowInvalid.length; i++) {
        validateWrongRowFields(rowInvalid[i]);
      }

      emitSafely(ActiveDirectoryUpdated());
      resetVariables(usersData.length, rowInvalid.length);

    } catch (e, stackTrace) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BACKUPS  (ADDED 30/8/2026)
  // ══════════════════════════════════════════════════════════════════════════
  //
  // The Restore button on this page used to open a success dialog and nothing
  // else — no read, no write. It now opens `_RestoreBackupDialog`
  // (csv_restore_dialog.dart), which previews the two backup collections with
  // the two methods below and then restores the one the user picks.
  //
  // The version strings are the ones `EmployeeBackupRemoteDataSource` already
  // switches on, so the collection previewed is the collection restored.

  /// `Demo/{companyId}/Employees Backup One`.
  static const String backupVersionOne = 'one';

  /// `Demo/{companyId}/Employees Backup Two`.
  static const String backupVersionSecond = 'second';

  /// Function Name: [getBackupTableData]
  ///
  /// Purpose: Read one backup collection and shape it exactly like
  ///          [usersData], so the restore dialog can render it with the same
  ///          columns as the Users Data table.
  ///
  /// Parameters:
  /// - [backupVersion]: [backupVersionOne] or [backupVersionSecond].
  ///
  /// Returns: [Future<List<List<dynamic>>>] one row per employee, each row
  ///          `EmployeeDataItems.values.length` cells wide. Empty when the
  ///          backup has never been written.
  Future<List<List<dynamic>>> getBackupTableData(String backupVersion) async {
    try {
      // Department ids are resolved to names while building each row; on a
      // cold open of the dialog the lookup table may not be loaded yet.
      try {
        await departmentCubit.getAllDepartments();
      } catch (e) {
        debugPrint('active_directory_controller.dart: non-fatal failure: $e');
      }

      final List<NewEmployeeModelHistory> employees =
          await employeeController.getBackupEmployees(backupVersion);

      final List<List<dynamic>> rows = <List<dynamic>>[];
      for (final NewEmployeeModelHistory employee in employees) {
        try {
          final List<String> row =
              List<String>.filled(EmployeeDataItems.values.length, '');
          this._getRowDataFromModel(
              row: row, employee: employee, isWrongEmployee: false);
          rows.add(row);
        } catch (e) {
          // One unreadable backup document must not empty the preview.
          debugPrint('active_directory_controller.dart: non-fatal failure: $e');
        }
      }
      return rows;
    } catch (e, stackTrace) {
      debugPrint('active_directory_controller.dart: non-fatal failure: $e');
      return <List<dynamic>>[];
    }
  }

  /// Function Name: [restoreBackup]
  ///
  /// Purpose: Replace `Employees_Info` with the chosen backup, then reload the
  ///          page from the restored collection.
  ///
  /// **Destructive.** Every current employee document is deleted first — call
  /// this only behind an explicit confirmation. The data source refuses to
  /// restore an empty backup, which is why the dialog also hides the action
  /// for a backup with no rows.
  ///
  /// Parameters:
  /// - [backupVersion]: [backupVersionOne] or [backupVersionSecond].
  ///
  /// Returns: [Future<bool>] `true` when the collection was replaced.
  Future<bool> restoreBackup(String backupVersion) async {
    showLoadingIndicator();
    try {
      await employeeController.restoreFromBackup(
        backupVersion,
        confirmDestructiveRestore: true,
      );
      // Re-read Employees_Info so the table behind the dialog shows the
      // restored rows rather than the ones that were just deleted.
      await init();
      hideLoadingIndicator();
      emitSafely(ActiveDirectoryUpdated());
      return true;
    } catch (e) {
      hideLoadingIndicator();
      await CustomDialogManager.showMessage(
        context: globalNavigatorKey.currentContext!,
        title: S.current.error,
        subtitle: '$e',
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
      );
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════════════════════════════════════

  void validateWrongRowFields(List<dynamic> row) {
    try {
      for (int j = 0; j < row.length; j++) {
        if (EmployeeDataItems.values[j].validate.call(row[j]) != null) {
          if (row[j].toString().trim().isNotEmpty && row[j] != null) {
            invalidFieldsCount++;
          } else if ((row[j].toString().trim().isEmpty || row[j] == null) &&
              ActiveDirectoryConstants.optionalItems
                  .contains(EmployeeDataItems.values[j]) ==
                  false) {
            invalidFieldsCount++;
          }
        }
      }
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
      debugPrint('active_directory_controller.dart: non-fatal failure: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SAVE / EDIT
  // ══════════════════════════════════════════════════════════════════════════

  saveEdits({required int rowIndex, required BuildContext context}) async {

    try {
      hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact);

      if (selectedIndex == 1) {
        updateWrongRow(rowIndex);
      } else {
        final int idIndex    = EmployeeDataItems.id.index;
        final int emailIndex = EmployeeDataItems.email.index;

        final originalId =
            usersData[rowIndex][idIndex]?.toString().trim() ?? '';
        final changedId =
            changedFields[rowIndex][idIndex]?.toString().trim() ?? '';
        final originalEmail = usersData[rowIndex][emailIndex]
            ?.toString()
            .trim()
            .toLowerCase() ??
            '';
        final changedEmail = changedFields[rowIndex][emailIndex]
            ?.toString()
            .trim()
            .toLowerCase() ??
            '';


        if (changedId != originalId || changedEmail != originalEmail) {
          CustomDialogManager.showMessage(
            context: context,
            title: "Warning",
            subtitle: "The User ID and Email cannot be changed",
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        } else {
          await editUsersData(changedFields[rowIndex]);
          isSaved[rowIndex]    = true;
          isChanged[rowIndex]  = false;
          usersData     = changedFields.map((s) => List.from(s)).toList();
          changedFields = usersData.map((s) => List.from(s)).toList();
          isEditable[rowIndex] = false;
          emitSafely(ActiveDirectoryUpdated());
        }
      }
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
      debugPrint('active_directory_controller.dart: non-fatal failure: $e');
    }
  }

  updateWrongRow(int rowIndex) async {

    try {
      bool allValid = EmployeesCsvFileUploader()
          .validateRowValues(invalidChangedFields[rowIndex]);

      if (allValid) {
        await uploadEmployeesData(
            companyId: ApiConstants.baseUri.split("/").last,
            validData: [invalidChangedFields[rowIndex]],
            invalidData: []);
      } else {
        await uploadEmployeesData(
            companyId: ApiConstants.baseUri.split("/").last,
            validData: [],
            invalidData: [invalidChangedFields[rowIndex]]);
      }

      init();
      emitSafely(ActiveDirectoryUpdated());
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
      debugPrint('active_directory_controller.dart: non-fatal failure: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> uploadExcelFile({required int length}) async {

    try {
      showLoadingIndicator();

      Either<Failure, dynamic> result =
      await activeDirectoryRepository.getDemoNumberOfUsers(
          currentUserEmail:
          AppControllers.settings.employee!.email!.last!);

      if (result.isLeft()) {
        hideLoadingIndicator();
        return;
      }

      int demoUsers = result.getOrElse(() => 0);

      Map<String, List<dynamic>> data = await EmployeesCsvFileUploader()
          .extractExcelFileData(length: demoUsers);

      if (data[ActiveDirectoryConstants.validEmployeesData]!.isEmpty &&
          data[ActiveDirectoryConstants.invalidEmployeesData]!.isEmpty) {
        emitSafely(ActiveDirectoryUpdated());
        hideLoadingIndicator();
        return;
      }

      bool isDataConsistent =
      await EmployeesCsvFileDataConsistency(departmentCubit: departmentCubit)
          .validateDepartmentsConsistency(
          data[ActiveDirectoryConstants.validEmployeesData]!
          as List<List<dynamic>>);

      if (!isDataConsistent) {
        hideLoadingIndicator();
        return;
      }

      await uploadEmployeesData(
          companyId: ApiConstants.baseUri.split("/").last,
          validData: data[ActiveDirectoryConstants.validEmployeesData]!,
          invalidData: data[ActiveDirectoryConstants.invalidEmployeesData]!);

      if (data[ActiveDirectoryConstants.validEmployeesData]!.isNotEmpty) {
        await employeeController.getAllEmployees();
        int employeeCount = employeeController.allEmployees?.length ?? 0;
        if (employeeCount > 0) {
          await employeeController.backupCollections();
        }
      }

      hideLoadingIndicator();
      emitSafely(ActiveDirectoryUpdated());
      init();

    } catch (e, stackTrace) {
      hideLoadingIndicator();
    }
  }

  uploadEmployeesData({
    required List validData,
    required List invalidData,
    required String companyId,
  }) async {

    try {
      invalidFieldsCount = 0;

      var result = await activeDirectoryRepository.uploadCsvFileData(
          validData: validData,
          invalidData: invalidData,
          companyId: companyId,
          departmentIds:
          departmentCubit.departmentIds,
          employeesIds: AppControllers.employeeDirectory
              .employeesWithoutFilter!
              .map((e) => e.id!)
              .toList(),
          employeesEmails: AppControllers.employeeDirectory
              .employeesWithoutFilter!
              .map((e) => e.email!.last!)
              .toList(),
          currentUserEmail:
          AppControllers.settings.employee!.email!.last!);

      if (result.isLeft()) {
        hideLoadingIndicator();
        await CustomDialogManager.showMessage(
          context: globalNavigatorKey.currentContext!,
          title: "Upload Failed",
          subtitle: "Failed to upload data.\n\n${result.fold((failure) => failure.message, (_) => '')}",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
        return result;
      }

      return result;
    } catch (e, stackTrace) {

      hideLoadingIndicator();
      await CustomDialogManager.showMessage(
        context: globalNavigatorKey.currentContext!,
        title: "Upload Failed",
        subtitle: "An error occurred: $e",
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
      );
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EDIT SINGLE ROW
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> editUsersData(List<dynamic> data) async {

    try {
      NewEmployeeModelHistory employeesModel = employeeController
          .employeesWithoutFilter!
          .firstWhere((element) => element.id == data[0].toString());

      final result = await activeDirectoryRepository.editValidUserData(
        editedData: data,
        departmentIds:
        departmentCubit.departmentIds,
        employee: employeesModel,
        currentUserEmail:
        AppControllers.settings.employee!.email!.last!,
      );

      result.fold(
            (failure) {
          throw Exception(failure.message);
        },
            (_) {},
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SAVE CHANGES DIALOGS
  // ══════════════════════════════════════════════════════════════════════════

}


