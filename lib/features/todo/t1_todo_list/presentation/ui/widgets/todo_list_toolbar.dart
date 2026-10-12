/// Module: todo / t1_todo_list / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_list_toolbar.dart
/// Purpose: Declares `TodoListToolbar` — Search · Sort (entries depend on the
///          status tab, see `TodoSortOption.forTab`) · yellow "Create To Do".
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// All three are core widgets: `AppSearchTextField` (custom/35, its root IS an
/// Expanded so it goes straight into the Row), `CustomSortButton` (custom/47,
/// icon-only on phone) and `customButtonWithSvg` (custom/6, icon-only square
/// on phone — Figma 1:33532). The create button already fires a medium haptic.
/// Debug builds also show `TodoDebugToolsButton` (demo data + reminders).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/widgets/todo_debug_tools.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoListToolbar extends StatelessWidget {
  const TodoListToolbar({
    super.key,
    required this.searchController,
    required this.canCreate,
    required this.onCreate,
  });

  /// Owned by the page's State (never the cubit).
  final TextEditingController searchController;

  /// `TodoAccess.canCreate` — hides the Create button when false.
  final bool canCreate;
  final VoidCallback onCreate;

  /// Module icon on the Create button — the outlined clipboard the Figma
  /// button draws (todo_checklist_clipboard.svg is a filled glyph).
  static const String _createSvg =
      'assets/icons_assets/home_assets/picker_create_todo.svg';

  @override
  Widget build(BuildContext context) {
    final bool isPhone = context.isPhone;
    final TodoListCubit cubit = context.read<TodoListCubit>();
    final S s = S.of(context);

    return Row(
      children: <Widget>[
        AppSearchTextField(
          controller: searchController,
          hintText: s.search,
          fillColor: AppColors.card,
          onChanged: cubit.searchChanged,
        ),
        SizedBox(width: 15.sp),
        BlocBuilder<TodoListCubit, TodoListState>(
          buildWhen: (TodoListState a, TodoListState b) =>
              a.sort != b.sort || a.tab != b.tab,
          builder: (BuildContext context, TodoListState state) =>
              CustomSortButton<TodoSortOption>(
            // The entries depend on the tab (TodoSortOption.forTab).
            key: ValueKey<TodoStatusTab>(state.tab),
            value: state.sort,
            items: state.sortOptions,
            labelBuilder: (TodoSortOption o) => o.label(context),
            onChanged: (TodoSortOption? o) {
              HapticController.low();
              cubit.selectSort(o);
            },
            title: s.sort,
            showTitle: !isPhone,
            width: isPhone ? ButtonSizing.iconButtonSize : 100.sp,
            height: ButtonSizing.height,
          ),
        ),
        // DEBUG builds only (kDebugMode is a compile-time constant, so this
        // is tree-shaken from release): demo to-dos + "send reminders now".
        if (kDebugMode) ...<Widget>[
          SizedBox(width: 15.sp),
          const TodoDebugToolsButton(),
        ],
        if (canCreate) ...<Widget>[
          SizedBox(width: 15.sp),
          ShrinkOnTap(
            child: customButtonWithSvg(
              title: isPhone ? '' : s.createToDo,
              function: onCreate,
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              image: _createSvg,
              widthImage: 20.r,
              heightImage: 24.r,
              svgColor: AppColors.textButton,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
            ),
          ),
        ],
      ],
    );
  }
}
