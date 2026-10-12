/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_screens_test.dart
/// Purpose: Widget tests for the three phase-2 screens' key states and the
///          permission gating (a switch OFF hides its button / tab): the
///          main page header + tabs, Check In & Out states, the Personal
///          Dashboard, the Attendance tab (Export / + Transaction) and the
///          Creating Transaction form.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/ui/widgets/check_in_sheet.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_test_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

/// The Employee switches of Figma (Screen Inventory §3.2, switches OFF).
const Set<String> _employee = <String>{
  'Check_In_Permissions',
  'Check_In_And_Out',
  'Time_Tracker_Dashboard_Permissions',
  'Personal_Dashboard',
  'Attendance_Permissions',
  'View_Attendance',
  'Time_Tracker_Request_Permissions',
  'View_Time_Tracker_Requests',
};

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office');

Finder _tab(String label) =>
    find.descendant(of: find.byType(CustomTabs), matching: find.text(label));

Future<void> _seedDays(FakeTimeTrackerRemote remote) async {
  final AttendanceRepositoryImpl repo =
      AttendanceRepositoryImpl(remoteDataSource: remote, access: accessWith(<String>{}));
  final DateTime today = DateTime.now();
  for (int i = 1; i <= 3; i++) {
    await repo.saveDay(
      day: AttendanceDay(
        id: '',
        employeeEmail: 'me@co.com',
        date: DateTime(today.year, today.month, today.day - i),
        status: i == 2 ? AttendanceStatus.absent : AttendanceStatus.present,
        totalWorkMinutes: i == 2 ? 0 : 450,
        breakMinutes: i == 2 ? 0 : 30,
      ),
    );
  }
}

