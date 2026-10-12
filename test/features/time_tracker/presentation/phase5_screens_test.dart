/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: phase5_screens_test.dart
/// Purpose: Widget tests of phase 5: the dashboard tab's switch gating
///          (Dashboard vs Overview, the My Dashboard | HR toggle, HR only),
///          the HR view's filters per switch, the Today strip and its
///          Approvals link, Needs attention, the multi-select Employee
///          picker and the picked cards, the employee dashboard (scope
///          gate), the Location → employee dashboard link, the Vacation
///          Balances tab (switches, cards / table, Edit dialog), and phone /
///          Arabic / dark smoke runs.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/pages/employee_dashboard_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_phase5_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

final DateTime _now = DateTime(2026, 10, 9, 10, 30);
const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office', nameAr: 'المكتب الرئيسي');
const WorkSchedule _nineToFive = WorkSchedule(startMinutes: 540, endMinutes: 1020, lateAfterMinutes: 10);

Finder _key(String k) => find.byKey(ValueKey<String>(k));
Finder _tab(String label) => find.descendant(of: find.byType(CustomTabs), matching: find.text(label));
Set<String> _without(Set<String> remove) => allKeys()..removeAll(remove);

Future<void> _open(WidgetTester tester, TimeTrackerHarness h, String label) async {
  await tester.ensureVisible(_tab(label));
  await tester.pump();
  await tester.tap(_tab(label));
  await h.settle(tester);
}

/// The HR side of the Overview toggle.
Future<void> _showHr(WidgetTester tester, TimeTrackerHarness h) async {
  await tester.tap(find.descendant(of: _key('overviewToggle'), matching: find.text(S.current.timeTrackerHrStep)));
  await h.settle(tester);
}

Map<String, EmployeePlacement> _places() => <String, EmployeePlacement>{
      for (final TimeTrackerEmployee e in FakeDirectory.defaultPeople)
        e.email: EmployeePlacement(email: e.email, locationId: 'hq', schedule: _nineToFive, startDate: DateTime(2026, 10, 1)),
    };

/// A HR harness: Sara (dep-2) late today; a request of Amr waiting for me
/// since 1 Oct; Sara's transaction pending.
TimeTrackerHarness _hr({Set<String>? on, Map<String, EmployeePlacement>? places}) {
  final TimeTrackerHarness h = TimeTrackerHarness(on: on, placements: places ?? _places());
  seedAssignment(h.remote, location: _hq);
  seedDays(h.remote, <AttendanceDay>[
    AttendanceDay(
      id: '',
      employeeEmail: 'sara@co.com',
      date: DateTime(2026, 10, 9),
      status: AttendanceStatus.late,
      sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 9, 9, 40))],
    ),
  ]);
  seedRequests(h.remote, <TimeTrackerRequest>[
    TimeTrackerRequest(
      id: 'waiting',
      requesterEmail: 'amr@co.com',
      requesterDepartmentId: 'dep-1',
      startAt: DateTime(2026, 10, 20),
      endAt: DateTime(2026, 10, 21),
      isAllDay: true,
      approvalSteps: const <RequestApprovalStep>[
        RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'me@co.com'),
      ],
      currentStep: ApprovalStepKind.manager,
    ),
    TimeTrackerRequest(
      id: 'tx',
      requesterEmail: 'sara@co.com',
      requesterDepartmentId: 'dep-2',
      isTransaction: true,
      startAt: DateTime(2026, 10, 8, 9),
      endAt: DateTime(2026, 10, 8, 17),
      approvalSteps: const <RequestApprovalStep>[
        RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'boss@co.com'),
      ],
      currentStep: ApprovalStepKind.manager,
    ),
  ], at: DateTime(2026, 10, 1));
  return h;
}

/// A personal dashboard cubit that is "loaded" at once (the core spinner
/// needs a GetMaterialApp the tests do not have).
class _InstantDashboardCubit extends PersonalDashboardCubit {
  _InstantDashboardCubit(TimeTrackerHarness h)
      : super(
          attendance: AttendanceRepositoryImpl(remoteDataSource: h.remote, access: h.access),
          requests: RequestRepositoryImpl(remoteDataSource: h.remote, access: h.access),
          balances: VacationBalanceRepositoryImpl(remoteDataSource: h.remote, access: h.access),
          resolver: h.resolver,
          access: h.access,
        );

  String opened = '';

  // 9/10/2026 (code review): `employeeId` finds an HR shift's schedule.
  @override
  Future<void> init({String? employeeEmail, String employeeId = ''}) async {
    opened = employeeEmail ?? '';
    emit(state.copyWith(status: PersonalDashboardStatus.loaded, email: opened));
  }
}

