/// Module: roles / r5_system_logs / presentation / controller
///
/// ************************* FILE INFO ******************** ///
/// FILE NAME: system_logs_controller.dart
/// PURPOSE: handle all the operations related to the system logs.
/// Author: Amr Mesbah
/// Created At: 2/2/2025
/// Updated: 9/10/2026 - Time Tracker phase 6: a MODULE filter ([moduleValue],
///          the enum `name` stored on every log; [selectModuleFilter] from the
///          tablet app bar's Module menu) so the tablet System Logs can show
///          one module's activity (e.g. Time Tracker) — the tablet screen had
///          no filter at all (`FilterDialog` is not used anywhere); the phone
///          export page already filtered by module.
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';
// ADDED 9/9/2026: `systemLogsAction` names the type of the top-level
// `employee` getter so it can null-check it before passing it on.
// `settings_screen.dart` exposes the getter but imports are not
// transitive, so the model has to be imported here too.
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/geolocator/geolocator_repository.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/repository/system_logs_repository.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/domain/enums/system_logs_items.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

part './system_logs_state.dart';

/// Converted from GetxController to Cubit. Dependency lookup still goes
/// through GetX (`Get.put` in main.dart / `Get.find` at call sites) — only the
/// state-notification mechanism changed, so the widgets bind with
/// `BlocBuilder(bloc: AppControllers.systemLogs)`.
class SystemLogsController extends Cubit<SystemLogsState> {
  SystemLogsController() : super(SystemLogsInitial());

  /// Function Name: [emitSafely]
  ///
  /// Purpose: Publish [state] only while this cubit is still open.
  ///
  /// `getSystemLogs()` and `systemLogsAction()` await the repository before
  /// emitting; closing the tab mid-fetch used to throw
  /// "Cannot emit after close" (§16).
  ///
  /// Parameters:
  /// - [state]: The state to publish.
  ///
  /// Returns: [void]
  void emitSafely(SystemLogsState state) {
    if (isClosed) return;
    emit(state);
  }

  /// Language used when rendering exported CSV rows.
  ///
  /// The export runs outside any widget, so the page sets this from
  /// `Localizations.localeOf(context)` before calling [exportSystemLogs] —
  /// replacing the `Get.locale` read that used to sit in the domain enum.
  bool exportInArabic = false;

  SystemLogsRepository systemLogsRepository = SystemLogsRepository();
  List<SystemLogsModel> systemLogsData = [];
  List<SystemLogsModel> finalSystemLogsList = [];
  // Tracks whether the initial fetch has completed (success, failure, or empty)
  // so the UI can stop showing the loading spinner and render an empty state.
  bool logsLoaded = false;
  List<String> systemLogsUserNamesFilter = [];
  List<String> cities = [];
  List<String> countries = [];
  List<String> actions = [];
  List<String> actionsEnglish = [];
  List<String> accessNames = [];
  String? status;
  String? actionValue;
  String? countryValue;
  String? cityValue;
  String? roleValue;

  /// ADDED 9/10/2026 — the module filter: a `Modules.name` (exact match on
  /// `log.module?.name`), null = every module.
  String? moduleValue;
  List<DateTime?> rangeDatePickerValueWithDefaultValue = [];
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? endTime;
  TimeOfDay? startTime;
  bool isFilter = false;

  /// The active sort key, or `null` when the list is in its natural order.
  ///
  /// One of `SystemLogsConstants.sortList` — the stable English keys
  /// [sortLogs] switches on, never a display label.
  ///
  /// CHANGED 30/8/2026: was `String sortValue = "Date"`. Nothing ever sorted on
  /// that default — [sortLogs] only ran from the dropdown's `onChanged` — so it
  /// was a label pre-filled into a control, and it made "no sort" unreachable.
  /// Nullable now, so the Sort button can show an inactive state and re-picking
  /// the active option can clear the sort, the same as
  /// `UserAccessCubit.selectedSortOption`. Read only by the Sort control in
  /// system_logs_appbar.dart.
  String? sortValue;

  void updateCountryValue(String? v) {
    countryValue = v;
    emitSafely(SystemLogsUpdated());
  }

  void updateCityValue(String? v) {
    cityValue = v;
    emitSafely(SystemLogsUpdated());
  }

  void updateActionValue(String? v) {
    actionValue = v;
    emitSafely(SystemLogsUpdated());
  }

  void updateRoleValue(String? v) {
    roleValue = v;
    emitSafely(SystemLogsUpdated());
  }

