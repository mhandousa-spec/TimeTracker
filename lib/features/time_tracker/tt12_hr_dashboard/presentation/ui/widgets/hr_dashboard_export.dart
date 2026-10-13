/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_export.dart
/// Purpose: Declares `HrDashboardExport` — the CSV of the numbers the HR
///          view shows right now (filters, Today strip, Needs attention,
///          every chart), and `exportHrDashboard` (the export flow).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5 — owner asked to innovate)
///
/// Three columns — Section · Item · Value — in the app language, through
/// the module's CSV export (`exportTimeTrackerCsv`: file-name dialog, UTF-8
/// BOM so Arabic opens in Excel, the system save sheet). Month items read
/// "Jan 2026 · Present". No separate switch exists for it: whoever holds
/// `HR_Dashboard` may export what they see (decision to confirm).

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_charts.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/ui/widgets/dashboard_range_menu.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HrDashboardExport {
  const HrDashboardExport._();

  /// Function Name: [header]
  ///
  /// Return type: [List<String>] — Section · Item · Value.
  static List<String> header(BuildContext context) {
    final S s = S.of(context);
    return <String>[s.timeTrackerExportSection, s.timeTrackerExportItem, s.timeTrackerExportValue];
  }

  /// Function Name: [rows]
  ///
  /// Purpose: Every number of [state] as CSV rows.
  ///
  /// Return type: [List<List<String>>]
  static List<List<String>> rows(BuildContext context, HrDashboardState state) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final String locale = Localizations.localeOf(context).languageCode;
    final HrDashboardStats st = state.stats;
    String n(int v) => '$v';
    String month(DateTime m) => DateFormat('MMM yyyy', locale).format(m);
    String namesOr(Iterable<String> names) => names.isEmpty ? s.timeTrackerAll : names.join(' · ');
    final List<String> locationNames = <String>[
      for (final String id in state.filters.locationIds)
        if (state.locationById(id) case final WorkLocation l) l.name(isArabic: ar),
    ];
    final List<TimeTrackerEmployee> picked = state.canFilterByEmployee ? state.pickedEmployees : const <TimeTrackerEmployee>[];
    final List<List<String>> out = <List<String>>[
      <String>[
        s.timeTrackerFiltersTitle,
        s.timeTrackerRangeTime,
        '${DashboardRangeMenu.label(context, state.range)} (${s.timeTrackerTimeframeValue(
          TimeTrackerFormat.date(context, state.span.first),
          TimeTrackerFormat.date(context, state.span.last),
        )})',
      ],
      if (state.allDepartments)
        <String>[
          s.timeTrackerFiltersTitle,
          s.timeTrackerDepartment,
          namesOr(<String>[
            for (final String id in state.filters.departmentIds)
              if (state.departments[id] case final String name) name,
          ]),
        ],
      <String>[s.timeTrackerFiltersTitle, s.timeTrackerLocation, namesOr(locationNames)],
      if (state.canFilterByEmployee)
        <String>[
          s.timeTrackerFiltersTitle,
          s.timeTrackerTabEmployees,
          picked.isEmpty
              ? s.timeTrackerAllEmployees
              : picked.map((TimeTrackerEmployee e) => e.name(isArabic: ar)).join(', '),
        ],
      <String>[s.timeTrackerFiltersTitle, s.timeTrackerEmployeesInScope, n(st.employeeCount)],
      <String>[s.today, s.timeTrackerCheckedInNow, n(st.kpi.checkedInNow)],
      <String>[s.today, s.timeTrackerLateToday, n(st.kpi.lateToday)],
      <String>[s.today, s.timeTrackerAbsentToday, n(st.kpi.absentToday)],
      <String>[s.today, s.timeTrackerOnLeaveToday, n(st.kpi.onLeaveToday)],
      <String>[s.today, s.timeTrackerPendingApprovals, n(st.kpi.pendingApprovals)],
      <String>[s.timeTrackerNeedsAttention, s.timeTrackerOverdueApprovals, n(st.attention.overdueApprovals.length)],
      <String>[s.timeTrackerNeedsAttention, s.timeTrackerFrequentAbsences, n(st.attention.frequentAbsences.length)],
      <String>[s.timeTrackerNeedsAttention, s.timeTrackerMissingCheckOuts, n(st.attention.missingCheckOuts.length)],
      <String>[s.timeTrackerNeedsAttention, s.timeTrackerTransactionsWaiting, n(st.attention.waitingTransactions.length)],
      <String>[s.timeTrackerRequestsTitle, s.timeTrackerApproved, n(st.approved)],
      <String>[s.timeTrackerRequestsTitle, s.timeTrackerPending, n(st.pending)],
      <String>[s.timeTrackerRequestsTitle, s.timeTrackerRejected, n(st.rejected)],
      <String>[s.timeTrackerRequestsTitle, s.timeTrackerCanceled, n(st.canceled)],
      <String>[s.timeTrackerRequestsTitle, s.timeTrackerTotal, n(st.totalRequests)],
      for (final HrTypeSlice t in st.typeSlices)
        <String>[s.timeTrackerTabRequestTypes, hrTypeName(context, state, t.typeId), n(t.count)],
      for (final HrMonthAttendance m in st.attendanceByMonth) ...<List<String>>[
        <String>[s.timeTrackerAttendanceHistory, '${month(m.month)} · ${s.timeTrackerPresent}', n(m.present)],
        <String>[s.timeTrackerAttendanceHistory, '${month(m.month)} · ${s.timeTrackerAbsent}', n(m.absent)],
        <String>[s.timeTrackerAttendanceHistory, '${month(m.month)} · ${s.timeTrackerLate}', n(m.late)],
        <String>[s.timeTrackerAttendanceHistory, '${month(m.month)} · ${s.timeTrackerVacation}', n(m.leave)],
      ],
      for (final HrMonthCount m in st.typeByMonth)
        <String>[
          '${s.timeTrackerTabRequestTypes} · '
              '${state.requestTypeIds.isEmpty ? s.timeTrackerAll : <String>{for (final String id in state.requestTypeIds) hrTypeName(context, state, id)}.join(' · ')}',
          month(m.month),
          n(m.count),
        ],
      for (final HrMonthCount m in st.timelineByMonth)
        <String>[s.timeTrackerRequestTimeline, month(m.month), n(m.count)],
    ];
    return out;
  }
}

/// Function Name: [exportHrDashboard]
///
/// Purpose: Export the HR view's current numbers as CSV.
///
/// Return type: [Future<void>]
Future<void> exportHrDashboard(BuildContext context, HrDashboardState state) => exportTimeTrackerCsv(
      context: context,
      defaultFileName: S.of(context).timeTrackerHrDashboardExportName,
      header: HrDashboardExport.header(context),
      rows: HrDashboardExport.rows(context, state),
    );
