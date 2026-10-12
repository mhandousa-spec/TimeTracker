/// Module: test / time_tracker / presentation / ui_pass
///
///*************************** FILE INFO ****************************///
/// File Name: ui_pass_components_test.dart
/// Purpose: The redesigned components of the UI quality pass (9/10/2026),
///          checked with the real Cairo fonts over the demo data: one-line
///          neutral stat labels, the employee card (one action, red trash),
///          cards that hug their content, one height + gap on the HR filter
///          row, the new filters, red Delete, the status switch inside Edit,
///          capitalised export names and proper-case names.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_stats_card.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/ui/widgets/attendance_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/pages/location_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/pages/request_type_details_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../../_support/time_tracker_widget_harness.dart';
import '../../_support/tt_demo_seed.dart';
import '../../_support/tt_shots.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<TimeTrackerHarness> _pump(WidgetTester tester, TtDevice d, {String locale = 'en'}) async {
  setTtTheme(dark: false, locale: locale);
  addTearDown(() => setTtTheme(dark: false, locale: 'en'));
  final TimeTrackerHarness h = ttDemoHarness();
  await seedTtDemo(tester, h, isArabic: locale == 'ar');
  await h.pump(tester, const TimeTrackerHomePage(),
      size: d.size, designSize: d.designSize, frame: ttFrame(d), locale: Locale(locale));
  return h;
}

