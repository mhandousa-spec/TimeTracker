/// Module: todo / t1_todo_list / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_debug_tools.dart
/// Purpose: Declares `TodoDebugToolsButton` — a DEBUG-ONLY icon in the To-Do
///          list toolbar that opens the "Demo tools" dialog: Load demo
///          to-dos · Send due reminders now · Remove demo to-dos.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Owner request (7/10/2026): a way to SEE the To-Do notifications and the
/// calendar entries without waiting for real dates. The toolbar only builds
/// this widget behind `if (kDebugMode)`, a compile-time constant, so it is
/// tree-shaken from release builds and no client ever sees it.
///
/// All work goes through `TodoListCubit` (`loadDemoTodos`, `forceSweep`,
/// `removeDemoTodos`); this file only shows the result as a toast. The demo
/// to-dos and their timing are documented in `todo_sample_data.dart`.
///
/// Haptics: opening = Low; Load / Send = Medium (customButton's default);
/// Remove = High (a delete).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/app_toast.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_reminder_sweeper.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Square toolbar icon (same size as the sort / create buttons) that opens
/// the demo tools. Build it ONLY under `kDebugMode`.
///
/// API: `if (kDebugMode) const TodoDebugToolsButton()`.
class TodoDebugToolsButton extends StatelessWidget {
  const TodoDebugToolsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.of(context).todoDebugTools,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: Container(
          width: ButtonSizing.iconButtonSize,
          height: ButtonSizing.iconButtonSize,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadiusDirectional.circular(ButtonSizing.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            Icons.science_outlined,
            size: 20.sp,
            color: AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  /// Function Name: [_open]
  ///
  /// Purpose: Low haptic, then the scale-in dialog. The cubit is handed in
  /// because the dialog route sits above the module's providers.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///
  /// Return type: [void]
  void _open(BuildContext context) {
    HapticController.low();
    final TodoListCubit cubit = context.read<TodoListCubit>();
    showScaleDialog<void>(
      context: context,
      builder: (_) => _TodoDebugToolsDialog(cubit: cubit),
    );
  }
}

class _TodoDebugToolsDialog extends StatelessWidget {
  const _TodoDebugToolsDialog({required this.cubit});

  final TodoListCubit cubit;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.circular(12.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380.sp),
        child: Padding(
          padding: EdgeInsetsDirectional.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                s.todoDebugTools,
                style: StyleText.fontSize16Weight600
                    .copyWith(color: AppColors.text),
              ),
              SizedBox(height: 6.sp),
              Text(
                s.todoDebugToolsHint,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
              ),
              SizedBox(height: 16.sp),
              customButton(
                title: s.todoDebugLoad,
                function: () => _run(context, _load),
                fullWidth: true,
              ),
              SizedBox(height: 10.sp),
              customButton(
                title: s.todoDebugSweep,
                function: () => _run(context, _sweep),
                fullWidth: true,
              ),
              SizedBox(height: 10.sp),
              customButton(
                title: s.todoDebugRemove,
                function: () => _run(context, _remove),
                fullWidth: true,
                haptic: HapticController.high,
                color: AppColors.red,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Function Name: [_run]
  ///
  /// Purpose: Close the dialog, run [action] and toast the message it
  /// returns. Strings are resolved before the dialog closes.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///   [Future<String> Function(BuildContext, S)] action
  ///
  /// Return type: [Future<void>]
  Future<void> _run(
    BuildContext context,
    Future<String> Function(BuildContext context, S s) action,
  ) async {
    final S s = S.of(context);
    final Future<String> pending = action(context, s);
    Navigator.of(context).pop();
    AppToast.show(await pending);
  }

  Future<String> _load(BuildContext context, S s) {
    final String Function(int) count = _counter(context);
    return cubit.loadDemoTodos().then(
          (({int count, bool ok}) r) =>
              r.ok ? s.todoDebugLoadDone(count(r.count)) : s.todoDebugFailed,
        );
  }

  Future<String> _sweep(BuildContext context, S s) {
    final String Function(int) count = _counter(context);
    return cubit.forceSweep().then(
          (TodoSweepReport? r) => r == null
              ? s.todoDebugFailed
              : s.todoDebugSweepDone(count(r.sent)),
        );
  }

  Future<String> _remove(BuildContext context, S s) {
    final String Function(int) count = _counter(context);
    return cubit.removeDemoTodos().then(
          (({int count, bool ok}) r) =>
              r.ok ? s.todoDebugRemoveDone(count(r.count)) : s.todoDebugFailed,
        );
  }

  /// Localised digits, with the locale captured while [context] is mounted.
  String Function(int) _counter(BuildContext context) {
    final String localeName = Localizations.localeOf(context).toString();
    return (int n) => LocalizedNumber.forLocale(n, localeName);
  }
}
