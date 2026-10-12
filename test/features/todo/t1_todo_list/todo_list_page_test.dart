/// Module: test / todo / t1_todo_list
///
///*************************** FILE INFO ****************************///
/// File Name: todo_list_page_test.dart
/// Purpose: Widget tests for S1 "To Do List": tab counts render, tab taps
///          filter the grid, the red "Deleted" badge hides on the Deleted
///          tab, card checklist / check-circle taps call the actions cubit
///          (and do nothing without Edit), Create hidden without Create,
///          search filters cards, stream failure shows the load error.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Taps that fire `HapticController` work because [initTestStorage] opens
/// GetStorage on a temp directory first.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/widgets/todo_badges.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/pages/todo_list_page.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/widgets/todo_card.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/controller/todo_actions_cubit.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/ui/pages/todo_details_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/todo_test_fakes.dart';
import '../_support/todo_widget_harness.dart';

List<TodoEntity> _fixture() {
  final DateTime now = DateTime.now();
  return <TodoEntity>[
    makeTodo(
      'shop',
      name: 'Shopping',
      createdAt: now.subtract(const Duration(hours: 1)),
      items: const <TodoItem>[
        TodoItem(id: 'i1', title: 'Milk'),
        TodoItem(id: 'i2', title: 'Bread'),
      ],
    ),
    makeTodo(
      'done',
      name: 'Pay Rent',
      isDone: true,
      completedAt: now.subtract(const Duration(hours: 2)),
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    makeTodo(
      'gone',
      name: 'Old Idea',
      isDeleted: true,
      deletedAt: now.subtract(const Duration(hours: 3)),
      createdAt: now.subtract(const Duration(days: 2)),
    ),
  ];
}

/// Count rendered for [tab] in the status row.
int _renderedCount(WidgetTester tester, TodoStatusTab tab) {
  final StatusChipFilter row =
      tester.widget<StatusChipFilter>(find.byType(StatusChipFilter));
  return row.items.firstWhere((StatusChipItem i) => i.key == tab.key).count;
}

/// The tab label inside the status row (the badge also says "Deleted").
Finder _tab(String label) => find.descendant(
      of: find.byType(StatusChipFilter),
      matching: find.text(label),
    );

void main() {
  setUpAll(initTestStorage);

  testWidgets('tab counts render; All includes deleted',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    expect(_renderedCount(tester, TodoStatusTab.all), 3);
    expect(_renderedCount(tester, TodoStatusTab.toDo), 1);
    expect(_renderedCount(tester, TodoStatusTab.done), 1);
    expect(_renderedCount(tester, TodoStatusTab.overdue), 0);
    expect(_renderedCount(tester, TodoStatusTab.scheduled), 0);
    expect(_renderedCount(tester, TodoStatusTab.deleted), 1);
    // The digits are on screen inside the count boxes.
    expect(
      find.descendant(
        of: find.byType(StatusChipFilter),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
    expect(find.byType(TodoCard), findsNWidgets(3));
    await h.dispose(tester);
  });

  testWidgets('tapping a tab filters the grid', (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    await tester.tap(_tab(S.current.done));
    await tester.pumpAndSettle();
    expect(h.list.state.tab, TodoStatusTab.done);
    expect(find.byType(TodoCard), findsOneWidget);
    expect(find.text('Pay Rent'), findsOneWidget);
    expect(find.text('Shopping'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('"Deleted" badge shows on All, hides on the Deleted tab',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());
    expect(find.byType(TodoDeletedBadge), findsOneWidget);

    await tester.tap(_tab(S.current.deleted));
    await tester.pumpAndSettle();
    expect(h.list.state.tab, TodoStatusTab.deleted);
    expect(find.byType(TodoCard), findsOneWidget);
    expect(find.text('Old Idea'), findsOneWidget);
    expect(find.byType(TodoDeletedBadge), findsNothing);
    // Restore square still offered (Restore permission on).
    expect(find.byType(TodoRestoreBadge), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('no Restore permission → no restore square on deleted cards',
      (WidgetTester tester) async {
    final TodoHarness h =
        TodoHarness(access: FakeTodoAccess(canRestore: false));
    await h.pump(tester, const TodoListPage(), todos: _fixture());
    expect(find.byType(TodoDeletedBadge), findsOneWidget);
    expect(find.byType(TodoRestoreBadge), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('tapping a checklist line on a card calls toggleItem',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(h.repo.updated, hasLength(1));
    final TodoEntity saved = h.repo.updated.single;
    expect(saved.id, 'shop');
    expect(saved.items.map((TodoItem i) => i.isDone), <bool>[true, false]);
    expect(h.actions.state.kind, TodoActionKind.toggleItem);
    expect(h.actions.state.status, TodoActionStatus.success);
    expect(h.log.actions, isEmpty); // ticks are silent
    // Stayed on the list (did not open details).
    expect(find.byType(TodoDetailsPage), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('tapping the card check-circle marks it done (logged)',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    final Finder shopCard = find.ancestor(
        of: find.text('Shopping'), matching: find.byType(TodoCard));
    await tester.tap(
      find.descendant(of: shopCard, matching: find.byType(TodoCheckIcon)).first,
    );
    await tester.pumpAndSettle();

    expect(h.repo.updated.single.isDone, isTrue);
    expect(h.repo.updated.single.completedAt, isNotNull);
    expect(h.log.actions, <String>['mark to do done']);
    await h.dispose(tester);
  });

  testWidgets('without Edit, a checklist tap writes nothing (opens details)',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness(access: FakeTodoAccess(canEdit: false));
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(h.repo.writeCount, 0);
    expect(find.byType(TodoDetailsPage), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('tapping a card opens its details', (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    await tester.tap(find.text('Pay Rent'));
    await tester.pumpAndSettle();

    final TodoDetailsPage page =
        tester.widget<TodoDetailsPage>(find.byType(TodoDetailsPage));
    expect(page.todoId, 'done');
    await h.dispose(tester);
  });

  testWidgets('Create button follows the Create permission',
      (WidgetTester tester) async {
    final TodoHarness on = TodoHarness();
    await on.pump(tester, const TodoListPage(), todos: _fixture());
    expect(find.text(S.current.createToDo), findsOneWidget);
    await on.dispose(tester);

    final TodoHarness off =
        TodoHarness(access: FakeTodoAccess(canCreate: false));
    await off.pump(tester, const TodoListPage(), todos: _fixture());
    expect(find.text(S.current.createToDo), findsNothing);
    await off.dispose(tester);
  });

  testWidgets('typing in search filters the cards',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    await tester.enterText(find.byType(TextField).first, 'bread');
    await tester.pumpAndSettle();
    expect(h.list.state.query, 'bread');
    expect(find.byType(TodoCard), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('a live snapshot re-renders the grid and counts',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());
    await h.emit(tester, <TodoEntity>[makeTodo('new', name: 'Fresh')]);

    expect(find.byType(TodoCard), findsOneWidget);
    expect(find.text('Fresh'), findsOneWidget);
    expect(_renderedCount(tester, TodoStatusTab.all), 1);
    expect(_renderedCount(tester, TodoStatusTab.deleted), 0);
    await h.dispose(tester);
  });

  testWidgets('stream failure shows the load error, no cards',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    // Start with data (the empty state's Lottie never settles), then fail.
    await h.pump(tester, const TodoListPage(), todos: _fixture());
    h.repo.controller.addError(Exception('denied'));
    await tester.pumpAndSettle();

    expect(h.list.state.status, TodoListStatus.failure);
    expect(find.text(S.current.todoLoadError), findsOneWidget);
    expect(find.byType(TodoCard), findsNothing);
    await h.dispose(tester);
  });
}
