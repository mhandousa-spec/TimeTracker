/// Module: test / todo / t2_todo_form
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_page_test.dart
/// Purpose: Widget tests for "Creating / Editing To Do List" (round-2 owner
///          rules): disabled Create reveals the missing fields, valid draft
///          enables it, unchanged edit stays disabled, the 3-reminder cap,
///          weekly weekday chips and the "16 Oct 2026" date format.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// The cubit is built through GetIt exactly like the app does, but with test
/// fakes for the repository and the permission service (no Firebase, no
/// GetX controllers). Nothing here taps a control that fires a haptic: the
/// haptic singleton reads GetStorage, which needs a platform channel.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/100-custom_add_row_button.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/controller/todo_form_cubit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/pages/todo_form_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class _FakeRepository implements TodoBaseRepository {
  @override
  Stream<List<TodoEntity>> watchTodos({required String ownerEmail}) =>
      const Stream<List<TodoEntity>>.empty();

  @override
  Future<TodoEntity> createTodo({required TodoEntity todo}) async => todo;

  @override
  Future<void> updateTodo({required TodoEntity todo}) async {}
}

class _FakeAccess implements TodoAccess {
  const _FakeAccess();

  @override
  String get currentUserEmail => 'owner@test.local';
  @override
  bool get canView => true;
  @override
  bool get canCreate => true;
  @override
  bool get canEdit => true;
  @override
  bool get canDelete => true;
  @override
  bool get canRestore => true;
}

/// A tablet-landscape surface (the Figma frames), so the paired layout runs.
const Size _tablet = Size(1194, 834);

Future<void> _pumpForm(WidgetTester tester, {TodoEntity? initial}) async {
  tester.view.physicalSize = _tablet;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _tablet,
      builder: (_, __) => MaterialApp(
        locale: const Locale('en'),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: TodoFormPage(initial: initial),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The page's Scaffold sits below the cubit's provider.
TodoFormCubit _cubitOf(WidgetTester tester) =>
    BlocProvider.of<TodoFormCubit>(tester.element(find.byType(Scaffold)));

/// True when the primary button showing [label] is the enabled (yellow,
/// shrink-on-tap) variant.
bool _isEnabled(String label) => find
    .ancestor(of: find.text(label), matching: find.byType(ShrinkOnTap))
    .evaluate()
    .isNotEmpty;

TodoEntity _valid({
  bool scheduled = false,
  List<TodoReminder> reminders = const <TodoReminder>[],
  bool frequency = false,
  TodoFrequency freq = const TodoFrequency(),
}) =>
    TodoEntity(
      id: 't1',
      ownerEmail: 'owner@test.local',
      name: 'Pay rent',
      priority: TodoPriority.high,
      isScheduled: scheduled,
      startAt: scheduled ? DateTime(2026, 10, 16, 14, 21) : null,
      endAt: scheduled ? DateTime(2026, 10, 17, 9, 5) : null,
      reminders: reminders,
      hasFrequency: frequency,
      frequency: freq,
    );

void main() {
  setUp(() {
    GetIt.instance.registerFactoryParam<TodoFormCubit, TodoEntity?, void>(
      (TodoEntity? initial, _) => TodoFormCubit(
        repository: _FakeRepository(),
        access: const _FakeAccess(),
        logService: const TodoLogService(),
        initial: initial,
      ),
    );
  });

  tearDown(() => GetIt.instance.reset());

  testWidgets('disabled Create: tap reveals the required errors, no dialog',
      (WidgetTester tester) async {
    await _pumpForm(tester);
    final String required = S.current.fieldRequired;

    expect(_isEnabled(S.current.create), isFalse);
    expect(find.text(required), findsNothing);

    await tester.tap(find.text(S.current.create));
    await tester.pumpAndSettle();

    // Name AND Priority are both missing.
    expect(find.text(required), findsNWidgets(2));
    expect(find.text(S.current.creatingToDoTitle), findsNothing);
    final TodoFormState state = _cubitOf(tester).state;
    expect(state.submitAttempted, isTrue);
    expect(state.status, TodoFormStatus.editing);
    expect(_isEnabled(S.current.create), isFalse);
  });

  testWidgets(
      'disabled Create text is the theme-independent dark grey, never the fill',
      (WidgetTester tester) async {
    await _pumpForm(tester);
    final Text label = tester.widget<Text>(find.text(S.current.create));
    expect(label.style?.color, AppColors.colorGreyDark);
    expect(label.style?.color, isNot(AppColors.disabledButton));
  });

  testWidgets('valid draft enables Create', (WidgetTester tester) async {
    await _pumpForm(tester);

    await tester.enterText(find.byType(TextField).first, 'Buy milk');
    await tester.pump();
    expect(_isEnabled(S.current.create), isFalse); // priority still missing

    await tester.tap(find.text(S.current.todoChoose));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.high).last);
    await tester.pumpAndSettle();

    expect(_isEnabled(S.current.create), isTrue);
    expect(find.text(S.current.fieldRequired), findsNothing);
  });

  testWidgets('edit with no change keeps Save disabled; a change enables it',
      (WidgetTester tester) async {
    await _pumpForm(tester, initial: _valid());
    expect(_isEnabled(S.current.save), isFalse);

    // Tapping the disabled Save on a valid, unchanged draft shows nothing.
    await tester.tap(find.text(S.current.save));
    await tester.pumpAndSettle();
    expect(find.text(S.current.fieldRequired), findsNothing);
    expect(find.text(S.current.editingToDoTitle), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'Pay rent today');
    await tester.pump();
    expect(_isEnabled(S.current.save), isTrue);
  });

  testWidgets('"+ Reminder" shows below 3 reminders and hides at 3',
      (WidgetTester tester) async {
    await _pumpForm(
      tester,
      initial: _valid(
        scheduled: true,
        reminders: const <TodoReminder>[TodoReminder(), TodoReminder()],
      ),
    );
    expect(find.byType(CustomAddRowButton), findsOneWidget);

    _cubitOf(tester).addReminder();
    await tester.pumpAndSettle();
    expect(_cubitOf(tester).state.draft.reminders.length, 3);
    expect(find.byType(CustomAddRowButton), findsNothing);
  });

  testWidgets('picking Weekly shows the Sun…Sat chips',
      (WidgetTester tester) async {
    await _pumpForm(tester, initial: _valid(frequency: true));
    expect(find.text('Mon'), findsNothing);

    await tester.tap(find.text(S.current.daily));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.weekly).last);
    await tester.pumpAndSettle();

    for (final String day in <String>[
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ]) {
      expect(find.text(day), findsOneWidget, reason: day);
    }
    expect(
      _cubitOf(tester).state.draft.frequency.unit,
      TodoFrequencyUnit.weekly,
    );
  });

  testWidgets('dates read "16 Oct 2026" and times "02:21 PM"',
      (WidgetTester tester) async {
    await _pumpForm(tester, initial: _valid(scheduled: true));
    expect(find.text('16 Oct 2026'), findsOneWidget);
    expect(find.text('17 Oct 2026'), findsOneWidget);
    expect(find.text('02:21 PM'), findsOneWidget);
    expect(find.text('09:05 AM'), findsOneWidget);
    expect(find.textContaining(','), findsNothing);
  });
}
