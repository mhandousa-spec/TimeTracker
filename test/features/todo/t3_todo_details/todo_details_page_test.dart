/// Module: test / todo / t3_todo_details
///
///*************************** FILE INFO ****************************///
/// File Name: todo_details_page_test.dart
/// Purpose: Widget tests for "To Do List Details": which of Edit / Delete /
///          Restore show for each permission mix and for a deleted to-do,
///          checklist tick / remove / "+ item" reaching the actions cubit,
///          the read-only checklist without Edit, and the live re-render
///          when the stream changes.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/100-custom_add_row_button.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/widgets/todo_badges.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/ui/pages/todo_details_page.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/ui/widgets/todo_details_actions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/todo_test_fakes.dart';
import '../_support/todo_widget_harness.dart';

const List<TodoItem> _items = <TodoItem>[
  TodoItem(id: 'i1', title: 'Milk'),
  TodoItem(id: 'i2', title: 'Bread', isDone: true),
];

TodoEntity _live() => makeTodo(
      'live',
      name: 'Shopping',
      description: 'Weekly groceries',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      items: _items,
    );

TodoEntity _deleted() => makeTodo(
      'gone',
      name: 'Old Idea',
      isDeleted: true,
      deletedAt: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      items: _items,
    );

Finder get _edit => find.text(S.current.edit);
Finder get _delete => find.text(S.current.delete);
Finder get _restore => find.text(S.current.restore);

/// The tappable pill of the core "+ item" button (its Align box is wider).
Finder get _addItemButton => find.descendant(
      of: find.byType(CustomAddRowButton),
      matching: find.byType(GestureDetector),
    );

/// The ⊖ remove buttons of the checklist.
Finder get _removeButtons => find.ancestor(
      of: find.byWidgetPredicate(
        (Widget w) =>
            w is CustomSvgImage && w.assetPath == AppAssets.minusCircle,
      ),
      matching: find.byType(GestureDetector),
    );

Future<TodoHarness> _pump(
  WidgetTester tester,
  TodoEntity todo, {
  FakeTodoAccess? access,
}) async {
  final TodoHarness h = TodoHarness(access: access);
  await h.pump(
    tester,
    TodoDetailsPage(todoId: todo.id),
    todos: <TodoEntity>[todo],
  );
  return h;
}

