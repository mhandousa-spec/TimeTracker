/// Module: todo / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_badges.dart
/// Purpose: Declares every reusable chip / badge the To-Do screens draw:
///          `TodoBadge` (base), `TodoProgressBadge` ("2/5"),
///          `TodoScheduledBadge` ("Scheduled: 12 Feb 2025 At 10:30 PM"),
///          `TodoFrequencyBadge` ("Frequency: Weekly"), `TodoDeletedBadge`,
///          `TodoRestoreBadge`, `TodoStatusBadges` (the top-end row of a card),
///          `TodoDateChip`, `TodoTimeChip` and `TodoCheckIcon`.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - Round 2: one chip height + radius 8, dates without
///          commas ('dd MMM yyyy').
/// Updated: 7/10/2026 - Badge order Deleted → Scheduled → Frequency →
///          Progress (then Date, Time where shown).
///
/// Shared by the list card (t1) and the details card (t3) so the two screens
/// can never draw the same to-do differently.
///
/// Figma (LIST TO DO, card 282 x 155), adjusted by the owner (round 2,
/// 7/10/2026): EVERY badge and chip shares one height ([TodoChipMetrics.height])
/// and one radius ([TodoChipMetrics.radius] = 8), so a row of them lines up.
///   * badges   — 8 horizontal padding, Cairo 10 regular, yellow fill
///                (`main` #FFDE59), red fill for "Deleted".
///   * chips    — #F5F5F5 fill, 16 icon + 5 gap, Cairo 10 regular grey; red
///                (overdue) / green (done on time) fill with white content.
///   * dates    — `LocalizedDate.of(context, d)` → "16 Oct 2026" /
///                "١٦ أكتوبر ٢٠٢٦" (no commas); times 'hh:mm a' → "02:21 PM".
///   * checkbox — 20 x 20 outlined check, yellow filled when done.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Asset paths used by the badges and chips (all existing app icons).
abstract final class TodoBadgeAssets {
  static const String checkEmpty =
      'assets/icons_assets/main_icons_assets/checkbox_checked_gray.svg';
  static const String checkDone =
      'assets/icons_assets/main_icons_assets/checkbox_checked_yellow.svg';
  static const String calendar =
      'assets/icons_assets/main_icons_assets/images_Calendar.svg';
  static const String clock =
      'assets/icons_assets/main_icons_assets/clock_circle.svg';
}

/// Shared size of every To-Do badge and chip (owner, round 2: same height,
/// radius 8). Unscaled; callers apply `.sp` / `.r`.
abstract final class TodoChipMetrics {
  /// Height of every badge, chip and the restore square.
  static const double height = 28;

  /// Corner radius of every badge and chip.
  static const double radius = 8;
}

/// Time pattern of the time chip and the scheduled badge — "02:21 PM".
/// Dates use `LocalizedDate.of`'s default ('dd MMM yyyy' → "16 Oct 2026").
const String kTodoChipTimePattern = 'hh:mm a';

/// Base pill every badge is built from.
///
/// API: `TodoBadge(label: '2/5')` → yellow badge with dark text.
/// Pass [color] / [textColor] for another fill (the red "Deleted" badge).
class TodoBadge extends StatelessWidget {
  const TodoBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  final String label;

  /// Fill; defaults to `AppColors.primary`.
  final Color? color;

  /// Text colour; defaults to `AppColors.textButton` (text on yellow).
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TodoChipMetrics.height.sp,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.sp),
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius:
            BorderRadiusDirectional.circular(TodoChipMetrics.radius.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize10Weight400
            .copyWith(color: textColor ?? AppColors.textButton),
      ),
    );
  }
}

/// Checklist progress badge — "2/5" (done / total), localised digits.
///
/// API: `TodoProgressBadge(todo: todo)`. Draws nothing when the to-do has no
/// checklist items.
class TodoProgressBadge extends StatelessWidget {
  const TodoProgressBadge({super.key, required this.todo});

  final TodoEntity todo;

  @override
  Widget build(BuildContext context) {
    if (todo.items.isEmpty) return const SizedBox.shrink();
    return TodoBadge(
      label: LocalizedNumber.digits(
        context,
        '${todo.completedItemsCount}/${todo.items.length}',
      ),
    );
  }
}

/// "Scheduled: 12 Feb 2025 At 10:30 PM" (`S.todoScheduledAt`) — date via
/// `LocalizedDate.of` (no commas), time 'hh:mm a'.
///
/// API: `TodoScheduledBadge(date: todo.startAt!)` — pass the start time.
class TodoScheduledBadge extends StatelessWidget {
  const TodoScheduledBadge({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return TodoBadge(
      label: S.of(context).todoScheduledAt(
            LocalizedDate.of(context, date),
            LocalizedDate.of(context, date, pattern: kTodoChipTimePattern),
          ),
    );
  }
}

/// "Frequency: Weekly" (`S.todoFrequencyBadge`). With an interval above 1 the
/// value reads "Every 2 Weeks" (`S.todoEveryInterval`).
///
/// API: `TodoFrequencyBadge(frequency: todo.frequency)`; also exposes
/// [TodoFrequencyBadge.valueOf] for screens that need the bare text.
class TodoFrequencyBadge extends StatelessWidget {
  const TodoFrequencyBadge({super.key, required this.frequency});