/// Every text under [of] fits on its lines (no "…", no clipped line).
void _noEllipsis(WidgetTester tester, Finder of, {String reason = ''}) {
  for (final Element e in find.descendant(of: of, matching: find.byType(RichText)).evaluate()) {
    final RenderParagraph p = e.renderObject! as RenderParagraph;
    expect(p.didExceedMaxLines, isFalse, reason: '$reason "${p.text.toPlainText()}" is cut');
  }
}

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    await loadTtFonts();
  });

  for (final (TtDevice d, String l) in <(TtDevice, String)>[
    (kIpadV, 'en'),
    (kIpad11V, 'en'),
    (kIpad11V, 'ar'),
    (kIphone, 'en'),
    (kIphone, 'ar'),
  ]) {
    testWidgets('stat tiles: every label on ONE line, neutral colour (${d.name} $l)', (WidgetTester tester) async {
      final TimeTrackerHarness h = await _pump(tester, d, locale: l);
      Future<void> check(Finder card) async {
        expect(card, findsOneWidget);
        final TtStatsCard widget = tester.widget<TtStatsCard>(card);
        for (final TtStat s in widget.stats) {
          final Finder label = find.descendant(of: card, matching: find.text(s.label));
          expect(label, findsOneWidget, reason: s.label);
          final RenderParagraph p = tester.renderObject<RenderParagraph>(
            find.descendant(of: label, matching: find.byType(RichText)),
          );
          final double line = p.getFullHeightForCaret(const TextPosition(offset: 0));
          expect((p.size.height / line).round(), 1, reason: '"${s.label}" wraps');
          expect(p.didExceedMaxLines, isFalse, reason: '"${s.label}" is cut');
          final Color? color = (tester.widget<Text>(label).style ?? const TextStyle()).color;
          expect(color, AppColors.secondaryText, reason: '"${s.label}" must be neutral');
        }
        // iPhone: two tiles share a row (never one long tile per row).
        if (d == kIphone && widget.stats.length > 1) {
          final double first = tester.getTopLeft(find.descendant(of: card, matching: find.text(widget.stats[0].label))).dy;
          final double second = tester.getTopLeft(find.descendant(of: card, matching: find.text(widget.stats[1].label))).dy;
          expect(second, closeTo(first, 1), reason: 'tiles 1 and 2 on one row');
        }
      }

      await check(_key('timeTrackerOverallCard'));
      h.hrDashboard!.setShowHr(true);
      await h.settle(tester);
      await check(_key('hrKpiStrip'));
      expect(tester.takeException(), isNull);
      await h.dispose(tester);
    });
  }

  for (final String l in <String>['en', 'ar']) {
    testWidgets('iPhone rule: no table and no List / Grid toggle on any tab ($l)', (WidgetTester tester) async {
      final TimeTrackerHarness h = await _pump(tester, kIphone, locale: l);
      for (final TimeTrackerTab tab in <TimeTrackerTab>[
        TimeTrackerTab.attendance,
        TimeTrackerTab.requests,
        TimeTrackerTab.approvals,
        TimeTrackerTab.requestTypes,
        TimeTrackerTab.locations,
        TimeTrackerTab.employees,
        TimeTrackerTab.vacationBalances,
      ]) {
        h.home.selectTab(tab);
        await h.settle(tester);
        expect(find.byType(TimeTrackerTable), findsNothing, reason: tab.name);
        expect(find.byType(AttendanceTableView), findsNothing, reason: tab.name);
        expect(
          find.byWidgetPredicate((Widget w) {
            final Key? k = w.key;
            return k is ValueKey<String> && (k.value.endsWith('TableToggle') || k.value.endsWith('GridToggle'));
          }),
          findsNothing,
          reason: tab.name,
        );
        if (tab == TimeTrackerTab.vacationBalances) {
          // The Year selector stays on a phone (its own row with Department).
          expect(_key('vacationYearFilter'), findsOneWidget);
          expect(_key('vacationDepartmentFilter'), findsOneWidget);
          expect(tester.getTopLeft(_key('vacationYearFilter')).dy,
              closeTo(tester.getTopLeft(_key('vacationDepartmentFilter')).dy, 1));
        }
      }
      // The collapsed check-in control sits under the title: one title line.
      final RenderParagraph title = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.text(S.current.timeTrackerTitle), matching: find.byType(RichText)),
      );
      final double line = title.getFullHeightForCaret(const TextPosition(offset: 0));
      expect((title.size.height / line).round(), 1, reason: 'title wraps');
      expect(tester.takeException(), isNull);
      await h.dispose(tester);
    });
  }

  for (final (TtDevice d, String l) in <(TtDevice, String)>[
    (kIpadH, 'en'),
    (kIpadH, 'ar'),
    (kIpadV, 'en'),
    (kIphone, 'ar'),
  ]) {
    testWidgets('request type + vacation cards: nothing cut, no word split (${d.name} $l)', (WidgetTester tester) async {
      final TimeTrackerHarness h = await _pump(tester, d, locale: l);
      Future<void> check(TimeTrackerTab tab, String gridKey, String cardPrefix) async {
        h.home.selectTab(tab);
        await h.settle(tester);
        final Finder cards = find.byWidgetPredicate((Widget w) {
          final Key? k = w.key;
          return k is ValueKey<String> && k.value.startsWith(cardPrefix);
        });
        expect(cards, findsWidgets, reason: tab.name);
        // A card is never narrower than the grid's minimum (Figma ~270).
        expect(tester.getSize(cards.first).width, greaterThanOrEqualTo(TtCardGrid.minCardWidth - 1));
        for (final Element card in cards.evaluate()) {
          _noEllipsis(tester, find.byElementPredicate((Element e) => e == card), reason: tab.name);
          for (final Element t in find
              .descendant(of: find.byElementPredicate((Element e) => e == card), matching: find.byType(RichText))
              .evaluate()) {
            final RenderParagraph p = t.renderObject! as RenderParagraph;
            final String text = p.text.toPlainText().trim();
            if (text.isEmpty || text.contains(' ')) continue;
            final double line = p.getFullHeightForCaret(const TextPosition(offset: 0));
            expect((p.size.height / line).round(), 1, reason: '"$text" is split mid-word');
          }
        }
      }

      await check(TimeTrackerTab.requestTypes, 'requestTypesGrid', 'requestTypeCard_');
      await check(TimeTrackerTab.vacationBalances, 'vacationGrid', 'vacationCard_');
      expect(tester.takeException(), isNull);
      await h.dispose(tester);
    });
  }

  testWidgets('HR filter row: one height + radius, ONE gap between every control (11" iPad)', (WidgetTester tester) async {
    final TimeTrackerHarness h = await _pump(tester, kIpad11V);
    h.hrDashboard!.setShowHr(true);
    await h.settle(tester);
    final List<Rect> rects = <Rect>[
      tester.getRect(_key('hrEmployeeButton')),
      tester.getRect(_key('hrDepartmentFilter')),
      tester.getRect(_key('hrLocationFilter')),
      tester.getRect(_key('hrRangeMenu')),
      tester.getRect(_key('hrExportButton')),
    ];
    for (final Rect r in rects) {
      expect(r.height, closeTo(rects.last.height, 1.5));
      expect(r.center.dy, closeTo(rects.last.center.dy, 1.5));
    }
    final List<double> gaps = <double>[for (int i = 1; i < rects.length; i++) rects[i].left - rects[i - 1].right];
    for (final double g in gaps) {
      expect(g, greaterThan(8));
      expect(g, closeTo(gaps.first, 1.5));
    }
    await h.dispose(tester);
  });

  testWidgets('employee card: one primary action, Remove = red trash; nothing cut; proper case', (WidgetTester tester) async {
    final TimeTrackerHarness h = await _pump(tester, kIpad11V);
    h.home.selectTab(TimeTrackerTab.employees);
    await h.settle(tester);
    const String salma = 'salma.fathy@dm003.test';
    final Finder card = _key('employeeCard_$salma');
    await tester.ensureVisible(card);
    await tester.pump();
    expect(find.descendant(of: card, matching: find.byType(EmployeeCardAction)), findsOneWidget);
    expect(find.descendant(of: card, matching: find.byType(EmployeeCardRemove)), findsOneWidget);
    final Container trash = tester.widget<Container>(
      find.descendant(of: _key('employeeRemove_$salma'), matching: find.byType(Container)).first,
    );
    expect((trash.decoration! as BoxDecoration).color, AppColors.red);
    // Stored "salma fathy" / "service center coordinator" read in proper case.
    expect(find.descendant(of: card, matching: find.text('Salma Fathy')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('Service Center Coordinator')), findsOneWidget);
    _noEllipsis(tester, card, reason: 'employee card');
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });

  testWidgets('Arabic UI: the department in Arabic (QA KP-TT-017)', (WidgetTester tester) async {
    final TimeTrackerHarness h = await _pump(tester, kIpad11V, locale: 'ar');
    h.home.selectTab(TimeTrackerTab.employees);
    await h.settle(tester);
    final Finder card = _key('employeeCard_salma.fathy@dm003.test');
    await tester.ensureVisible(card);
    await tester.pump();
    expect(find.descendant(of: card, matching: find.textContaining('خدمات المواطنين', findRichText: true)), findsWidgets);
    expect(find.descendant(of: card, matching: find.textContaining('Citizen Services', findRichText: true)), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('cards hug their content: a grid row is exactly as tall as its tallest card', (WidgetTester tester) async {
    final TimeTrackerHarness h = await _pump(tester, kIpadV);
    h.home.selectTab(TimeTrackerTab.requestTypes);
    await h.settle(tester);
    final Finder grid = _key('requestTypesGrid');
    expect(tester.widget(grid), isA<TtCardGrid>());
    final Rect annual = tester.getRect(_key('requestTypeCard_${TtDemoIds.annual}'));
    // Figma 661:35833 card ≈ 182 px at 270 wide; never the old 236.h × 1.33.
    expect(annual.height, lessThan(annual.width * 0.62));
    expect(annual.height, greaterThan(150));
    await h.dispose(tester);
  });

  testWidgets('location details: assigned employees are the Employees-tab card (Message); Delete red; status in Edit',
      (WidgetTester tester) async {
    final TimeTrackerHarness h = await _pump(tester, kIpadV);
    final NavigatorState nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaterialPageRoute<void>(builder: (_) => const LocationDetailsPage(locationId: TtDemoIds.headquarters)));
    await h.settle(tester);
    expect(find.byType(EmployeeCard), findsWidgets);
    expect(_key('locationStatusSwitch'), findsNothing);
    final CustomDeleteIcon delete = tester.widget<CustomDeleteIcon>(
      find.descendant(of: _key('locationDeleteButton'), matching: find.byType(CustomDeleteIcon)),
    );
    expect(delete.color, AppColors.red);
    expect(delete.svgColor, AppColors.white);
    await tester.tap(_key('locationEditButton'));
    await h.settle(tester);
    expect(_key('locationStatusSwitch'), findsOneWidget);
    nav.pop();
    await h.settle(tester);
    nav.pop();
    await h.settle(tester);
    nav.push(MaterialPageRoute<void>(builder: (_) => const RequestTypeDetailsPage(typeId: TtDemoIds.sick)));
    await h.settle(tester);
    expect(_key('requestTypeStatusSwitch'), findsNothing);
    expect(
      tester.widget<CustomDeleteIcon>(find.descendant(of: _key('requestTypeRemoveButton'), matching: find.byType(CustomDeleteIcon))).color,
      AppColors.red,
    );
    await tester.tap(_key('requestTypeEditButton'));
    await h.settle(tester);
    expect(_key('requestTypeActiveSwitch'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('filters: Requests = Request Type · Status · From–To (no Day / Total Time); invalid range greys Apply',
      (WidgetTester tester) async {
    final TimeTrackerHarness h = await _pump(tester, kIpadV);
    h.home.selectTab(TimeTrackerTab.requests);
    await h.settle(tester);
    await tester.tap(_key('requestsFilterButton'));
    await h.settle(tester);
    for (final String label in <String>[
      S.current.timeTrackerRequestType,
      S.current.timeTrackerStatus,
      S.current.timeTrackerDateFrom,
      S.current.timeTrackerDateTo,
    ]) {
      expect(find.textContaining(label, findRichText: true), findsWidgets, reason: label);
    }
    expect(find.text(S.current.timeTrackerFilterDay), findsNothing);
    expect(find.text(S.current.timeTrackerTotalTime), findsNothing);
    expect(find.text(S.current.timeTrackerDepartment), findsNothing); // Approvals only
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await h.settle(tester);
    h.home.selectTab(TimeTrackerTab.attendance);
    await h.settle(tester);
    await tester.tap(_key('attendanceFilterButton'));
    await h.settle(tester);
    for (final String label in <String>[
      S.current.timeTrackerStatus,
      S.current.timeTrackerWorkLocationType,
      S.current.timeTrackerDateFrom,
      S.current.timeTrackerDateTo,
    ]) {
      expect(find.textContaining(label, findRichText: true), findsWidgets, reason: label);
    }
    expect(find.text(S.current.timeTrackerFilterDay), findsNothing);
    await h.dispose(tester);
  });

  for (final String l in <String>['en', 'ar']) {
    testWidgets('day counts with the right noun: "1 Day", "يومان", "٤ أيام", "١٥ يوما" ($l)', (WidgetTester tester) async {
      setTtTheme(dark: false, locale: l);
      addTearDown(() => setTtTheme(dark: false, locale: 'en'));
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        locale: Locale(l),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(builder: (BuildContext c) {
          ctx = c;
          return const SizedBox();
        }),
      ));
      await tester.pumpAndSettle();
      final Map<int, String> expected = l == 'en'
          ? <int, String>{0: '0 Days', 1: '1 Day', 2: '2 Days', 4: '4 Days', 15: '15 Days', 100: '100 Days'}
          : <int, String>{0: '٠ يوم', 1: 'يوم واحد', 2: 'يومان', 4: '٤ أيام', 15: '١٥ يوما', 100: '١٠٠ يوم', 103: '١٠٣ أيام'};
      expected.forEach((int n, String text) => expect(TimeTrackerFormat.days(ctx, n), text, reason: '$n'));
      final Map<int, String> absences = l == 'en'
          ? <int, String>{1: '1 absence', 3: '3 absences', 12: '12 absences'}
          : <int, String>{1: 'غياب واحد', 2: 'غيابان', 3: '٣ غيابات', 12: '١٢ غيابا'};
      absences.forEach((int n, String text) => expect(TimeTrackerFormat.absences(ctx, n), text, reason: 'absences $n'));
    });
  }

  test('export default file names are capitalised (owner 13:45 #2)', () async {
    await S.load(const Locale('en'));
    for (final String name in <String>[
      S.current.timeTrackerAttendanceExportName,
      S.current.timeTrackerRequestsExportName,
      S.current.timeTrackerLocationsExportName,
      S.current.timeTrackerEmployeesExportName,
      S.current.timeTrackerRequestTypesExportName,
      S.current.timeTrackerHrDashboardExportName,
      S.current.timeTrackerVacationBalancesExportName,
    ]) {
      expect(name[0], name[0].toUpperCase(), reason: name);
      expect(name.contains('_'), isFalse, reason: name);
    }
  });
}
