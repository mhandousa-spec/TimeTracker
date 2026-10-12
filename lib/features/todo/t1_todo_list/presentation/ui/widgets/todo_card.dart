/// Module: todo / t1_todo_list / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_card.dart
/// Purpose: Declares `TodoCard` — one to-do in the list grid.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma card (282 x 155, white, radius 8, 10 padding — the grid gives it
/// [TodoCard.extent], a little taller, so nothing is ever clipped):
///   top-end badges (progress · scheduled · frequency · deleted)
///   checkbox 20 + name (Cairo 14, ONE line, struck through when done)
///   description (Cairo 11 grey, at most 2 lines then "…") OR up to 2
///     checklist lines (each ticks in place when [TodoCard.onToggleItem] set)
///   [_footerGap] · footer: date chip · time chip (both from `displayDate`)
/// Red 1.5 border when the to-do is due today (owner decision 7/10/2026).
/// Updated: 7/10/2026 - Owner round 3: description 2 lines + ellipsis (no
///          half-visible third line), a fixed gap above the footer, line
///          heights pinned so the content always fits [TodoCard.extent].

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/widgets/todo_badges.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.now,
    required this.onTap,
    this.onToggleDone,
    this.onToggleItem,
    this.onRestore,
    this.showDeletedBadge = true,
  });

  final TodoEntity todo;

  /// The list's clock (`TodoListState.now`).
  final DateTime now;

  /// Opens the details screen. Haptics are fired by the caller.
  final VoidCallback onTap;

  /// Null when the user cannot edit — the checkbox becomes display-only.
  final VoidCallback? onToggleDone;

  /// Tap on a previewed checklist line; null = display-only (no edit
  /// permission or deleted). Haptics are fired by the caller.
  final ValueChanged<TodoItem>? onToggleItem;

  /// Tap on the restore badge of a deleted to-do; null hides it.
  final VoidCallback? onRestore;

  /// False on the Deleted tab, where the red "Deleted" badge is redundant.
  final bool showDeletedBadge;

  /// Checklist lines previewed on the card (Figma shows two).
  static const int _previewItems = 2;

  /// Grid row height (`mainAxisExtent`) for every card. Worst case = badges
  /// 28 + 5 · title 21 + 4 · two checklist lines 20 + 6 + 20 · gap 10 ·
  /// footer 28 · padding 20 = 162; the rest is headroom. Figma draws 155,
  /// which clipped the footer gap (owner, round 3).
  static double get extent => 170.sp;

  /// Space between the description / checklist and the date-time footer.
  static double get _footerGap => 10.sp;

  @override
  Widget build(BuildContext context) {
    final bool dueToday = todo.isDueToday(now);
    final DateTime? date = todo.displayDate;

    // GestureDetector, not InkWell: no hover / splash highlight (owner, 7/10/2026).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadiusDirectional.circular(8.r),
          border:
              dueToday ? Border.all(color: AppColors.red, width: 1.5.sp) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (TodoStatusBadges.hasAny(
              todo,
              now,
              showRestore: onRestore != null,
              showDeletedBadge: showDeletedBadge,
            )) ...<Widget>[
              TodoStatusBadges(
                todo: todo,
                now: now,
                onRestore: onRestore,
                showRestore: onRestore != null,
                showDeletedBadge: showDeletedBadge,
              ),
              SizedBox(height: 5.sp),
            ],
            _TitleRow(todo: todo, onToggleDone: onToggleDone),
            SizedBox(height: 4.sp),
            Expanded(
              // Sized so the content fits [extent]; the never-scrolling
              // viewport is only a safety net against a RenderFlex overflow
              // (e.g. a huge accessibility text scale).
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 25.sp),
                  child: todo.items.isEmpty
                      ? _Description(text: todo.description)
                      : _ItemsPreview(
                          items: todo.items.take(_previewItems).toList(),
                          onToggle: onToggleItem,
                        ),
                ),
              ),
            ),
            if (date != null) ...<Widget>[
              SizedBox(height: _footerGap),
              Row(
                children: <Widget>[
                  TodoDateChip.forTodo(todo: todo, now: now),
                  const Spacer(),
                  TodoTimeChip(date: date),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Checkbox + name; the name is struck through once done.
class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.todo, this.onToggleDone});

  final TodoEntity todo;
  final VoidCallback? onToggleDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        TodoCheckIcon(isDone: todo.isDone, onTap: onToggleDone),
        SizedBox(width: 5.sp),
        Expanded(
          child: Text(
            FormatHelper.capitalize(todo.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
              height: 1.5,
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

/// Description clamped to TWO lines, ending in "…" (owner, round 3 — a third
/// line used to show cut through the middle).
class _Description extends StatelessWidget {
  const _Description({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: StyleText.fontSize11Weight400
          .copyWith(color: AppColors.secondaryText, height: 1.7),
    );
  }
}

/// Up to two checklist lines. With [onToggle] set, tapping a line ticks it
/// in place; the line's own detector wins the gesture arena, so the card's
/// "open details" tap does not fire. With [onToggle] null the taps fall
/// through to the card.
class _ItemsPreview extends StatelessWidget {
  const _ItemsPreview({required this.items, this.onToggle});

  final List<TodoItem> items;
  final ValueChanged<TodoItem>? onToggle;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<TodoItem>? toggle = onToggle;
    // Gap only BETWEEN lines; the gap to the footer is the card's own.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.sp,
      children: <Widget>[
        for (final TodoItem item in items)
          _ItemLine(
            item: item,
            onTap: toggle == null ? null : () => toggle(item),
          ),
      ],
    );
  }
}

/// One previewed checklist line: check + title, tappable when [onTap] is set.
class _ItemLine extends StatelessWidget {
  const _ItemLine({required this.item, this.onTap});

  final TodoItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget line = Row(
      children: <Widget>[
        TodoCheckIcon(isDone: item.isDone),
        SizedBox(width: 5.sp),
        Expanded(
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.text,
              height: 1.5,
              decoration: item.isDone ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.text,
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return line;
    return Semantics(
      button: true,
      checked: item.isDone,
      label: item.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: line,
      ),
    );
  }
}
