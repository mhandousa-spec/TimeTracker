/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: todo_status.dart
/// Purpose: Declares `MyTodoStatus` — home To-Do card 3: High / Medium / Low
///          counts and the yellow View button.
/// Author: Knowticed Plus team
/// Updated: 7/10/2026 - Reads the new To-Do module through `TodoHomeCubit`;
///          View opens `TodoModuleEntry` (was a removed-module placeholder).
/// Updated: 7/10/2026 - Owner round 3: label + count per priority, grid
///          narrow width, shared card height.
///
/// Figma: To-Do widget node 130:8096, third card. Counts equal the list's
/// All tab with that priority chip selected (deleted to-dos excluded).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/todo_home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/todo_home_card_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/pages/todo_module_entry.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MyTodoStatus extends StatelessWidget {
  const MyTodoStatus({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    return TodoHomeCardScope(
      width: TodoHomeCardMetrics.narrowWidth,
      builder: (BuildContext context, TodoHomeState state) => Column(
        spacing: 6.sp,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                // 3 rows x 18 + 2 x 3 fits the space above View.
                spacing: 3.sp,
                children: <Widget>[
                  for (final TodoPriority priority in TodoPriority.values)
                    TodoHomeCountRow(
                      iconPath: priority.iconPath,
                      color: _colorOf(priority),
                      // Yellow is too light for a white glyph.
                      glyphColor: priority == TodoPriority.medium
                          ? AppColors.textButton
                          : null,
                      label: priority.label(context),
                      count: state.countPriority(priority),
                    ),
                ],
              ),
            ),
          ),
          const _ViewButton(),
        ],
      ),
    );
  }

  /// Same colours as before: High red, Medium yellow, Low blue.
  static Color _colorOf(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return AppColors.red;
      case TodoPriority.medium:
        return AppColors.yellow;
      case TodoPriority.low:
        return AppColors.blue;
    }
  }
}

/// Yellow "View" — medium haptic + shrink, opens the module.
class _ViewButton extends StatelessWidget {
  const _ViewButton();

  @override
  Widget build(BuildContext context) {
    return ShrinkOnTap(
      child: GestureDetector(
        onTap: () {
          HapticController.medium();
          navigateTo(context, const TodoModuleEntry());
        },
        child: Container(
          height: 24.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(4.r),
            color: AppColors.primary,
          ),
          alignment: AlignmentDirectional.center,
          child: Text(
            S.of(context).view,
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.textButton),
          ),
        ),
      ),
    );
  }
}
