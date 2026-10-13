/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: round6_groups_rules_test.dart
/// Purpose: Owner review + decisions 32–33 (9/10/2026) on the real screens:
///          the Create Group members picker (Search + Department on one
///          row, tick rows, "n selected", selected rows stay visible,
///          proper-case names), the bilingual name / description, the
///          location rules PREVIEW + "Use the location's rules" switch (group
///          form and the Assign dialog), and the "From location" / "Custom"
///          tag on employee cards. iPad + iPhone, English + Arabic (RTL), light
///          + dark; any overflow / exception fails.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/grant_access_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/location_rules_panel.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

const WorkLocation _hq = WorkLocation(
  id: 'hq',
  nameEn: 'Main Office',
  nameAr: 'المكتب الرئيسي',
  workStartMinutes: 8 * 60,
  workEndMinutes: 16 * 60,
  workingDays: <int>[7, 1, 2, 3, 4],
  lateAfterMinutes: 10,
  isBreakAllowed: true,
  breakMinutes: 30,
  isPauseAllowed: true,
);

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(
    email: 'me@co.com',
    nameEn: 'Bayanatz Transformation',
    nameAr: 'بيانات للتحول الرقمي',
    jobTitleEn: 'Digital Transformation Lead',
    departmentId: 'dep-1',
    departmentName: 'Administrative Affairs',
  ),
  TimeTrackerEmployee(
    email: 'khaled@co.com',
    nameEn: 'Khaled Abdelrahman',
    nameAr: 'خالد عبد الرحمن',
    jobTitleEn: 'Citizen Services Officer',
    departmentId: 'dep-1',
    departmentName: 'Administrative Affairs',
  ),
  // Stored lower-case: shown proper case (owner review).
  TimeTrackerEmployee(
    email: 'salma@co.com',
    nameEn: 'salma fathy',
    jobTitleEn: 'Designer',
    departmentId: 'dep-2',
    departmentName: 'Design',
  ),
];

Finder _key(String k) => find.byKey(ValueKey<String>(k));
Finder _tab(String label) => find.descendant(of: find.byType(CustomTabs), matching: find.text(label));

Future<void> _open(WidgetTester tester, TimeTrackerHarness h, String label) async {
  await tester.ensureVisible(_tab(label));
  await tester.pump();
  await tester.tap(_tab(label));
  await h.settle(tester);
}

Future<void> _openGroupForm(WidgetTester tester, TimeTrackerHarness h) async {
  await _open(tester, h, S.current.timeTrackerTabEmployees);
  await _tapIn(tester, h, _key('employeesCounter_groups'));
  await _tapIn(tester, h, _key('groupsAddButton'));
}

String _countText(WidgetTester tester) => tester.widget<Text>(_key('groupMembersCount')).data!;

String _expectedCount(WidgetTester tester, int n) {
  final BuildContext ctx = tester.element(_key('groupMembersCount'));
  return S.of(ctx).timeTrackerMembersSelected(TimeTrackerFormat.count(ctx, n));
}

/// Scroll [f] into view, then tap it.
Future<void> _tapIn(WidgetTester tester, TimeTrackerHarness h, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await h.settle(tester);
}

/// The harness cubits listen in the real zone (`runAsync`): let a write
/// made from the UI reach them, then rebuild.
Future<void> _sync(WidgetTester tester, TimeTrackerHarness h) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await h.settle(tester);
}