  final TodoFrequency frequency;

  /// Function Name: [valueOf]
  ///
  /// Purpose: The recurrence as text — "Weekly", or "Every 2 Weeks".
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///   [TodoFrequency] frequency
  ///
  /// Return type: [String]
  static String valueOf(BuildContext context, TodoFrequency frequency) {
    if (frequency.interval <= 1) return frequency.unit.label(context);
    final S s = S.of(context);
    final String unit;
    switch (frequency.unit) {
      case TodoFrequencyUnit.daily:
        unit = s.days;
      case TodoFrequencyUnit.weekly:
        unit = s.weeks;
      case TodoFrequencyUnit.monthly:
        unit = s.months;
    }
    return s.todoEveryInterval(
      LocalizedNumber.of(context, frequency.interval),
      unit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TodoBadge(
      label: S.of(context).todoFrequencyBadge(valueOf(context, frequency)),
    );
  }
}

/// Red "Deleted" badge shown on soft-deleted to-dos.
///
/// API: `const TodoDeletedBadge()`.
class TodoDeletedBadge extends StatelessWidget {
  const TodoDeletedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return TodoBadge(
      label: S.of(context).deleted,
      color: AppColors.red,
      textColor: AppColors.white,
    );
  }
}

/// Small yellow restore square beside "Deleted" — same height as the badges.
///
/// API: `TodoRestoreBadge(onTap: …)`. With [onTap] null it is display-only.
/// Haptics are the caller's job (restore opens a confirm flow).
class TodoRestoreBadge extends StatelessWidget {
  const TodoRestoreBadge({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Semantics(
        button: onTap != null,
        label: S.of(context).restore,
        child: Container(
          width: TodoChipMetrics.height.sp,
          height: TodoChipMetrics.height.sp,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius:
                BorderRadiusDirectional.circular(TodoChipMetrics.radius.r),
          ),
          child: Icon(
            Icons.restore_rounded,
            size: 14.sp,
            color: AppColors.textButton,
          ),
        ),
      ),
    );
  }
}

/// The top-end badge row of a to-do card, in the owner's order (7/10/2026):
/// deleted + restore · scheduled (only while upcoming) · frequency · progress.
/// Everywhere a date / time chip follows, it comes after these: Date, Time.
///
/// API: `TodoStatusBadges(todo: todo, now: state.now, onRestore: …)`.
/// Use [hasAny] to decide whether to reserve the row at all, and [badgesOf]
/// when the badges must share one row with other chips (details screen).
class TodoStatusBadges extends StatelessWidget {
  const TodoStatusBadges({
    super.key,
    required this.todo,
    required this.now,
    this.onRestore,
    this.showRestore = true,
    this.showDeletedBadge = true,
  });

  final TodoEntity todo;
  final DateTime now;

  /// Tap on the restore badge (deleted to-dos only).
  final VoidCallback? onRestore;

  /// Hide the restore badge (e.g. when the user lacks Restore).
  final bool showRestore;

  /// Hide the red "Deleted" badge — redundant on the Deleted tab, where every
  /// card is deleted (owner, 7/10/2026).
  final bool showDeletedBadge;

  /// Function Name: [hasAny]
  ///
  /// Purpose: Whether [todo] shows at least one badge at [now] with the same
  /// visibility flags the row will be built with.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [DateTime] now
  ///   [bool] showRestore
  ///   [bool] showDeletedBadge
  ///
  /// Return type: [bool]
  static bool hasAny(
    TodoEntity todo,
    DateTime now, {
    bool showRestore = true,
    bool showDeletedBadge = true,
  }) =>
      todo.items.isNotEmpty ||
      todo.isUpcoming(now) ||
      todo.hasFrequency ||
      (todo.isDeleted && (showDeletedBadge || showRestore));