void main() {
  setUpAll(initTimeTrackerTestStorage);

  group('main page', () {
    testWidgets('Employee switches → Dashboard · Attendance · Requests + Check In',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(on: _employee);
      seedAssignment(h.remote, location: _hq);
      await h.pump(tester, const TimeTrackerHomePage());

      expect(find.text(S.current.timeTrackerTitle), findsOneWidget);
      expect(_tab(S.current.timeTrackerTabDashboard), findsOneWidget);
      expect(_tab(S.current.timeTrackerTabAttendance), findsOneWidget);
      expect(_tab(S.current.timeTrackerTabRequests), findsOneWidget);
      expect(_tab(S.current.timeTrackerTabApprovals), findsNothing);
      expect(find.byKey(const ValueKey<String>('timeTrackerCheckInButton')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('personalDashboardTab')), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('Check_In_And_Out OFF → no Check In button; more switches → more tabs',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(
        on: allKeys()..remove('Check_In_And_Out'),
      );
      seedAssignment(h.remote, location: _hq);
      await h.pump(tester, const TimeTrackerHomePage());

      expect(find.byKey(const ValueKey<String>('timeTrackerCheckInButton')), findsNothing);
      expect(find.byKey(const ValueKey<String>('timeTrackerProfileCard')), findsOneWidget);
      expect(_tab(S.current.timeTrackerTabApprovals), findsOneWidget);
      expect(_tab(S.current.timeTrackerTabOverview), findsOneWidget);
      await h.dispose(tester);
    });

    // Updated 9/10/2026 - phase 4: the Requests tab is built (no placeholder).
    testWidgets('Personal_Dashboard OFF → Attendance opens first; Requests opens its tab',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(
        on: Set<String>.of(_employee)..remove('Personal_Dashboard'),
      );
      seedAssignment(h.remote, location: _hq);
      await h.pump(tester, const TimeTrackerHomePage());

      expect(_tab(S.current.timeTrackerTabDashboard), findsNothing);
      expect(find.byKey(const ValueKey<String>('attendanceTab')), findsOneWidget);
      await tester.tap(_tab(S.current.timeTrackerTabRequests));
      await h.settle(tester);
      expect(find.byKey(const ValueKey<String>('requestsTab')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('timeTrackerComingSoon')), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('Hide collapses the profile card, Expand brings it back',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(on: _employee);
      seedAssignment(h.remote, location: _hq);
      await h.pump(tester, const TimeTrackerHomePage());

      await tester.tap(find.text(S.current.hide));
      await h.settle(tester);
      expect(h.home.state.headerExpanded, isFalse);
      expect(find.text(S.current.expand), findsOneWidget);
      // The check-in control stays reachable in the title row.
      expect(find.byKey(const ValueKey<String>('timeTrackerCheckInButton')), findsWidgets);
      await tester.tap(find.text(S.current.expand));
      await h.settle(tester);
      expect(h.home.state.headerExpanded, isTrue);
      await h.dispose(tester);
    });
  });

  group('check in & out states', () {
    testWidgets('checked in (pause allowed) → timer, Pause, Check Out, info strip',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(on: _employee);
      seedAssignment(h.remote,
          location: _hq, rules: const AttendanceRules(isPauseAllowed: true));
      await h.pump(tester, const TimeTrackerHomePage());

      await tester.runAsync(() => h.checkIn.checkIn(h.checkIn.state.options.first));
      await h.settle(tester);
      expect(find.byKey(const ValueKey<String>('timeTrackerCheckInButton')), findsNothing);
      expect(find.byKey(const ValueKey<String>('timeTrackerPauseButton')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('timeTrackerCheckOutButton')), findsOneWidget);
      expect(find.textContaining(S.current.timeTrackerHourUnit), findsOneWidget);
      expect(find.text(S.current.timeTrackerCheckInTime), findsOneWidget);
      expect(find.text('Main Office'), findsOneWidget);

      await tester.runAsync(() => h.checkIn.pause());
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerResume), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('pause NOT allowed → Check Out only', (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(on: _employee);
      seedAssignment(h.remote, location: _hq);
      await h.pump(tester, const TimeTrackerHomePage());

      await tester.runAsync(() => h.checkIn.checkIn(h.checkIn.state.options.first));
      await h.settle(tester);
      expect(find.byKey(const ValueKey<String>('timeTrackerPauseButton')), findsNothing);
      expect(find.byKey(const ValueKey<String>('timeTrackerCheckOutButton')), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('tapping Check In opens the Work Location sheet',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(on: _employee);
      seedAssignment(h.remote, location: _hq);
      await h.pump(tester, const TimeTrackerHomePage());

      await tester.tap(find.byKey(const ValueKey<String>('timeTrackerCheckInButton')));
      await h.settle(tester);
      expect(find.byType(CheckInSheet), findsOneWidget);
      expect(find.text(S.current.timeTrackerStartShift), findsOneWidget);
      await h.dispose(tester);
    });
  });

  group('personal dashboard', () {
    testWidgets('Overall · Requests · Late History render', (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(on: _employee);
      seedAssignment(h.remote, location: _hq);
      await _seedDays(h.remote);
      await h.pump(tester, const TimeTrackerHomePage());

      expect(find.byKey(const ValueKey<String>('timeTrackerOverallCard')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('timeTrackerRequestsDonut')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('timeTrackerRangeMenu')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('timeTrackerLateHistory')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(S.current.timeTrackerCounts), findsOneWidget);
      expect(find.text(S.current.timeTrackerMinutes), findsOneWidget);
      await h.dispose(tester);
    });
  });

  group('attendance tab', () {
    Future<TimeTrackerHarness> open(WidgetTester tester, Set<String> on, {Size size = kTimeTrackerTablet}) async {
      final TimeTrackerHarness h = TimeTrackerHarness(on: on);
      seedAssignment(h.remote, location: _hq);
      await _seedDays(h.remote);
      await h.pump(tester, const TimeTrackerHomePage(), size: size);
      await tester.tap(_tab(S.current.timeTrackerTabAttendance));
      await h.settle(tester);
      return h;
    }

    testWidgets('table rows, tiles; Export / + Transaction hidden when OFF',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = await open(tester, _employee);
      expect(find.byKey(const ValueKey<String>('attendanceTiles')), findsOneWidget);
      expect(find.text(S.current.timeTrackerOncomingTime), findsOneWidget);
      expect(find.text(S.current.timeTrackerAbsent), findsWidgets);
      expect(find.byKey(const ValueKey<String>('attendanceExportButton')), findsNothing);
      expect(find.byKey(const ValueKey<String>('attendanceTransactionButton')), findsNothing);
      expect(find.byKey(const ValueKey<String>('attendanceFilterButton')), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('Export_Attendance + Request_Transaction ON → both buttons',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = await open(
        tester,
        <String>{..._employee, 'Export_Attendance', 'Request_Transaction'},
      );
      expect(find.byKey(const ValueKey<String>('attendanceExportButton')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('attendanceTransactionButton')), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('+ Transaction opens the form; Submit disabled reveals errors',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = await open(
        tester,
        <String>{..._employee, 'Request_Transaction'},
      );
      await tester.tap(find.byKey(const ValueKey<String>('attendanceTransactionButton')));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerCreatingTransaction), findsOneWidget);
      expect(find.text(S.current.timeTrackerTransactionDocument), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('transactionUploadBox')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('transactionSubmitButton')));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerCheckInRequired), findsOneWidget);
      expect(find.text(S.current.timeTrackerCheckOutRequired), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('phone → one card per day', (WidgetTester tester) async {
      final TimeTrackerHarness h = await open(tester, _employee, size: kTimeTrackerPhone);
      expect(find.text(S.current.timeTrackerOncomingTime), findsNWidgets(3));
      await h.dispose(tester);
    });
  });

  testWidgets('Arabic (RTL): main page, dashboard and attendance build cleanly',
      (WidgetTester tester) async {
    await S.load(const Locale('ar'));
    addTearDown(() => S.load(const Locale('en')));
    final TimeTrackerHarness h = TimeTrackerHarness(
      on: <String>{..._employee, 'Export_Attendance', 'Request_Transaction'},
    );
    seedAssignment(h.remote, location: _hq);
    await _seedDays(h.remote);
    await h.pump(tester, const TimeTrackerHomePage(), locale: const Locale('ar'));
    expect(find.text('تتبع الوقت'), findsWidgets);
    expect(
      Directionality.of(tester.element(find.byType(TimeTrackerHomePage))),
      TextDirection.rtl,
    );
    await tester.tap(_tab('الحضور'));
    await h.settle(tester);
    expect(find.text('وقت الحضور'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });
}