  /// Function Name: [selectModuleFilter]
  ///
  /// Purpose: The tablet Module menu (ADDED 9/10/2026): show only [name]'s
  /// logs, applied at once with the search; picking the active module again,
  /// or null ("All"), clears it.
  ///
  /// Parameters:
  ///   [String?] name: a `Modules.name`.
  ///
  /// Return type: [void]
  void selectModuleFilter(String? name) {
    moduleValue = (name == null || name == moduleValue) ? null : name;
    isFilter = isThereFilter();
    searchLogs();
    if (isFilter) _applyFilter();
    emitSafely(SystemLogsUpdated());
  }

  /// Function Name: [moduleNamesInLogs]
  ///
  /// Purpose: The `Modules.name`s that appear in the loaded logs, in enum
  /// order — the Module filter's options (ADDED 9/10/2026).
  ///
  /// Return type: [List<String>]
  List<String> get moduleNamesInLogs {
    final Set<String> seen = <String>{
      for (final SystemLogsModel log in systemLogsData)
        if (log.module != null) log.module!.name,
    };
    return <String>[
      for (final Modules m in Modules.values)
        if (seen.contains(m.name)) m.name,
    ];
  }

  /// Function Name: [matchesModule]
  ///
  /// Purpose: [log] passes a module filter of [moduleName] (null = any).
  /// Static and pure so it is unit-tested (ADDED 9/10/2026).
  ///
  /// Return type: [bool]
  static bool matchesModule(SystemLogsModel log, String? moduleName) =>
      moduleName == null || log.module?.name == moduleName;

  Position? currentPosition;

  /// Method Name: [getSystemLogs]
  ///
  /// Description: this method will get the system logs from the repository.
  ///
  Future<void> getSystemLogs() async {
    Either<Failure, dynamic> result =
        await systemLogsRepository.getSystemLogs();
    if (result.isLeft()) {
      // Fetch failed: stop the spinner and let the UI show an empty state
      // instead of hanging on the loading indicator forever.
      logsLoaded = true;
      emitSafely(SystemLogsUpdated());
      return;
    }
    systemLogsData = result.getOrElse(() => []);
    systemLogsData.sort((a, b) {
      final aTime = a.timestamp;
      final bTime = b.timestamp;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });
    finalSystemLogsList = [];
    for (var element in systemLogsData) {
      finalSystemLogsList.add(element);
    }
    logsLoaded = true;
    emitSafely(SystemLogsUpdated());
  }

  void initFiltersLists() {
    _getLocationList();
    _getRolesList();
    _getActionsList();
  }

  void _getLocationList() {
    for (var element in AppControllers.employeeDirectory.allEmployees!) {
      if (element.city?.lastOrNull != null) {
        if (!cities.contains(FormatHelper.capitalize(element.city!.last!))) {
          cities.add(FormatHelper.capitalize(element.city!.last!));
        }
      }
      if (element.country?.lastOrNull != null) {
        if (!countries.contains(FormatHelper.capitalize(element.country!.last!))) {
          countries.add(FormatHelper.capitalize(element.country!.last!));
        }
      }
    }
  }

  /// Method Name: [selectSortOption]
  ///
  /// Description: Apply the sort key the user just picked in the Sort menu.
  ///
  /// Re-picking the key that is already active CLEARS the sort: [sortValue]
  /// goes back to `null`, the list is rebuilt in its natural order, and the
  /// Sort button drops out of its active fill.
  ///
  /// ADDED 30/8/2026, mirroring `UserAccessCubit.selectSortOption` so both
  /// screens' Sort controls behave identically. The menu is a list of options
  /// with the active one filled, not a direction control, so a second tap on a
  /// filled row has to mean "turn this off" — and without it there is no way
  /// back to no sort at all, since the menu has no "none" row.
  ///
  /// Clearing goes through [searchAndFilterLogs] rather than an "unsort":
  /// [sortLogs] reorders `finalSystemLogsList` in place, and [searchLogs]
  /// rebuilds that list from `systemLogsData` in source order, so re-running
  /// search + filter IS the unsorted list.
  ///
  /// Parameters:
  ///         [String?] sortKey: one of `SystemLogsConstants.sortList`; `null`
  ///         is ignored, so a dismissed menu changes nothing.
  ///
  /// Return Value: [void]
  void selectSortOption(String? sortKey) {
    if (sortKey == null) return;

    if (sortKey == sortValue) {
      sortValue = null;
      searchAndFilterLogs();
      emitSafely(SystemLogsUpdated());
      return;
    }

    sortValue = sortKey;
    sortLogs(sortKey);
  }