  /// Function Name: [badgesOf]
  ///
  /// Purpose: The badges of [todo] at [now] (Deleted → Scheduled → Frequency
  /// → Progress), without any row
  /// or spacing around them.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [DateTime] now
  ///   [VoidCallback?] onRestore
  ///   [bool] showRestore
  ///   [bool] showDeletedBadge
  ///
  /// Return type: [List<Widget>]
  static List<Widget> badgesOf(
    TodoEntity todo,
    DateTime now, {
    VoidCallback? onRestore,
    bool showRestore = true,
    bool showDeletedBadge = true,
  }) {
    final DateTime? start = todo.startAt;
    // Owner order (7/10/2026): Deleted (+ restore) → Scheduled → Frequency →
    // Progress. Callers that also show chips append Date then Time after it.
    // A plain Row, so RTL simply mirrors the same order.
    return <Widget>[
      if (todo.isDeleted && showDeletedBadge) const TodoDeletedBadge(),
      if (todo.isDeleted && showRestore) TodoRestoreBadge(onTap: onRestore),
      if (todo.isUpcoming(now) && start != null)
        TodoScheduledBadge(date: start),
      if (todo.hasFrequency) TodoFrequencyBadge(frequency: todo.frequency),
      if (todo.items.isNotEmpty) TodoProgressBadge(todo: todo),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = badgesOf(
      todo,
      now,
      onRestore: onRestore,
      showRestore: showRestore,
      showDeletedBadge: showDeletedBadge,
    );
    // ONE row, always (bug 7/10/2026: a Wrap stacked the badges on narrow
    // cards). If they don't fit they scroll sideways instead of wrapping.
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < badges.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: 6.sp),
              badges[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Visual state of a [TodoDateChip].
enum TodoDateChipTone { normal, overdue, doneOnTime }

/// Footer date chip — "16 Oct 2026" with a calendar icon.
/// Grey normally, red when overdue, green when done on/before the end time.
///
/// API: `TodoDateChip.forTodo(todo: todo, now: now)` picks date + tone from
/// the entity (`displayDate`, `isOverdue`, `isDoneOnTime`); or build one
/// directly with `TodoDateChip(date: d, tone: …)`.
class TodoDateChip extends StatelessWidget {
  const TodoDateChip({
    super.key,
    required this.date,
    this.tone = TodoDateChipTone.normal,
  });

  /// Function Name: [forTodo]
  ///
  /// Purpose: Chip for a to-do's display date with the right colour, or an
  /// empty box when the to-do has no date.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [DateTime] now
  ///
  /// Return type: [Widget]
  static Widget forTodo({required TodoEntity todo, required DateTime now}) {
    final DateTime? date = todo.displayDate;
    if (date == null) return const SizedBox.shrink();
    final TodoDateChipTone tone = todo.isOverdue(now)
        ? TodoDateChipTone.overdue
        : (todo.isDoneOnTime && todo.endAt != null
            ? TodoDateChipTone.doneOnTime
            : TodoDateChipTone.normal);
    return TodoDateChip(date: date, tone: tone);
  }

  final DateTime date;
  final TodoDateChipTone tone;

  @override
  Widget build(BuildContext context) {
    final Color? fill;
    switch (tone) {
      case TodoDateChipTone.normal:
        fill = null;
      case TodoDateChipTone.overdue:
        fill = AppColors.red;
      case TodoDateChipTone.doneOnTime:
        fill = AppColors.green;
    }
    return _TodoInfoChip(
      iconPath: TodoBadgeAssets.calendar,
      label: LocalizedDate.of(context, date),
      fill: fill,
    );
  }
}

/// Footer time chip — "02:21 PM" with a clock icon. Always grey.
///
/// API: `TodoTimeChip(date: todo.displayDate!)`.
class TodoTimeChip extends StatelessWidget {
  const TodoTimeChip({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return _TodoInfoChip(
      iconPath: TodoBadgeAssets.clock,
      label: LocalizedDate.of(context, date, pattern: kTodoChipTimePattern),
    );
  }
}

/// Shared shape of the date and time chips. [fill] null = grey chip.
class _TodoInfoChip extends StatelessWidget {
  const _TodoInfoChip({
    required this.iconPath,
    required this.label,
    this.fill,
  });

  final String iconPath;
  final String label;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final Color content =
        fill == null ? AppColors.secondaryText : AppColors.white;
    return Container(
      height: TodoChipMetrics.height.sp,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.sp),
      decoration: BoxDecoration(
        color: fill ?? AppColors.background,
        borderRadius:
            BorderRadiusDirectional.circular(TodoChipMetrics.radius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomSvgImage(
            assetPath: iconPath,
            width: 16.sp,
            height: 16.sp,
            fit: BoxFit.contain,
            color: content,
          ),
          SizedBox(width: 5.sp),
          Text(
            label,
            maxLines: 1,
            style: StyleText.fontSize10Weight400.copyWith(color: content),
          ),
        ],
      ),
    );
  }
}

/// The to-do checkbox: outlined grey check, yellow filled when [isDone].
///
/// API: `TodoCheckIcon(isDone: todo.isDone, onTap: …, size: 20.sp)`.
/// With [onTap] null it is display-only (no edit permission). Haptics are the
/// caller's job.
class TodoCheckIcon extends StatelessWidget {
  const TodoCheckIcon({
    super.key,
    required this.isDone,
    this.onTap,
    this.size,
  });

  final bool isDone;
  final VoidCallback? onTap;

  /// Defaults to 20.sp (Figma).
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double dimension = size ?? 20.sp;
    final Widget icon = CustomSvgImage(
      assetPath:
          isDone ? TodoBadgeAssets.checkDone : TodoBadgeAssets.checkEmpty,
      width: dimension,
      height: dimension,
      fit: BoxFit.contain,
      color: isDone ? AppColors.secondaryPrimary : AppColors.secondaryText,
    );
    if (onTap == null) return icon;
    return Semantics(
      button: true,
      checked: isDone,
      label: S.of(context).todoMarkDone,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: icon,
      ),
    );
  }
}
