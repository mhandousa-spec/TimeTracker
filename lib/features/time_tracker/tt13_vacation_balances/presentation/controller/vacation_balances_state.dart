/// Module: time_tracker / tt13_vacation_balances / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balances_state.dart
/// Purpose: Declares `VacationBalancesState` (+ `VacationBalancesStatus`,
///          `VacationImportRead`) — the company's employees and stored
///          balances, the tab's search / department filter / card-table
///          toggle, and the derived rows.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// One immutable state + `copyWith` + status enum + derived getters
/// (playbook §3). Rows come from the pure `VacationBalanceList`.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): [year] is the SELECTED
/// year (balances are one document per employee per year); [currentYear]
/// anchors the Year selector ([years]).

import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';

enum VacationBalancesStatus { initial, loading, loaded, failure }

/// The outcome of reading an import file.
class VacationImportRead {
  const VacationImportRead.cancelled()
      : plan = null,
        unreadable = false;
  const VacationImportRead.read(VacationImportPlan this.plan) : unreadable = false;
  const VacationImportRead.unreadable()
      : plan = null,
        unreadable = true;

  final VacationImportPlan? plan;
  final bool unreadable;
}

class VacationBalancesState {
  const VacationBalancesState({
    this.status = VacationBalancesStatus.initial,
    this.employees = const <TimeTrackerEmployee>[],
    this.departments = const <String, String>{},
    this.balances = const <VacationBalance>[],
    this.year = 0,
    this.currentYear = 0,
    this.isArabic = false,
    this.query = '',
    this.departmentId = '',
    this.isGrid = true,
    this.failure = TimeTrackerActionFailure.none,
    this.errorMessage = '',
  });

  final VacationBalancesStatus status;
  final List<TimeTrackerEmployee> employees;

  /// Department id → name.
  final Map<String, String> departments;

  /// Stored balances of the selected [year].
  final List<VacationBalance> balances;

  /// The selected year (the list, Edit and Import use it).
  final int year;

  /// The calendar year when the tab opened (anchors [years]).
  final int currentYear;

  /// The Year selector's entries (newest first).
  List<int> get years => VacationBalanceYears.selectable(currentYear == 0 ? year : currentYear);
  final bool isArabic;
  final String query;

  /// '' = every department.
  final String departmentId;
  final bool isGrid;
  final TimeTrackerActionFailure failure;
  final String errorMessage;

  bool get isLoading => status == VacationBalancesStatus.initial || status == VacationBalancesStatus.loading;

  /// One row per employee (selected year).
  List<VacationBalanceRow> get rows => VacationBalanceList.rows(
        employees: employees,
        balances: balances,
        year: year,
        isArabic: isArabic,
      );

  /// [rows] narrowed by the search and the department filter.
  List<VacationBalanceRow> get visible =>
      VacationBalanceList.filter(rows, query: query, departmentId: departmentId);

  /// Departments that have employees (the filter's entries).
  Map<String, String> get usedDepartments {
    final Set<String> ids = <String>{for (final TimeTrackerEmployee e in employees) e.departmentId};
    return <String, String>{
      for (final MapEntry<String, String> d in departments.entries)
        if (ids.contains(d.key)) d.key: d.value,
    };
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [VacationBalancesState]
  VacationBalancesState copyWith({
    VacationBalancesStatus? status,
    List<TimeTrackerEmployee>? employees,
    Map<String, String>? departments,
    List<VacationBalance>? balances,
    int? year,
    int? currentYear,
    bool? isArabic,
    String? query,
    String? departmentId,
    bool? isGrid,
    TimeTrackerActionFailure? failure,
    String? errorMessage,
  }) =>
      VacationBalancesState(
        status: status ?? this.status,
        employees: employees ?? this.employees,
        departments: departments ?? this.departments,
        balances: balances ?? this.balances,
        year: year ?? this.year,
        currentYear: currentYear ?? this.currentYear,
        isArabic: isArabic ?? this.isArabic,
        query: query ?? this.query,
        departmentId: departmentId ?? this.departmentId,
        isGrid: isGrid ?? this.isGrid,
        failure: failure ?? this.failure,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
