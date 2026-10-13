/// Module: test / time_tracker / _support
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_widget_harness.dart
/// Purpose: Pumps a Time Tracker page the way `TimeTrackerModuleEntry` does
///          — real cubits over the in-memory fakes, `TimeTrackerAccess` in
///          GetIt — on a tablet-landscape (or phone) surface with ScreenUtil
///          and the S delegates. Also [initTimeTrackerTestStorage], so taps
///          that fire `HapticController` work.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Every cubit is initialised BEFORE the first frame: the core loading
/// spinner (`CircleProgressMaster`) reads `Get.height`, which needs a
/// GetMaterialApp context the module never has in tests (same rule as the
/// To-Do harness).
/// Updated: 9/10/2026 - phase 3: also provides the Locations, Employees and
/// Request Types cubits, registers the phase-3 form cubits in GetIt, and can
/// pump a company WITH HR ([hasHr]) or a custom employee list ([people]).
/// Updated: 9/10/2026 - phase 4: also provides `RequestsCubit` +
/// `RequestActionsCubit` (services over the same fakes, see `Phase4Kit`),
/// registers `RequestFormCubit`, and takes the requester's [manager] and
/// the company's approver [roles].
/// Updated: 9/10/2026 - phase 5: also provides `HrDashboardCubit` (over
/// `FakeHrDashboardRepository`, [placements]) and `VacationBalancesCubit`,
/// each only when its switch is on (same as the module entry).
/// Updated: 9/10/2026 - code review / QA KP-TT-003: [pump] `moduleEntry`
/// registers every cubit in GetIt (the instances built here) so the REAL
/// `TimeTrackerModuleEntry` — with its own lazy providers — can be pumped,
/// under a `GetMaterialApp` (its loading spinner reads `Get.height`).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/controller/transaction_form_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/group_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_assignment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_assignment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_type_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/group_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/location_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/controller/group_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_type_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/controller/request_form_cubit.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';

import 'time_tracker_phase3_fakes.dart';
import 'time_tracker_phase4_fakes.dart';
import 'time_tracker_phase5_fakes.dart';
import 'time_tracker_test_fakes.dart';

/// The Figma iPad landscape frame (Employee 661:10375 is 1024 wide).
const Size kTimeTrackerTablet = Size(1194, 834);

/// A phone (iPhone frames are 375 wide).
const Size kTimeTrackerPhone = Size(390, 844);

/// Function Name: [initTimeTrackerTestStorage]
///
/// Purpose: Open the default GetStorage box on a temp directory and register
/// a `HapticController` (haptics stay OFF). Call from `setUpAll`.
///
/// Return type: [Future<void>]
Future<void> initTimeTrackerTestStorage() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Directory dir = Directory.systemTemp.createTempSync('time_tracker_test_');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async => dir.path,
  );
  await GetStorage('GetStorage', dir.path).initStorage;
  if (!Get.isRegistered<HapticController>()) Get.put(HapticController());
}

class TimeTrackerHarness {
  TimeTrackerHarness({
    Set<String>? on,
    FakeTimeTrackerRemote? remote,
    this.hasHr = false,
    List<TimeTrackerEmployee>? people,
    this.manager = '',
    this.roles = const <(TimeTrackerRoleRecord, Map<String, dynamic>)>[],
    String email = 'me@co.com',
    String departmentId = 'dep-1',
    Map<String, EmployeePlacement>? placements,
    TimeTrackerAccess? access,
    Map<String, String>? departments,
    Map<String, String>? departmentsAr,
  })  : access = access ?? accessWith(on ?? allKeys(), email: email, departmentId: departmentId),
        remote = remote ?? FakeTimeTrackerRemote(),
        directory = FakeDirectory(people, departments, departmentsAr),
        placements = placements ?? <String, EmployeePlacement>{};

  final TimeTrackerAccess access;
  final FakeTimeTrackerRemote remote;
  final FakeLog log = FakeLog();
  final bool hasHr;
  final FakeDirectory directory;
  late TimeTrackerHomeCubit home;
  late CheckInCubit checkIn;
  late PersonalDashboardCubit dashboard;
  late AttendanceCubit attendance;
  late LocationsCubit locations;
  late EmployeesCubit employees;
  late RequestTypesCubit requestTypes;
  late RequestsCubit feed;
  late RequestActionsCubit actions;
  late Phase4Kit kit;

  /// Phase 5: null when the switch is off (not provided, like the entry).
  HrDashboardCubit? hrDashboard;
  VacationBalancesCubit? vacations;
  late FakeHrDashboardRepository hrRepository;

  /// E-mail → location + schedule for the HR dashboard.
  final Map<String, EmployeePlacement> placements;

  /// The signed-in user's direct manager ('' = none).
  final String manager;

