/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: ui_fix_round1_test.dart
/// Purpose: Widget tests for the owner's UI fix round 1 (iPad review,
///          9/10/2026): the two-option toggles in their own container, the
///          Overall / legend / info-strip labels never ending in "…", the
///          icon-only Filter / Export on every toolbar, the centred search
///          text, the Figma table colours (light + dark), the yellow Upload
///          buttons, the Approvals employee picker (search + Department on
///          one row, no "All Employees", tap again = all), one start edge
///          for the page (iPad H / V, iPhone, Arabic), the tab strip that
///          keeps the selected tab in view, the dark-mode Pause label and a
///          semantics-on smoke run over every tab.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// The real Cairo fonts are loaded (this file's isolate only), so text
/// widths and line boxes are the app's, not the square test font's.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office', nameAr: 'المكتب الرئيسي');
const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick Leave', nameAr: 'إجازة مرضية');

/// iPad Air 11" in both orientations, and an iPhone.
const Size _ipadH = Size(1180, 820);
const Size _ipadV = Size(820, 1180);

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

TimeTrackerRequest _req(String id, RequestStatus status, {String who = 'me@co.com', String manager = 'boss@co.com'}) =>
    TimeTrackerRequest(
      id: id,
      requesterEmail: who,
      requesterDepartmentId: 'dep-1',
      requestTypeId: 'sick',
      startAt: DateTime(2026, 10, 12),
      endAt: DateTime(2026, 10, 14, 23, 59),
      isAllDay: true,
      totalMinutes: 3 * 1440,
      status: status,
      approvalSteps: <RequestApprovalStep>[
        RequestApprovalStep(
          step: ApprovalStepKind.manager,
          approverEmail: manager,
          decision: status == RequestStatus.pending ? ApprovalDecision.pending : ApprovalDecision.approved,
        ),
      ],
      currentStep: status == RequestStatus.pending ? ApprovalStepKind.manager : null,
    );

TimeTrackerHarness _harness() {
  final TimeTrackerHarness h = TimeTrackerHarness();
  seedAssignment(h.remote, location: _hq, rules: const AttendanceRules(isPauseAllowed: true));
  seedRequestTypes(h.remote, <RequestType>[_sick]);
  seedRequests(h.remote, <TimeTrackerRequest>[
    _req('p1', RequestStatus.pending),
    _req('ok', RequestStatus.approved),
    _req('amr', RequestStatus.pending, who: 'amr@co.com', manager: 'me@co.com'),
    _req('sara', RequestStatus.pending, who: 'sara@co.com', manager: 'me@co.com'),
  ]);
  return h;
}

Future<void> _open(WidgetTester tester, TimeTrackerHarness h, String label) async {
  await tester.ensureVisible(_tab(label));
  await tester.pump();
  await tester.tap(_tab(label));
  await h.settle(tester);
}

