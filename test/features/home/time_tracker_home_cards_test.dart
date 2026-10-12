/// Module: test / home / h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_home_cards_test.dart
/// Purpose: Time Tracker phase 6 — the seven home cards over the in-memory
///          module fakes (GetIt registrations like `main.dart`): each card's
///          OWN width (125 / 260 / 405) in English and Arabic on a tablet and
///          a phone, live figures, the no-access state, the quick cards'
///          Check In / Check Out states, the Pending tile's approvals dialog
///          (the module's own `ApprovalCard`), and the stable database names.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/time_tracker_home_cards_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt11_approvals/presentation/ui/widgets/approval_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../time_tracker/_support/time_tracker_phase3_fakes.dart';
import '../time_tracker/_support/time_tracker_phase4_fakes.dart';
import '../time_tracker/_support/time_tracker_test_fakes.dart';
import '../time_tracker/_support/time_tracker_widget_harness.dart';

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Moataz H', departmentId: 'dep-1'),
  TimeTrackerEmployee(email: 'amal@co.com', nameEn: 'Amal S', departmentId: 'dep-1', jobTitleEn: 'Accountant'),
];

/// The time-tracker cards and the grid width each declares (before `.w`).
const Map<HomeComponents, double> _widths = <HomeComponents, double>{
  HomeComponents.timeTrackerTotals: kHomeWidgetWideWidth,
  HomeComponents.timeTrackerPresence: kHomeWidgetCompactWidth,
  HomeComponents.timeTrackerStatus: kHomeWidgetCompactWidth,
  HomeComponents.timeTrackerApprover: kHomeWidgetCompactWidth,
  HomeComponents.timeTrackerMyRequest: kHomeWidgetNarrowWidth,
  HomeComponents.timeTrackerQuickRequests: kHomeWidgetNarrowWidth,
  HomeComponents.timeTrackerQuickApprovals: kHomeWidgetNarrowWidth,
};

