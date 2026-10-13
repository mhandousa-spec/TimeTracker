/// Module: test / time_tracker / presentation / ui_pass
///
///*************************** FILE INFO ****************************///
/// File Name: ui_pass_screens_test.dart
/// Purpose: The UI quality pass (9/10/2026) — every Time Tracker screen /
///          state rendered over the REAL debug demo data (what the 🧪 button
///          writes), on iPad 1366×1024 landscape, iPad 1024×1366 portrait
///          and iPhone 390×844, light + dark, English + Arabic, through the
///          app's ScreenUtil ladder and a shell stand-in.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Without `TT_SHOTS` these are plain widget tests: every screen must build
/// with no exception / overflow in every variant. With
/// `TT_SHOTS=<folder>` each state is also saved as `<variant>__<scene>.png`
/// (QA/ui_pass/before|after). `TT_VARIANTS=ipadV-light-en,iphone-dark-ar`
/// limits the variants.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/ui/pages/vacation_history_page.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/controller/request_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/controller/transaction_form_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/local_data_source/time_tracker_sheet_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_import_rules.dart';

import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/pages/employee_dashboard_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/pages/location_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/pages/location_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/ui/pages/group_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/ui/pages/group_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/pages/request_type_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/pages/request_type_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/pages/request_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/ui/pages/request_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/ui/pages/transaction_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_state.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/pages/employee_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';

import '../../_support/time_tracker_phase5_fakes.dart';
import '../../_support/time_tracker_widget_harness.dart';
import '../../_support/tt_demo_seed.dart';
import '../../_support/tt_shots.dart';

/// One rendered variant.
class _Variant {
  const _Variant(this.device, {required this.dark, required this.locale});

  final TtDevice device;
  final bool dark;
  final String locale;

  String get name => '${device.name}-${dark ? 'dark' : 'light'}-$locale';
}

List<_Variant> get _variants {
  final List<_Variant> all = <_Variant>[
    for (final TtDevice d in kTtDevices)
      for (final bool dark in <bool>[false, true])
        for (final String l in <String>['en', 'ar']) _Variant(d, dark: dark, locale: l),
  ];
  final String? only = Platform.environment['TT_VARIANTS'];
  if (only == null || only.trim().isEmpty) return all;
  final Set<String> keep = only.split(',').map((String s) => s.trim()).toSet();
  return all.where((_Variant v) => keep.contains(v.name)).toList();
}

/// A running scene: the harness + a shot helper.
class _Ctx {
  _Ctx(this.tester, this.h, this.v);

  final WidgetTester tester;
  final TimeTrackerHarness h;
  final _Variant v;

  Future<void> shot(String scene) async {
    final Object? error = tester.takeException();
    if (error != null) {
      fail('${v.name} $scene: $error\n${error is Error ? error.stackTrace : ''}');
    }
    await ttShot(tester, '${v.name}__$scene');
  }

  Future<void> settle() => h.settle(tester);

  Future<void> tab(TimeTrackerTab t) async {
    h.home.selectTab(t);
    await settle();
  }

  NavigatorState get _module => tester.state<NavigatorState>(find.byType(Navigator).last);
  NavigatorState get _root => tester.state<NavigatorState>(find.byType(Navigator).first);

  Future<void> push(Widget page) async {
    _module.push(MaterialPageRoute<void>(builder: (_) => page));
    await settle();
  }

  Future<void> back() async {
    _module.pop();
    await settle();
  }

  Future<void> closeDialog() async {
    _root.pop();
    await settle();
  }

  Future<void> tap(String key) async {
    final Finder f = find.byKey(ValueKey<String>(key));
    await tester.ensureVisible(f.first);
    await tester.pump();
    await tester.tap(f.first, warnIfMissed: false);
    await settle();
  }

  /// Scroll the main page by about one screen ([times] screens).
  Future<void> scroll({int times = 1}) async {
    final Finder s = find.byType(Scrollable).first;
    for (int i = 0; i < times; i++) {
      await tester.drag(s, Offset(0, -v.device.size.height * 0.7), warnIfMissed: false);
      await settle();
    }
  }

