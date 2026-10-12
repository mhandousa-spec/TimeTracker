/// Module: todo / t3_todo_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_details_card.dart
/// Purpose: Declares `TodoDetailsCard` — the white card of S3 "To Do List
///          Details": check + name, status badges + date/time chips,
///          full description and the editable checklist.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma: 1:31079 (normal), 1:32106 (scheduled weekly), 1:32553 (overdue, red
/// date chip), 1:32256 (deleted), 1:31223 (portrait), 1:34479 (iPhone).
///   * card     — white, radius 8, 15 padding; red 1.5 border when due today.
///   * header   — tablet: check 24 + name (Cairo 16 medium) at the start,
///                badges + date + time chips at the end of the same row.
///                Phone: chips/badges row first, then check + name.
///                Badges, date and time are always ONE row (owner,
///                7/10/2026); if it is too wide it scrolls sideways.
///   * body     — description Cairo 14 grey (line height 20), then checklist.
///
/// Badges and chips are the shared ones from `todo_badges.dart`, so the list
/// card and this card can never draw the same to-do differently.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/widgets/todo_badges.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/ui/widgets/todo_details_checklist.dart';

class TodoDetailsCard extends StatelessWidget {
  const TodoDetailsCard({
    super.key,
    required this.todo,
    required this.now,
    required this.isPhone,
    required this.editable,
    required this.onToggleDone,
    required this.onToggleItem,
    required this.onRemoveItem,
    required this.onAddItem,
  });

  final TodoEntity todo;

  /// The list's clock (`TodoListState.now`).
  final DateTime now;

  /// Phone layout (Figma 1:34479): chips above the name.
  final bool isPhone;

  /// Edit permission and not deleted — enables the check and the checklist
  /// controls.
  final bool editable;

  final VoidCallback onToggleDone;
  final ValueChanged<TodoItem> onToggleItem;
  final ValueChanged<TodoItem> onRemoveItem;
  final ValueChanged<String> onAddItem;

  /// Max share of the tablet header the badge/chip row may take.
  static const double _chipsShare = 0.65;

  @override
  Widget build(BuildContext context) {
    final Widget title = _TitleRow(
      todo: todo,
      onToggleDone: editable ? onToggleDone : null,
    );
    final Widget chips = _ChipsRow(todo: todo, now: now, isPhone: isPhone);
    return Container(
      padding: EdgeInsetsDirectional.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadiusDirectional.circular(8.r),
        border: todo.isDueToday(now)
            ? Border.all(color: AppColors.red, width: 1.5.sp)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (isPhone) ...<Widget>[
            chips,
            SizedBox(height: 15.sp),
            title,
          ] else
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints box) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: title),
                  SizedBox(width: 15.sp),
                  // The chip row takes what it needs (up to 65%); the name
                  // gets the rest.
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: box.maxWidth * _chipsShare),
                    child: chips,
                  ),
                ],
              ),
            ),
          if (todo.description.trim().isNotEmpty) ...<Widget>[
            SizedBox(height: 15.sp),
            Text(
              todo.description,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.secondaryText,
                height: 20 / 14,
              ),
            ),
          ],
          SizedBox(height: 20.sp),
          TodoDetailsChecklist(
            items: todo.items,
            editable: editable,
            onToggle: onToggleItem,
            onRemove: onRemoveItem,
            onAdd: onAddItem,
          ),
        ],
      ),
    );
  }
}

/// Check 24 + full name; the name is struck through once done.
class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.todo, this.onToggleDone});

  final TodoEntity todo;
  final VoidCallback? onToggleDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 3.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TodoCheckIcon(
            isDone: todo.isDone,
            onTap: onToggleDone,
            size: 24.sp,
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Text(
              FormatHelper.capitalize(todo.name),
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.text,
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badges (deleted · scheduled · frequency · progress — the shared
/// `TodoStatusBadges.badgesOf` order) followed by the date then time chips, all in ONE horizontal row that scrolls when it does
/// not fit. End-aligned on tablet, start-aligned on phone.
class _ChipsRow extends StatelessWidget {
  const _ChipsRow({
    required this.todo,
    required this.now,
    required this.isPhone,
  });

  final TodoEntity todo;
  final DateTime now;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    final DateTime? date = todo.displayDate;
    final List<Widget> parts = <Widget>[
      // Restore lives under the card on this screen, not as a badge.
      ...TodoStatusBadges.badgesOf(todo, now, showRestore: false),
      if (date != null) ...<Widget>[
        TodoDateChip.forTodo(todo: todo, now: now),
        TodoTimeChip(date: date),
      ],
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: isPhone
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Tablet keeps the end (date + time) in view when it overflows.
        reverse: !isPhone,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < parts.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: 10.sp),
              parts[i],
            ],
          ],
        ),
      ),
    );
  }
}