/// The real Cairo fonts, so line breaks / heights are the device's.
Future<void> _cairo() async {
  const String dir = 'assets/fonts/fonts_english/Cairo';
  for (final String family in <String>['Cairo', 'CairoArabic']) {
    final FontLoader loader = FontLoader(family);
    for (final String f in <String>['Cairo-Regular.ttf', 'Cairo-Medium.ttf', 'Cairo-SemiBold.ttf']) {
      final Uint8List bytes = File('$dir/$f').readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }
}

bool _ticked(WidgetTester tester, String email) =>
    tester.widget<CustomCheckBox>(_key('groupMemberTick_$email')).isSelected;

String _plain(WidgetTester tester, Finder f) =>
    tester.widgetList<RichText>(find.descendant(of: f, matching: find.byType(RichText)))
        .map((RichText t) => t.text.toPlainText())
        .join(' ');

LocationAssignment _stored(TimeTrackerHarness h, String email) => LocationAssignmentModel.fromMap(
    email, h.remote.store[TimeTrackerFirestorePaths.locationAssignments]![email]!);

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    await _cairo();
  });
  tearDown(() => AppColors.currentThemeColors = AppTheme.lightThemeColors);

  for (final (String name, Size size, Locale locale, bool dark) in <(String, Size, Locale, bool)>[
    ('iPad EN', kTimeTrackerTablet, const Locale('en'), false),
    ('iPad AR dark', kTimeTrackerTablet, const Locale('ar'), true),
    ('iPad portrait EN', const Size(820, 1180), const Locale('en'), false),
    ('iPhone EN dark', kTimeTrackerPhone, const Locale('en'), true),
    ('iPhone AR', kTimeTrackerPhone, const Locale('ar'), false),
  ]) {
    testWidgets('Create Group: members picker — search, department, tick, count ($name)',
        (WidgetTester tester) async {
      if (dark) AppColors.currentThemeColors = AppTheme.darkThemeColors;
      final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
      seedLocations(h.remote, <WorkLocation>[_hq]);
      await h.pump(tester, const TimeTrackerHomePage(), size: size, locale: locale);
      await _openGroupForm(tester, h);
      expect(tester.takeException(), isNull);
      // Search + Department share ONE row.
      expect(tester.getTopLeft(_key('groupMembersSearch')).dy,
          closeTo(tester.getTopLeft(_key('groupMembersDepartment')).dy, 4));
      expect(_countText(tester), _expectedCount(tester, 0));
      // Names in proper case, never lower-cased.
      if (locale.languageCode == 'en') {
        expect(tester.widget<Text>(_key('groupMemberName_salma@co.com')).data, 'Salma Fathy');
      }

      // Search narrows the list.
      await tester.enterText(find.descendant(of: _key('groupMembersSearch'), matching: find.byType(TextField)), 'khaled');
      await h.settle(tester);
      expect(_key('groupMemberRow_khaled@co.com'), findsOneWidget);
      expect(_key('groupMemberRow_salma@co.com'), findsNothing);

      // Tick → counted; it stays visible when the search changes.
      await _tapIn(tester, h, _key('groupMemberRow_khaled@co.com'));
      expect(_ticked(tester, 'khaled@co.com'), isTrue);
      expect(_countText(tester), _expectedCount(tester, 1));
      await tester.enterText(find.descendant(of: _key('groupMembersSearch'), matching: find.byType(TextField)), 'salma');
      await h.settle(tester);
      expect(_key('groupMemberRow_khaled@co.com'), findsOneWidget, reason: 'selected rows stay visible');
      expect(_key('groupMemberRow_salma@co.com'), findsOneWidget);
      await tester.enterText(find.descendant(of: _key('groupMembersSearch'), matching: find.byType(TextField)), '');
      await h.settle(tester);

      // Department filter: Design only (+ the selected row).
      tester.widget<CustomDropdown<String>>(_key('groupMembersDepartment')).onChanged!('dep-2');
      await h.settle(tester);
      expect(_key('groupMemberRow_salma@co.com'), findsOneWidget);
      expect(_key('groupMemberRow_me@co.com'), findsNothing);
      expect(_key('groupMemberRow_khaled@co.com'), findsOneWidget);

      // Untick: no longer selected → the Department filter hides it again.
      await _tapIn(tester, h, _key('groupMemberRow_khaled@co.com'));
      expect(_countText(tester), _expectedCount(tester, 0));
      expect(_key('groupMemberRow_khaled@co.com'), findsNothing);
      tester.widget<CustomDropdown<String>>(_key('groupMembersDepartment')).onChanged!('');
      await h.settle(tester);
      expect(_ticked(tester, 'khaled@co.com'), isFalse);
      expect(tester.takeException(), isNull);
      await h.dispose(tester);
    });

    testWidgets('Create Group: EN + AR names, rules preview and "Use the location\'s rules" ($name)',
        (WidgetTester tester) async {
      if (dark) AppColors.currentThemeColors = AppTheme.darkThemeColors;
      final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
      seedLocations(h.remote, <WorkLocation>[_hq]);
      await h.pump(tester, const TimeTrackerHomePage(), size: size, locale: locale);
      await _openGroupForm(tester, h);
      expect(_key('groupNameArField'), findsOneWidget);
      expect(_key('groupDescriptionArField'), findsOneWidget);
      // Arabic name required (Locations rule).
      await _tapIn(tester, h, _key('groupSubmitButton'));
      expect(find.text(S.current.timeTrackerArabicNameRequired), findsOneWidget);

      // No location yet → no preview; pick one → preview + switch ON.
      expect(_key('locationRulesPreview'), findsNothing);
      tester.widget<TtWorkLocationsField>(_key('groupLocationField')).onChanged('hq', const <String>[]);
      await h.settle(tester);
      expect(_key('locationRulesPreview'), findsOneWidget);
      final BuildContext ctx = tester.element(_key('locationRulesPreview'));
      final String preview = _plain(tester, _key('locationRulesPreview'));
      expect(preview, contains(LocationRulesText.summary(ctx, _hq)));
      expect(preview, contains(_hq.name(isArabic: locale.languageCode == 'ar')));
      expect(tester.widget<TtSwitchRow>(_key('useLocationRulesSwitch')).value, isTrue);
      expect(_key('rulesBreakSwitch'), findsNothing, reason: 'nothing to fill while the location rules apply');
      expect(_key('customRulesNote'), findsNothing);

      // OFF → custom fields, pre-filled from the location, labelled.
      tester.widget<TtSwitchRow>(_key('useLocationRulesSwitch')).onChanged(false);
      await h.settle(tester);
      expect(_key('customRulesNote'), findsOneWidget);
      expect(find.text(S.current.timeTrackerCustomRulesGroup), findsOneWidget);
      expect(_key('rulesBreakSwitch'), findsOneWidget);
      expect(find.descendant(of: _key('groupMembersField'), matching: find.byType(TextField)), findsOneWidget);
      // ON again → back to the preview only.
      tester.widget<TtSwitchRow>(_key('useLocationRulesSwitch')).onChanged(true);
      await h.settle(tester);
      expect(_key('customRulesNote'), findsNothing);
      expect(tester.takeException(), isNull);
      await h.dispose(tester);
    });
  }

  testWidgets('Assign dialog: preview + switch; ON saves "follow the location", OFF saves custom rules',
      (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
    seedLocations(h.remote, <WorkLocation>[_hq]);
    await h.pump(tester, const TimeTrackerHomePage());
    await _open(tester, h, S.current.timeTrackerTabEmployees);
    await _tapIn(tester, h, _key('employeesCounter_unassigned'));
    await _tapIn(tester, h, _key('employeeAssign_khaled@co.com'));
    tester.widget<TtWorkLocationsField>(_key('grantAccessLocation')).onChanged('hq', const <String>[]);
    tester.widget<CustomDropdownCalendar>(_key('grantAccessStartDate')).onChanged!(DateTime(2026, 10, 12));
    await h.settle(tester);
    expect(_key('locationRulesPreview'), findsOneWidget);
    expect(tester.widget<TtSwitchRow>(_key('useLocationRulesSwitch')).value, isTrue);
    expect(_key('rulesBreakSwitch'), findsNothing);
    await _tapIn(tester, h, _key('grantAccessButton'));
    LocationAssignment a = _stored(h, 'khaled@co.com');
    expect(a.locationId, 'hq');
    expect(a.rules.isCustom, isFalse, reason: 'nothing copied — the location\'s rules apply at read time');
    // Close "Access Granted" (its OK button).
    await _tapIn(tester, h, find.text(S.current.ok2).last);
    await _sync(tester, h);

    // Reassign with custom rules.
    await _tapIn(tester, h, _key('employeesCounter_assigned'));
    // 12/10/2026 (owner T3): rules from the location → no "Custom" ribbon.
    expect(_key('employeeRules_khaled@co.com'), findsOneWidget);
    expect(_key('employeeCustomRibbon_khaled@co.com'), findsNothing);
    await _tapIn(tester, h, _key('employeeReassign_khaled@co.com'));
    tester.widget<TtSwitchRow>(_key('useLocationRulesSwitch')).onChanged(false);
    await h.settle(tester);
    expect(_key('customRulesNote'), findsOneWidget);
    expect(find.text(S.current.timeTrackerCustomRulesEmployee), findsOneWidget);
    expect(_key('rulesBreakSwitch'), findsOneWidget);
    await _tapIn(tester, h, _key('grantAccessButton'));
    a = _stored(h, 'khaled@co.com');
    expect(a.rules.isCustom, isTrue);
    expect(a.rules.isBreakAllowed, isTrue, reason: 'pre-filled from the location');
    expect(a.rules.breakMinutes, 30);
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });

  testWidgets('employee cards: the effective rules line + the "Custom" corner ribbon only for custom rules (AR, phone)',
      (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
    seedAssignment(h.remote, location: _hq, email: 'khaled@co.com', rules: AttendanceRules.fromLocation,
        startDate: DateTime(2026, 10, 1));
    seedAssignment(h.remote, location: _hq, email: 'me@co.com',
        rules: const AttendanceRules(isBreakAllowed: true, breakMinutes: 15), startDate: DateTime(2026, 10, 1));
    await h.pump(tester, const TimeTrackerHomePage(), size: kTimeTrackerPhone, locale: const Locale('ar'));
    await _open(tester, h, S.current.timeTrackerTabEmployees);
    // 12/10/2026 (owner T3): "From location" shows no tag; "Custom" is a
    // corner ribbon on the card.
    await tester.ensureVisible(_key('employeeRules_khaled@co.com'));
    expect(_key('employeeCustomRibbon_khaled@co.com'), findsNothing);
    await tester.ensureVisible(_key('employeeRules_me@co.com'));
    expect(_key('employeeCustomRibbon_me@co.com'), findsOneWidget);
    expect(find.descendant(of: _key('employeeCustomRibbon_me@co.com'), matching: find.byType(Banner)), findsOneWidget);
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });
}
