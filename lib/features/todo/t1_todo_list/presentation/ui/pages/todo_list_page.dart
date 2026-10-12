/// Module: todo / t1_todo_list / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: todo_list_page.dart
/// Purpose: Declares `TodoListPage` — S1 "To Do List" (Figma 1:28215
///          landscape, 1:28522 portrait, 1:33532 phone).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Root route of the module's nested Navigator (see `TodoModuleEntry`), so
/// `TodoListCubit` and `TodoActionsCubit` are read from above and every page
/// pushed from here inherits them.
///
/// Layout, top to bottom: title · status tabs · search / sort / create ·
/// priority chips · card grid. Each section slides in (SlideInContent); the
/// grid resizes with AnimatedSizeWrap.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/app_toast.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/widgets/todo_card_grid.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/widgets/todo_list_toolbar.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/widgets/todo_priority_chips.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/widgets/todo_status_tabs.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/pages/todo_form_page.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/controller/todo_actions_cubit.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/ui/pages/todo_details_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _search = TextEditingController();

  TodoAccess get _access => GetIt.instance<TodoAccess>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Function Name: [_openCreate]
  ///
  /// Purpose: Push the create form inside the module navigator. The button
  /// (customButtonWithSvg) already fired the medium haptic.
  ///
  /// Return type: [void]
  void _openCreate() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const TodoFormPage()),
    );
  }

  /// Function Name: [_openDetails]
  ///
  /// Purpose: Card tap → details (low haptic).
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [void]
  void _openDetails(TodoEntity todo) {
    HapticController.low();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TodoDetailsPage(todoId: todo.id),
      ),
    );
  }

  /// Function Name: [_toggleDone]
  ///
  /// Purpose: Checkbox tap → mark done / reopen (low haptic).
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [void]
  void _toggleDone(TodoEntity todo) {
    HapticController.low();
    context.read<TodoActionsCubit>().toggleDone(todo);
  }

  /// Function Name: [_toggleItem]
  ///
  /// Purpose: Tap on a checklist line previewed on a card → tick / untick it
  /// in place, without opening details (low haptic).
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///   [TodoItem] item
  ///
  /// Return type: [void]
  void _toggleItem(TodoEntity todo, TodoItem item) {
    HapticController.low();
    context.read<TodoActionsCubit>().toggleItem(todo, item.id);
  }

  /// Function Name: [_onActionFailure]
  ///
  /// Purpose: Toast a failed mutation, then return the cubit to idle. Only
  /// while this route is on top, so the details screen (same cubit) handles
  /// its own failures without a double toast.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///   [TodoActionsState] state
  ///
  /// Return type: [void]
  void _onActionFailure(BuildContext context, TodoActionsState state) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    final S s = S.of(context);
    AppToast.show(
      state.errorMessage == TodoActionsCubit.permissionDenied
          ? s.todoNoPermission
          : s.todoSaveError,
      backgroundColor: AppColors.red,
      textColor: AppColors.white,
    );
    context.read<TodoActionsCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhone = context.isPhone;
    final TodoAccess access = _access;
    // 15 on every device: start, end and above the title (owner, 7/10/2026).
    final double gutter = 15.w;

    return BlocListener<TodoActionsCubit, TodoActionsState>(
      listenWhen: (TodoActionsState a, TodoActionsState b) =>
          b.status == TodoActionStatus.failure && a.status != b.status,
      listener: _onActionFailure,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          // Header (title, tabs, toolbar, chips) stays put; only the cards
          // scroll (bug 7/10/2026: the whole page scrolled as one block and
          // the grid itself never scrolled).
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(gutter, 15.sp, gutter, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SlideInContent(
                  child: Text(
                    S.of(context).toDoListTitle,
                    style: (isPhone
                            ? StyleText.fontSize24Weight600
                            : StyleText.fontSize28Weight600)
                        .copyWith(color: AppColors.text),
                  ),
                ),
                SizedBox(height: 20.sp),
                const SlideInContent(
                  delay: Duration(milliseconds: 60),
                  child: TodoStatusTabs(),
                ),
                SizedBox(height: 20.sp),
                SlideInContent(
                  delay: const Duration(milliseconds: 120),
                  child: TodoListToolbar(
                    searchController: _search,
                    canCreate: access.canCreate,
                    onCreate: _openCreate,
                  ),
                ),
                SizedBox(height: 15.sp),
                const SlideInContent(
                  delay: Duration(milliseconds: 180),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TodoPriorityChips(),
                  ),
                ),
                SizedBox(height: 15.sp),
                Expanded(
                  child: SlideInContent(
                    delay: const Duration(milliseconds: 240),
                    child: _TodoListBody(
                      onOpen: _openDetails,
                      onToggleDone: access.canEdit ? _toggleDone : null,
                      onToggleItem: access.canEdit ? _toggleItem : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading / failure / empty / grid.
class _TodoListBody extends StatelessWidget {
  const _TodoListBody({
    required this.onOpen,
    this.onToggleDone,
    this.onToggleItem,
  });

  final ValueChanged<TodoEntity> onOpen;
  final ValueChanged<TodoEntity>? onToggleDone;
  final void Function(TodoEntity todo, TodoItem item)? onToggleItem;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListCubit, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        switch (state.status) {
          case TodoListStatus.initial:
          case TodoListStatus.loading:
            return const Center(child: CircleProgressMaster());
          case TodoListStatus.failure:
            return Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 60.sp),
              child: Text(
                S.of(context).todoLoadError,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.red),
              ),
            );
          case TodoListStatus.loaded:
            final List<TodoEntity> visible = state.visible;
            if (visible.isEmpty) {
              return const SingleChildScrollView(child: CustomEmptyState());
            }
            return TodoCardGrid(
              todos: visible,
              now: state.now,
              onOpen: onOpen,
              onToggleDone: onToggleDone,
              onToggleItem: onToggleItem,
              // The Deleted tab only holds deleted cards — the red badge
              // would be noise there; it stays on "All" (owner, 7/10/2026).
              showDeletedBadge: state.tab != TodoStatusTab.deleted,
              // Restore runs behind a confirm flow on the details screen, so
              // the badge opens details rather than restoring blind.
              onRestore:
                  GetIt.instance<TodoAccess>().canRestore ? onOpen : null,
            );
        }
      },
    );
  }
}
