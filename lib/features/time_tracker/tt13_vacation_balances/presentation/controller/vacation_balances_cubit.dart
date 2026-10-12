/// Module: time_tracker / tt13_vacation_balances / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balances_cubit.dart
/// Purpose: Declares `VacationBalancesCubit` — streams the stored vacation
///          balances, loads the company's employees, holds the Vacation
///          Balances tab's search / department filter / card-table toggle,
///          and runs Edit (set Total Days) and Import.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// FINAL SPEC §1 section 10 (`Vacation_Balance_Permissions`): the tab needs
/// `View_Vacation_Balances`; Edit `Edit_Vacation_Balance`; Import
/// `Import_Vacation_Balances` (refused in the cubit too, not only hidden).
/// The balance always lives in Time Tracker (decision 11), with or without
/// HR. Every save keeps the stored used days (a deduction made meanwhile is
/// never lost) and appends one history row; each saved row is written to
/// System Logs as "edit vacation balance". Async work in [init]; stream
/// cancelled in [close]; emit-after-close guarded (playbook §3).
/// Updated: 9/10/2026 - code review: no stream opened after [close] ran
/// during [init]'s awaits.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): balances are one
/// document per employee per YEAR. The tab lists the SELECTED year
/// ([setYear], current year first; `VacationBalanceYears.selectable`) —
/// only that year's documents are streamed. Edit and Import write the
/// selected year through `setTotalDays` (the used days stored at that moment
/// are kept inside the same transaction). No roll-over.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/vacation_balance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_state.dart';

class VacationBalancesCubit extends Cubit<VacationBalancesState> {
  VacationBalancesCubit({
    required VacationBalanceBaseRepository balances,
    required EmployeeDirectoryBaseRepository directory,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
    DateTime Function() clock = DateTime.now,
  })  : _balances = balances,
        _directory = directory,
        _access = access,
        _log = log,
        _clock = clock,
        super(const VacationBalancesState());

  final VacationBalanceBaseRepository _balances;
  final EmployeeDirectoryBaseRepository _directory;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;
  final DateTime Function() _clock;
  StreamSubscription<List<VacationBalance>>? _sub;

  @override
  void emit(VacationBalancesState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Load the employees / departments, then stream the balances.
  ///
  /// Return type: [Future<void>]
  Future<void> init({bool isArabic = false}) async {
    if (!_access.canViewVacationBalances) return;
    final int thisYear = _clock().year;
    emit(state.copyWith(
      status: VacationBalancesStatus.loading,
      year: state.year == 0 ? thisYear : state.year,
      currentYear: thisYear,
      isArabic: isArabic,
      errorMessage: '',
    ));
    try {
      final List<TimeTrackerEmployee> people = await _directory.fetchEmployees(isArabic: isArabic);
      final Map<String, String> departments = await _directory.fetchDepartments(isArabic: isArabic);
      emit(state.copyWith(employees: people, departments: departments));
    } catch (error) {
      emit(state.copyWith(status: VacationBalancesStatus.failure, errorMessage: error.toString()));
      return;
    }
    await _watchYear(state.year);
  }

  /// Function Name: [setYear]
  ///
  /// Purpose: ADDED 9/10/2026 (data model) — show the balances of [year]
  /// (one document per employee per year); Edit / Import then write it.
  ///
  /// Return type: [Future<void>]
  Future<void> setYear(int year) async {
    if (year == state.year && state.status == VacationBalancesStatus.loaded) return;
    emit(state.copyWith(year: year, status: VacationBalancesStatus.loading, balances: const <VacationBalance>[]));
    await _watchYear(year);
  }

  Future<void> _watchYear(int year) async {
    await _sub?.cancel();
    // 9/10/2026 (code review): closed during the awaits → open nothing.
    if (isClosed) return;
    _sub = _balances.watchBalancesOfYear(year: year).listen(
      (List<VacationBalance> list) {
        // A late event of a year no longer selected is dropped.
        if (year != state.year) return;
        emit(state.copyWith(status: VacationBalancesStatus.loaded, balances: list));
      },
      onError: (Object error) => emit(state.copyWith(
        status: VacationBalancesStatus.failure,
        errorMessage: error.toString(),
      )),
    );
  }

  void search(String query) => emit(state.copyWith(query: query));
  void setDepartment(String departmentId) => emit(state.copyWith(departmentId: departmentId));
  void setGrid(bool isGrid) => emit(state.copyWith(isGrid: isGrid));

  /// Function Name: [editTotal]
  ///
  /// Purpose: Set [email]'s Total Days for the SELECTED year
  /// (`Edit_Vacation_Balance`). The stored used days are kept.
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> editTotal(String email, double totalDays) => _run(() async {
        if (!_access.canEditVacationBalance) throw const TimeTrackerPermissionDenied();
        await _save(email, totalDays);
      });

  /// Function Name: [readImport]
  ///
  /// Purpose: Run [pick] (file picker + reader, from the data layer) and
  /// plan its grid. Never throws: an unreadable file is a result.
  ///
  /// Return type: [Future<VacationImportRead>]
  Future<VacationImportRead> readImport(Future<List<List<String>>?> Function() pick) async {
    try {
      final List<List<String>>? grid = await pick();
      if (grid == null) return const VacationImportRead.cancelled();
      return VacationImportRead.read(planImport(grid));
    } catch (_) {
      return const VacationImportRead.unreadable();
    }
  }

  /// Function Name: [planImport]
  ///
  /// Purpose: The preview of importing [grid] into the SELECTED year.
  ///
  /// Return type: [VacationImportPlan]
  VacationImportPlan planImport(List<List<String>> grid) => VacationBalanceImportRules.plan(
        grid: grid,
        employees: state.employees,
        stored: state.balances,
        year: state.year,
      );

  /// Function Name: [applyImport]
  ///
  /// Purpose: Write every create / update row of [plan]
  /// (`Import_Vacation_Balances`). Never deletes. Stops at the first
  /// failure; rows already written stay.
  ///
  /// Return type: [Future<bool>] — every row saved.
  Future<bool> applyImport(VacationImportPlan plan) => _run(() async {
        if (!_access.canImportVacationBalances) throw const TimeTrackerPermissionDenied();
        for (final VacationImportRow row in plan.writable) {
          await _save(row.email, row.balance!.totalDays, year: plan.year);
        }
      });

  /// One `{email}_{year}` row; the used days stored at that moment are kept
  /// (inside the repository's transaction — 9/10/2026).
  Future<void> _save(String email, double totalDays, {int? year}) async {
    await _balances.setTotalDays(employeeEmail: email, year: year ?? state.year, totalDays: totalDays);
    _log.log(TimeTrackerLogService.actionEditVacationBalance);
  }

  void acknowledgeFailure() => emit(state.copyWith(failure: TimeTrackerActionFailure.none));

  Future<bool> _run(Future<void> Function() action) async {
    emit(state.copyWith(failure: TimeTrackerActionFailure.none));
    try {
      await action();
      return true;
    } catch (error) {
      emit(state.copyWith(failure: timeTrackerFailureOf(error)));
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
