/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: phase3_screens_test.dart
/// Purpose: Widget tests of the phase-3 screens: the new tabs and their
///          HR-present hiding, the Locations tab (table, toolbar gating,
///          form, details), Request Types (empty state, cards ↔ table,
///          gating), Employees (counters, Assign gating, the Review dialog)
///          and Groups — tablet, phone and Arabic (RTL).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

const WorkLocation _hq = WorkLocation(
  id: 'hq',
  nameEn: 'Main Office',
  nameAr: 'المكتب الرئيسي',
  latitude: 30.05,
  longitude: 31.23,
  isGeofenceEnabled: true,
  geofenceRadiusMeters: 500,
);
const WorkLocation _b2 = WorkLocation(id: 'b2', nameEn: 'Branch 2', nameAr: 'الفرع الثاني');

Finder _tab(String label) =>
    find.descendant(of: find.byType(CustomTabs), matching: find.text(label));

Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<void> _open(WidgetTester tester, TimeTrackerHarness h, String label) async {
  // The strip scrolls sideways when the tabs do not fit (phone, 8 tabs).
  await tester.ensureVisible(_tab(label));
  await tester.pump();
  await tester.tap(_tab(label));
  await h.settle(tester);
}

Set<String> _without(Set<String> remove) => allKeys()..removeAll(remove);