  /// Roles holding the approval switches (`FakeRoleSource.approverRole`).
  final List<(TimeTrackerRoleRecord, Map<String, dynamic>)> roles;

  WorkSetupSourceResolver get resolver => hasHr ? hrResolver(remote) : noHrResolver(remote);

  void _registerPhase3Forms(GetIt getIt) {
    void drop<T extends Object>() {
      if (getIt.isRegistered<T>()) getIt.unregister<T>();
    }

    drop<LocationFormCubit>();
    drop<GroupFormCubit>();
    drop<RequestTypeFormCubit>();
    drop<RequestFormCubit>();
    getIt.registerFactory<RequestFormCubit>(
      () => RequestFormCubit(
        service: kit.requestService,
        attachments: _NoUploads(),
        access: access,
        pickFile: () async => null,
      ),
    );
    getIt.registerFactoryParam<LocationFormCubit, WorkLocation?, void>(
      (WorkLocation? original, _) => LocationFormCubit(
        locations: LocationRepositoryImpl(remoteDataSource: remote, access: access),
        device: FakeLocationReader(const DeviceLocationResult.found(GeoPoint(30.1, 31.2))),
        resolver: resolver,
        access: access,
        log: log,
        original: original,
      ),
    );
    getIt.registerFactoryParam<GroupFormCubit, EmployeeGroup?, void>(
      (EmployeeGroup? original, _) => GroupFormCubit(
        attachments: _NoUploads(),
        access: access,
        original: original,
        pickImage: () async => null,
      ),
    );
    getIt.registerFactoryParam<RequestTypeFormCubit, RequestType?, void>(
      (RequestType? original, _) => RequestTypeFormCubit(
        types: RequestTypeRepositoryImpl(remoteDataSource: remote, access: access),
        access: access,
        log: log,
        original: original,
      ),
    );
    addTearDown(() {
      drop<LocationFormCubit>();
      drop<GroupFormCubit>();
      drop<RequestTypeFormCubit>();
      drop<RequestFormCubit>();
    });
  }

