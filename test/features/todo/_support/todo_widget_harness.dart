/// Module: test / todo / _support
///
///*************************** FILE INFO ****************************///
/// File Name: todo_widget_harness.dart
/// Purpose: Pumps a To-Do page the way `TodoModuleEntry` does — real
///          `TodoListCubit` + `TodoActionsCubit` (over the test fakes)
///          provided ABOVE the navigator, `TodoAccess` in GetIt — on a
///          tablet-landscape surface with ScreenUtil and the S delegates.
///          The optimistic hooks are bound as in the entry.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/controller/todo_actions_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'todo_test_fakes.dart';

/// The Figma tablet-landscape frame.
const Size kTodoTablet = Size(1194, 834);

/// Everything a widget test needs to drive and inspect the page.
class TodoHarness {
  TodoHarness({FakeTodoAccess? access})
      : access = access ?? FakeTodoAccess(),
        repo = FakeTodoRepository(),
        log = FakeTodoLogService(),
        sweeper = FakeReminderSweeper();

  final FakeTodoAccess access;
  final FakeTodoRepository repo;
  final FakeTodoLogService log;
  final FakeReminderSweeper sweeper;
  late TodoListCubit list;
  late TodoActionsCubit actions;

  /// Function Name: [pump]
  ///
  /// Purpose: Build [page] under the providers and deliver [todos] as the
  /// first Firestore snapshot.
  ///
  /// Return type: [Future<void>]
  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    required List<TodoEntity> todos,
  }) async {
    tester.view.physicalSize = kTodoTablet;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final GetIt getIt = GetIt.instance;
    if (getIt.isRegistered<TodoAccess>()) getIt.unregister<TodoAccess>();
    getIt.registerSingleton<TodoAccess>(access);
    addTearDown(() {
      if (getIt.isRegistered<TodoAccess>()) getIt.unregister<TodoAccess>();
    });

    list = TodoListCubit(
      repository: repo,
      access: access,
      reminderSweeper: sweeper,
    )..init();
    actions = TodoActionsCubit(
      repository: repo,
      access: access,
      logService: log,
    )..bindOptimistic(apply: list.applyLocal, revert: list.revertLocal);

    // Deliver the first snapshot BEFORE the first frame: the loading
    // spinner (core CircleProgressMaster) reads `Get.height`, which needs a
    // GetMaterialApp context the module never has in tests.
    repo.controller.add(todos);
    await tester.pump();
    expect(list.state.status, TodoListStatus.loaded);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<TodoListCubit>(create: (_) => list),
          BlocProvider<TodoActionsCubit>(create: (_) => actions),
        ],
        child: ScreenUtilInit(
          designSize: kTodoTablet,
          builder: (_, __) => MaterialApp(
            locale: const Locale('en'),
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
    await tester.pumpAndSettle();
  }

  /// Function Name: [emit]
  ///
  /// Purpose: Push a new live snapshot (what Firestore does after a write).
  ///
  /// Return type: [Future<void>]
  Future<void> emit(WidgetTester tester, List<TodoEntity> todos) async {
    repo.controller.add(todos);
    await tester.pumpAndSettle();
  }

  /// Function Name: [dispose]
  ///
  /// Purpose: Unmount the tree (closes both cubits, so the one-minute clock
  /// timer is cancelled before the pending-timer check).
  ///
  /// Return type: [Future<void>]
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    unawaited(repo.controller.close());
  }
}