void _registerInstantDashboard(TimeTrackerHarness h) {
  final GetIt getIt = GetIt.instance;
  if (getIt.isRegistered<PersonalDashboardCubit>()) getIt.unregister<PersonalDashboardCubit>();
  getIt.registerFactory<PersonalDashboardCubit>(() => _InstantDashboardCubit(h));
  addTearDown(() {
    if (getIt.isRegistered<PersonalDashboardCubit>()) getIt.unregister<PersonalDashboardCubit>();
  });
}

void main() {
  setUpAll(initTimeTrackerTestStorage);

  group('dashboard tab gating', () {
    testWidgets('Personal_Dashboard only → "Dashboard", personal dashboard, no toggle', (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr(on: _without(<String>{'HR_Dashboard'}));
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      expect(_tab(S.current.timeTrackerTabDashboard), findsOneWidget);
      expect(_key('personalDashboardTab'), findsOneWidget);
      expect(_key('overviewToggle'), findsNothing);
      expect(h.hrDashboard, isNull, reason: 'not even created');
      await h.dispose(tester);
    });

    testWidgets('both → "Overview" + My Dashboard | HR (opens on My Dashboard)', (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr();
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      expect(_tab(S.current.timeTrackerTabOverview), findsOneWidget);
      expect(_key('overviewToggle'), findsOneWidget);
      expect(_key('personalDashboardTab'), findsOneWidget);
      await _showHr(tester, h);
      expect(_key('hrDashboardView'), findsOneWidget);
      expect(_key('personalDashboardTab'), findsNothing);
      expect(h.hrDashboard!.state.showHr, isTrue);
      await h.dispose(tester);
    });

    testWidgets('HR_Dashboard only → "Overview", the HR view, no toggle', (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr(on: _without(<String>{'Personal_Dashboard'}));
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      expect(_tab(S.current.timeTrackerTabOverview), findsOneWidget);
      expect(_key('overviewToggle'), findsNothing);
      expect(_key('hrDashboardView'), findsOneWidget);
      await h.dispose(tester);
    });
  });

  group('HR view', () {
    testWidgets('filters follow their switches; cards render', (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr();
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _showHr(tester, h);
      expect(_key('hrEmployeeButton'), findsOneWidget);
      expect(_key('hrDepartmentFilter'), findsOneWidget);
      expect(_key('hrLocationFilter'), findsOneWidget);
      expect(_key('hrRangeMenu'), findsOneWidget);
      expect(_key('hrExportButton'), findsOneWidget);
      for (final String k in <String>['hrKpiStrip', 'hrNeedsAttention', 'hrRequestsDonut', 'hrRequestTypesDonut']) {
        expect(_key(k), findsOneWidget, reason: k);
      }
      for (final String k in <String>['hrAttendanceHistory', 'hrRequestTypeBars', 'hrRequestTimeline']) {
        await tester.scrollUntilVisible(_key(k), 300, scrollable: find.byType(Scrollable).first);
        expect(_key(k), findsOneWidget, reason: k);
      }
      await h.dispose(tester);

      final TimeTrackerHarness narrow = _hr(on: _without(<String>{'HR_Dashboard_All_Departments', 'HR_Dashboard_Filter_By_Employee'}));
      await narrow.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _showHr(tester, narrow);
      expect(_key('hrEmployeeButton'), findsNothing);
      expect(_key('hrDepartmentFilter'), findsNothing);
      expect(_key('hrLocationFilter'), findsOneWidget);
      expect(narrow.hrDashboard!.state.stats.employeeCount, 2, reason: 'own department only');
      await narrow.dispose(tester);
    });

    testWidgets('Today strip counts; Pending Approvals opens Approvals on Pending', (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr();
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _showHr(tester, h);
      final kpi = h.hrDashboard!.state.stats.kpi;
      expect(kpi.lateToday, 1);
      expect(kpi.checkedInNow, 1);
      expect(kpi.absentToday, 2, reason: 'me + Amr: no check-in after 09:10');
      expect(kpi.pendingApprovals, 2);
      expect(find.text(S.current.timeTrackerPendingApprovals), findsOneWidget);
      await tester.tap(find.text(S.current.timeTrackerPendingApprovals));
      await h.settle(tester);
      expect(h.home.state.selectedTab, TimeTrackerTab.approvals);
      expect(h.feed.state.approvals.bucket, RequestBucket.pending);
      expect(_key('approvalsTab'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('Needs attention: overdue approval opens the approver details; absences open the dashboard',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr();
      _registerInstantDashboard(h);
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _showHr(tester, h);
      expect(_key('hrAttentionOverdue'), findsOneWidget);
      expect(_key('hrAttentionTransactions'), findsOneWidget);
      expect(_key('hrAttentionAbsences'), findsOneWidget, reason: 'me + Amr: 6–9 Oct with no record');
      await tester.tap(_key('hrAttentionRequest_waiting'));
      await h.settle(tester);
      expect(_key('requestDetails_waiting'), findsOneWidget, reason: 'it waits for me → approver details');
      Navigator.of(tester.element(_key('requestDetails_waiting'))).pop();
      await h.settle(tester);
      await tester.tap(_key('hrAttentionAbsence_amr@co.com'));
      await h.settle(tester);
      expect(_key('employeeDashboard_amr@co.com'), findsOneWidget);
      expect(_key('employeeDashboardBody'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('nothing to act on → "all clear"', (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(placements: const <String, EmployeePlacement>{});
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _showHr(tester, h);
      expect(_key('hrAttentionAllClear'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('Employee picker: several can be picked; one → wide card, more → grid; untick = all',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr();
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _showHr(tester, h);
      await tester.tap(_key('hrEmployeeButton'));
      await h.settle(tester);
      expect(_key('hrPickerGrid'), findsOneWidget);
      expect(find.text(S.current.timeTrackerAllEmployees), findsNothing, reason: 'owner rule: no "All Employees" row');
      expect(_key('hrPickerDepartment'), findsOneWidget);
      await tester.tap(_key('hrPickerRow_amr@co.com'));
      await h.settle(tester);
      expect(h.hrDashboard!.state.filters.employeeEmails, <String>{'amr@co.com'});
      await tester.tap(_key('hrPickerRow_sara@co.com'));
      await h.settle(tester);
      expect(h.hrDashboard!.state.filters.employeeEmails, <String>{'amr@co.com', 'sara@co.com'});
      Navigator.of(tester.element(_key('hrPickerGrid'))).pop();
      await h.settle(tester);
      expect(_key('hrPickedGrid'), findsOneWidget);
      expect(h.hrDashboard!.state.stats.employeeCount, 2);
      h.hrDashboard!.setEmployees(<String>{'amr@co.com'});
      await h.settle(tester);
      expect(_key('hrPickedGrid'), findsNothing);
      expect(_key('hrPickedCard_amr@co.com'), findsOneWidget);
      expect(find.text(S.current.message), findsOneWidget);
      h.hrDashboard!.setEmployees(<String>{});
      await h.settle(tester);
      expect(_key('hrPickedCard_amr@co.com'), findsNothing);
      expect(h.hrDashboard!.state.stats.employeeCount, 3);
      await h.dispose(tester);
    });

    testWidgets('phone, Arabic and dark mode build cleanly', (WidgetTester tester) async {
      for (final (Size, Locale, bool) c in <(Size, Locale, bool)>[
        (kTimeTrackerPhone, const Locale('en'), false),
        (kTimeTrackerTablet, const Locale('ar'), false),
        (kTimeTrackerPhone, const Locale('ar'), true),
      ]) {
        if (c.$3) {
          AppTheme.isDark = true;
          AppColors.currentThemeColors = AppTheme.darkThemeColors;
        }
        final TimeTrackerHarness h = _hr();
        await h.pump(tester, const TimeTrackerHomePage(), size: c.$1, locale: c.$2, clock: () => _now);
        await _showHr(tester, h);
        expect(_key('hrDashboardView'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _open(tester, h, S.of(tester.element(find.byType(TimeTrackerHomePage))).timeTrackerTabVacationBalances);
        expect(_key('vacationBalancesTab'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await h.dispose(tester);
        AppTheme.isDark = false;
        AppColors.currentThemeColors = AppTheme.lightThemeColors;
      }
    });
  });

  group('employee dashboard (661:96459)', () {
    testWidgets('only HR dashboard holders whose scope covers the employee', (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr(on: _without(<String>{'HR_Dashboard_All_Departments'}));
      _registerInstantDashboard(h);
      await h.pump(
        tester,
        const EmployeeDashboardPage(employee: TimeTrackerEmployee(email: 'sara@co.com', departmentId: 'dep-2')),
      );
      expect(_key('employeeDashboardNoAccess'), findsOneWidget);
      await h.dispose(tester);

      final TimeTrackerHarness ok = _hr(on: _without(<String>{'HR_Dashboard_All_Departments'}));
      _registerInstantDashboard(ok);
      await ok.pump(
        tester,
        const EmployeeDashboardPage(employee: TimeTrackerEmployee(email: 'amr@co.com', nameEn: 'Amr M', departmentId: 'dep-1')),
      );
      expect(_key('employeeDashboard_amr@co.com'), findsOneWidget);
      expect(find.text('Amr M'), findsWidgets);
      expect(find.text(S.current.message), findsOneWidget);
      expect(_key('timeTrackerOverallCard'), findsOneWidget);
      await ok.dispose(tester);
    });

    testWidgets('Location details: an assigned employee opens their dashboard (HR dashboard only)',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = _hr();
      _registerInstantDashboard(h);
      seedAssignment(h.remote, location: _hq, email: 'amr@co.com');
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _open(tester, h, S.current.timeTrackerTabLocations);
      await tester.tap(_key('locationRow_hq'));
      await h.settle(tester);
      expect(_key('assignedEmployeeMessage_amr@co.com'), findsOneWidget);
      expect(_key('assignedEmployeeMessage_me@co.com'), findsNothing, reason: 'no Message on my own card');
      await tester.ensureVisible(_key('assignedEmployee_amr@co.com'));
      await tester.pump();
      await tester.tap(_key('assignedEmployee_amr@co.com'), warnIfMissed: false);
      await h.settle(tester);
      expect(_key('employeeDashboard_amr@co.com'), findsOneWidget);
      await h.dispose(tester);

      final TimeTrackerHarness noHr = _hr(on: _without(<String>{'HR_Dashboard'}));
      seedAssignment(noHr.remote, location: _hq, email: 'amr@co.com');
      await noHr.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _open(tester, noHr, S.current.timeTrackerTabLocations);
      await tester.tap(_key('locationRow_hq'));
      await noHr.settle(tester);
      await tester.ensureVisible(_key('assignedEmployee_amr@co.com'));
      await tester.pump();
      await tester.tap(_key('assignedEmployee_amr@co.com'), warnIfMissed: false);
      await noHr.settle(tester);
      expect(_key('employeeDashboard_amr@co.com'), findsNothing);
      await noHr.dispose(tester);
    });
  });

  group('Vacation Balances tab', () {
    TimeTrackerHarness balances({Set<String>? on}) {
      final TimeTrackerHarness h = TimeTrackerHarness(on: on);
      seedBalance(h.remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21, usedDays: 6));
      return h;
    }

    testWidgets('View off → no tab; on → cards with Edit / Export / Import', (WidgetTester tester) async {
      final TimeTrackerHarness off = balances(on: _without(<String>{'View_Vacation_Balances'}));
      await off.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      expect(_tab(S.current.timeTrackerTabVacationBalances), findsNothing);
      await off.dispose(tester);

      final TimeTrackerHarness h = balances();
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _open(tester, h, S.current.timeTrackerTabVacationBalances);
      expect(_key('vacationGrid'), findsOneWidget);
      expect(_key('vacationCard_me@co.com'), findsOneWidget);
      expect(_key('vacationEdit_me@co.com'), findsOneWidget);
      expect(_key('vacationExportButton'), findsOneWidget);
      expect(_key('vacationImportButton'), findsOneWidget);
      expect(find.text('15'), findsOneWidget, reason: 'remaining 21 − 6');
      await tester.tap(_key('vacationTableToggle'));
      await h.settle(tester);
      expect(_key('vacationTable'), findsOneWidget);
      expect(_key('vacationRow_sara@co.com'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('switches OFF hide Edit / Export / Import', (WidgetTester tester) async {
      final TimeTrackerHarness h = balances(
        on: _without(<String>{'Edit_Vacation_Balance', 'Export_Vacation_Balances', 'Import_Vacation_Balances'}),
      );
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _open(tester, h, S.current.timeTrackerTabVacationBalances);
      expect(_key('vacationCard_me@co.com'), findsOneWidget);
      expect(_key('vacationEdit_me@co.com'), findsNothing);
      expect(_key('vacationExportButton'), findsNothing);
      expect(_key('vacationImportButton'), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('Edit dialog: Save grey until the value changes; an invalid value shows its error',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = balances();
      await h.pump(tester, const TimeTrackerHomePage(), clock: () => _now);
      await _open(tester, h, S.current.timeTrackerTabVacationBalances);
      await tester.tap(_key('vacationEdit_me@co.com'));
      await h.settle(tester);
      expect(_key('vacationTotalField'), findsOneWidget);
      await tester.tap(_key('vacationEditSave'));
      await h.settle(tester);
      expect(_key('vacationTotalField'), findsOneWidget, reason: 'unchanged → still open');
      await tester.enterText(find.descendant(of: _key('vacationTotalField'), matching: find.byType(TextField)), '2.25');
      await h.settle(tester);
      await tester.tap(_key('vacationEditSave'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerTotalDaysInvalid), findsOneWidget);
      await tester.enterText(find.descendant(of: _key('vacationTotalField'), matching: find.byType(TextField)), '25');
      await h.settle(tester);
      expect(find.text('19'), findsWidgets, reason: 'Remaining previews 25 − 6');
      await h.dispose(tester);
    });
  });
}