class _Env {
  _Env({Set<String>? keys, this.checkedIn = false})
      : access = accessWith(keys ?? allKeys(), email: 'me@co.com', departmentId: 'dep-1') {
    final DateTime today = DateTime.now();
    seedAssignment(remote, location: const WorkLocation(id: 'hq', nameEn: 'Main Office'));
    seedRequestTypes(remote, const <RequestType>[RequestType(id: 'sick', nameEn: 'Sick Leave')]);
    seedRequests(remote, <TimeTrackerRequest>[
      TimeTrackerRequest(
        id: 'mine-approved',
        requesterEmail: 'me@co.com',
        requestTypeId: 'sick',
        startAt: DateTime(today.year, today.month, 1),
        endAt: DateTime(today.year, today.month, 1),
        status: RequestStatus.approved,
      ),
      TimeTrackerRequest(
        id: 'mine-pending',
        requesterEmail: 'me@co.com',
        requestTypeId: 'sick',
        startAt: today,
        endAt: today,
      ),
      TimeTrackerRequest(
        id: 'amal-waits',
        requesterEmail: 'amal@co.com',
        requesterDepartmentId: 'dep-1',
        requestTypeId: 'sick',
        startAt: today,
        endAt: today,
        approvalSteps: const <RequestApprovalStep>[
          RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'me@co.com'),
        ],
        currentStep: ApprovalStepKind.manager,
      ),
    ]);
    attendance = AttendanceRepositoryImpl(remoteDataSource: remote, access: access);
    kit = Phase4Kit(remote: remote, access: access, people: _people);
  }

  final TimeTrackerAccess access;
  final bool checkedIn;
  final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
  late final AttendanceRepositoryImpl attendance;
  late final Phase4Kit kit;

  void register() {
    final GetIt sl = GetIt.instance;
    void put<T extends Object>(T value) {
      if (sl.isRegistered<T>()) sl.unregister<T>();
      sl.registerSingleton<T>(value);
    }

    void factory<T extends Object>(T Function() make) {
      if (sl.isRegistered<T>()) sl.unregister<T>();
      sl.registerFactory<T>(make);
    }

    put<TimeTrackerAccess>(access);
    put<AttendanceBaseRepository>(attendance);
    put<RequestBaseRepository>(kit.requests);
    factory<CheckInCubit>(() => CheckInCubit(
          attendance: attendance,
          resolver: noHrResolver(remote),
          location: FakeLocationReader(const DeviceLocationResult.found(GeoPoint(30, 31))),
          access: access,
          log: FakeLog(),
        ));
    factory<RequestsCubit>(() => RequestsCubit(
          requests: kit.requests,
          types: kit.types,
          directory: kit.directory,
          access: access,
        ));
    factory<RequestActionsCubit>(
        () => RequestActionsCubit(requests: kit.requestService, approvals: kit.approvalService));
    void drop<T extends Object>() {
      if (sl.isRegistered<T>()) sl.unregister<T>();
    }

    addTearDown(() {
      drop<TimeTrackerAccess>();
      drop<AttendanceBaseRepository>();
      drop<RequestBaseRepository>();
      drop<CheckInCubit>();
      drop<RequestsCubit>();
      drop<RequestActionsCubit>();
    });
  }

  Future<void> seedDays() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    // Two earlier days of THIS month (a month may start today: then none).
    if (today.day > 2) {
      await attendance.saveDay(
          day: AttendanceDay(id: '', employeeEmail: 'me@co.com', date: DateTime(now.year, now.month, 1), status: AttendanceStatus.late));
      await attendance.saveDay(
          day: AttendanceDay(id: '', employeeEmail: 'me@co.com', date: DateTime(now.year, now.month, 2), status: AttendanceStatus.absent));
    }
    if (checkedIn) {
      await attendance.saveDay(
        day: AttendanceDay(
          id: '',
          employeeEmail: 'me@co.com',
          date: today,
          sessions: <AttendanceSession>[AttendanceSession(checkInAt: now.subtract(const Duration(minutes: 75)))],
        ),
      );
    }
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Env env,
  HomeComponents c, {
  Size size = const Size(1194, 834),
  Size design = const Size(1024, 768),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  env.register();
  await tester.runAsync(env.seedDays);
  final HomeComponentModel model = c.getModel(rowNumber: 1, columnNumber: 1);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: design,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        locale: locale,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[KeyedSubtree(key: const ValueKey<String>('card'), child: c.widget(model)!)],
            ),
          ),
        ),
      ),
    ),
  );
  for (int i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
  await tester.pump();
}