  /// Method Name: [sortLogs]
  ///
  /// Description: this method will sort the system logs based on the selected criteria.
  ///
  /// This is the apply path and does not touch [sortValue]. User selections go
  /// through [selectSortOption], which owns the select/clear decision.
  ///
  /// Parameters:
  ///         [String] criteria: the criteria that the system logs will be sorted based on.
  void sortLogs(String criteria) {
    emitSafely(SystemLogsUpdated());
    switch (criteria) {
      case 'First Name':
        finalSystemLogsList
            .sort((a, b) => a.firstName?.compareTo(b.firstName ?? '') ?? 0);
        break;
      case 'Last Name':
        finalSystemLogsList
            .sort((a, b) => a.lastName?.compareTo(b.lastName ?? '') ?? 0);
        break;
      case 'Date':
        // Was `b.timestamp?.compareTo(a.timestamp ?? Timestamp.now())`, which
        // forced `cloud_firestore` into the cubit for a sort fallback (§3).
        finalSystemLogsList.sort((a, b) =>
            (b.loggedAt ?? DateTime.now()).compareTo(a.loggedAt ?? DateTime.now()));

        break;
      case 'Country':
        finalSystemLogsList
            .sort((a, b) => a.country?.compareTo(b.country ?? '') ?? 0);
        break;
      case 'City':
        finalSystemLogsList
            .sort((a, b) => a.city?.compareTo(b.city ?? '') ?? 0);
        break;
      default:
        // Was `b.timestamp?.compareTo(a.timestamp ?? Timestamp.now())`, which
        // forced `cloud_firestore` into the cubit for a sort fallback (§3).
        finalSystemLogsList.sort((a, b) =>
            (b.loggedAt ?? DateTime.now()).compareTo(a.loggedAt ?? DateTime.now()));
        break;
    }

    emitSafely(SystemLogsUpdated());
  }

  /// Method Name: [filterLogs]
  ///
  /// Description: this method will filter the system logs based on the selected filters.
  void filterLogs() {
    if (fromDate == null &&
        toDate == null &&
        startTime == null &&
        endTime == null &&
        roleValue == null &&
        countryValue == null &&
        cityValue == null &&
        actionValue == null &&
        moduleValue == null) {
      isFilter = false;
      // Was `CustomDialogManager.showMessage(context: Get.context!, ...)`.
      // A cubit must not open dialogs (§16), and `Get.context!` was a null-bang
      // on a global. The page listens for this state and shows the warning.
      emitSafely(SystemLogsNoFilterSelected());
    } else {
      _applyFilter();
    }
    emitSafely(SystemLogsUpdated());
  }

  /// Method Name: [_applyFilter]
  ///
  /// Description: this method will apply the selected filters on the system logs.
  ///
  /// Return Value: [void]
  void _applyFilter() {
    {
      isFilter = true;
      emitSafely(SystemLogsUpdated());
      finalSystemLogsList = finalSystemLogsList.where((log) {
        bool isValid = true;

        isValid &= _isValidSingleFilter(roleValue, log.role);
        isValid &= _isValidSingleFilter(countryValue, log.country);
        isValid &= _isValidSingleFilter(cityValue, log.city);
        isValid &= _isValidSingleFilter(actionValue, log.action);
        isValid &= matchesModule(log, moduleValue);
        isValid &= isValidDateRange(log);
        isValid &= _isValidStartTimeFilter(log);
        isValid &= _isValidEndTimeFilter(log);

        return isValid;
      }).toList();
    }
  }

  /// Method Name: [isValidDateRange]
  ///
  /// Description: this method will check if the log date is in the selected date range or not.
  ///
  /// Parameters:
  ///       [SystemLogsModel] log: the log that will be checked.
  ///
  /// Return Value: [bool] true if the log date is in the selected date range, false otherwise.
  bool isValidDateRange(SystemLogsModel log) {
    bool isValid = true;
    if (fromDate != null) {
      DateTime logDate = DateTime(log.timestamp!.toDate().year,
          log.timestamp!.toDate().month, log.timestamp!.toDate().day);
      isValid &=
          logDate.isAtSameMomentAs(fromDate!) || logDate.isAfter(fromDate!);
    }
    if (toDate != null) {
      DateTime logDate = DateTime(log.timestamp!.toDate().year,
          log.timestamp!.toDate().month, log.timestamp!.toDate().day);
      isValid &=
          (logDate.isAtSameMomentAs(toDate!) || logDate.isBefore(toDate!));
    }

    return isValid;
  }

