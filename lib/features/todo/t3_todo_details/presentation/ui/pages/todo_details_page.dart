/// Module: todo / t3_todo_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: todo_details_page.dart
/// Purpose: Declares `TodoDetailsPage` — S3 "To Do List Details": the full
///          to-do with Edit / Delete (or Restore when deleted), mark done,
///          and the editable checklist.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - Replaces the placeholder with the real screen.
///
/// Figma: LIST TO DO → 1:31079 / 1:32106 / 1:32553 / 1:32256 (iPad
/// landscape), 1:31223 (portrait), 1:34479 (iPhone); dialogs 1:33114 /
/// 1:33106 (delete confirm / success), 1:33204 / 1:33196 (restore).
///
/// Pushed inside the To-Do module navigator, under `TodoModuleEntry`, which
/// provides both cubits this page needs:
///   * `TodoListCubit`    — the live to-do (`state.byId(todoId)`), so a change
///                          from anywhere (the Firestore stream) re-renders it;
///   * `TodoActionsCubit` — every mutation (done, delete, restore, checklist).
/// The page keeps no copy of the to-do. If it disappears (deleted elsewhere,
/// or never loaded) the page shows `S.todoNotFound` and the breadcrumb / back
/// arrow still leads back.
///
/// Delete / Restore run the confirm → write → success flow
/// (`CustomDialogManager.showDialogFlow`); after a delete the page pops back
/// to the list. Failures of the silent actions (ticks, add/remove item) are
/// toasted here; the list page ignores them while this route is on top.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
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
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/pages/todo_form_page.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/controller/todo_actions_cubit.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/ui/widgets/todo_details_actions.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/ui/widgets/todo_details_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoDetailsPage extends StatefulWidget {
  const TodoDetailsPage({super.key, required this.todoId});

  /// Id of the to-do to show; read live from `TodoListCubit.state.byId`.
  final String todoId;

  @override
  State<TodoDetailsPage> createState() => _TodoDetailsPageState();
}

class _TodoDetailsPageState extends State<TodoDetailsPage> {
  TodoAccess get _access => GetIt.instance<TodoAccess>();

  TodoActionsCubit get _actions => context.read<TodoActionsCubit>();

  /// Delete / Restore report through their dialog flow; everything else is
  /// silent and toasted by [_onActionFailure].
  static bool _isFlowKind(TodoActionKind? kind) =>
      kind == TodoActionKind.delete || kind == TodoActionKind.restore;

  // ------------------------------------------------------------------ edits

