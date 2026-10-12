/// Module: test / home / h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_card_widths_test.dart
/// Purpose: Owner decision 7/10/2026 — every home card keeps its OWN width.
///          Pumps each `HomeComponents` card inside the three real wrappers
///          (dashboard: `HomeCardMetrics.fitBox` in a horizontal Row inside a
///          SingleChildScrollView · editor: `RemoveComponentWrapper` +
///          `heightBox` in the same kind of Row · picker: `AddComponentWrapper`
///          + `heightBox` in a Wrap) at phone 375x812 and tablet 1180x820, and
///          asserts: no exception / overflow, the card is the same width in all
///          three wrappers, and never wider than `HomeCardMetrics.maxWidthOf`.
///          The three To-Do cards must render at exactly 125 / 260 (`.w`).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// NOT PUMPED (need Firebase / a live GetX employee controller; verified by
/// code reading — each declares its own width, see the file headers):
///   • knowledgeHubOverview, approvalDashboard — `Get.find<MainCoreEmployee
///     Controller>()` in build; root `SizedBox(width: 400.sp)`.
///   • commentsAndFeedbacks, mySettingsRequests — Firestore repositories built
///     in State fields; `HomeWidgetCard(width: kHomeWidgetCompactWidth)`.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/roles_home_stats_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/roles_home_stats_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/add_component_wrapper.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/todo_home_card_parts.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/remove_component_wrapper.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../todo/_support/todo_test_fakes.dart';

/// A surface and the design size main.dart's `_getDesignSize` picks for it.
class _Device {
  const _Device(this.name, this.size, this.design);
  final String name;
  final Size size;
  final Size design;
}

const List<_Device> _devices = <_Device>[
  _Device('phone', Size(375, 812), Size(375, 812)),
  _Device('tablet', Size(1180, 820), Size(1024, 768)),
];

/// Components that cannot be built without Firebase / a live GetX employee
/// controller (see the file header).
const Set<HomeComponents> _notPumpable = <HomeComponents>{
  HomeComponents.unknown,
  HomeComponents.none,
  HomeComponents.knowledgeHubOverview,
  HomeComponents.approvalDashboard,
  HomeComponents.commentsAndFeedbacks,
  HomeComponents.mySettingsRequests,
};

/// Roles counts without Firestore. Implements rather than extends: the real
/// cubit builds three Firestore repositories in its field initialisers.
class _QuietRolesStats extends Cubit<RolesHomeStatsState>
    implements RolesHomeStatsCubit {
  _QuietRolesStats() : super(RolesHomeStatsInitial());

  @override
  Map<RoleStatus, int> roleCounts = <RoleStatus, int>{
    for (final RoleStatus v in RoleStatus.values) v: 0,
  };
  @override
  Map<UserAccessStatus, int> accessCounts = <UserAccessStatus, int>{
    for (final UserAccessStatus v in UserAccessStatus.values) v: 0,
  };
  @override
  Map<EmployeeStatusEnum, int> accountCounts = <EmployeeStatusEnum, int>{
    for (final EmployeeStatusEnum v in EmployeeStatusEnum.values) v: 0,
  };
  @override
  Map<String, int> requestCounts = <String, int>{
    RequestStatusKey.approved: 0,
    RequestStatusKey.pending: 0,
    RequestStatusKey.rejected: 0,
  };

  @override
  void ensureLoaded() {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _NoServicesRepository extends Fake implements CreateServicesRepository {}

/// Services counts without the Firestore load.
class _QuietServicesStats extends ServicesHomeStatsCubit {
  _QuietServicesStats() : super(repository: _NoServicesRepository());

  @override
  void ensureLoaded() {}
}

final FakeTodoRepository _todoRepo = FakeTodoRepository();

/// Loads the app's Cairo font under both families `StyleText` resolves to,
/// so text measures like the device instead of the square test glyphs.
Future<void> _loadAppFont() async {
  final Uint8List bytes = File(
    'assets/fonts/fonts_english/Cairo/Cairo-Regular.ttf',
  ).readAsBytesSync();
  for (final String family in <String>['Cairo', 'CairoArabic']) {
    final FontLoader loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
}

List<TodoEntity> _todos() {
  final DateTime now = DateTime.now();
  return <TodoEntity>[
    makeTodo('a', name: 'Prepare the quarterly report for the board',
        priority: TodoPriority.high,
        createdAt: now.subtract(const Duration(hours: 1)),
        items: const <TodoItem>[
          TodoItem(id: 'i1', title: 'Collect figures'),
          TodoItem(id: 'i2', title: 'Draft summary'),
        ]),
    makeTodo('b', name: 'Call supplier',
        createdAt: now.subtract(const Duration(hours: 2))),
    makeTodo('c', name: 'Book meeting room', isDone: true,
        completedAt: now, priority: TodoPriority.low,
        createdAt: now.subtract(const Duration(hours: 3))),
  ];
}

/// The three placements of [c], each keyed so its card can be measured.
Widget _placements(HomeComponents c) {
  final HomeComponentModel model = c.getModel(rowNumber: 1, columnNumber: 1);
  Widget card(String where) =>
      KeyedSubtree(key: ValueKey<String>(where), child: c.widget(model)!);

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Dashboard — home_screen.dart `_buildComponentsGrid`.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HomeCardMetrics.fitBox(child: card('dashboard')),
            ],
          ),
        ),
        // Layout editor — edit_home_page.dart `item()`.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: HomeCardMetrics.gap,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RemoveComponentWrapper(
                model: model,
                component: HomeCardMetrics.heightBox(child: card('editor')),
              ),
            ],
          ),
        ),
        // Widget picker — adding_widget_page.dart.
        Wrap(
          runSpacing: 3.h,
          spacing: 3.w,
          children: <Widget>[
            AddComponentWrapper(
              model: model,
              component: HomeCardMetrics.heightBox(child: card('picker')),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _pump(WidgetTester tester, _Device device, HomeComponents c) async {
  tester.view.physicalSize = device.size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RolesHomeStatsCubit>(create: (_) => _QuietRolesStats()),
        BlocProvider<ServicesHomeStatsCubit>(
            create: (_) => _QuietServicesStats()),
      ],
      child: ScreenUtilInit(
        designSize: device.design,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => MaterialApp(
          locale: const Locale('en'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: Builder(builder: (_) => _placements(c))),
        ),
      ),
    ),
  );
  _todoRepo.controller.add(_todos());
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(seconds: 2));
}

