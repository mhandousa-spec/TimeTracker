/// Module: test / todo / t1_todo_list
///
///*************************** FILE INFO ****************************///
/// File Name: todo_card_layout_test.dart
/// Purpose: List card, owner round 3 — description clamped to 2 lines with
///          an ellipsis, a real gap between the checklist preview and the
///          date / time footer, nothing overflowing the grid extent, and a
///          checklist tick showing on the card before any snapshot arrives
///          (optimistic).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/widgets/todo_badges.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/pages/todo_list_page.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/widgets/todo_card.dart';

import '../_support/todo_test_fakes.dart';
import '../_support/todo_widget_harness.dart';

List<TodoEntity> _fixture() {
  final DateTime now = DateTime.now();
  final DateTime start = now.add(const Duration(days: 3));
  return <TodoEntity>[
    makeTodo(
      'long',
      name: 'Notes',
      description: List<String>.filled(40, 'word').join(' '),
      createdAt: now.subtract(const Duration(hours: 1)),
      isScheduled: true,
      startAt: start,
      endAt: start.add(const Duration(hours: 1)),
    ),
    makeTodo(
      'list',
      name: 'Checklist',
      createdAt: now.subtract(const Duration(hours: 2)),
      isScheduled: true,
      startAt: start,
      endAt: start.add(const Duration(hours: 1)),
      items: const <TodoItem>[
        TodoItem(id: 'i1', title: 'Milk'),
        TodoItem(id: 'i2', title: 'Bread'),
        TodoItem(id: 'i3', title: 'Eggs'),
      ],
    ),
  ];
}

Finder _card(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(TodoCard));

void main() {
  setUpAll(initTestStorage);

  testWidgets('description: at most 2 lines, ending in an ellipsis',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    final Text description = tester.widget<Text>(
      find.descendant(
        of: _card('Notes'),
        matching: find.textContaining('word word'),
      ),
    );
    expect(description.maxLines, 2);
    expect(description.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });

  testWidgets('checklist preview keeps a gap above the footer, no overflow',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    final Finder card = _card('Checklist');
    final double lastLineBottom =
        tester.getBottomLeft(find.text('Bread')).dy;
    final double footerTop = tester
        .getTopLeft(
            find.descendant(of: card, matching: find.byType(TodoDateChip)))
        .dy;
    expect(footerTop - lastLineBottom, greaterThanOrEqualTo(8.sp));
    // Footer fully inside the card.
    expect(
      tester
          .getBottomLeft(
              find.descendant(of: card, matching: find.byType(TodoDateChip)))
          .dy,
      lessThanOrEqualTo(tester.getBottomLeft(card).dy),
    );
    // Only two lines are previewed.
    expect(find.text('Eggs'), findsNothing);
    expect(tester.getSize(card).height, closeTo(TodoCard.extent, 0.5));
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });

  testWidgets('a tick shows on the card at once (no snapshot yet)',
      (WidgetTester tester) async {
    final TodoHarness h = TodoHarness();
    await h.pump(tester, const TodoListPage(), todos: _fixture());

    await tester.tap(find.text('Milk'));
    await tester.pump();

    // No new Firestore snapshot was delivered — the optimistic override
    // alone already shows the line ticked.
    expect(h.list.state.byId('list')!.items.first.isDone, isTrue);
    final Finder milkLine = find.ancestor(
      of: find.text('Milk'),
      matching: find.byType(Row),
    );
    final TodoCheckIcon icon = tester.widget<TodoCheckIcon>(
      find.descendant(of: milkLine.first, matching: find.byType(TodoCheckIcon)),
    );
    expect(icon.isDone, isTrue);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });
}
