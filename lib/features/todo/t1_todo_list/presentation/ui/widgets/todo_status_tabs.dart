/// Module: todo / t1_todo_list / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_status_tabs.dart
/// Purpose: Declares `TodoStatusTabs` — the All · To Do · Done · Overdue ·
///          Scheduled · Deleted row with counts.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Core `StatusChipFilter` (custom/8) is the Figma shape exactly: white count
/// box, yellow when selected, label beside it; it scrolls sideways on phone.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';

class TodoStatusTabs extends StatelessWidget {
  const TodoStatusTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListCubit, TodoListState>(
      buildWhen: (TodoListState a, TodoListState b) =>
          a.tab != b.tab || a.todos != b.todos || a.now != b.now,
      builder: (BuildContext context, TodoListState state) {
        return StatusChipFilter(
          selectedKey: state.tab.key,
          items: <StatusChipItem>[
            for (final TodoStatusTab tab in TodoStatusTab.values)
              StatusChipItem(
                key: tab.key,
                label: tab.label(context),
                count: state.countFor(tab),
              ),
          ],
          onSelected: (String key) {
            HapticController.low();
            context.read<TodoListCubit>().selectTab(TodoStatusTab.fromKey(key));
          },
        );
      },
    );
  }
}