  Future<void> top() async {
    final Finder s = find.byType(Scrollable).first;
    await tester.drag(s, Offset(0, v.device.size.height * 20), warnIfMissed: false);
    await settle();
  }
}

Future<void> _run(
  WidgetTester tester,
  _Variant v,
  Future<void> Function(_Ctx c) scene, {
  bool seed = true,
  void Function(TimeTrackerHarness h)? beforePump,
}) async {
  setTtTheme(dark: v.dark, locale: v.locale);
  addTearDown(() => setTtTheme(dark: false, locale: 'en'));
  final TimeTrackerHarness h = ttDemoHarness();
  if (seed) await seedTtDemo(tester, h, isArabic: v.locale == 'ar');
  beforePump?.call(h);
  await h.pump(
    tester,
    const TimeTrackerHomePage(),
    size: v.device.size,
    designSize: v.device.designSize,
    frame: ttFrame(v.device),
    locale: Locale(v.locale),
  );
  await scene(_Ctx(tester, h, v));
  await h.dispose(tester);
}

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    await loadTtFonts();
  });

  /// The owner's today: checked in at 08:05 (optionally paused / out).
  void today(TimeTrackerHarness h, {bool paused = false, bool out = false}) {
    final DateTime now = DateTime.now();
    final DateTime d = DateTime(now.year, now.month, now.day);
    final DateTime start = d.add(const Duration(hours: 8, minutes: 5));
    seedDays(h.remote, <AttendanceDay>[
      AttendanceDay(
        id: TimeTrackerFirestorePaths.attendanceDocId(kTtOwner, d),
        employeeEmail: kTtOwner,
        date: d,
        status: AttendanceStatus.present,
        sessions: <AttendanceSession>[
          AttendanceSession(
            checkInAt: start,
            checkOutAt: out ? start.add(const Duration(hours: 4)) : null,
            workLocationId: TtDemoIds.headquarters,
            pauses: paused ? <AttendancePause>[AttendancePause(startAt: start.add(const Duration(hours: 2)))] : const <AttendancePause>[],
          ),
        ],
      ),
    ]);
  }

  for (final _Variant v in _variants) {
    group(v.name, () {
      testWidgets('header: check-in states', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.tap('timeTrackerCheckInButton');
          await c.shot('00_checkin_sheet');
          await c.closeDialog();
        });
        await _run(tester, v, beforePump: today, (_Ctx c) async {
          await c.shot('00_header_checked_in');
          await c.tap('timeTrackerHideExpand');
          await c.shot('00_header_collapsed');
        });
        await _run(tester, v, beforePump: (TimeTrackerHarness h) => today(h, paused: true), (_Ctx c) async {
          await c.shot('00_header_paused');
        });
        await _run(tester, v, beforePump: (TimeTrackerHarness h) => today(h, out: true), (_Ctx c) async {
          await c.shot('00_header_checked_out');
        });
      });

      testWidgets('dashboard: personal + HR overview', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.shot('01_dashboard_personal');
          await c.scroll();
          await c.shot('01_dashboard_personal_s1');
          await c.scroll();
          await c.shot('01_dashboard_personal_s2');
          await c.top();
          c.h.hrDashboard!.setShowHr(true);
          await c.settle();
          await c.shot('02_dashboard_hr');
          await c.scroll();
          await c.shot('02_dashboard_hr_s1');
          await c.scroll();
          await c.shot('02_dashboard_hr_s2');
          await c.scroll();
          await c.shot('02_dashboard_hr_s3');
          await c.top();
          await c.tap('hrEmployeeButton');
          await c.shot('03_hr_employee_picker');
          await c.closeDialog();
          c.h.hrDashboard!.setEmployees(<String>{'salma.fathy@dm003.test'});
          await c.settle();
          await c.shot('03_hr_one_employee');
          c.h.hrDashboard!.setEmployees(<String>{'salma.fathy@dm003.test', 'omar.farouk@dm003.test', 'mona.elsayed@dm003.test'});
          await c.settle();
          await c.shot('03_hr_three_employees');
          c.h.hrDashboard!.setEmployees(<String>{});
          await c.settle();
          await c.tap('hrExportButton');
          await c.shot('05_export_dialog');
          await c.closeDialog();
          final GetIt getIt = GetIt.instance;
          if (getIt.isRegistered<PersonalDashboardCubit>()) getIt.unregister<PersonalDashboardCubit>();
          getIt.registerFactory<PersonalDashboardCubit>(() => c.h.fresh<PersonalDashboardCubit>());
          addTearDown(() => getIt.unregister<PersonalDashboardCubit>());
          await c.push(EmployeeDashboardPage(employee: kTtPeople.last));
          await c.shot('04_employee_dashboard');
        });
      });

      testWidgets('attendance', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.tab(TimeTrackerTab.attendance);
          await c.shot('10_attendance');
          await c.scroll();
          await c.shot('10_attendance_s1');
          await c.top();
          await c.tap('attendanceFilterButton');
          await c.shot('11_attendance_filter');
          await c.closeDialog();
          await c.push(const TransactionFormPage());
          await c.shot('12_transaction_form');
          // 12/10/2026 (owner R4 / G1): a tap on the grey Submit shows every missing field.
          await c.tap('transactionSubmitButton');
          await c.shot('12_transaction_form_required');
          // 13/10/2026 (owner G3): the file card after an upload.
          await c.tester.runAsync(() => c.tester
              .element(find.byKey(const ValueKey<String>('transactionUploadBox')))
              .read<TransactionFormCubit>()
              .uploadAttachment('Attendance_Proof_11_Oct.pdf', List<int>.filled(240000, 0)));
          await c.settle();
          await c.shot('12_transaction_form_file');
        });
      });

      testWidgets('requests', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.tab(TimeTrackerTab.requests);
          await c.shot('20_requests_cards');
          await c.scroll();
          await c.shot('20_requests_cards_s1');
          await c.top();
          await c.tap('requestsFilterButton');
          await c.shot('21_requests_filter');
          await c.closeDialog();
          c.h.feed.setGrid(RequestScope.mine, false);
          await c.settle();
          await c.shot('22_requests_table');
          await c.push(const RequestFormPage());
          await c.shot('23_request_form');
          // 13/10/2026 (owner P2): the fields appear for the chosen type.
          final RequestFormCubit form =
              c.tester.element(find.byKey(const ValueKey<String>('requestTypeDropdown'))).read<RequestFormCubit>();
          final List<RequestType> types = form.state.setup.types;
          form.typeChanged(types.firstWhere((RequestType t) => t.isAttachmentRequired,
              orElse: () => const RequestType(id: 'sick', nameEn: 'Sick Leave', nameAr: 'إجازة مرضية', isAttachmentRequired: true)));
          await c.settle();
          await c.shot('23_request_form_type');
          await c.back();
          for (final (String id, String name) in <(String, String)>[
            (TtDemoIds.request(1), 'pending'),
            (TtDemoIds.request(2), 'approved_doc'),
            (TtDemoIds.request(4), 'rejected'),
            (TtDemoIds.request(5), 'canceled'),
            (TtDemoIds.request(6), 'canceled_by_hr'),
            (TtDemoIds.request(7), 'under_review'),
            (TtDemoIds.request(10), 'transaction_pending'),
            (TtDemoIds.request(11), 'transaction_approved'),
          ]) {
            await c.push(RequestDetailsPage(requestId: id));
            await c.shot('24_request_details_$name');
            await c.back();
          }
        });
      });

      testWidgets('approvals', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.tab(TimeTrackerTab.approvals);
          await c.shot('30_approvals');
          await c.scroll();
          await c.shot('30_approvals_s1');
          await c.top();
          await c.tap('approvalsFilterButton');
          await c.shot('31_approvals_filter');
          await c.closeDialog();
          // Khaled's pending annual vacation (waiting for the owner as manager).
          await c.push(RequestDetailsPage(requestId: TtDemoIds.request(13), asApprover: true));
          await c.shot('32_approval_details_pending');
          await c.back();
        });
      });

      testWidgets('request types', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.tab(TimeTrackerTab.requestTypes);
          await c.shot('40_request_types_cards');
          // 12/10/2026 (owner): the Request Types filter = the Approvals one.
          await c.tap('requestTypesFilterButton');
          await c.shot('40_request_types_filter');
          await c.closeDialog();
          c.h.requestTypes.setGrid(false);
          await c.settle();
          await c.shot('41_request_types_table');
          await c.push(const RequestTypeFormPage());
          await c.shot('42_request_type_form');
          await c.back();
          await c.push(const RequestTypeDetailsPage(typeId: TtDemoIds.sick));
          await c.shot('43_request_type_details');
          await c.tap('requestTypeRemoveButton');
          await c.shot('44_request_type_remove_confirm');
          await c.closeDialog();
          await c.tap('requestTypeEditButton');
          await c.shot('45_request_type_edit');
          // 12/10/2026 (owner R4 / K2): an unchanged Edit says why Save is grey.
          await c.tap('requestTypeSubmitButton');
          await c.shot('45_request_type_edit_no_change');
          expect(find.byKey(const ValueKey<String>('formActionsHint')), findsOneWidget);
        });
      });

      testWidgets('locations', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.tab(TimeTrackerTab.locations);
          await c.shot('50_locations');
          // 13/10/2026 (owner S3): the self-explaining Import.
          // 13/10/2026 (owner): Export is as wide as the Filter dialog.
          await c.tap('locationsExportButton');
          await c.shot('50a_location_export');
          await c.closeDialog();
          await c.tap('locationsFilterButton');
          await c.shot('50a_location_filter');
          await c.closeDialog();
          await c.tap('locationsImportButton');
          await c.shot('50b_location_import');
          // 13/10/2026 (owner): the bulk-upload review after a file is read
          // (one new row, one with mistakes).
          await _withSheet(<List<String>>[
            LocationImportRules.headings,
            <String>['Ministry Headquarters', '', '', '', '', '', '', '', '', '', '', '', '', '', '20'],
            <String>['Giza Branch', 'فرع الجيزة', 'not a link', '30.01', '31.2', 'Yes', '', 'EG', '', 'Giza', '',
                '09:00', '09:00', 'Sun, Mon', '', 'Maybe'],
            <String>['Alex Branch', 'فرع الإسكندرية', '', '31.2', '29.9', 'No', '', 'EG', '', 'Alexandria', '',
                '08:00', '16:00', 'Sun, Mon, Tue, Wed, Thu'],
          ], () async {
            await c.tap('locationImportUpload');
            await c.shot('50c_location_import_review');
          });
          await c.closeDialog();
          await c.push(const LocationFormPage());
          await c.shot('51_location_form');
          await c.scroll();
          await c.shot('51_location_form_s1');
          await c.back();
          await c.push(const LocationDetailsPage(locationId: TtDemoIds.headquarters));
          await c.shot('52_location_details');
          await c.scroll();
          await c.shot('52_location_details_s1');
          await c.scroll();
          await c.shot('52_location_details_s2');
          await c.top();
          await c.tap('locationDeleteButton');
          await c.shot('53_location_delete_blocked');
          await c.closeDialog();
          await c.tap('locationEditButton');
          await c.shot('54_location_edit');
        });
      });

      testWidgets('employees + groups', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.tab(TimeTrackerTab.employees);
          await c.shot('60_employees_assigned');
          await c.scroll();
          await c.shot('60_employees_assigned_s1');
          await c.top();
          c.h.employees.setSegment(EmployeesSegment.unassigned);
          await c.settle();
          await c.shot('60_employees_unassigned');
          c.h.employees.setSegment(EmployeesSegment.assigned);
          await c.settle();
          await c.tap('employeeReassign_omar.farouk@dm003.test');
          await c.shot('61_reassign_dialog');
          await c.closeDialog();
          await c.push(const EmployeeDetailsPage(employeeEmail: 'omar.farouk@dm003.test'));
          await c.shot('61b_employee_details');
          await c.scroll();
          await c.shot('61b_employee_details_s1');
          await c.back();
          c.h.employees.setSegment(EmployeesSegment.groups);
          await c.settle();
          await c.shot('62_groups');
          await c.push(const GroupFormPage());
          await c.shot('63_group_form');
          await c.scroll();
          // 13/10/2026 (owner U2): pick two members → chips.
          await c.tap('groupMemberRow_omar.farouk@dm003.test');
          await c.tap('groupMemberRow_mona.elsayed@dm003.test');
          await c.shot('63_group_form_s1');
          await c.back();
          await c.push(const GroupDetailsPage(groupId: TtDemoIds.group));
          await c.shot('64_group_details');
          await c.back();
          c.h.employees.setView(EmployeesSubView.locations);
          await c.settle();
          await c.shot('65_employees_locations');
        });
      });

      testWidgets('vacation balances', (WidgetTester tester) async {
        await _run(tester, v, (_Ctx c) async {
          await c.tab(TimeTrackerTab.vacationBalances);
          await c.shot('70_vacation_balances_cards');
          // 13/10/2026 (owner V2 / S3): the Edit and Import dialogs.
          await c.tap('vacationEdit_${kTtPeople.first.email}');
          await c.shot('72_vacation_edit');
          // The keyboard is up (owner V2: it overflowed).
          c.tester.view.viewInsets = FakeViewPadding(bottom: 320 * c.tester.view.devicePixelRatio);
          await c.settle();
          await c.shot('72b_vacation_edit_keyboard');
          c.tester.view.resetViewInsets();
          await c.settle();
          await c.closeDialog();
          await c.tap('vacationImportButton');
          await c.shot('73_vacation_import');
          await _withSheet(<List<String>>[
            VacationBalanceImportRules.headings,
            <String>[kTtPeople.first.name(isArabic: false), kTtPeople.first.email, '', '', '2026', '25'],
            <String>['Someone', 'nobody@company.com', '', '', '2026', '21'],
            <String>[kTtPeople[1].name(isArabic: false), kTtPeople[1].email, '', '', '2025', 'abc'],
          ], () async {
            await c.tap('vacationImportUpload');
            await c.shot('73b_vacation_import_review');
          });
          await c.closeDialog();
          // 13/10/2026 (owner V1): an employee's vacation history.
          await c.push(VacationHistoryPage(employeeEmail: kTtPeople.first.email));
          await c.shot('74_vacation_history');
          await c.scroll();
          await c.shot('74_vacation_history_s1');
          await c.back();
          c.h.vacations!.setGrid(false);
          await c.settle();
          await c.shot('71_vacation_balances_table');
        });
      });

      testWidgets('empty states', (WidgetTester tester) async {
        await _run(tester, v, seed: false, (_Ctx c) async {
          for (final TimeTrackerTab t in <TimeTrackerTab>[
            TimeTrackerTab.attendance,
            TimeTrackerTab.requests,
            TimeTrackerTab.approvals,
            TimeTrackerTab.requestTypes,
            TimeTrackerTab.locations,
            TimeTrackerTab.employees,
          ]) {
            await c.tab(t);
            await c.shot('90_empty_${t.name}');
          }
        });
      });
    });
  }
}

/// A file reader that "picks" [grid] (the import review screenshots).
class _SheetReader extends TimeTrackerSheetReader {
  const _SheetReader(this.grid);

  final List<List<String>> grid;

  @override
  Future<TimeTrackerSheet?> pickAndRead() async => TimeTrackerSheet(fileName: 'upload.csv', grid: grid);
}

/// Run [body] with [_SheetReader] ([grid]) in place of the real reader.
Future<void> _withSheet(List<List<String>> grid, Future<void> Function() body) async {
  final GetIt getIt = GetIt.instance;
  if (getIt.isRegistered<TimeTrackerSheetReader>()) getIt.unregister<TimeTrackerSheetReader>();
  getIt.registerSingleton<TimeTrackerSheetReader>(_SheetReader(grid));
  try {
    await body();
  } finally {
    getIt.unregister<TimeTrackerSheetReader>();
    getIt.registerLazySingleton<TimeTrackerSheetReader>(() => const TimeTrackerSheetReader());
  }
}