  /// Function Name: [pump]
  ///
  /// Purpose: Initialise every cubit, then build [page] under them.
  ///
  /// Return type: [Future<void>]
  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    Size size = kTimeTrackerTablet,
    DateTime Function()? clock,
    Locale locale = const Locale('en'),
    bool moduleEntry = false,
    Size? designSize,
    Widget Function(Widget page)? frame,
  }) async {
    // 9/10/2026 (UI quality pass): [designSize] = the app's ScreenUtil
    // ladder (main.dart) so `.sp/.w/.h` scale like on the device; [frame]
    // wraps the page in the shell's rail / header for the PNG renders.
    final Size design = designSize ?? size;
    final Widget Function(Widget) wrap = frame ?? (Widget p) => p;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final GetIt getIt = GetIt.instance;
    if (getIt.isRegistered<TimeTrackerAccess>()) {
      getIt.unregister<TimeTrackerAccess>();
    }
    getIt.registerSingleton<TimeTrackerAccess>(access);
    if (getIt.isRegistered<TransactionFormCubit>()) {
      getIt.unregister<TransactionFormCubit>();
    }
    getIt.registerFactory<TransactionFormCubit>(
      () => TransactionFormCubit(
        service: TransactionService(
          requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
          managers: FakeManagerResolver('boss@co.com'),
          access: access,
          log: log,
        ),
        attachments: _NoUploads(),
        access: access,
        pickFile: () async => null,
      ),
    );
    addTearDown(() {
      if (getIt.isRegistered<TimeTrackerAccess>()) {
        getIt.unregister<TimeTrackerAccess>();
      }
      if (getIt.isRegistered<TransactionFormCubit>()) {
        getIt.unregister<TransactionFormCubit>();
      }
    });

    final DateTime Function() now0 = clock ?? DateTime.now;
    kit = Phase4Kit(
      remote: remote,
      access: access,
      manager: manager,
      people: directory.people,
      roles: roles,
      resolver: resolver,
      clock: now0,
    );
    _registerPhase3Forms(getIt);
    final AttendanceRepositoryImpl days =
        AttendanceRepositoryImpl(remoteDataSource: remote, access: access);
    final RequestRepositoryImpl requests =
        RequestRepositoryImpl(remoteDataSource: remote, access: access);
    final DateTime Function() now = clock ?? DateTime.now;
    final LocationRepositoryImpl places = LocationRepositoryImpl(remoteDataSource: remote, access: access);
    final LocationAssignmentRepositoryImpl assignments =
        LocationAssignmentRepositoryImpl(remoteDataSource: remote, access: access);
    final GroupRepositoryImpl groups = GroupRepositoryImpl(remoteDataSource: remote, access: access);
    hrRepository = FakeHrDashboardRepository(remote, placements: placements);
    // One builder per cubit (9/10/2026): the harness instances below, and —
    // for the real module entry — FRESH instances its providers create and
    // close themselves (`moduleEntry`).
    _makers.clear();
    _makers[TimeTrackerHomeCubit] = () => TimeTrackerHomeCubit(access: access, resolver: resolver);
    _makers[CheckInCubit] = () => CheckInCubit(
          attendance: days,
          resolver: resolver,
          location: FakeLocationReader(const DeviceLocationResult.found(GeoPoint(30, 31))),
          access: access,
          log: log,
          clock: now,
        );
    _makers[PersonalDashboardCubit] = () => PersonalDashboardCubit(
          attendance: days,
          requests: requests,
          balances: VacationBalanceRepositoryImpl(remoteDataSource: remote, access: access),
          resolver: resolver,
          access: access,
          clock: now,
        );
    _makers[AttendanceCubit] = () => AttendanceCubit(attendance: days, access: access);
    _makers[LocationsCubit] = () => LocationsCubit(
          locations: places,
          assignments: assignments,
          resolver: resolver,
          access: access,
          log: log,
        );
    _makers[EmployeesCubit] = () => EmployeesCubit(
          // Never the real sender in a widget test (no Firebase).
          notifications: FakeNotifications(),
          directory: directory,
          assignments: assignments,
          groups: groups,
          locations: places,
          groupService: GroupService(groups: groups, assignments: assignments, access: access, log: log),
          resolver: resolver,
          access: access,
          log: log,
        );
    _makers[RequestTypesCubit] = () => RequestTypesCubit(
          types: RequestTypeRepositoryImpl(remoteDataSource: remote, access: access),
          resolver: resolver,
          directory: directory,
          access: access,
          log: log,
        );
    _makers[RequestsCubit] = () => RequestsCubit(
          requests: kit.requests,
          types: kit.types,
          directory: directory,
          access: access,
        );
    _makers[RequestActionsCubit] = () => RequestActionsCubit(requests: kit.requestService, approvals: kit.approvalService);
    _makers[HrDashboardCubit] = () => HrDashboardCubit(
          dashboard: hrRepository,
          requests: requests,
          types: RequestTypeRepositoryImpl(remoteDataSource: remote, access: access),
          directory: directory,
          resolver: resolver,
          access: access,
          clock: now,
        );
    _makers[VacationBalancesCubit] = () => VacationBalancesCubit(
          balances: VacationBalanceRepositoryImpl(remoteDataSource: remote, access: access),
          directory: directory,
          access: access,
          log: log,
          clock: now,
        );
    T make<T>() => _makers[T]!() as T;
    // Pages that build their own cubits from GetIt (Employee Details, T8) —
    // unless the test registered its own.
    void put<T extends Object>(T Function() build) {
      if (getIt.isRegistered<T>()) return;
      getIt.registerFactory<T>(build);
      addTearDown(() {
        if (getIt.isRegistered<T>()) getIt.unregister<T>();
      });
    }

    put<LocationAssignmentBaseRepository>(() => assignments);
    put<RequestBaseRepository>(() => requests);
    if (!moduleEntry) put<PersonalDashboardCubit>(() => make<PersonalDashboardCubit>());
    await tester.runAsync(() async {
      home = make<TimeTrackerHomeCubit>();
      checkIn = make<CheckInCubit>();
      dashboard = make<PersonalDashboardCubit>();
      attendance = make<AttendanceCubit>();
      locations = make<LocationsCubit>();
      employees = make<EmployeesCubit>();
      requestTypes = make<RequestTypesCubit>();
      feed = make<RequestsCubit>();
      actions = make<RequestActionsCubit>();
      hrDashboard = access.canViewHrDashboard ? make<HrDashboardCubit>() : null;
      vacations = access.canViewVacationBalances ? make<VacationBalancesCubit>() : null;
      await Future.wait(<Future<void>>[
        feed.init(),
        home.init(),
        checkIn.init(),
        dashboard.init(),
        attendance.init(),
        locations.init(),
        employees.init(),
        requestTypes.init(),
        if (hrDashboard != null) hrDashboard!.init(),
        if (vacations != null) vacations!.init(),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    if (moduleEntry) _registerEntryCubits(getIt);
    if (moduleEntry) {
      // The real entry builds its own providers from GetIt (KP-TT-003).
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: size,
          builder: (_, __) => GetMaterialApp(
            locale: locale,
            supportedLocales: S.delegate.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: page,
          ),
        ),
      );
      await settle(tester);
      return;
    }
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<TimeTrackerHomeCubit>.value(value: home),
          BlocProvider<CheckInCubit>.value(value: checkIn),
          BlocProvider<PersonalDashboardCubit>.value(value: dashboard),
          BlocProvider<AttendanceCubit>.value(value: attendance),
          BlocProvider<LocationsCubit>.value(value: locations),
          BlocProvider<EmployeesCubit>.value(value: employees),
          BlocProvider<RequestTypesCubit>.value(value: requestTypes),
          BlocProvider<RequestsCubit>.value(value: feed),
          BlocProvider<RequestActionsCubit>.value(value: actions),
          if (hrDashboard != null) BlocProvider<HrDashboardCubit>.value(value: hrDashboard!),
          if (vacations != null) BlocProvider<VacationBalancesCubit>.value(value: vacations!),
        ],
        child: ScreenUtilInit(
          designSize: design,
          // 9/10/2026 (UI pass): renders use GetMaterialApp — the core
          // spinner of a pushed page reads `Get.height`.
          builder: (_, __) => frame != null
              ? GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: locale,
                  supportedLocales: S.delegate.supportedLocales,
                  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: wrap(page),
                )
              : MaterialApp(
                  locale: locale,
                  supportedLocales: S.delegate.supportedLocales,
                  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: page,
                ),
        ),
      ),
    );
    await settle(tester);
  }

  /// Every cubit the module entry asks GetIt for → the instances built here.
  void _registerEntryCubits(GetIt getIt) {
    void put<T extends Object>(T Function() make) {
      if (getIt.isRegistered<T>()) getIt.unregister<T>();
      getIt.registerFactory<T>(make);
      addTearDown(() {
        if (getIt.isRegistered<T>()) getIt.unregister<T>();
      });
    }

    // FRESH instances: the entry's providers create, init and close them;
    // [entryHome] is the home cubit the entry is using (tests drive it).
    put<TimeTrackerHomeCubit>(() => entryHome = _makers[TimeTrackerHomeCubit]!() as TimeTrackerHomeCubit);
    put<CheckInCubit>(() => _makers[CheckInCubit]!() as CheckInCubit);
    put<PersonalDashboardCubit>(() => _makers[PersonalDashboardCubit]!() as PersonalDashboardCubit);
    put<AttendanceCubit>(() => _makers[AttendanceCubit]!() as AttendanceCubit);
    put<LocationsCubit>(() => _makers[LocationsCubit]!() as LocationsCubit);
    put<EmployeesCubit>(() => _makers[EmployeesCubit]!() as EmployeesCubit);
    put<RequestTypesCubit>(() => _makers[RequestTypesCubit]!() as RequestTypesCubit);
    put<RequestsCubit>(() => _makers[RequestsCubit]!() as RequestsCubit);
    put<RequestActionsCubit>(() => _makers[RequestActionsCubit]!() as RequestActionsCubit);
    put<HrDashboardCubit>(() => _makers[HrDashboardCubit]!() as HrDashboardCubit);
    put<VacationBalancesCubit>(() => _makers[VacationBalancesCubit]!() as VacationBalancesCubit);
  }

  /// Builders of every cubit (filled by [pump]).
  final Map<Type, Object Function()> _makers = <Type, Object Function()>{};

  /// 9/10/2026 (UI pass): a FRESH cubit of type [T] over the same fakes
  /// (e.g. for a pushed page that asks GetIt for its own cubit).
  T fresh<T>() => _makers[T]!() as T;

  /// The home cubit the REAL module entry created (`moduleEntry` pumps).
  TimeTrackerHomeCubit? entryHome;

  /// Function Name: [settle]
  ///
  /// Purpose: Let the slide-in / size animations finish (a fixed pump —
  /// Lottie empty states loop, so `pumpAndSettle` would never return).
  ///
  /// Return type: [Future<void>]
  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Function Name: [dispose]
  ///
  /// Purpose: Unmount, then close every cubit.
  ///
  /// Return type: [Future<void>]
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    // 9/10/2026: the real module entry's providers close THEIR (fresh)
    // cubits on unmount — let that finish; the harness's own are closed here.
    await settle(tester);
    await tester.runAsync(() async {
      for (final BlocBase<Object?>? c in <BlocBase<Object?>?>[
        home, checkIn, dashboard, attendance, locations, employees, requestTypes,
        feed, actions, hrDashboard, vacations,
      ]) {
        if (c != null && !c.isClosed) await c.close();
      }
    });
  }
}

/// Upload stub (widget tests never pick a file).
class _NoUploads implements AttachmentBaseRepository {
  @override
  Future<RequestAttachment> uploadRequestAttachment({
    required String employeeEmail,
    required String fileName,
    required List<int> bytes,
  }) async =>
      RequestAttachment(name: fileName, url: 'https://x/$fileName', sizeBytes: bytes.length);

  @override
  Future<String> uploadGroupImage({
    required String uploaderEmail,
    required String fileName,
    required List<int> bytes,
  }) async =>
      'https://x/$fileName';
}