  /// Yellow Edit → the edit form. `CustomEditIcon` fired the Medium haptic.
  void _openEdit(TodoEntity todo) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => TodoFormPage(initial: todo)),
    );
  }

  void _toggleDone(TodoEntity todo) {
    HapticController.low();
    _actions.toggleDone(todo);
  }

  void _toggleItem(TodoEntity todo, TodoItem item) {
    HapticController.low();
    _actions.toggleItem(todo, item.id);
  }

  /// Red ⊖ — removes straight away (Figma has no confirm for it).
  void _removeItem(TodoEntity todo, TodoItem item) {
    HapticController.high();
    _actions.removeItem(todo, item.id);
  }

  void _addItem(TodoEntity todo, String title) {
    HapticController.medium();
    _actions.addItem(todo, title);
  }

  // ------------------------------------------------------------ dialog flows

  /// Function Name: [_delete]
  ///
  /// Purpose: Deleting To Do List → soft delete → success → back to the list.
  /// `CustomDeleteIcon` fires High on the tap; the dialog is `destructive`,
  /// so it shakes once and its "Yes" fires High / "No" Low by itself.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [Future<void>]
  Future<void> _delete(TodoEntity todo) async {
    final S s = S.of(context);
    final TodoActionsCubit cubit = _actions;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.trash,
      confirmTitle: s.deletingToDoList,
      confirmSubtitle: s.areYouSureYouWantToDeleteThisListToDo,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async {
        await cubit.delete(todo);
        return cubit.state.status == TodoActionStatus.success;
      },
      successLottie: AppAssets.successful,
      successTitle: s.successful,
      successSubtitle: s.youSuccessfullyDeletedThisToDo,
      onSuccessComplete: () {
        cubit.reset();
        if (mounted) Navigator.of(context).maybePop();
      },
    );
    _showFlowFailure(cubit, TodoActionKind.delete);
  }

  /// Function Name: [_restore]
  ///
  /// Purpose: Restoring To Do → undo the soft delete → success. The page stays
  /// and re-renders as a live (not deleted) to-do. `customButton` fired the
  /// Medium haptic on the tap.
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [Future<void>]
  Future<void> _restore(TodoEntity todo) async {
    final S s = S.of(context);
    final TodoActionsCubit cubit = _actions;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      // Yellow circular "restore" arrow. Not `AppAssets.restore` (e-commerce
      // returns box) nor `lottieConfirmation` (document + plus reads as
      // "create") — both rejected by the owner, 7/10/2026; no other
      // restore/undo/refresh Lottie exists under assets/.
      confirmLottie: AppAssets.todoRestore,
      confirmTitle: s.restoringToDo,
      confirmSubtitle: s.areYouSureYouWantToRestoreThisListToDo,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async {
        await cubit.restore(todo);
        return cubit.state.status == TodoActionStatus.success;
      },
      successLottie: AppAssets.successful,
      successTitle: s.successful,
      successSubtitle: s.youSuccessfullyRestoredThisToDo,
      onSuccessComplete: cubit.reset,
    );
    _showFlowFailure(cubit, TodoActionKind.restore);
  }

  /// Function Name: [_showFlowFailure]
  ///
  /// Purpose: After a Delete/Restore flow, explain a failed write (the flow
  /// itself only skips the success step) and return the cubit to idle.
  ///
  /// Parameters:
  ///   [TodoActionsCubit] cubit
  ///   [TodoActionKind] kind
  ///
  /// Return type: [void]
  void _showFlowFailure(TodoActionsCubit cubit, TodoActionKind kind) {
    final TodoActionsState state = cubit.state;
    if (!mounted ||
        state.status != TodoActionStatus.failure ||
        state.kind != kind) {
      return;
    }
    final S s = S.of(context);
    cubit.reset();
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.lottieWarning,
      title: s.errorOccurred,
      subtitle: _reason(s, state),
    );
  }

  /// Function Name: [_onActionFailure]
  ///
  /// Purpose: Toast a failed silent action (done / checklist) and reset.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///   [TodoActionsState] state
  ///
  /// Return type: [void]
  void _onActionFailure(BuildContext context, TodoActionsState state) {
    if (_isFlowKind(state.kind)) return;
    AppToast.show(
      _reason(S.of(context), state),
      backgroundColor: AppColors.red,
      textColor: AppColors.white,
    );
    context.read<TodoActionsCubit>().reset();
  }

  static String _reason(S s, TodoActionsState state) =>
      state.errorMessage == TodoActionsCubit.permissionDenied
          ? s.todoNoPermission
          : s.todoSaveError;

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocListener<TodoActionsCubit, TodoActionsState>(
      listenWhen: (TodoActionsState a, TodoActionsState b) =>
          b.status == TodoActionStatus.failure && a.status != b.status,
      listener: _onActionFailure,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: s.toDoListTitle,
          secondTitle: s.toDoListDetails,
          // The frame already fires the Low haptic for breadcrumb taps.
          onFirstTap: () => Navigator.of(context).maybePop(),
          child: SideFrameScrollableBody(
            child: BlocBuilder<TodoListCubit, TodoListState>(
              buildWhen: (TodoListState a, TodoListState b) =>
                  a.status != b.status ||
                  a.now != b.now ||
                  a.byId(widget.todoId) != b.byId(widget.todoId),
              builder: (BuildContext context, TodoListState state) =>
                  _body(state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(TodoListState state) {
    final TodoEntity? todo = state.byId(widget.todoId);
    if (todo != null) return _content(todo, state.now);
    final bool loading = state.status == TodoListStatus.initial ||
        state.status == TodoListStatus.loading;
    if (loading) {
      return SizedBox(height: 300.sp, child: const CircleProgressMaster());
    }
    return const _TodoNotFound();
  }

  Widget _content(TodoEntity todo, DateTime now) {
    final TodoAccess access = _access;
    final bool deleted = todo.isDeleted;
    final bool isPhone = context.isPhone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!deleted && (access.canEdit || access.canDelete)) ...<Widget>[
          SlideInContent(
            child: TodoDetailsActions(
              onEdit: access.canEdit ? () => _openEdit(todo) : null,
              onDelete: access.canDelete ? () => _delete(todo) : null,
            ),
          ),
          SizedBox(height: 15.sp),
        ],
        SlideInContent(
          delay: const Duration(milliseconds: 80),
          child: TodoDetailsCard(
            todo: todo,
            now: now,
            isPhone: isPhone,
            editable: access.canEdit && !deleted,
            onToggleDone: () => _toggleDone(todo),
            onToggleItem: (TodoItem item) => _toggleItem(todo, item),
            onRemoveItem: (TodoItem item) => _removeItem(todo, item),
            onAddItem: (String title) => _addItem(todo, title),
          ),
        ),
        if (deleted && access.canRestore) ...<Widget>[
          SizedBox(height: 20.sp),
          SlideInContent(
            delay: const Duration(milliseconds: 160),
            child: TodoDetailsRestoreButton(onRestore: () => _restore(todo)),
          ),
        ],
        SizedBox(height: 20.sp),
      ],
    );
  }
}

/// The to-do is gone (deleted elsewhere, or not in this user's list).
class _TodoNotFound extends StatelessWidget {
  const _TodoNotFound();

  @override
  Widget build(BuildContext context) {
    return SlideInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CustomEmptyState(),
          SizedBox(height: 12.sp),
          Text(
            S.of(context).todoNotFound,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