/// A Filter / Export key is the module icon button: the Figma icon, no label.
void _expectIconOnly(WidgetTester tester, String key, {required bool filter}) {
  expect(_key(key), findsOneWidget, reason: key);
  expect(tester.widget(_key(key)), filter ? isA<TtFilterButton>() : isA<TtExportButton>(), reason: key);
  final String icon = filter ? TtAssets.filter : TtAssets.export;
  expect(
    find.descendant(
      of: _key(key),
      matching: find.byWidgetPredicate((Widget w) => w is CustomSvgImage && w.assetPath == icon),
    ),
    findsOneWidget,
    reason: '$key draws $icon',
  );
  expect(find.descendant(of: _key(key), matching: find.text(S.current.filter)), findsNothing, reason: key);
  expect(find.descendant(of: _key(key), matching: find.text(S.current.export)), findsNothing, reason: key);
}

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    const String cairo = 'assets/fonts/fonts_english/Cairo';
    final List<String> files = <String>[
      '$cairo/Cairo-Regular.ttf',
      '$cairo/Cairo-Medium.ttf',
      '$cairo/Cairo-SemiBold.ttf',
    ];
    await _font('Cairo', files);
    await _font('CairoArabic', files);
  });

  group('finding 1 — two-option toggles sit in their own container', () {
    testWidgets('Counts / Minutes: page-colour container inside the card; tap switches', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadH);
      final CustomSegmentedTabs tabs = tester.widget<CustomSegmentedTabs>(
        find.descendant(of: _key('timeTrackerLateModeToggle'), matching: find.byType(CustomSegmentedTabs)),
      );
      expect(tabs.containerColor, AppColors.background);
      expect(tabs.containerColor, isNot(AppColors.card), reason: 'must show on the white card');
      expect(tabs.selectedColor, AppColors.primary);
      await tester.tap(find.text(S.current.timeTrackerCounts));
      await h.settle(tester);
      expect(h.dashboard.state.lateMode.name, 'counts');
      await h.dispose(tester);
    });

    testWidgets('Employees | Locations: card-colour container on the page', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadH);
      await _open(tester, h, S.current.timeTrackerTabEmployees);
      final CustomSegmentedTabs tabs = tester.widget<CustomSegmentedTabs>(
        find.descendant(of: _key('employeesSubToggle'), matching: find.byType(CustomSegmentedTabs)),
      );
      expect(tabs.containerColor, AppColors.card);
      expect(tabs.containerColor, isNot(AppColors.background), reason: 'must show on the grey page');
      await h.dispose(tester);
    });
  });

  group('finding 2 / 10 — labels never end in "…"', () {
    for (final MapEntry<String, Size> size in <String, Size>{'iPad V': _ipadV, 'iPhone': kTimeTrackerPhone}.entries) {
      testWidgets('Vacations Credit + donut legends read in full (${size.key})', (WidgetTester tester) async {
        final TimeTrackerHarness h = _harness();
        await h.pump(tester, const TimeTrackerHomePage(), size: size.value);
        final Text label = tester.widget<Text>(find.text(S.current.timeTrackerVacationsCredit));
        expect(label.overflow, isNot(TextOverflow.ellipsis));
        final RenderParagraph p =
            tester.renderObject<RenderParagraph>(find.text(S.current.timeTrackerVacationsCredit));
        expect(p.didExceedMaxLines, isFalse);
        for (final DonutChartCard card in tester.widgetList<DonutChartCard>(find.byType(DonutChartCard))) {
          expect(card.legendMaxLines, 2, reason: card.title);
        }
        await h.dispose(tester);
      });
    }

    testWidgets('iPad V: the empty Work Locations legend is not cut', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadV);
      // Empty donut → one legend row named after the card ("Work Locations").
      final Finder legend = find.descendant(
        of: find.byType(DonutChartCard).first,
        matching: find.text(S.current.timeTrackerWorkLocations),
      );
      for (final Element e in legend.evaluate()) {
        final RenderParagraph p = e.renderObject! as RenderParagraph;
        expect(p.didExceedMaxLines, isFalse);
      }
      await h.dispose(tester);
    });

    testWidgets('iPad V: the check-in strip shows "Check Out Time" in full', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadV);
      await tester.runAsync(() => h.checkIn.checkIn(h.checkIn.state.options.first));
      await h.settle(tester);
      final RenderParagraph p = tester.renderObject<RenderParagraph>(find.text(S.current.timeTrackerCheckOutTime));
      expect(p.didExceedMaxLines, isFalse);
      expect(p.size.width, greaterThanOrEqualTo(p.getMaxIntrinsicWidth(double.infinity) - 0.5));
      await h.dispose(tester);
    });
  });

  group('finding 3 / 4 — icon-only Filter / Export, centred search', () {
    testWidgets('every Time Tracker toolbar', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadH);
      final Map<String, List<String>> toolbars = <String, List<String>>{
        S.current.timeTrackerTabAttendance: <String>['attendanceFilterButton', 'attendanceExportButton'],
        S.current.timeTrackerTabRequests: <String>['requestsFilterButton', 'requestsExportButton'],
        S.current.timeTrackerTabApprovals: <String>['approvalsFilterButton'],
        S.current.timeTrackerTabRequestTypes: <String>['requestTypesFilterButton', 'requestTypesExportButton'],
        S.current.timeTrackerTabLocations: <String>['locationsFilterButton', 'locationsExportButton'],
        S.current.timeTrackerTabEmployees: <String>['employeesFilterButton', 'employeesExportButton'],
      };
      for (final MapEntry<String, List<String>> t in toolbars.entries) {
        await _open(tester, h, t.key);
        _expectIconOnly(tester, t.value.first, filter: true);
        if (t.value.length > 1) _expectIconOnly(tester, t.value.last, filter: false);
        // Search: no vertical padding + even line height = centred text.
        final AppSearchTextField search = tester.widget<AppSearchTextField>(find.byType(AppSearchTextField).first);
        expect((search.contentPadding! as EdgeInsets).vertical, 0, reason: t.key);
        expect(search.valueStyle?.leadingDistribution, TextLeadingDistribution.even, reason: t.key);
        expect(search.valueStyle?.height, 1, reason: t.key);
      }
      await h.dispose(tester);
    });

    testWidgets('typed text is vertically centred in the 38-high box', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadH);
      await _open(tester, h, S.current.timeTrackerTabAttendance);
      await tester.enterText(find.byType(TextField).first, 'Present');
      await h.settle(tester);
      final Rect box = tester.getRect(find.byType(InputDecorator).first);
      final Rect line = tester.getRect(find.byType(EditableText).first);
      // The line box is centred in the field…
      expect((line.center.dy - box.center.dy).abs(), lessThan(1.0));
      // …and is one em high (even leading), so the Cairo cap height sits on
      // that centre. With the font's own leading the line was ~26 high and
      // the letters landed ~2 px low (16 px above / 12 px below).
      expect(line.height, lessThan(18));
      await h.dispose(tester);
    });
  });

  group('finding 5 — table colours (Figma 661:14645, light + dark)', () {
    testWidgets('Requests table rows: #F1F1F1 then white', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadH);
      await _open(tester, h, S.current.timeTrackerTabRequests);
      await tester.tap(_key('requestsTableToggle'));
      await h.settle(tester);
      final List<Element> rows = find
          .byWidgetPredicate((Widget w) => w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('requestRow_'))
          .evaluate()
          .toList()
        ..sort((Element a, Element b) =>
            tester.getTopLeft(find.byWidget(a.widget)).dy.compareTo(tester.getTopLeft(find.byWidget(b.widget)).dy));
      expect(rows.length, greaterThanOrEqualTo(2));
      expect((rows[0].widget as Container).color, const Color(0xFFF1F1F1));
      expect((rows[1].widget as Container).color, AppColors.oddRowColor);
      await h.dispose(tester);
    });

    test('dark mode: dark header (white titles stay readable) and dark zebra rows', () {
      AppTheme.isDark = true;
      AppColors.currentThemeColors = AppTheme.darkThemeColors;
      addTearDown(() {
        AppTheme.isDark = false;
        AppColors.currentThemeColors = AppTheme.lightThemeColors;
      });
      expect(TtTableColors.header, isNot(AppColors.white));
      expect(TtTableColors.header.computeLuminance(), lessThan(0.2));
      expect(TtTableColors.row(0), AppColors.tableRowDark);
      expect(TtTableColors.row(1), AppColors.tableDarkBackground);
    });

    test('light mode: Figma header #2D2D2D', () {
      expect(TtTableColors.header, const Color(0xFF2D2D2D));
      expect(TtTableColors.row(0), const Color(0xFFF1F1F1));
      expect(TtTableColors.row(1), AppColors.oddRowColor);
    });
  });

  group('finding 6 — yellow Upload buttons', () {
    testWidgets('request form "Upload" and transaction form "Upload Attachment"', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadH);
      await _open(tester, h, S.current.timeTrackerTabRequests);
      await tester.tap(_key('requestsAddButton'));
      await h.settle(tester);
      expect(tester.widget(_key('requestUploadBox')), isA<TtUploadButton>());
      expect(find.descendant(of: _key('requestUploadBox'), matching: find.text(S.current.upload)), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator).last).pop();
      await h.settle(tester);
      await _open(tester, h, S.current.timeTrackerTabAttendance);
      await tester.tap(_key('attendanceTransactionButton'));
      await h.settle(tester);
      expect(tester.widget(_key('transactionUploadBox')), isA<TtUploadButton>());
      expect(find.descendant(of: _key('transactionUploadBox'), matching: find.text(S.current.uploadAttachment)),
          findsOneWidget);
      await h.dispose(tester);
    });
  });

  // UI quality pass (9/10/2026, owner 13:45 #3): the Approvals Employee
  // choice moved INTO the Filter (Department → Employee); no separate button.
  group('finding 7 — Approvals filter holds Department + Employee', () {
    testWidgets('Request Type · Status · From–To · Department · Employee; no Day / Total Time', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadH);
      await _open(tester, h, S.current.timeTrackerTabApprovals);
      expect(_key('approvalsEmployeesButton'), findsNothing);
      await tester.tap(_key('approvalsFilterButton'));
      await h.settle(tester);
      for (final String label in <String>[
        S.current.timeTrackerRequestType,
        S.current.timeTrackerStatus,
        S.current.timeTrackerDateFrom,
        S.current.timeTrackerDateTo,
        S.current.timeTrackerDepartment,
        S.current.employee,
      ]) {
        expect(find.textContaining(label, findRichText: true), findsWidgets, reason: label);
      }
      expect(find.text(S.current.timeTrackerFilterDay), findsNothing);
      expect(find.text(S.current.timeTrackerTotalTime), findsNothing);
      await tester.tap(_key('requestFilterApply'));
      await h.settle(tester);
      expect(h.feed.state.approvals.filter.isActive, isFalse);
      await h.dispose(tester);
    });
  });

  group('finding 8 — one start edge for the page', () {
    final Map<String, (Size, Locale)> cases = <String, (Size, Locale)>{
      'iPad H': (_ipadH, const Locale('en')),
      'iPad V': (_ipadV, const Locale('en')),
      'iPhone': (kTimeTrackerPhone, const Locale('en')),
      'iPad H Arabic': (_ipadH, const Locale('ar')),
      'iPhone Arabic': (kTimeTrackerPhone, const Locale('ar')),
    };
    for (final MapEntry<String, (Size, Locale)> c in cases.entries) {
      testWidgets('title · profile card · tabs · first card align (${c.key})', (WidgetTester tester) async {
        final TimeTrackerHarness h = _harness();
        await h.pump(tester, const TimeTrackerHomePage(), size: c.value.$1, locale: c.value.$2);
        final bool rtl = c.value.$2.languageCode == 'ar';
        double start(Finder f) => rtl ? c.value.$1.width - tester.getTopRight(f).dx : tester.getTopLeft(f).dx;
        final double title = start(find.text(S.current.timeTrackerTitle));
        expect(start(_key('timeTrackerProfileCard')), moreOrLessEquals(title, epsilon: 0.5));
        expect(start(_key('timeTrackerTabStrip')), moreOrLessEquals(title, epsilon: 0.5));
        expect(start(_key('timeTrackerOverallCard')), moreOrLessEquals(title, epsilon: 0.5));
        expect(title, moreOrLessEquals(TimeTrackerHomePage.gutter, epsilon: 0.5));
        await h.dispose(tester);
      });
    }
  });

  group('finding 9 — every tab reachable', () {
    testWidgets('iPhone: the selected (last) tab is scrolled fully into view', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: kTimeTrackerPhone);
      final TimeTrackerTab last = h.home.state.tabs.last;
      h.home.selectTab(last);
      await h.settle(tester);
      final Rect strip = tester.getRect(_key('timeTrackerTabStrip'));
      final Rect tab = tester.getRect(_tab(last.label(tester.element(_key('timeTrackerTabStrip')),
          hasHrDashboard: h.home.state.hasHrDashboard)));
      expect(tab.left, greaterThanOrEqualTo(strip.left - 0.5));
      expect(tab.right, lessThanOrEqualTo(strip.right + 0.5));
      await h.dispose(tester);
    });
  });

  group('same class of defect', () {
    testWidgets('dark mode: the black Pause button keeps a readable label', (WidgetTester tester) async {
      AppTheme.isDark = true;
      AppColors.currentThemeColors = AppTheme.darkThemeColors;
      addTearDown(() {
        AppTheme.isDark = false;
        AppColors.currentThemeColors = AppTheme.lightThemeColors;
      });
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadH);
      await tester.runAsync(() => h.checkIn.checkIn(h.checkIn.state.options.first));
      await h.settle(tester);
      final Text pause = tester.widget<Text>(find.text(S.current.timeTrackerPause));
      expect(pause.style?.color, isNot(AppColors.blackButton), reason: 'label colour = button colour');
      await h.dispose(tester);
    });

    testWidgets('semantics on: every tab builds without an assertion', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage(), size: _ipadV);
      for (final TimeTrackerTab t in h.home.state.tabs) {
        h.home.selectTab(t);
        await h.settle(tester);
        expect(tester.takeException(), isNull, reason: t.name);
      }
      await h.dispose(tester);
      semantics.dispose();
    });
  });
}
