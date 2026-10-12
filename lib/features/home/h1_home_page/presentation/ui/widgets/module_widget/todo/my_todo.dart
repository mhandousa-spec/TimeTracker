/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: my_todo.dart
/// Purpose: Declares `MyTodo` — home To-Do card 1: Total, then Done /
///          Overdue / Scheduled counts.
/// Author: Knowticed Plus team
/// Updated: 7/10/2026 - Reads the new To-Do module through `TodoHomeCubit`
///          (was the removed tasks_module stub, always 0).
/// Updated: 7/10/2026 - Owner round 3: each status is icon + label + count
///          (readable in dark mode); grid narrow width; shared card height.
///
/// Figma: To-Do widget node 130:8096, first card. Counts use
/// `TodoEntity.matchesTab`, so each number equals the list tab it names.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/todo_home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/todo_home_card_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MyTodo extends StatelessWidget {
  const MyTodo({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    return TodoHomeCardScope(
      width: TodoHomeCardMetrics.narrowWidth,
      builder: (BuildContext context, TodoHomeState state) =>
          SingleChildScrollView(
        child: Column(
          spacing: 4.sp,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '${S.of(context).total} '
              '${LocalizedNumber.of(context, state.countFor(TodoStatusTab.all))}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize12Weight600.copyWith(
                color: AppColors.secondaryText,
                height: TodoHomeCardMetrics.lineHeight,
              ),
            ),
            for (final _StatusLine line in _lines)
              TodoHomeCountRow(
                iconPath: line.iconPath,
                color: line.color,
                label: line.tab.label(context),
                count: state.countFor(line.tab),
              ),
          ],
        ),
      ),
    );
  }

  /// Done · Overdue · Scheduled, in the Figma order.
  static List<_StatusLine> get _lines => <_StatusLine>[
        _StatusLine(
          tab: TodoStatusTab.done,
          iconPath: 'assets/icons_assets/home_assets/todo_done_stamp.svg',
          color: AppColors.green,
        ),
        _StatusLine(
          tab: TodoStatusTab.overdue,
          iconPath:
              'assets/icons_assets/home_assets/todo_overdue_stopwatch.svg',
          color: AppColors.red,
        ),
        _StatusLine(
          tab: TodoStatusTab.scheduled,
          iconPath:
              'assets/icons_assets/home_assets/todo_scheduled_calendar.svg',
          color: AppColors.orange,
        ),
      ];
}

/// One status row's tab, glyph and colour.
class _StatusLine {
  const _StatusLine({
    required this.tab,
    required this.iconPath,
    required this.color,
  });

  final TodoStatusTab tab;
  final String iconPath;
  final Color color;
}