void main() {
  setUpAll(initTimeTrackerTestStorage);

  testWidgets('no HR: Request Types · Locations · Employees tabs are shown', (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness();
    await h.pump(tester, const TimeTrackerHomePage());
    expect(_tab(S.current.timeTrackerTabRequestTypes), findsOneWidget);
    expect(_tab(S.current.timeTrackerTabLocations), findsOneWidget);
    expect(_tab(S.current.timeTrackerTabEmployees), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('company WITH HR: Locations and Employees hidden, Request Types stays',
      (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness(hasHr: true);
    await h.pump(tester, const TimeTrackerHomePage());
    expect(_tab(S.current.timeTrackerTabRequestTypes), findsOneWidget);
    expect(_tab(S.current.timeTrackerTabLocations), findsNothing);
    expect(_tab(S.current.timeTrackerTabEmployees), findsNothing);
    await h.dispose(tester);
  });

  group('Locations tab', () {
    testWidgets('table rows + Export / Import / + Location; a row opens the details',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      seedLocations(h.remote, <WorkLocation>[_hq, _b2]);
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabLocations);
      expect(_key('locationsTable'), findsOneWidget);
      expect(_key('locationRow_hq'), findsOneWidget);
      expect(_key('locationRow_b2'), findsOneWidget);
      expect(_key('locationsExportButton'), findsOneWidget);
      expect(_key('locationsImportButton'), findsOneWidget);
      expect(_key('locationsAddButton'), findsOneWidget);

      await tester.tap(_key('locationRow_hq'));
      await h.settle(tester);
      expect(_key('locationEditButton'), findsOneWidget);
      expect(_key('locationDeleteButton'), findsOneWidget);
      // UI quality pass (owner 9/10/2026 #8): the status switch lives INSIDE
      // the Edit form, not on the details header.
      expect(_key('locationStatusSwitch'), findsNothing);
      expect(find.text(S.current.timeTrackerAssignedEmployees), findsOneWidget);
      await tester.tap(_key('locationEditButton'));
      await h.settle(tester);
      expect(_key('locationStatusSwitch'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('switches OFF hide Export / Import / + Location and Edit / Delete / status',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(on: _without(<String>{
        'Export_Locations',
        'Import_Locations',
        'Create_Location',
        'Edit_Location',
        'Delete_Location',
        'Change_Location_Status',
      }));
      seedLocations(h.remote, <WorkLocation>[_hq]);
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabLocations);
      expect(_key('locationsExportButton'), findsNothing);
      expect(_key('locationsImportButton'), findsNothing);
      expect(_key('locationsAddButton'), findsNothing);
      await tester.tap(_key('locationRow_hq'));
      await h.settle(tester);
      expect(_key('locationEditButton'), findsNothing);
      expect(_key('locationDeleteButton'), findsNothing);
      expect(_key('locationStatusSwitch'), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('+ Location form: Create grey; tapping it reveals the errors', (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabLocations);
      await tester.tap(_key('locationsAddButton'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerCreatingNewLocation), findsWidgets);
      expect(find.text(S.current.timeTrackerWorkingDays), findsOneWidget);
      expect(find.text(S.current.timeTrackerNameRequired), findsNothing);
      await tester.ensureVisible(_key('locationSubmitButton'));
      await tester.tap(_key('locationSubmitButton'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerNameRequired), findsOneWidget);
      expect(find.text(S.current.timeTrackerArabicNameRequired), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('location map (owner L1 / S5): tap the map sets the pin; geofence circle + quick radius',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabLocations);
      await tester.tap(_key('locationsAddButton'));
      await h.settle(tester);
      await tester.ensureVisible(_key('geofenceMap'));
      await h.settle(tester);
      expect(_key('locationUseMyLocation'), findsOneWidget);
      expect(_key('geofenceSearchField'), findsOneWidget);
      // No coordinates yet → tap the map → latitude / longitude filled.
      await tester.tap(_key('geofenceMap'));
      await h.settle(tester);
      String text(String label) => tester
          .widgetList<EditableText>(find.byType(EditableText))
          .map((EditableText e) => e.controller.text)
          .firstWhere((String t) => t.contains('.'), orElse: () => label);
      expect(text(''), isNot(''), reason: 'a coordinate was written');
      // Geofence ON → the quick radius buttons; 500 m draws the badge.
      await tester.ensureVisible(_key('locationGeofenceSwitch'));
      await tester.tap(find.descendant(of: _key('locationGeofenceSwitch'), matching: find.byType(GestureDetector)).last);
      await h.settle(tester);
      await tester.ensureVisible(_key('geofenceQuickRadius_500'));
      await tester.tap(_key('geofenceQuickRadius_500'));
      await h.settle(tester);
      expect(_key('geofenceRadiusBadge'), findsOneWidget);
      expect(find.descendant(of: _key('geofenceRadiusBadge'), matching: find.text(S.current.timeTrackerMetersValue('500'))),
          findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('phone: one card per location', (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      seedLocations(h.remote, <WorkLocation>[_hq]);
      await h.pump(tester, const TimeTrackerHomePage(), size: kTimeTrackerPhone);
      await _open(tester, h, S.current.timeTrackerTabLocations);
      expect(_key('locationsTable'), findsNothing);
      expect(_key('locationRow_hq'), findsOneWidget);
      await h.dispose(tester);
    });
  });

  group('Request Types tab', () {
    testWidgets('nothing seeded → empty state; + Request Type opens the form', (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabRequestTypes);
      expect(find.byType(CustomEmptyState), findsOneWidget);
      await tester.tap(_key('requestTypesAddButton'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerCreatingRequestType), findsWidgets);
      expect(_key('requestTypeDeductsSwitch'), findsOneWidget);
      expect(_key('requestTypeActiveSwitch'), findsNothing); // create form
      await h.dispose(tester);
    });

    testWidgets('cards ↔ table; Export / + Request Type follow their switches', (WidgetTester tester) async {
      final TimeTrackerHarness h =
          TimeTrackerHarness(on: _without(<String>{'Export_Request_Types', 'Create_Request_Type'}));
      seedRequestTypes(h.remote, const <RequestType>[
        RequestType(id: 't1', nameEn: 'Sick Leave', nameAr: 'إجازة مرضية'),
      ]);
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabRequestTypes);
      expect(_key('requestTypeCard_t1'), findsOneWidget);
      expect(_key('requestTypesExportButton'), findsNothing);
      expect(_key('requestTypesAddButton'), findsNothing);
      await tester.tap(_key('requestTypesTableToggle'));
      await h.settle(tester);
      expect(_key('requestTypesTable'), findsOneWidget);
      expect(_key('requestTypeRow_t1'), findsOneWidget);
      await tester.tap(_key('requestTypeRow_t1'));
      await h.settle(tester);
      expect(_key('requestTypeEditButton'), findsOneWidget);
      expect(_key('requestTypeRemoveButton'), findsOneWidget);
      await h.dispose(tester);
    });
  });

  group('Employees tab', () {
    testWidgets('counters; Unassigned cards have Assign; the Review dialog starts grey',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      seedLocations(h.remote, <WorkLocation>[_hq]);
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabEmployees);
      expect(_key('employeesSubToggle'), findsOneWidget);
      expect(_key('employeesCounter_assigned'), findsOneWidget);
      expect(_key('employeesCounter_groups'), findsOneWidget);
      await tester.tap(_key('employeesCounter_unassigned'));
      await h.settle(tester);
      expect(_key('employeeCard_me@co.com'), findsOneWidget);
      expect(_key('employeeAssign_me@co.com'), findsOneWidget);
      // 12/10/2026 (owner T2): Department sits inside the Filter popup.
      expect(_key('employeesDepartmentFilter'), findsNothing);
      await tester.tap(_key('employeesFilterButton'));
      await h.settle(tester);
      expect(_key('employeesDepartmentFilter'), findsOneWidget);
      await tester.tap(_key('employeesFilterApply'));
      await h.settle(tester);
      await tester.tap(_key('employeeAssign_me@co.com'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerGrantAccess), findsOneWidget);
      await tester.tap(_key('grantAccessButton'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerLocationRequired), findsOneWidget);
      expect(find.text(S.current.timeTrackerStartDateRequired), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('Assign / All Departments OFF: no Assign button, no Department filter, own department only',
        (WidgetTester tester) async {
      final TimeTrackerHarness h =
          TimeTrackerHarness(on: _without(<String>{'Assign_Employee', 'Employees_All_Departments'}));
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabEmployees);
      await tester.tap(_key('employeesCounter_unassigned'));
      await h.settle(tester);
      expect(_key('employeeCard_me@co.com'), findsOneWidget);
      expect(_key('employeeCard_sara@co.com'), findsNothing); // other department
      expect(_key('employeeAssign_me@co.com'), findsNothing);
      expect(_key('employeesDepartmentFilter'), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('Groups: + Group and the group cards; View Groups only → Groups first',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(
        on: <String>{'Group_Permissions', 'View_Groups', 'Create_Group'},
      );
      seedGroups(h.remote, const <EmployeeGroup>[
        EmployeeGroup(id: 'g1', name: 'Design Team', memberEmails: <String>['me@co.com'], locationId: 'hq'),
      ]);
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabEmployees);
      expect(_key('employeesSubToggle'), findsNothing);
      expect(_key('groupsAddButton'), findsOneWidget);
      expect(find.text('Design Team'), findsOneWidget);
      // Details: Create_Group only → no Edit / Delete.
      await tester.tap(_key('groupCard_g1'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerEmployeeInformation), findsOneWidget);
      expect(_key('groupEditButton'), findsNothing);
      expect(_key('groupDeleteButton'), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('+ Group form: Create Group grey; tap reveals name / members / location / date',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabEmployees);
      await tester.tap(_key('employeesCounter_groups'));
      await h.settle(tester);
      await tester.tap(_key('groupsAddButton'));
      await h.settle(tester);
      await tester.ensureVisible(_key('groupSubmitButton'));
      await tester.tap(_key('groupSubmitButton'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerNameRequired), findsOneWidget);
      expect(find.text(S.current.timeTrackerMembersRequired), findsOneWidget);
      expect(find.text(S.current.timeTrackerLocationRequired), findsOneWidget);
      expect(find.text(S.current.timeTrackerStartDateRequired), findsOneWidget);
      await h.dispose(tester);
    });
  });

  testWidgets('phone: Employees (+ Groups), Request Types and the Location form lay out',
      (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness();
    seedLocations(h.remote, <WorkLocation>[_hq]);
    seedRequestTypes(h.remote, const <RequestType>[RequestType(id: 't1', nameEn: 'Sick', nameAr: 'مرضية')]);
    seedGroups(h.remote, const <EmployeeGroup>[
      EmployeeGroup(id: 'g1', name: 'Design Team', memberEmails: <String>['me@co.com']),
    ]);
    await h.pump(tester, const TimeTrackerHomePage(), size: kTimeTrackerPhone);
    await _open(tester, h, S.current.timeTrackerTabEmployees);
    await tester.tap(_key('employeesCounter_unassigned'));
    await h.settle(tester);
    expect(_key('employeeCard_me@co.com'), findsOneWidget);
    await tester.tap(_key('employeesCounter_groups'));
    await h.settle(tester);
    expect(_key('groupCard_g1'), findsOneWidget);
    await _open(tester, h, S.current.timeTrackerTabRequestTypes);
    expect(_key('requestTypeCard_t1'), findsOneWidget);
    await _open(tester, h, S.current.timeTrackerTabLocations);
    await tester.tap(_key('locationsAddButton'));
    await h.settle(tester);
    expect(_key('locationSubmitButton'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });

  testWidgets('Arabic (RTL): Locations, Employees and Request Types build cleanly',
      (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness();
    seedLocations(h.remote, <WorkLocation>[_hq]);
    seedRequestTypes(h.remote, const <RequestType>[RequestType(id: 't1', nameEn: 'Sick', nameAr: 'مرضية')]);
    await h.pump(tester, const TimeTrackerHomePage(), locale: const Locale('ar'));
    final S ar = await S.load(const Locale('ar'));
    for (final String tab in <String>[
      ar.timeTrackerTabLocations,
      ar.timeTrackerTabEmployees,
      ar.timeTrackerTabRequestTypes,
    ]) {
      await _open(tester, h, tab);
      expect(tester.takeException(), isNull);
    }
    expect(find.text('مرضية'), findsOneWidget);
    await S.load(const Locale('en'));
    await h.dispose(tester);
  });
}
