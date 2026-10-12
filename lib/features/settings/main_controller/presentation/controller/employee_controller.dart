/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_controller.dart
/// Purpose: Employee lookups, caching and the backup/restore entry points.
/// Author: MohamedFouad (original), Knowticed Plus team
/// Created at: Jan/8/2024
/// Updated: 11/8/2026 - Converted GetxController+StateMixin -> Cubit; all
///          Firestore access moved into the data layer; repository injected;
///          silent catches replaced with an EmployeeError state.
///
/// The class name and the `Get.put` / `Get.find` registration are kept on
/// purpose: 221 call sites across ~40 files resolve this through GetX. Only
/// the state mechanism changed — the same approach already used for
/// `NavBarCubit` and `AppDrawerCubit`.
///
/// PORTING NOTE (services_app):
/// A trimmed port of services_app's employee controller — only the members
/// services_app references are kept.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/models/employee_directory_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/repository/employees_repository.dart';
import 'package:knowticed_plus/features/settings/main_controller/domain/base_repository/employees_base_repository.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/presentation/controller/emergency_contact_controller.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/controller/employees_health_insurance_cubit.dart';

part './employee_state.dart';

class EmployeeController extends Cubit<EmployeeControllerState> {
  /// The repository is injected so it can be faked in tests; existing call
  /// sites keep using `EmployeeController()`.
  EmployeeController({EmployeesBaseRepository? employeesRepository})
      : employeesRepository = employeesRepository ?? EmployeesRepository(),
        super(const EmployeeInitial());

  final EmployeesBaseRepository employeesRepository;

  bool _initialised = false;

