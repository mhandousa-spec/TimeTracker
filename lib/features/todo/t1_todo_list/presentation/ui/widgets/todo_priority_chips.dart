/// Module: todo / t1_todo_list / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_priority_chips.dart
/// Purpose: Declares `TodoPriorityChips` — All · ⚠ High · ↑ Medium · ↓ Low
///          under the search bar.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma: 28 high, radius 4, Cairo 14 regular, icon before the label; the
/// selected chip is yellow, the rest white. No core widget has an icon chip of
/// this size (StatusChipFilter is count-box shaped), so it is drawn here.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoPriorityChips extends StatelessWidget {
  const TodoPriorityChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListCubit, TodoListState>(
      buildWhen: (TodoListState a, TodoListState b) => a.priority != b.priority,
      builder: (BuildContext context, TodoListState state) {
        final TodoListCubit cubit = context.read<TodoListCubit>();
        void select(TodoPriority? p) {
          HapticController.low();
          cubit.selectPriority(p);
        }

        return Wrap(
          spacing: 10.sp,
          runSpacing: 8.sp,
          children: <Widget>[
            _PriorityChip(
              label: S.of(context).all,
              selected: state.priority == null,
              onTap: () => select(null),
            ),
            for (final TodoPriority p in TodoPriority.values)
              _PriorityChip(
                label: p.label(context),
                iconPath: p.iconPath,
                selected: state.priority == p,
                onTap: () => select(p),
              ),
          ],
        );
      },
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconPath,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    final String? icon = iconPath;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 28.sp,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 8.sp),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadiusDirectional.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                CustomSvgImage(
                  assetPath: icon,
                  width: 14.sp,
                  height: 14.sp,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 4.sp),
              ],
              Text(
                label,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: selected ? AppColors.textButton : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
