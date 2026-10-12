/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: qa_group_location_rules_test.dart
/// Purpose: QA KP-TT-008 (9/10/2026), re-checked on the round-6 group form:
///          the group takes the chosen location's break / pause rules —
///          "Use the location's rules" ON follows the location (nothing
///          copied); OFF starts from the location's values, and untouched
///          custom values follow a NEWLY chosen location (like Grant Access);
///          values edited by hand are kept.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/controller/group_form_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

/// "Head Office — Riyadh": breaks 30, pause allowed.
const WorkLocation _riyadh = WorkLocation(
  id: 'riyadh',
  nameEn: 'Head Office — Riyadh',
  nameAr: 'المكتب الرئيسي — الرياض',
  workStartMinutes: 8 * 60,
  workEndMinutes: 16 * 60,
  workingDays: <int>[7, 1, 2, 3, 4],
  isBreakAllowed: true,
  breakMinutes: 30,
  isPauseAllowed: true,
);

/// "Citizen Services Center — Jeddah": breaks 45, NO pause.
const WorkLocation _jeddah = WorkLocation(
  id: 'jeddah',
  nameEn: 'Citizen Services Center — Jeddah',
  nameAr: 'مركز خدمات المواطنين — جدة',
  workStartMinutes: 10 * 60,
  workEndMinutes: 18 * 60,
  isBreakAllowed: true,
  breakMinutes: 45,
);

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Bayanatz Transformation', departmentId: 'dep-1'),
  TimeTrackerEmployee(email: 'salma@co.com', nameEn: 'Salma Fathy', departmentId: 'dep-1'),
];

Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<void> _tapIn(WidgetTester tester, TimeTrackerHarness h, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await h.settle(tester);
}

/// The real Cairo fonts, so widths are the device's (as in round6 tests).
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

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    await _cairo();
  });

  testWidgets('KP-TT-008: the group form takes the chosen location\'s break / pause rules', (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
    seedLocations(h.remote, <WorkLocation>[_riyadh, _jeddah]);
    await h.pump(tester, const TimeTrackerHomePage(), size: const Size(820, 1180));
    final Finder tab = find.descendant(of: find.byType(CustomTabs), matching: find.text(S.current.timeTrackerTabEmployees));
    await _tapIn(tester, h, tab);
    await _tapIn(tester, h, _key('employeesCounter_groups'));
    await _tapIn(tester, h, _key('groupsAddButton'));
    GroupFormCubit form() => BlocProvider.of<GroupFormCubit>(tester.element(_key('groupLocationField')));
    void pick(String id) => tester.widget<CustomDropdown<String>>(_key('groupLocationField')).onChanged!(id);

    // Jeddah chosen, "Use the location's rules" ON (default): the group
    // follows the location — what the members get is Jeddah's own rules.
    pick('jeddah');
    await h.settle(tester);
    expect(tester.widget<TtSwitchRow>(_key('useLocationRulesSwitch')).value, isTrue);
    expect(form().state.draft.rules.isCustom, isFalse, reason: 'follows the location, nothing copied');

    // OFF → custom fields start from Jeddah: breaks 45, no pause.
    tester.widget<TtSwitchRow>(_key('useLocationRulesSwitch')).onChanged(false);
    await h.settle(tester);
    AttendanceRules r = form().state.draft.rules;
    expect(r.isCustom, isTrue);
    expect(<Object>[r.isBreakAllowed, r.breakMinutes, r.isPauseAllowed], <Object>[true, 45, false]);

    // A NEW location while the custom values are untouched → they follow it
    // (they used to keep Jeddah's values — "pause OFF" for Riyadh).
    pick('riyadh');
    await h.settle(tester);
    r = form().state.draft.rules;
    expect(r.isCustom, isTrue);
    expect(<Object>[r.isBreakAllowed, r.breakMinutes, r.isPauseAllowed], <Object>[true, 30, true]);

    // Edited by hand → kept when the location changes again.
    tester.widget<TtSwitchRow>(_key('rulesPauseSwitch')).onChanged(false);
    await h.settle(tester);
    pick('jeddah');
    await h.settle(tester);
    r = form().state.draft.rules;
    expect(r.isPauseAllowed, isFalse);
    expect(r.breakMinutes, 30, reason: 'the admin\'s custom rules are not overwritten');
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });
}