  /// Method Name: [_isValidEndTimeFilter]
  ///
  /// Description: this method will check if the log time is before the end time or not.
  ///
  /// Parameters:
  ///       [SystemLogsModel] log: the log that will be checked.
  ///
  /// Return Value: [bool] true if the log time is before the end time, false otherwise.
  bool _isValidEndTimeFilter(SystemLogsModel log) {
    bool isValid = true;
    DateTime? timeToDateTime = endTime == null
        ? null
        : DateTime(0, 1, 1, endTime!.hour, endTime!.minute);

    if (timeToDateTime != null) {
      DateTime logTime = DateTime(0, 1, 1, log.timestamp!.toDate().hour,
          log.timestamp!.toDate().minute);
      isValid &= (logTime.isBefore(timeToDateTime) ||
          logTime.isAtSameMomentAs(timeToDateTime));
    }
    return isValid;
  }

  /// Method Name: [_isValidStartTimeFilter]
  ///
  /// Description: this method will check if the log time is after the start time or not.
  ///
  /// Parameters:
  ///        [SystemLogsModel] log: the log that will be checked.
  ///
  /// Return Value: [bool] true if the log time is after the start time, false otherwise.
  bool _isValidStartTimeFilter(SystemLogsModel log) {
    bool isValid = true;
    DateTime? timeFromDateTime = startTime == null
        ? null
        : DateTime(0, 1, 1, startTime!.hour, startTime!.minute);
    if (timeFromDateTime != null) {
      DateTime logTime = DateTime(0, 1, 1, log.timestamp!.toDate().hour,
          log.timestamp!.toDate().minute);
      isValid &= logTime.isAfter(timeFromDateTime) ||
          logTime.isAtSameMomentAs(timeFromDateTime);
    }
    return isValid;
  }

  bool _isValidSingleFilter(String? filter, String? value) {
    return filter == null || value!.toLowerCase() == filter.toLowerCase();
  }

  /// Method Name: [resetFilter]
  ///
  /// Description: this method will reset the filters.
  void resetFilter() {
    isFilter = false;
    status = null;
    countryValue = null;
    cityValue = null;
    actionValue = null;
    roleValue = null;
    moduleValue = null;
    startTime = null;
    endTime = null;
    selectedDate = null;
    fromDate = null;
    toDate = null;
    rangeDatePickerValueWithDefaultValue = [];
    startDate = TextEditingController();
    endDate = TextEditingController();

    finalSystemLogsList = [];
    systemLogsData.forEach((element) {
      finalSystemLogsList.add(element);
    });
    searchAndFilterLogs();
    emitSafely(SystemLogsUpdated());
  }

  /// Method Name: [searchLogs]
  ///
  /// Description: this method will search the system logs.
  void searchLogs() {
    String query = searchController.text;
    finalSystemLogsList = [];
    final lowerCaseQuery = query.toLowerCase();
    finalSystemLogsList = systemLogsData.where((log) {
      return !exportInArabic
          ? "${log.firstName} ${log.middleName} ${log.lastName}"
              .toLowerCase()
              .contains(lowerCaseQuery)
          : "${log.firstNameInArabic} ${log.middleNameInArabic} ${log.lastNameInArabic}"
              .contains(lowerCaseQuery);
    }).toList();
    emitSafely(SystemLogsUpdated());
  }

  // UsersAccessController removed (module not available in knowticed)

  /// Method Name: [systemLogsAction]
  ///
  /// Description: this method will add the activity log to the system logs.
  ///
  /// FIRE-AND-FORGET, SO NOTHING IN HERE MAY THROW (9/9/2026). Every call site
  /// invokes this without awaiting it — `role_screen.indexContainer` calls it
  /// from inside a `build`, for instance — so there is no future for anyone to
  /// catch. An exception raised here does not fail the caller, it escapes to
  /// `runZonedGuarded` as an uncaught async error and takes the log entry with
  /// it.
  ///
  /// That is exactly what a missing `NSLocationWhenInUseUsageDescription` did:
  /// `GelocatorRepository.getCurrentLocation` threw
  /// `PermissionDefinitionsNotFoundException`, this method never reached
  /// `addActivityLog`, and the activity was lost with only a console trace to
  /// show for it. The repository now returns null instead of throwing, and the
  /// two remaining hazards are handled below.
  ///
  /// Parameters:
  ///        [String] action: the activity that will be added to the system logs.
  ///        [Modules] module: the module the activity happened in.
  void systemLogsAction(String action, {Modules module = Modules.more}) async {
    // `employee` is a top-level nullable getter (settings_screen.dart) that is
    // only populated once the signed-in profile has loaded. `employee!` threw
    // for any action logged before that — the Roles screen logs 'open Logs' the
    // moment its tab is built. There is nothing useful to write without an
    // actor, so the log is skipped rather than crashed.
    final NewEmployeeModelHistory? currentEmployee = employee;
    if (currentEmployee == null) {
      debugPrint(
          'systemLogsAction("$action") skipped: no signed-in employee loaded yet');
      return;
    }

    try {
      // Best-effort: null when the device will not give a position, which
      // `addActivityLog` already stores as an empty lat/long.
      currentPosition = await GelocatorRepository.getCurrentLocation();

      await systemLogsRepository.addActivityLog(
          module: module,
          activity: action,
          currentEmployee: currentEmployee,
          currentPosition: currentPosition);
    } catch (e, stackTrace) {
      // A dropped activity log must never surface to the user or bring down
      // the zone — it is telemetry, not the task they asked for.
      debugPrint('systemLogsAction("$action") failed: $e\n$stackTrace');
    }
  }

