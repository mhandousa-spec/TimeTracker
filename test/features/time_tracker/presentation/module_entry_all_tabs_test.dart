/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: module_entry_all_tabs_test.dart
/// Purpose: QA KP-TT-003 (Critical, 9/10/2026) — the REAL
///          `TimeTrackerModuleEntry` (its own lazy providers from GetIt) opens
///          EVERY tab with every switch on, without an exception / red
///          screen.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Before the fix the Request Types and Employees providers read
/// `Localizations.localeOf(ctx)` inside their lazy `create` → "Tried to
/// listen to an InheritedWidget in a life-cycle that will never be called
/// again" the moment the tab first read its cubit (fails without the fix).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_module_entry.dart';

import '../_support/time_tracker_widget_harness.dart';

const Map<TimeTrackerTab, String> _bodyKey = <TimeTrackerTab, String>{
  TimeTrackerTab.dashboard: 'overviewTab',
  TimeTrackerTab.attendance: 'attendanceTab',
  TimeTrackerTab.requests: 'requestsTab',
  TimeTrackerTab.approvals: 'approvalsTab',
  TimeTrackerTab.requestTypes: 'requestTypesTab',
  TimeTrackerTab.locations: 'locationsTab',
  TimeTrackerTab.employees: 'employeesTab',
  TimeTrackerTab.vacationBalances: 'vacationBalancesTab',
};

void main() {
  setUpAll(initTimeTrackerTestStorage);

  for (final (String name, Locale locale, Size size) in <(String, Locale, Size)>[
    ('iPad EN', const Locale('en'), kTimeTrackerTablet),
    ('iPad AR', const Locale('ar'), kTimeTrackerTablet),
    ('iPhone EN', const Locale('en'), kTimeTrackerPhone),
  ]) {
    testWidgets('KP-TT-003: the module entry opens every tab without an error ($name)',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      await h.pump(tester, const TimeTrackerModuleEntry(), moduleEntry: true, locale: locale, size: size);
      expect(tester.takeException(), isNull);
      // Request Types and Employees first: they are the two that crashed.
      final List<TimeTrackerTab> order = <TimeTrackerTab>[
        TimeTrackerTab.requestTypes,
        TimeTrackerTab.employees,
        ...TimeTrackerTab.values.where(
          (TimeTrackerTab t) => t != TimeTrackerTab.requestTypes && t != TimeTrackerTab.employees,
        ),
      ];
      for (final TimeTrackerTab tab in order) {
        h.entryHome!.selectTab(tab);
        await h.settle(tester);
        expect(tester.takeException(), isNull, reason: '$tab threw');
        expect(find.byType(ErrorWidget), findsNothing, reason: '$tab shows a red error screen');
        expect(find.byKey(ValueKey<String>(_bodyKey[tab]!)), findsOneWidget, reason: '$tab body missing');
      }
      await h.dispose(tester);
    });
  }
}