  /// Function Name: [init]
  ///
  /// Purpose: Replaces the GetX `onInit()` hook, which Cubit does not have.
  ///          Call once after registering the controller.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;
    // Registered here (as services_app does) so SettingsHealthInsuranceController's
    // Get.find<...>() calls resolve.
    // NOTE 9/10/2026: SettingsHealthInsuranceController no longer calls them —
    // the Health page reads Employees_Info only, not the duplicate `Insurance`
    // / `Emergency Contacts` collections these two cubits load. Nothing in
    // Settings resolves them any more; the registrations are left in place
    // (no reads happen until a method is called) for the se4/se5 data-layer
    // clean-up, which removes them together with those collections.
    if (!Get.isRegistered<EmployeesHealthInsuranceCubit>()) {
      Get.put(EmployeesHealthInsuranceCubit());
    }
    if (!Get.isRegistered<EmergencyContactController>()) {
      Get.put(EmergencyContactController());
    }
    await getAllEmployees();
  }

  /// Department name lookup, reused from active_directory.
  MainCoreDepartmentCubit get addDepartmentController =>
      Get.find<MainCoreDepartmentCubit>();

  /// Currently loaded employee (set by [getEmployee]).
  NewEmployeeModelHistory? employee;

  List<NewEmployeeModelHistory>? allEmployees;
  List<NewEmployeeModelHistory>? employeesWithoutFilter;
  List<EmployeeDirectoryModel>? allEmployeesDirectory;

  /// Replaces GetX `update()`. A fresh instance every time, so listeners
  /// always rebuild.
  void _publish() {
    if (!isClosed) emit(const EmployeeLoaded());
  }

  void _fail(String message) {
    if (!isClosed) emit(EmployeeError(message));
  }

  /// Function Name: [getAllEmployees]
  ///
  /// Purpose: Load every employee and cache into [allEmployees] /
  ///          [employeesWithoutFilter], then sync MainCoreEmployeeController.
  ///
  /// Returns: [Future<List<NewEmployeeModelHistory>?>] the cached list.
  Future<List<NewEmployeeModelHistory>?> getAllEmployees() async {
    if (!isClosed) emit(const EmployeeLoading());

    final Either<Failure, dynamic> result =
        await employeesRepository.getAllEmployees();

    if (result.isLeft()) {
      _fail(result.fold(
          (Failure l) => l.errMessage, (_) => 'Could not load employees.'));
      return allEmployees;
    }

    final dynamic rawData = result.getOrElse(() => <NewEmployeeModelHistory>[]);
    employeesWithoutFilter = (rawData is List)
        ? rawData.cast<NewEmployeeModelHistory>()
        : <NewEmployeeModelHistory>[];
    allEmployees = employeesWithoutFilter;

    try {
      await Get.find<MainCoreEmployeeController>().getAllNewEmployees();
      final String? userEmail = employee?.email.lastOrNull;
      if (userEmail != null && userEmail.isNotEmpty) {
        await Get.find<MainCoreEmployeeController>().getNewEmployee(userEmail);
      }
    } catch (e) {
      // The employee list itself loaded; only the cross-controller sync
      // failed. Previously an empty catch — now at least reported.
      _fail('Employee list loaded, but syncing the current user failed: $e');
      return allEmployees;
    }

    _publish();
    return allEmployees;
  }

  /// Function Name: [createEmployee]
  ///
  /// Purpose: Create or merge-update an employee document.
  ///
  /// Parameters:
  /// - [employeeModelNew]: Employee data to save.
  /// - [email]: Retained for call-site compatibility; the document id comes
  ///   from the model.
  Future<void> createEmployee(
      NewEmployeeModelHistory employeeModelNew, String email) async {
    try {
      await employeesRepository.saveEmployee(employeeModelNew);
      employee = employeeModelNew;
      _publish();
    } catch (e) {
      _fail('Could not save the employee: $e');
    }
  }

  /// Function Name: [getEmployee]
  ///
  /// Purpose: Look an employee up by email.
  ///
  /// Returns: [Future<NewEmployeeModelHistory?>] — `null` when not found *or*
  ///          when the read failed; an [EmployeeError] is emitted in the
  ///          latter case so the two are distinguishable.
  Future<NewEmployeeModelHistory?> getEmployee(String email) async {
    try {
      employee = await employeesRepository.getEmployeeByEmail(email);
      _publish();
      return employee;
    } catch (e) {
      _fail('Could not load the employee record: $e');
      return null;
    }
  }

  /// Function Name: [getEmployeeDirectory]
  ///
  /// Purpose: Read the directory entry for an email.
  Future<EmployeeDirectoryModel?> getEmployeeDirectory(String email) async {
    try {
      return await employeesRepository.getEmployeeDirectory(email);
    } catch (e) {
      _fail('Could not load the employee directory: $e');
      return null;
    }
  }

  /// Function Name: [getLocaleEmployee]
  ///
  /// Purpose: Cached employee by email.
  ///
  /// Returns a non-null model to stay source-compatible: call sites chain
  /// straight onto the result (`getLocaleEmployee(x).mobilePhone!`), so a
  /// nullable return would not compile at six of them.
  ///
  /// The previous body was `employeesWithoutFilter!.firstWhere(...)` with no
  /// `orElse`, which threw before the cache had loaded and on any unknown
  /// email. An empty model is returned instead — prefer
  /// [getLocaleEmployeeOrNull] in new code, which lets you handle "not found".
  NewEmployeeModelHistory getLocaleEmployee(String email) =>
      _cachedByEmail(email) ?? NewEmployeeModelHistory();

  /// Function Name: [getLocaleEmployeeOrNull]
  ///
  /// Purpose: Cached employee by email, or `null` when unknown.
  NewEmployeeModelHistory? getLocaleEmployeeOrNull(String email) =>
      _cachedByEmail(email);

  NewEmployeeModelHistory? _cachedByEmail(String email) {
    final List<NewEmployeeModelHistory> list =
        employeesWithoutFilter ?? const <NewEmployeeModelHistory>[];
    for (final NewEmployeeModelHistory e in list) {
      if (e.email.lastOrNull == email) return e;
    }
    return null;
  }

  /// Function Name: [getEmployeeName]
  ///
  /// Purpose: Full name for the active locale.
  ///
  /// Parameters:
  /// - [email]: Employee email.
  /// - [isEnglish]: Active locale. Pass `context.isEnglish`; defaults to
  ///   English so existing call sites keep working.
  String getEmployeeName(String email, {bool isEnglish = true}) =>
      getEmployeeNameEnglishArabic(email, isEnglish);

  /// Function Name: [getEmployeeNameEnglishArabic]
  ///
  /// Purpose: Full name in the requested language.
  String getEmployeeNameEnglishArabic(String email, bool isEnglish) {
    final NewEmployeeModelHistory? e = _cachedByEmail(email);
    if (e == null) return '';
    final String first =
        (isEnglish ? e.firstName.lastOrNull : e.firstNameInArabic.lastOrNull) ??
            '';
    final String last =
        (isEnglish ? e.lastName.lastOrNull : e.lastNameInArabic.lastOrNull) ??
            '';
    return '$first $last'.trim();
  }

  /// Function Name: [getEmployeeEmailFromId]
  String getEmployeeEmailFromId(String employeeId) {
    final List<NewEmployeeModelHistory> list =
        employeesWithoutFilter ?? const <NewEmployeeModelHistory>[];
    for (final NewEmployeeModelHistory e in list) {
      if (e.id == employeeId) return e.email.lastOrNull ?? '';
    }
    return '';
  }

  /// Function Name: [getEmployeeJobTitle]
  ///
  /// Parameters:
  /// - [isEnglish]: Active locale; defaults to English for compatibility.
  String getEmployeeJobTitle(String email, {bool isEnglish = true}) {
    final NewEmployeeModelHistory? e = _cachedByEmail(email);
    if (e == null) return '';
    return (isEnglish ? e.title.lastOrNull : e.titleInArabic.lastOrNull) ?? '';
  }

  /// Function Name: [getEmployeePhoto]
  ///
  /// Purpose: Photo URL, or a gendered default avatar.
  String getEmployeePhoto(String email) {
    final NewEmployeeModelHistory? e = _cachedByEmail(email);
    final String? photo = e?.photo.lastOrNull;
    if (photo != null && photo.isNotEmpty) return photo;

    final bool isFemale = e?.gender.lastOrNull?.toLowerCase() == 'female';
    return isFemale
        ? "assets/icons_assets/main_icons_assets/female_avatar.png"
        : "assets/icons_assets/main_icons_assets/male_avatar.png";
  }

  /// Function Name: [getDepartment]
  ///
  /// Parameters:
  /// - [isEnglish]: Active locale; defaults to English for compatibility.
  String getDepartment(String department, {bool isEnglish = true}) {
    if (isEnglish) {
      return (addDepartmentController.getEnglishDepartmentNameFromDepartmentId(
                  departmentId: department) ??
              "")
          .toLowerCase();
    }
    return addDepartmentController.getArabicDepartmentNameFromDepartmentId(
            departmentId: department) ??
        "";
  }

  /// Function Name: [backupCollections]
  ///
  /// Purpose: Roll the two-level employee backup. Delegates to the repository.
  Future<void> backupCollections() async {
    try {
      await employeesRepository.backupCollections();
      _publish();
    } catch (e) {
      _fail('Backup failed: $e');
      rethrow;
    }
  }

  /// Function Name: [getBackupEmployees]
  ///
  /// Purpose: Read one backup collection so the caller can show it before
  ///          restoring. Non-destructive.
  ///
  /// Parameters:
  /// - [backupVersion]: `'second'` for backup two, anything else for backup
  ///   one — the same string [restoreFromBackup] takes.
  ///
  /// Returns: [Future<List<NewEmployeeModelHistory>>] — empty on failure, with
  ///          an [EmployeeError] emitted so the two are distinguishable.
  Future<List<NewEmployeeModelHistory>> getBackupEmployees(
    String backupVersion,
  ) async {
    try {
      return await employeesRepository.getBackupEmployees(backupVersion);
    } catch (e) {
      _fail('Could not load the "$backupVersion" backup: $e');
      return const <NewEmployeeModelHistory>[];
    }
  }

  /// Function Name: [restoreFromBackup]
  ///
  /// Purpose: Replace the live employee collection with a backup.
  ///
  /// **Destructive.** [confirmDestructiveRestore] must be `true`; the guard
  /// lives in the data source. Callers should only pass `true` after an
  /// explicit user confirmation.
  Future<void> restoreFromBackup(
    String backupVersion, {
    bool confirmDestructiveRestore = false,
  }) async {
    try {
      await employeesRepository.restoreFromBackup(
        backupVersion,
        confirmDestructiveRestore: confirmDestructiveRestore,
      );
      _publish();
    } catch (e) {
      _fail('Restore failed: $e');
      rethrow;
    }
  }
}