/// Unmount, then let the cubits' async `close()` cancel their timers.
///
/// `TodoHomeCubit.close()` awaits the stream cancel BEFORE cancelling its
/// one-minute clock, and that cancel future completes in the root zone — so
/// one real event-loop turn (`runAsync`) is needed before the fake clock
/// timer is cancelled.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
}

/// KNOWN, PRE-EXISTING (not width-related): several chart cards overflow
/// their fixed 200 cell VERTICALLY (core `24-custom_chart_card.dart` Column,
/// 0.5–31 px with the Cairo font). Identical with the old 250 fitBox, and in
/// the editor / picker, which already used the charts' own widths. A width
/// regression (horizontal overflow, infinite width) is still a failure.
bool _isKnownChartOverflow(String error) =>
    error.contains('RenderFlex overflowed') && error.contains('on the bottom');

double _widthAt(WidgetTester tester, String where) =>
    tester.getSize(find.byKey(ValueKey<String>(where))).width;

void main() {
  setUpAll(() async {
    await initTestStorage();
    await _loadAppFont();
    final GetIt getIt = GetIt.instance;
    if (!getIt.isRegistered<TodoBaseRepository>()) {
      getIt.registerSingleton<TodoBaseRepository>(_todoRepo);
    }
    if (!getIt.isRegistered<TodoAccess>()) {
      getIt.registerSingleton<TodoAccess>(FakeTodoAccess());
    }
    if (!getIt.isRegistered<TodoLogService>()) {
      getIt.registerSingleton<TodoLogService>(FakeTodoLogService());
    }
  });

  for (final _Device device in _devices) {
    group('${device.name} ${device.size.width.toInt()}x'
        '${device.size.height.toInt()}', () {
      for (final HomeComponents c in HomeComponents.values) {
        if (_notPumpable.contains(c)) continue;

        testWidgets('${c.name}: own width, same in dashboard / editor / '
            'picker, no overflow', (WidgetTester tester) async {
          // Charts: record errors instead of failing on them, then allow ONLY
          // the known vertical overflow (see [_isKnownChartOverflow]).
          final List<String> errors = <String>[];
          final void Function(FlutterErrorDetails)? previous =
              FlutterError.onError;
          if (c.isChart) {
            FlutterError.onError =
                (FlutterErrorDetails d) => errors.add(d.exceptionAsString());
          }
          await _pump(tester, device, c);
          FlutterError.onError = previous;
          expect(tester.takeException(), isNull);
          expect(errors.where((String e) => !_isKnownChartOverflow(e)),
              isEmpty);

          final double cap = HomeCardMetrics.maxWidthOf(
              tester.element(find.byKey(const ValueKey<String>('dashboard'))));
          final double dashboard = _widthAt(tester, 'dashboard');
          expect(dashboard, greaterThan(0));
          expect(dashboard, lessThanOrEqualTo(cap + 0.01));
          expect(_widthAt(tester, 'editor'), closeTo(dashboard, 0.5));
          expect(_widthAt(tester, 'picker'), closeTo(dashboard, 0.5));

          await _unmount(tester);
        });
      }

      testWidgets('To-Do cards render at their own 125 / 260 widths',
          (WidgetTester tester) async {
        final Map<HomeComponents, double Function()> expected =
            <HomeComponents, double Function()>{
          HomeComponents.myTodoList: () => TodoHomeCardMetrics.narrowWidth,
          HomeComponents.myTodoStatus: () => TodoHomeCardMetrics.narrowWidth,
          HomeComponents.MyTodoBox: () => TodoHomeCardMetrics.wideWidth,
        };
        for (final MapEntry<HomeComponents, double Function()> e
            in expected.entries) {
          await _pump(tester, device, e.key);
          final double want = e.value();
          for (final String where in <String>['dashboard', 'editor', 'picker']) {
            expect(_widthAt(tester, where), closeTo(want, 0.01),
                reason: '${e.key.name} in $where');
          }
          // Not the old shared 250.sp any more.
          expect((_widthAt(tester, 'dashboard') - 250.sp).abs(),
              greaterThan(1));
          await _unmount(tester);
        }
      });
    });
  }
}
