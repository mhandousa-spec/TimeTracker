/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: owner_review_cards_test.dart
/// Purpose: Owner review (9/10/2026, Vacation Balances on iPad portrait) —
///          a long realistic name is never cut with "…" next to a card
///          action; Edit is an icon-only square; toolbar Search / Department
///          / Export / Import share one height + radius; the unselected LIST
///          toggle looks like the unselected GRID toggle.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// The real Cairo fonts are loaded so line breaks are the device's. Every
/// layout: iPad portrait / landscape and iPhone, English and Arabic; any
/// overflow fails the test (`takeException`).

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_filter_frame.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

const Size _ipadV = Size(820, 1180);
const Size _ipadH = Size(1180, 820);

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(
    email: 'me@co.com',
    nameEn: 'Bayanatz Transformation',
    nameAr: 'بيانات للتحول الرقمي',
    jobTitleEn: 'Digital Transformation Lead',
    jobTitleAr: 'قائد التحول الرقمي',
    departmentId: 'dep-1',
    departmentName: 'Administrative Affairs',
  ),
  TimeTrackerEmployee(
    email: 'khaled@co.com',
    nameEn: 'Khaled Abdelrahman',
    nameAr: 'خالد عبد الرحمن',
    jobTitleEn: 'Citizen Services Officer',
    jobTitleAr: 'موظف خدمة المواطنين',
    departmentId: 'dep-1',
    departmentName: 'Citizen Services',
  ),
];

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office', nameAr: 'المكتب الرئيسي');

Finder _key(String k) => find.byKey(ValueKey<String>(k));
Finder _tab(String label) => find.descendant(of: find.byType(CustomTabs), matching: find.text(label));

Future<void> _font(String family, List<String> files) async {
  final FontLoader loader = FontLoader(family);
  for (final String f in files) {
    final Uint8List bytes = File(f).readAsBytesSync();
    loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<void> _open(WidgetTester tester, TimeTrackerHarness h, String label) async {
  await tester.ensureVisible(_tab(label));
  await tester.pump();
  await tester.tap(_tab(label));
  await h.settle(tester);
}

/// The text under [key] fits its lines (no "…").
void _fits(WidgetTester tester, String key) {
  final RenderParagraph p = tester.renderObject<RenderParagraph>(
    find.descendant(of: _key(key), matching: find.byType(RichText)).first,
  );
  expect(p.didExceedMaxLines, isFalse, reason: '$key is cut with "…"');
}

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    const String cairo = 'assets/fonts/fonts_english/Cairo';
    final List<String> files = <String>['$cairo/Cairo-Regular.ttf', '$cairo/Cairo-Medium.ttf', '$cairo/Cairo-SemiBold.ttf'];
    await _font('Cairo', files);
    await _font('CairoArabic', files);
  });

  for (final (String name, Size size, Locale locale) in <(String, Size, Locale)>[
    ('iPad portrait EN', _ipadV, const Locale('en')),
    ('iPad portrait AR', _ipadV, const Locale('ar')),
    ('iPad landscape EN', _ipadH, const Locale('en')),
    ('iPhone EN', kTimeTrackerPhone, const Locale('en')),
    ('iPhone AR', kTimeTrackerPhone, const Locale('ar')),
  ]) {
    testWidgets('Vacation Balances card: full name, icon-only Edit, no overflow ($name)', (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
      seedBalance(h.remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21, usedDays: 6));
      await h.pump(tester, const TimeTrackerHomePage(), size: size, locale: locale);
      await _open(tester, h, S.current.timeTrackerTabVacationBalances);
      expect(tester.takeException(), isNull);
      _fits(tester, 'vacationName_me@co.com');
      _fits(tester, 'vacationName_khaled@co.com');
      // Edit is the icon-only square, not the text button.
      expect(tester.widget(_key('vacationEdit_me@co.com')), isA<TtIconEditButton>());
      expect(find.descendant(of: _key('vacationCard_me@co.com'), matching: find.text(S.current.edit)), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('Employees cards: full name next to the actions, no overflow ($name)', (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
      seedAssignment(h.remote, location: _hq, email: 'khaled@co.com', startDate: DateTime(2026, 10, 1));
      await h.pump(tester, const TimeTrackerHomePage(), size: size, locale: locale);
      await _open(tester, h, S.current.timeTrackerTabEmployees);
      expect(tester.takeException(), isNull);
      _fits(tester, 'employeeName_khaled@co.com');
      await tester.tap(_key('employeesCounter_unassigned'));
      await h.settle(tester);
      expect(tester.takeException(), isNull);
      _fits(tester, 'employeeName_me@co.com');
      await h.dispose(tester);
    });
  }

  testWidgets('toolbar: Search, Department, Export, Import share one height + radius', (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
    await h.pump(tester, const TimeTrackerHomePage(), size: _ipadV);
    await _open(tester, h, S.current.timeTrackerTabVacationBalances);
    // 13/10/2026 (owner): Department is multi-select.
    final TtToolbarMultiFilter dept = tester.widget<TtToolbarMultiFilter>(_key('vacationDepartmentFilter'));
    expect(dept.hint, S.current.timeTrackerDepartment);
    final double searchH = tester.getSize(find.byType(TextField).first).height;
    final double deptH = tester.getSize(_key('vacationDepartmentFilter')).height;
    final double exportH = tester.getSize(_key('vacationExportButton')).height;
    final double importH = tester.getSize(_key('vacationImportButton')).height;
    expect(deptH, closeTo(exportH, 1));
    expect(importH, closeTo(exportH, 1));
    expect(searchH, lessThanOrEqualTo(exportH + 1));
    await h.dispose(tester);
  });

  testWidgets('list / card toggle: unselected LIST looks like unselected GRID', (WidgetTester tester) async {
    final TimeTrackerHarness h = TimeTrackerHarness(people: _people);
    await h.pump(tester, const TimeTrackerHomePage(), size: _ipadV);
    await _open(tester, h, S.current.timeTrackerTabVacationBalances);
    Color fillOf(String key) {
      final Container box = tester.widget<Container>(
        find.descendant(of: _key(key), matching: find.byType(Container)).first,
      );
      return (box.decoration! as BoxDecoration).color!;
    }

    // Grid selected → the LIST button is the unselected one.
    final Color listOff = fillOf('vacationTableToggle');
    await tester.tap(_key('vacationTableToggle'));
    await h.settle(tester);
    final Color gridOff = fillOf('vacationGridToggle');
    expect(listOff, gridOff);
    expect(listOff, AppColors.card);
    expect(fillOf('vacationTableToggle'), AppColors.primary);
    await h.dispose(tester);
  });
}