  /// Method Name: [searchAndFilterLogs]
  ///
  /// Description: this method will search and then filter the system logs.
  ///
  /// Return Value: [void]
  void searchAndFilterLogs() {
    searchLogs();
    if (isFilter) filterLogs();
  }

  /// Method Name: [_getRolesList]
  ///
  /// Description: this method will get all the roles_module from the system logs.
  void _getRolesList() {
    accessNames = roleCubit.roles.map((e) => e.currentRoleName).toList();
  }

  /// Method Name: [_getActionsList]
  ///
  /// Description: this method will get all the actions from the system logs.
  void _getActionsList() {
    for (var element in systemLogsData) {
      if (!actions.contains(FormatHelper.capitalize(element.action!))) {
        actions.add(FormatHelper.capitalize(element.action!));
      }
    }
  }

  /// Method Name: [exportSystemLogs]
  ///
  /// Description: this method will export the system logs to a CSV file.
  ///
  /// Parameters:
  ///        [String] fileName: the name of the file that the system logs will be saved to.
  /// Returns: [Future<void>]; progress and outcome are published as
  /// [SystemLogsExporting] / [SystemLogsExportFinished].
  ///
  /// The loading overlay, the `Navigator.pop(Get.context!)` and both result
  /// dialogs used to run from inside this method (§16 — a cubit emits, the
  /// widget presents; and `Get.context!` is a null-bang on a global context).
  Future<void> exportSystemLogs(String fileName) async {
    emitSafely(SystemLogsExporting());

    // 21/9/2026: the row building moved INSIDE the try. It used to run before
    // it, so anything thrown while formatting a log row escaped without
    // emitting SystemLogsExportFinished — the loading overlay then never came
    // down and no file was written. Every step is logged in debug builds so
    // "nothing was downloaded" can be traced to the step that failed.
    try {
      final List<List<dynamic>> rows = [];
      _fillHeaders(rows);
      _fillData(rows);
      debugPrint('[logs-export] ${rows.length - 1} row(s) -> "$fileName"');

      final saved = await CSVHelper()
          .exportRowsForUser(fileName: fileName, rows: rows);
      final String? error = saved.fold((l) => l, (_) => null);
      if (error != null) throw Exception(error);

      debugPrint('[logs-export] saved: ${saved.getOrElse(() => '')}');
      emitSafely(SystemLogsExportFinished());
    } catch (e, stackTrace) {
      debugPrint('exportSystemLogs failed: $e\n$stackTrace');
      emitSafely(SystemLogsExportFinished(error: e.toString()));
    }
  }

  /// Method Name: [_fillHeaders]
  ///
  /// Description: this method will fill the headers of the CSV file.
  ///
  /// Parameters:
  ///       [List<List>] rows: the rows of the CSV file.
  void _fillHeaders(List<List> rows) {
    rows.add([]);
    for (SystemLogsItems item in SystemLogsItems.values) {
      rows[0].add(item.name);
    }
  }

  /// Method Name: [_fillData]
  ///
  /// Description: this method will fill the data of the CSV file.
  ///
  /// Parameters:
  ///      [List<List>] rows: the rows of the CSV file.
  void _fillData(List<List> rows) {
    for (var log in finalSystemLogsList) {
      List<dynamic> row = [];
      for (SystemLogsItems item in SystemLogsItems.values) {
        row.add(item.itemValue(log, isArabic: exportInArabic));
      }
      rows.add(row);
    }
  }

  bool isThereFilter() {
    bool isThereFilter = false;
    if (fromDate != null ||
        toDate != null ||
        startTime != null ||
        endTime != null ||
        roleValue != null ||
        countryValue != null ||
        cityValue != null ||
        actionValue != null ||
        moduleValue != null) {
      isThereFilter = true;
    }
    return isThereFilter;
  }
}
