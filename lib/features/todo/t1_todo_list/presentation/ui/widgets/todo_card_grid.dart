/// Module: todo / t1_todo_list / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_card_grid.dart
/// Purpose: Declares `TodoCardGrid` — the cards in 3 columns (iPad
///          landscape), 2 (iPad portrait) or 1 (phone).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// The grid is the page's only scrolling area (the header above it stays
/// fixed).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/54-custom_grid_view.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/widgets/todo_card.dart';

class TodoCardGrid extends StatelessWidget {
  const TodoCardGrid({
    super.key,
    required this.todos,
    required this.now,
    required this.onOpen,
    this.onToggleDone,
    this.onToggleItem,
    this.onRestore,
    this.showDeletedBadge = true,
  });

  final List<TodoEntity> todos;
  final DateTime now;

  /// Card tap.
  final ValueChanged<TodoEntity> onOpen;

  /// Checkbox tap; null when the user cannot edit.
  final ValueChanged<TodoEntity>? onToggleDone;

  /// Previewed checklist-line tap (to-do, item); null when the user cannot
  /// edit. Never wired for deleted to-dos.
  final void Function(TodoEntity todo, TodoItem item)? onToggleItem;

  /// Restore badge tap on deleted cards; null hides the badge.
  final ValueChanged<TodoEntity>? onRestore;

  /// False on the Deleted tab (the red "Deleted" badge would be redundant).
  final bool showDeletedBadge;

  @override
  Widget build(BuildContext context) {
    // Same column rules as the other modules (core/custom/54): 1–2 on phone,
    // 2–3 tablet, 4–5 on wide desktop windows (owner: 3 big cards was too much).
    final int columns = CrossAxisCountHelperResponsive
        .getCrossAxisCountForDefaultTabletResponsive(context);
    final ValueChanged<TodoEntity>? toggle = onToggleDone;
    final ValueChanged<TodoEntity>? restore = onRestore;
    final void Function(TodoEntity, TodoItem)? toggleItem = onToggleItem;

    // Scrolls by itself inside the page's Expanded (bug 7/10/2026).
    return GridView.builder(
      padding: EdgeInsetsDirectional.only(bottom: 20.sp),
      itemCount: todos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 15.sp,
        mainAxisSpacing: 15.sp,
        // One height for every card (Figma 155, grown so the footer gap
        // never clips — see TodoCard.extent).
        mainAxisExtent: TodoCard.extent,
      ),
      itemBuilder: (BuildContext context, int index) {
        final TodoEntity todo = todos[index];
        return TodoCard(
          key: ValueKey<String>(todo.id),
          todo: todo,
          now: now,
          onTap: () => onOpen(todo),
          onToggleDone:
              toggle == null || todo.isDeleted ? null : () => toggle(todo),
          onToggleItem: toggleItem == null || todo.isDeleted
              ? null
              : (TodoItem item) => toggleItem(todo, item),
          onRestore: restore == null ? null : () => restore(todo),
          showDeletedBadge: showDeletedBadge,
        );
      },
    );
  }
}