void main() {
  setUpAll(initTestStorage);

  group('action buttons by permission', () {
    testWidgets('live to-do, full access: Edit + Delete, no Restore',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      expect(find.byType(TodoDetailsActions), findsOneWidget);
      expect(_edit, findsOneWidget);
      expect(_delete, findsOneWidget);
      expect(_restore, findsNothing);
      expect(find.text('Shopping'), findsWidgets);
      await h.dispose(tester);
    });

    testWidgets('no Edit: Delete only', (WidgetTester tester) async {
      final TodoHarness h =
          await _pump(tester, _live(), access: FakeTodoAccess(canEdit: false));
      expect(_edit, findsNothing);
      expect(_delete, findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('no Delete: Edit only', (WidgetTester tester) async {
      final TodoHarness h = await _pump(
        tester,
        _live(),
        access: FakeTodoAccess(canDelete: false),
      );
      expect(_edit, findsOneWidget);
      expect(_delete, findsNothing);
      await h.dispose(tester);
    });

    testWidgets('no Edit and no Delete: action row gone',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(
        tester,
        _live(),
        access: FakeTodoAccess(canEdit: false, canDelete: false),
      );
      expect(find.byType(TodoDetailsActions), findsNothing);
      expect(_edit, findsNothing);
      expect(_delete, findsNothing);
      await h.dispose(tester);
    });

    testWidgets('deleted to-do shows ONLY Restore (no Edit / Delete)',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _deleted());
      expect(_restore, findsOneWidget);
      expect(find.byType(TodoDetailsRestoreButton), findsOneWidget);
      expect(_edit, findsNothing);
      expect(_delete, findsNothing);
      expect(find.byType(TodoDetailsActions), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('deleted to-do without Restore permission: no buttons at all',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(
        tester,
        _deleted(),
        access: FakeTodoAccess(canRestore: false),
      );
      expect(_restore, findsNothing);
      expect(_edit, findsNothing);
      expect(_delete, findsNothing);
      await h.dispose(tester);
    });

    testWidgets('deleted to-do checklist is read-only (no ⊖, no + item)',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _deleted());
      expect(_removeButtons, findsNothing);
      expect(find.byType(CustomAddRowButton), findsNothing);
      await tester.tap(find.text('Milk'));
      await tester.pumpAndSettle();
      expect(h.repo.writeCount, 0);
      await h.dispose(tester);
    });
  });

  group('checklist', () {
    testWidgets('tick a line → toggleItem write, silent',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      final Finder milkRow = find.ancestor(
        of: find.text('Milk'),
        matching: find.byType(Row),
      );
      await tester.tap(
        find.descendant(
            of: milkRow.first, matching: find.byType(TodoCheckIcon)),
      );
      await tester.pumpAndSettle();
      expect(h.repo.updated, hasLength(1));
      expect(
        h.repo.updated.single.items.map((TodoItem i) => i.isDone),
        <bool>[true, true],
      );
      expect(h.log.actions, isEmpty);
      await h.dispose(tester);
    });

    testWidgets('⊖ removes that line and logs update',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      expect(_removeButtons, findsNWidgets(2));
      await tester.tap(_removeButtons.first);
      await tester.pumpAndSettle();
      expect(
        h.repo.updated.single.items.map((TodoItem i) => i.id),
        <String>['i2'],
      );
      expect(h.log.actions, <String>[TodoLogService.actionUpdate]);
      await h.dispose(tester);
    });

    testWidgets('"+ item" opens a field; submitting adds the line',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      await tester.tap(_addItemButton);
      await tester.pumpAndSettle();
      final Finder field = find.byType(TextField);
      expect(field, findsOneWidget);

      await tester.enterText(field, 'Eggs');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final List<TodoItem> items = h.repo.updated.single.items;
      expect(items.map((TodoItem i) => i.title), <String>[
        'Milk',
        'Bread',
        'Eggs',
      ]);
      expect(h.log.actions, <String>[TodoLogService.actionUpdate]);
      await h.dispose(tester);
    });

    testWidgets('"+ item" with an empty field just closes it, no write',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      await tester.tap(_addItemButton);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(_addItemButton);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(h.repo.writeCount, 0);
      await h.dispose(tester);
    });

    testWidgets('without Edit the checklist is read-only',
        (WidgetTester tester) async {
      final TodoHarness h =
          await _pump(tester, _live(), access: FakeTodoAccess(canEdit: false));
      expect(_removeButtons, findsNothing);
      expect(find.byType(CustomAddRowButton), findsNothing);
      await tester.tap(find.text('Milk'));
      await tester.pumpAndSettle();
      expect(h.repo.writeCount, 0);
      await h.dispose(tester);
    });
  });

  group('confirm flows', () {
    /// Advance frames without pumpAndSettle (the dialogs' Lotties loop).
    Future<void> step(WidgetTester tester, [int frames = 20]) async {
      for (int i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('Delete → Yes soft-deletes and logs delete',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      await tester.tap(_delete);
      await step(tester);
      expect(find.text(S.current.deletingToDoList), findsOneWidget);
      await tester.tap(find.text(S.current.yes));
      await step(tester, 60);

      expect(h.repo.updated.single.isDeleted, isTrue);
      expect(h.repo.updated.single.deletedAt, isNotNull);
      expect(h.log.actions, <String>[TodoLogService.actionDelete]);
      await h.dispose(tester);
    });

    testWidgets('Delete → No writes nothing', (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      await tester.tap(_delete);
      await step(tester);
      await tester.tap(find.text(S.current.no));
      await step(tester);
      expect(h.repo.writeCount, 0);
      expect(h.log.actions, isEmpty);
      await h.dispose(tester);
    });

    testWidgets('Restore → Yes restores and logs restore',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _deleted());
      await tester.tap(_restore);
      await step(tester);
      expect(find.text(S.current.restoringToDo), findsOneWidget);
      await tester.tap(find.text(S.current.yes));
      await step(tester, 60);

      expect(h.repo.updated.single.isDeleted, isFalse);
      expect(h.repo.updated.single.deletedAt, isNull);
      expect(h.log.actions, <String>[TodoLogService.actionRestore]);
      await h.dispose(tester);
    });

    testWidgets('Delete failing in the repository shows the error dialog',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      h.repo.failWith = Exception('offline');
      await tester.tap(_delete);
      await step(tester);
      await tester.tap(find.text(S.current.yes));
      await step(tester, 60);

      expect(h.repo.writeCount, 0);
      expect(h.log.actions, isEmpty);
      expect(find.text(S.current.errorOccurred), findsOneWidget);
      expect(find.text(S.current.todoSaveError), findsOneWidget);
      await h.dispose(tester);
    });
    testWidgets('permission revoked while open: Delete → Yes → no-permission',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      h.access.canDelete = false; // admin switched it off; screen is stale
      await tester.tap(_delete);
      await step(tester);
      await tester.tap(find.text(S.current.yes));
      await step(tester, 60);

      expect(h.repo.writeCount, 0);
      expect(find.text(S.current.todoNoPermission), findsOneWidget);
      await h.dispose(tester);
    });
  });

  group('live data', () {
    testWidgets('a new snapshot re-renders the details',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      await h.emit(tester, <TodoEntity>[
        _live().copyWith(
          items: const <TodoItem>[TodoItem(id: 'i9', title: 'Cheese')],
        ),
      ]);
      expect(find.text('Cheese'), findsOneWidget);
      expect(find.text('Milk'), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('soft-deleted on the stream → buttons flip to Restore',
        (WidgetTester tester) async {
      final TodoHarness h = await _pump(tester, _live());
      expect(_delete, findsOneWidget);
      await h.emit(tester, <TodoEntity>[
        _live().copyWith(isDeleted: true, deletedAt: DateTime.now()),
      ]);
      expect(_delete, findsNothing);
      expect(_edit, findsNothing);
      expect(_restore, findsOneWidget);
      await h.dispose(tester);
    });
  });
}