void main() {
  setUpAll(initTimeTrackerTestStorage);

  test('database names are stable Time_Tracker_… keys under Modules.timeTracker', () {
    final Map<HomeComponents, String> names = <HomeComponents, String>{
      for (final HomeComponents c in _widths.keys) c: c.databaseName,
    };
    expect(names.values.toSet(), <String>{
      'Time_Tracker_Totals',
      'Time_Tracker_Presence',
      'Time_Tracker_Status',
      'Time_Tracker_Approver',
      'Time_Tracker_My_Request',
      'Time_Tracker_Quick_Requests',
      'Time_Tracker_Quick_Approvals',
    });
    for (final HomeComponents c in _widths.keys) {
      expect(c.module, Modules.timeTracker);
      expect(c.isChart, isFalse);
    }
  });

  test('card gates follow the switches', () {
    final TimeTrackerAccess none = accessWith(<String>{});
    final TimeTrackerAccess all = accessWith(allKeys());
    for (final TimeTrackerHomeCard card in TimeTrackerHomeCard.values) {
      expect(card.allows(none), isFalse, reason: card.name);
      expect(card.allows(all), isTrue, reason: card.name);
    }
    final TimeTrackerAccess onlyCheckIn = accessWith(<String>{'Check_In_Permissions', 'Check_In_And_Out'});
    expect(TimeTrackerHomeCard.quickRequests.allows(onlyCheckIn), isTrue);
    expect(TimeTrackerHomeCard.trackerStatus.allows(onlyCheckIn), isFalse);
    expect(TimeTrackerHomeCard.trackerApprover.allows(onlyCheckIn), isFalse);
  });

  for (final (String name, Size size, Size design) device in <(String, Size, Size)>[
    ('tablet', const Size(1194, 834), const Size(1024, 768)),
    ('phone', const Size(390, 844), const Size(375, 812)),
  ]) {
    for (final Locale locale in const <Locale>[Locale('en'), Locale('ar')]) {
      testWidgets('${device.$1} ${locale.languageCode}: every card at its own width, no overflow',
          (WidgetTester tester) async {
        for (final MapEntry<HomeComponents, double> e in _widths.entries) {
          await _pump(tester, _Env(), e.key, size: device.$2, design: device.$3, locale: locale);
          expect(tester.takeException(), isNull, reason: e.key.name);
          expect(tester.getSize(find.byKey(const ValueKey<String>('card'))).width, closeTo(e.value.w, 0.01),
              reason: e.key.name);
          await _unmount(tester);
        }
      });
    }
  }

  testWidgets('live figures: Tracker Status, My Request, Tracker Approver, Presence', (WidgetTester tester) async {
    await _pump(tester, _Env(), HomeComponents.timeTrackerStatus);
    // Mine: 1 approved, 1 pending, 0 rejected, 0 canceled.
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('0'), findsNWidgets(2));
    await _unmount(tester);

    await _pump(tester, _Env(), HomeComponents.timeTrackerMyRequest);
    expect(find.text('Total 2'), findsOneWidget);
    await _unmount(tester);

    await _pump(tester, _Env(), HomeComponents.timeTrackerApprover);
    // Amal's request waits for me: Pending 1.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Tracker Approver'), findsOneWidget);
    await _unmount(tester);

    final DateTime now = DateTime.now();
    await _pump(tester, _Env(), HomeComponents.timeTrackerPresence);
    expect(find.text('Present'), findsOneWidget);
    if (now.day > 2) {
      expect(find.text('Absence'), findsOneWidget);
      // Present 1 (the late day), Absence 1, Late 1.
      expect(find.text('1'), findsNWidgets(3));
    }
    await _unmount(tester);
  });

  testWidgets('no switch → the standard no-access message', (WidgetTester tester) async {
    await _pump(tester, _Env(keys: <String>{}), HomeComponents.timeTrackerTotals);
    expect(find.text("You don't have access to the Time Tracker."), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('quick card: Check In active, Check Out grey; checked in → the live timer', (WidgetTester tester) async {
    await _pump(tester, _Env(), HomeComponents.timeTrackerQuickRequests);
    expect(find.byKey(const ValueKey<String>('timeTrackerQuickCheckIn')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('timeTrackerQuick_requests')), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    await _unmount(tester);

    await _pump(tester, _Env(checkedIn: true), HomeComponents.timeTrackerQuickApprovals);
    expect(find.byKey(const ValueKey<String>('timeTrackerQuickTimer')), findsOneWidget);
    expect(find.textContaining('01 : 1'), findsOneWidget, reason: '75 minutes worked');
    expect(find.text('Approvals'), findsOneWidget);
    await _unmount(tester);

    // Without Check_In_And_Out only the tab button is left.
    await _pump(tester, _Env(keys: allKeys()..remove('Check_In_And_Out')), HomeComponents.timeTrackerQuickRequests);
    expect(find.byKey(const ValueKey<String>('timeTrackerQuickCheckIn')), findsNothing);
    expect(find.text('Requests'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('Tracker Approver → Pending opens the waiting requests with Reject / Approve', (WidgetTester tester) async {
    await _pump(tester, _Env(), HomeComponents.timeTrackerApprover);
    await tester.tap(find.byKey(const ValueKey<String>('timeTrackerApproverPendingTile')));
    for (int i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const ValueKey<String>('timeTrackerPendingApprovalsSheet')), findsOneWidget);
    expect(find.byType(ApprovalCard), findsOneWidget);
    expect(find.text('Pending Approvals'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5)); // close the dialog
    await tester.pump(const Duration(milliseconds: 400));
    await _unmount(tester);
  });
}
