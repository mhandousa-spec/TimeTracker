/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: to_check_box.dart
/// Purpose: Declares `MyTodoCheckBox` — home To-Do card 2: the first three
///          open to-dos, each with a done checkbox and a "2/5" item badge.
/// Author: Knowticed Plus team
/// Updated: 7/10/2026 - Reads the new To-Do module through `TodoHomeCubit`;
///          the checkbox marks done via the repository + System Logs.
///          Badge radius 8; white text on the green "complete" badge.
/// Updated: 7/10/2026 - Owner round 3: tapping a row's TEXT opens that
///          to-do's details (module + `TodoDetailsPage` on top of the list);
///          the checkbox still toggles. Grid width; its height is the
///          reference for all three To-Do cards.
/// Updated: 7/10/2026 - Owner round 4: titles are ONE line with an
///          ellipsis; the "0/3" progress badge radius is 2.
///
/// Figma: To-Do widget node 130:8096, middle card. "Open" = the list's All
/// tab minus done, in the list's default (newest first) order.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/todo_home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/todo_home_card_parts.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MyTodoCheckBox extends StatelessWidget {
  const MyTodoCheckBox({required this.model, super.key});

  final HomeComponentModel model;

  /// Rows the Figma card draws.
  static const int _kRows = 3;

  @override
  Widget build(BuildContext context) {
    return TodoHomeCardScope(
      width: TodoHomeCardMetrics.wideWidth,
      builder: (BuildContext context, TodoHomeState state) {
        final List<TodoEntity> open = state.openTodos(_kRows);
        if (open.isEmpty) {
          return Center(
            child: Text(
              S.of(context).todoHomeNoOpen,
              textAlign: TextAlign.center,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
          );
        }
        // Three single-line rows fit the card; the scroll view only guards
        // against large accessibility text scales.
        return SingleChildScrollView(
          child: Column(
            spacing: 8.sp,
            children: <Widget>[
              for (final TodoEntity todo in open)
                _TodoRow(todo: todo, canEdit: state.canEdit),
            ],
          ),
        );
      },
    );
  }
}

/// Checkbox (toggles done) · name (opens details) · "done/total" badge.
class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.todo, required this.canEdit});

  final TodoEntity todo;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final int total = todo.items.length;
    return Row(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canEdit
              ? () {
                  HapticController.low();
                  context.read<TodoHomeCubit>().toggleDone(todo);
                }
              : null,
          child: Opacity(
            opacity: canEdit ? 1 : 0.4,
            child: CustomCheckBox(isSelected: todo.isDone, size: 18.sp),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openTodoModule(context, todoId: todo.id),
            child: Text(
              FormatHelper.capitalize(todo.name),
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.text,
                height: TodoHomeCardMetrics.lineHeight,
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
              ),
              // Owner (round 4): one line, ellipsis when it doesn't fit.
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (total > 0)
          _ProgressBadge(done: todo.completedItemsCount, total: total),
      ],
    );
  }
}

/// Yellow "2/5" pill; green once every item is ticked.
class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final bool complete = done == total;
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.sp, vertical: 2.sp),
      decoration: BoxDecoration(
        // Radius 2 — owner round 4 override for this progress badge.
        borderRadius: BorderRadiusDirectional.circular(2.r),
        color: complete ? AppColors.green : AppColors.primary,
      ),
      child: Text(
        '${LocalizedNumber.of(context, done)}/${LocalizedNumber.of(context, total)}',
        // `textButton` is computed against the YELLOW primary (→ near-black),
        // which is unreadable on the dark green fill in both themes; the
        // complete badge uses white instead.
        style: StyleText.fontSize10Weight500.copyWith(
          color: complete ? AppColors.white : AppColors.textButton,
        ),
      ),
    );
  }
}
